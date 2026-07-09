# SQL

Formatting and schema conventions for Postgres. The application-layer side — the repository contract, who owns transactions — is in [python.md](python.md); the reasoning behind keeping validation in the domain is in [engineering.md](engineering.md).

## Formatting

- **Uppercase SQL keywords.**
- **Always fully-qualify table names; never alias them.**
  ```sql
  -- do
  SELECT id FROM app.order;
  SELECT app.order.id FROM app.order;
  -- do not
  SELECT o.id FROM app.order o;
  ```
- **Bind every dynamic value; never assemble SQL from variables.** A query that carries a variable value sends it as a bound parameter, never formatted into the SQL text (no f-string, `%`, `+`, or `.format()`) — so it's injection-safe by construction. A fully static query may be a plain string literal.
- Single-line queries for trivial statements; multi-line for the rest.

## Naming

- **Tables are singular nouns** — one word where natural: `app.order`, `app.user`.
- **Join tables are named for their join semantics**: `app.user_role`.
- **Explicit indexes** are `<table>_<columns>_idx`, e.g. `CREATE INDEX order_user_idx ON app.order (user_id)`. (Postgres names the implicit primary-key and unique indexes itself.)

## Schema conventions

- **The application supplies every column value; the database defaults nothing.** Build the full row in code — `id` (a `uuid4()`), `created_at`/`updated_at`, every field — before the insert, and list every column explicitly in the `INSERT`. Columns carry no `DEFAULT`: an omitted value is a bug the insert should surface as a `NOT NULL` violation, not one the database silently fills. This rules out both DB-side generation you'd read back (`DEFAULT gen_random_uuid()`, `SERIAL`/`IDENTITY` via `RETURNING`) and convenience defaults (`DEFAULT now()`, `DEFAULT false`). When a value must come from a sequence, read `nextval(...)` first, then compose and persist the row. When a new `NOT NULL` column needs backfilling on an existing table, populate it inside the migration — add it with a transient `DEFAULT`, then `DROP DEFAULT` (or add it nullable, backfill, then `SET NOT NULL`) — so no default survives in the committed schema.
- **Prefer surrogate primary keys.** A table's primary key is an internal `UUID NOT NULL` surrogate (no DB default); foreign keys reference that surrogate, never a natural key, so a natural key can be renamed without re-keying every table that points at it. A surrogate that exists purely for referential stability is a persistence device and does not surface as a domain attribute — unless the domain itself identifies the entity by that id (one that appears in URLs), in which case the domain carries it.
- **Human-facing identifiers** stay readable `TEXT` modeled as `UNIQUE` columns, not primary keys: an order number, a user email. The domain references entities by their natural key; persistence joins through the surrogate.
- **Timestamps are `TIMESTAMPTZ`, always.** `deleted_at` is nullable.
- **Status columns are `TEXT`**, with valid values enforced by a domain enum, not a DB `CHECK`.
- **Constraints split by kind.** Foreign keys, uniqueness, and `NOT NULL` are structural and belong in the database. All other validation lives in the domain layer — avoid `CHECK` constraints, and never use triggers or stored procedures.
- **Soft delete by choice, not reflex.** Where history or audit matters, delete sets `deleted_at`, there are no physical `DELETE`s, and every read filters `deleted_at IS NULL`. Entities with no such obligation may be hard-deleted; decide per table.
- **No dead schema** — don't add tables or columns no code uses.
