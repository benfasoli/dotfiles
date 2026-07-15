# Writing

Anything written in Ben's name follows the Voice section below: PR descriptions, commit messages, tickets, Slack posts, and repo documentation. Repo documentation additionally routes through the two modes that follow. Formatting follows [markdown.md](markdown.md). Artifact-specific structure lives with the artifact (the `weekly-status` skill for Slack status posts); those build on this doc rather than restating it.

## Voice

Clear, conversational, readable. Write like a person explaining something they understand well to a technical reader, not like a generated report.

- Lead with the problem or the point. The reader should know why they're reading by the end of the first sentence.
- Spend words on why. The reasoning is the content; the change itself is visible in the diff, the code, or the artifact. Explain the prior state when it isn't obvious.
- Be technically specific. Name the real mechanism, failure mode, flag, or version rather than sanding it down to business terms.
- Be candid. Say what is unverified, WIP, or hacky. Use first person for judgment calls ("I chose X because..."). Credit people by name.
- Never fabricate. No invented metrics, user counts, or ticket numbers. If impact is unknown, say what the change enables and stop.

### AI tells

Patterns that read as generated text. Avoid them everywhere.

- Em dashes are rare and deliberate. Default to periods and commas, and restructure the sentence rather than splicing clauses. One per paragraph is the ceiling, and most paragraphs need none.
- Colons introduce lists and examples. Don't use them as a rhythm device inside prose.
- No sentence fragments posing as emphasis ("One statement. No savepoint. Done.").
- Cut filler: leverage, utilize, robust, seamless, comprehensive, significant, successfully, streamlined, facilitate, various, "a number of", "in order to", and vague adjectives (powerful, efficient) with no number behind them.
- Cut meta-commentary that grades the work: load-bearing, critical, key, crucial, notably, genuinely, "the real fix", "the important part".
- Don't narrate discovery ("testing surfaced", "it turned out", "we found that"). State the cause and the fix directly.

## Repo documentation

Two modes, routed by artifact type.

- **Narrative** — README introductions and overviews, design-note context sections, retrospectives, historical commentary.
- **Technical** — API and reference docs, semantic rules, compatibility tables, tests, implementation notes, docstrings, error messages, code comments.

When a document fits neither list, use technical mode. Narrative is the exception, not the default. One document can use both; a README opens in narrative mode and switches to technical at the first usage section.

### Narrative mode

Thoughtful, occasionally witty, reflective without going vague.

- Humor comes from the subject, never bolted on. The wit is an accurate observation about the thing itself, not a joke attached to it. If deleting the wit doesn't change the meaning, delete it. At most one such moment per section.
- Concrete comparison over abstract adjective. "Small enough to hold in your head" beats "simple and approachable" because the first is a claim the reader can test.
- Short declarative sentences. No hedging, no sentimentality. State the uncomfortable fact plainly ("the parser predates the grammar, and it shows").
- Every reflective sentence still carries a fact. If the reader takes nothing concrete away from a sentence, cut it.
- Paragraphs, not bullets. Narrative prose should move; bullets belong to technical mode.
- End on the point. Close a section with the sentence that carries it, not a trailing qualifier.

Calibration, the same README opening rewritten under these rules:

> This interpreter is a robust, feature-rich implementation that faithfully recreates the classic BASIC experience for a modern audience.

> BASIC is small enough to hold in your head and strange enough to remind you that your head is not a standards committee.

The first is adjectives; the second is two verifiable claims and the wit is one of them.

### Technical mode

Concise, direct, precise.

- One idea per sentence. Declarative, present tense.
- Order behavior first, then constraints, then error cases.
- No adjectives that don't discriminate. Simple, powerful, easy, flexible, robust describe nothing the reader can verify.
- Every claim checkable against the implementation. If behavior is an error or undefined, say which, explicitly.
- A short example beats a paragraph of explanation.
- No metaphor, no humor. Reference material is skimmed under deadline; ornament is friction.

Calibration:

> GOSUB pushes the next statement position onto the call stack. RETURN resumes from that position. Returning with an empty stack is an error.

Three sentences covering behavior, behavior, and the error case. Nothing to cut.

## Documentation freshness

Any change that alters behavior or architecture must review the main documentation set. If no update is needed, state that explicitly in the change notes or PR description.
