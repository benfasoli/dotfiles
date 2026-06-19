# Python

Language-level style applies to all Python. The **Backend services** section applies only to HTTP services of the FastAPI + Postgres shape — skip it for libraries, CLIs, and scripts. SQL and schema conventions live in [sql.md](sql.md); the reasoning behind the architectural choices here lives in [engineering.md](engineering.md).

Lean on tooling to enforce what it can — ruff for formatting and lint, a type checker in standard mode, a fixed line length — and treat the rest as convention.

## Style

### Docstrings

Google style. A few rules to hold to:

- **Summary fits on the opening line**, right after the opening quotes, and is minimally descriptive — say what the thing does, not how.
- **Don't duplicate the signature.** Types already live in the annotations; don't restate them in the docstring.
- **`Args:` for anything with more than ~2 parameters.** A one- or two-argument function whose names are self-explanatory doesn't need one; past that, document each parameter.
- **Be pedantic about `Raises:`.** Python has no checked exceptions, so the docstring is the only place a caller learns which exceptions to expect and handle. List every exception the function raises on purpose.

```python
def close_resource(ctx: Context, resource_id: UUID) -> None:
    """Close an open resource.

    Args:
        ctx: Context carrying the database handle.
        resource_id: Id of the resource to close.

    Raises:
        ResourceNotFoundError: No resource with that id exists.
        InvalidOperationError: The resource is not in a closeable state.
    """
```

### Naming and layout

- **Exception variables are `exc`, not `e`** — in `except` clauses and when re-raising with `from exc`.
- **Method order within a class**: `__init__` first, then public methods alphabetically, then private methods alphabetically.

### Typing

- **Type everything.** No untyped dicts and no `dict[str, object]` standing in for a structured value. Use specific types for actual usage, not theoretical broadness.
- **Prefer a Pydantic model** for request/response shapes and anything crossing a trust boundary, where runtime validation earns its keep. A plain dataclass is fine when no runtime type validation is needed — internal value objects, simple carriers wired up in code.

### Exceptions

Define semantically rich custom exceptions; don't reach for Python built-ins for application-level errors. Every module's exceptions inherit from a common domain base, and each carries the data (ids, codes) a handler needs to build a helpful response.

```python
class AppError(Exception):
    """Base for all application errors."""

class EntityNotFoundError(AppError):
    def __init__(self, entity_type: str, identifier: str):
        self.entity_type = entity_type
        self.identifier = identifier
        super().__init__(f"{entity_type} '{identifier}' not found")

class InvalidOperationError(AppError):
    """A precondition for an operation was not met."""
```

**Fail fast.** Let errors propagate; don't swallow exceptions broadly.

## Backend services (FastAPI + Postgres)

Conventions for HTTP services backed by Postgres. The principles underneath — keeping the domain independent of its delivery mechanism, durable side-effects, testing against real dependencies — are in [engineering.md](engineering.md).

### Architecture: core + adapter

Split the system into a **core** that owns business rules, domain models, and persistence, and one or more **adapters** that own a delivery mechanism (an HTTP server, a CLI, a queue worker, a scheduled job).

- Core is plain synchronous Python and imports no web framework. Each domain is a sub-package whose `__init__.py` exposes its public surface — service functions, domain models, exceptions. Implementation lives in underscore-prefixed private modules that other packages must not import across the boundary.
- Adapters own their entry point and runtime concerns (request/response shapes, authentication, process lifespan), then delegate to core. **Dependencies point inward: adapters import core, never the reverse.**
- Core declares what it needs from the outside world as a per-service `Protocol` (a `Context` carrying `db`, clock, HTTP clients, config). An adapter builds one concrete, application-scoped context at startup and passes it unchanged into every core call. The context carries only application-scoped, thread-safe infrastructure — anything request- or operation-scoped (caller identity, a request id, route params) is passed as an explicit argument.

### Concurrency

