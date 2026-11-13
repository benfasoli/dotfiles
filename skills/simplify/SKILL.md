---
name: simplify
description: Review the current branch, pull request, or diff for concrete ways to simplify changed code and for broader simplifications newly enabled by the change.
---

# Simplify

Review the current branch, pull request, or diff for opportunities to make the code smaller,
clearer, and easier to maintain without changing intended behavior. Review only: do not edit,
commit, or otherwise implement a finding unless the user explicitly asks.

## Establish the review scope

1. Identify the comparison base and inspect the complete diff, including tests and documentation.
2. Read enough surrounding code to understand the changed behavior, established project patterns,
   and whether an apparent simplification is safe.
3. Trace directly relevant callers, implementations, and state transitions when needed to verify
   that code or an interface is redundant.

Prefer evidence from the repository over general design preferences. Do not report an idea merely
because an alternative could be shorter.

## What to prioritize

Look first for:

- code, configuration, dependencies, or tests that can be deleted
- narrower function, type, module, or service interfaces
- redundant abstractions, wrappers, indirection, state, caching, conversions, or branches
- duplicate paths that can use an established project helper or pattern
- compatibility paths, feature gates, or transitional code made obsolete by the current change
- invariants introduced by the change that allow nearby code to collapse

Favor the smallest behavior-preserving change with a clear maintenance payoff. A simplification
should reduce concepts, paths, state, or surface area—not merely move complexity elsewhere.
An obsolete wrapper or interface created by the current diff can be worth deleting even if the
change is small: judge the concept removed and the risk, not just the number of lines saved.

## Scope findings

Classify every finding as one of:

- **Current change:** The simplification is within the touched behavior and is appropriate to
  address in this branch or pull request.
- **Follow-up:** The current change enables or reveals a worthwhile simplification elsewhere, but
  implementing it would broaden the change's review or risk surface.

Label each finding with its scope. A follow-up must have a direct causal or structural connection
to the current change; unrelated pre-existing cleanup is not a finding.

## Reject low-value churn

Before reporting a finding, sketch the smallest complete change across callers, construction
sites, tests, and documentation. Count any new wrappers, closures, captured state, imports, or
wiring against what would be removed. A shorter signature is not a payoff if the same dependency
still exists in another form. Recommend the change only when it eliminates a responsibility or
meaningfully reduces the total concepts a maintainer must understand.

Do not recommend:

- speculative abstractions for hypothetical reuse
- style-only rewrites, renames, formatting churn, or preference-driven reshaping
- replacing an explicit context field with closure or `partial` state solely to shorten an
  interface when the value and its construction wiring remain necessary
- broad architectural rewrites when a local deletion or narrowing is sufficient
- unrelated cleanup, even when encountered during review
- deduplication that obscures intent, couples independent behavior, or requires more coordination
  than the duplication it removes; prefer a little local duplication to the wrong abstraction
- combining independently useful loading boundaries just to reduce hook calls when shared
  caching already avoids duplicate requests
- removal of defensive behavior without evidence that its protected state is impossible
- changes whose implementation cost or risk outweighs the maintenance payoff

## Report findings

Report every obvious, high-confidence simplification that is worth its cost, with no fixed number
of findings. Stop when the next idea is marginal; do not pad the list. Put current-change findings
first and keep follow-ups brief. Do not recommend a change you judge not worth doing.

Give each finding a short descriptive heading, followed by its scope and source location.
Use separate labeled bullets for the details, with this structure:

### [Short title naming the simplification]

**Scope:** Current change or Follow-up  
**Location:** `path/to/file:line`

- **Before:** [What exists.]
- **After:** [Specific deletion or narrowing.]
- **Value:** [Concrete maintenance payoff.]
- **Risk:** [Practical behavior or scope cost, even when low.]
- **Recommendation:** [Why it is worth doing in this branch or as a separate change.]

Do not bundle these fields into a single paragraph or a single long bullet. Keep each field short
and use whitespace between findings so the report is easy to scan. Keep follow-ups compact, but
preserve the same visual structure.

Explain the before and after so the reader can understand the change without opening the file.
Avoid routine verification instructions and repository-tour context. If nothing clears the bar, say:

> No worthwhile simplifications.
