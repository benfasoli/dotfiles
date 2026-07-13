# Writing

Repo documentation uses two modes. Route by artifact type:

- **Narrative** — README introductions and overviews, design-note context sections, retrospectives, historical commentary.
- **Technical** — API and reference docs, semantic rules, compatibility tables, tests, implementation notes, docstrings, error messages, code comments.

When a document fits neither list, use technical mode — narrative is the exception, not the default. One document can use both: a README opens in narrative mode and switches to technical at the first usage section.

Formatting follows [markdown.md](markdown.md). Prose that goes out in Ben's name — PR descriptions, commit messages, Slack — follows "Writing in my voice" in CLAUDE.md, not this doc.

## Narrative mode

Thoughtful, occasionally witty, reflective without going vague.

- **Humor comes from the subject, never bolted on.** The wit is an accurate observation about the thing itself, not a joke attached to it. If deleting the wit doesn't change the meaning, delete it. At most one such moment per section.
- **Concrete comparison over abstract adjective.** "Small enough to hold in your head" beats "simple and approachable" — the first is a claim the reader can test.
- **Short declarative sentences; no hedging, no sentimentality.** State the uncomfortable fact plainly: "the parser predates the grammar, and it shows."
- **Every reflective sentence still carries a fact.** If the reader takes nothing concrete away from a sentence, cut it.
- **Paragraphs, not bullets.** Narrative prose should move; bullets belong to technical mode.
- **End on the point.** Close a section with the sentence that carries it, not a trailing qualifier.

Calibration — the same README opening, rewritten under these rules:

> This interpreter is a robust, feature-rich implementation that faithfully recreates the classic BASIC experience for a modern audience.

> BASIC is small enough to hold in your head and strange enough to remind you that your head is not a standards committee.

The first is adjectives; the second is two verifiable claims and the wit is one of them.

## Technical mode

Concise, direct, precise.

- **One idea per sentence.** Declarative, present tense.
- **Order: behavior, then constraints, then error cases.**
- **No adjectives that don't discriminate.** Simple, powerful, easy, flexible, robust describe nothing the reader can verify; cut them.
- **Every claim checkable against the implementation.** If behavior is an error or undefined, say which, explicitly.
- **A short example beats a paragraph of explanation.**
- **No metaphor, no humor.** Reference material is skimmed under deadline; ornament is friction.

Calibration:

> GOSUB pushes the next statement position onto the call stack. RETURN resumes from that position. Returning with an empty stack is an error.

Three sentences: behavior, behavior, error case. Nothing to cut.

## Documentation freshness

Any change that alters behavior or architecture must review the main documentation set. If no update is needed, state that explicitly in the change notes or PR description.
