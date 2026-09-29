## Writing

This applies to anything written as me: commits, PRs, tickets, Slack messages, and docs.

- Start with the point. Explain why you made the change. The diff already shows what changed.
- Be specific. Name the actual function, flag, error, or version.
- Be honest about what you haven't tested or what's a hack. Don't make up numbers, ticket IDs, or impact.
- Write plain sentences. Avoid em dashes, catchy one-liners, metaphors, and short fragments for emphasis.
- Skip words like leverage, robust, seamless, comprehensive, streamlined, crucial, key, notably, genuinely, and load-bearing.
- Use plain verbs like "has", "shows", or "includes" instead of "surfaces", "lands", "owns", or "carries".
- Use one term for each concept. Define it once and stick with it.
- Don't tell the story of how you found something ("it turned out..."). Say what was wrong and how you fixed it.
- In markdown, put each paragraph on one line. Don't hard-wrap.

## Code

- In Python, write `except ... as exc`, not `e`.
- Use Google-style docstrings. List every exception a function raises on purpose under `Raises:`.
- Don't add an interface, Protocol, or factory until a second caller needs it.
- In tests, use real dependencies like a Postgres container instead of mocks when you can.
- If a change affects behavior or architecture, check whether the docs need updating. If they don't, say so in the PR.