Pick one concurrency model and keep the whole call graph in it; don't mix `async def` and sync paths because the framework allows both. Sync handlers on a threadpool keep core as ordinary Python any contributor can read and scale horizontally by adding workers. A single `async def` deep in the call graph colors every caller above it.

### Transactions

Keep three lifetimes distinct rather than conflating them through one dependency mechanism:

- **Request lifecycle** is the adapter's (request received → response sent).
- **Connection lifetime** is the database's — a connection is checked out for the duration of a `transaction()` block and returned on exit.
- **Transaction boundary** is the **service layer's**. A handler calls one service function per business operation; that function opens the transaction around the unit of work. Handlers and repositories never open transactions.

One business operation is one local transaction. Don't coordinate work across services with sagas or distributed transactions; decompose so each step commits locally and follow-on work flows through a durable queue.

### Repositories

One repository per **aggregate** — the unit loaded and saved as a whole, and the boundary within which data stays consistent. Repositories speak only in domain models and translate database constraint violations into domain errors; they never enforce business rules. The service layer reads an aggregate, applies the rules (as behavior on the domain model that raises on an illegal transition), then calls repositories to persist.

A command/query split and a fixed verb vocabulary carry the contract:

- **`get_<aggregate>`** — fetch one that must exist; raises `NotFoundError` if absent.
- **`find_<aggregate>`** — fetch one that may legitimately be missing; returns `None`.
- **`list_<aggregate>s`** — fetch zero or more; returns a list.
- **`create_` / `update_` / `delete_`** — take a domain model, return nothing; `update`/`delete` raise `NotFoundError` when absent.

Reads return the whole aggregate — no status-only projections; the service inspects it in memory. The service generates ids, timestamps, and sequence values before calling `create`/`update`.

### HTTP API

**Expose business-context operations, not low-level CRUD.** Raw create/update/delete on individual entities are internal building blocks; expose the composite operations that capture who did something and why. Reference-data CRUD is exposed as admin endpoints.

- Resource ids go in path params, not the body: `POST /resources/{id}/close`. Query params for filtering and pagination on `GET`. Group routes by business domain; use `POST` for state-changing operations.
- JSON fields are camelCase; Python models are snake_case internally. Responses wrap the domain object: `{ "resource": {...} }`. `POST` creation endpoints return `201`. The actor comes from the authenticated user, never the body.

| Code | When |
| ---- | ---- |
| 201  | Resource created |
| 400  | Malformed or unbindable request (invalid JSON, missing fields) |
| 404  | Referenced entity not found |
| 409  | Conflict with existing state |
| 422  | Validation error — well-formed input that failed a business rule |

The `400`/`422` line: **`422` is a well-formed request whose value failed a rule or precondition; `400` is a request the framework couldn't even bind.**

Handlers stay thin — parse input, call one service function, translate domain exceptions into `HTTPException`:

```python
except EntityNotFoundError as exc:
    raise HTTPException(status_code=404, detail=str(exc)) from exc
```

Shape errors so clients can react programmatically — the exception class name, a human detail, and the exception's data attributes:

```json
{ "error": "EntityNotFoundError", "detail": "resource '...' not found", "context": { "resource_id": "..." } }
```

### Testing

Test against a real Postgres in Docker, exercising the same persistence code that ships — see [engineering.md](engineering.md) on testing against real dependencies.

- **Test through the HTTP API (black box).** Drive behavior as a client would: a `POST`, then assert the response and the resulting state.
- **Don't mock core behavior.** It couples tests to implementation and hides real behavior. Reach error and edge states through real calls — e.g. `POST` the same entity twice to hit the duplicate path. Matching dynamic values (UUIDs, timestamps) with a wildcard is fine.
- **Build request bodies from the typed request models**, not hand-written dicts, so required fields are type-checked.
- **Generate unique ids** (`uuid.uuid4()`) to avoid cross-test interference, and detect async tests automatically rather than decorating each one.

Cover every endpoint's success path, each error path (correct status + error response), and valid/invalid state transitions. Add service-level tests only for paths unreachable from the API. One test file per module.
