# Engineering

Cross-cutting principles for how to build and how to decide, independent of language. Language- and stack-specific conventions live in [python.md](python.md), [sql.md](sql.md), and [markdown.md](markdown.md).

## Principles

- **Name an abstraction's payoff before adding it.** Indirection belongs only where it buys something you will actually use. A Protocol in front of a single implementation, added for swappability or for testing, buys nothing if you never swap it and never substitute it in tests. Treat the concrete thing as a first-class part of the design until a second consumer forces the seam.
- **Design for current scale, with a written exit.** Don't add infrastructure (a broker, a cache, a new datastore) ahead of demonstrated need; reach for what you already run when forecasts fit it. When you choose the lighter option, write down the path to the heavier one so outgrowing it is a planned migration rather than a surprise.
- **Keep the domain independent of its delivery mechanism.** Business logic should be plain code callable from an HTTP handler, a CLI, a worker, or a test. The framework is an adapter at the edge; dependencies point inward toward the domain, never out.
- **Durable side-effects commit with the state that causes them.** Anything that must survive a crash (work to run after an operation, an event others react to) belongs in transactional state, such as an outbox row written in the same transaction, not in fire-and-forget background tasks that vanish on a restart. Accept at-least-once delivery and make consumers idempotent on a stable id; exactly-once over a network isn't achievable.
- **Test against real dependencies where the value is integration.** Well-formed SQL, firing constraints, and holding transactions are only verified against the real dependency. Prefer a containerized real database over substituted implementations; mocking the thing under test hides the behavior you need to verify.

## Documenting decisions

- **Record the why and the alternatives, not just the rule.** A durable decision doc states the context, the decision, the reasoning, and the options rejected and why. The rule alone tells a future reader what to do; the why tells them when it no longer applies.
- **Study prior art first.** Before designing a mechanism, look at mature implementations of the same pattern and borrow their choices. Cite them in the decision.
