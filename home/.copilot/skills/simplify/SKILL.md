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

## Scope findings explicitly

Classify every finding as one of:

- **Current change:** The simplification is within the touched behavior and is appropriate to
  address in this branch or pull request.
- **Follow-up:** The current change enables or reveals a worthwhile simplification elsewhere, but
  implementing it would broaden the change's review or risk surface.

Do not blur the two categories. A follow-up must have a direct causal or structural connection to
the current change; unrelated pre-existing cleanup is not a finding.

## Reject low-value churn

Do not recommend:

- speculative abstractions for hypothetical reuse
- style-only rewrites, renames, formatting churn, or preference-driven reshaping
- broad architectural rewrites when a local deletion or narrowing is sufficient
- unrelated cleanup, even when encountered during review
- deduplication that obscures intent or couples code that changes for different reasons
- removal of defensive behavior without evidence that its protected state is impossible
- changes whose implementation cost or risk outweighs the maintenance payoff

## Report findings

Order findings by scope, then by payoff and confidence. For each finding include:

- **Location:** File and precise line or line range.
- **Recommendation:** The exact code, branch, state, interface, or abstraction to remove, narrow,
  or replace, including the established project pattern to use when applicable.
- **Safety / verification:** Why behavior should remain unchanged and the focused checks needed to
  prove it.
- **Payoff:** What becomes smaller or easier to reason about; quantify deleted paths, state, or
  surface area when practical.
- **Scope:** `Current change` or `Follow-up`.
- **Confidence:** `High`, `Medium`, or `Low`, with the key evidence or uncertainty.

Keep findings concrete and independently actionable. Avoid a general summary disguised as a
finding. If there are no worthwhile simplifications, say explicitly:

> No worthwhile simplification findings.

Do not manufacture low-confidence suggestions to fill the report.
