---
name: improve-docs
description: Reader-first standard for improving a project's documentation with restraint —
  focused on the stable interface (OpenAPI, --help, public signatures, usage examples) and
  decoupled from churny internals. Use when improving, auditing, or pruning repo docs.
---

# Documentation standard

The goal is better docs, not more docs. A pass succeeds when a reader gets what they need
faster — often by cutting, consolidating, reordering, or rewriting rather than adding. Adding
nothing is a valid outcome, and cutting stale or low-value docs is good — but don't equate fewer
docs with better ones. Prose style for the docs themselves follows `~/.claude/docs/writing.md`
(voice, and the narrative/technical mode split).

## Write for the reader (the test everything else serves)
Every rule below answers one question: what does *this reader* need next, and at what level? When
a rule seems to conflict with that, the reader wins.
- **Their need, not the artifact's tidiness.** Optimize for the person reading — not for dedup,
  completeness, or precision as ends in themselves. Redundancy that helps a reader (an
  at-a-glance command list, a quickstart that repeats key flags) is not waste; don't remove it
  for duplication alone.
- **Altitude: what it does, not how it's built.** Describe behavior and contract, not internals
  or the specific tool/rule that implements them. "Runs lint, formatting, and import checks"
  helps more, and ages better, than "Biome + oxlint `import/no-cycle`." A claim can be perfectly
  true and still be the wrong altitude — true does not mean useful.
- **The smallest change that helps.** Fix in place before restructuring, replacing, or deleting.
  If a doc exists only to explain a confusing inconsistency, the inconsistency is the bug — fix
  it (or flag it) rather than writing a better explanation of it.

## What earns a place
Document only what a reader needs and can't easily get from the code itself:
- the contract (how to call it, what comes back, what can go wrong)
- the intent and the non-obvious "why"
- the things that bite (gotchas, invariants, constraints)
Skip the obvious, anything self-evident from a signature, and anything that just narrates code.
Claim only what the code does — don't generalize beyond it (e.g. don't write `deploy-<env>` if
prod has no such target); overstated shorthand reads as fact.

## Order and placement
- **Order by reader priority.** Lead with a brief "what it is and the problem it solves," then
  how to get running (install before usage examples), and only then deeper context like an
  architecture overview. Getting someone productive outranks a high-level "what's in here" tour —
  so the tour comes later, not first.
- **Place docs next to what they describe.** In a multi-service monorepo, detailed per-service
  docs (what it owns, what interfaces it exposes) belong in that service's README, where they sit
  by the code and don't rot like a root-level summary; the root README orients and points.

## Decouple from churny internals
Docs that mirror implementation detail rot on every refactor and generate low-value diffs. Raise
the abstraction level: document stable contracts and intent, not volatile internals.
- Before writing, ask: will this need editing every time someone refactors the internals? If yes,
  raise the level or don't write it.
- For anything that must track the code (API schema, CLI help), prefer a generated or exported
  source of truth over hand-copied text where you can. Where you do keep a human-facing summary
  (a command/target list, key flags), keep it accurate — fix drift in place; only replace an
  embedded block with a pointer when the output is genuinely volatile or exhaustive.

## The interface, in canonical form (usually the highest-value target)
The stable contract is where a pass tends to pay off most:
- HTTP API → OpenAPI. Keep the generated spec correct: accurate request/response models, status
  codes, documented error schema. (FastAPI: `response_model`, explicit `status_code`, `responses=`
  for errors.) Prefer pointing at `/openapi.json` or an export command over hand-written endpoint
  prose that duplicates the code.
- CLI → `--help`. Make the help text good at the source; a README command list is a fine
  at-a-glance reference even though `--help` reproduces it.
- Library/SDK → public signatures + a few runnable examples for the main entry points.

## Docstrings / doc-comments — public surface only
- First line: concise summary, imperative, <80 chars, ends with a period.
- Longer prose only if it adds something the signature doesn't.
- Document parameters only when there are several or any are non-obvious; describe meaning and how
  to choose a value, never restating types.
- Document the errors/exceptions a caller would reasonably handle + their trigger.
- Skip trivial accessors, `self`/`cls`, and private internals. No doc-comment just to have one.
- Python → Google-style (`Args:`, `Raises:`). TS/JS → TSDoc/JSDoc on exported symbols, leaning on
  the type signature. Other languages → the idiomatic doc-comment, same restraint.

## docs/ topic files and agent notes (CLAUDE.md)
- docs/ topic files: touch only where code clearly supports the claim and the topic is durable
  enough to maintain. architecture = components and boundaries; api = contracts/errors;
  persistence = schema/ownership/transactions. No speculative future-state.
- CLAUDE.md: small and high-signal — durable invariants, key decisions, gotchas. Prune anything
  the current code contradicts; don't restate README/docs; ~150-line budget.

## Each pass
- Removing stale, wrong, or code-narrating docs is improvement — do it.
- Consolidate overlapping docs instead of adding another.
- If a doc is wrong, fix or delete it rather than layering a correction on top.
- Prefer no change over a low-value change. Read before you write. Leave `TODO(docs):` for claims
  you can't verify instead of inventing.
- Docs-only: no code refactors, no reformatting.

## Scheduled pass (daily, unattended)
Applies only when invoked by the daily schedule, not in an interactive session. Runs locally
against the local clones. This pass is an orchestrator: it fans the per-repo work out to subagents
and only keeps their summaries, so the main thread never fills with the file dumps of every repo.
(A manual single-repo invocation needs none of this — just apply the standard inline.)

**1. Pick targets (orchestrator, inline).** Run `scripts/select-repos.sh`. It fetches each clone
and emits one line per eligible repo — `<repo-path>\t<base-branch>\t<base-sha>` — already filtered
to repos you authored commits in within ~2 weeks and skipping any repo that already has an open
`docs/improve-*` PR (so passes don't stack). If it emits nothing, the pass is done: report "no
changes" and stop. The output is small; keep this in the main thread.

**2. Dispatch one worker subagent per repo.** Give each worker the repo path, base branch, base
SHA, and this standard. Workers are independent — run them concurrently. Each worker:
- Creates a throwaway worktree off the base SHA (`git worktree add <tmp> <base-sha>`) so it never
  disturbs the clone you're actively working in, and documents the code at that ref — not the
  possibly-stale working tree.
- Applies the standard — right content, right altitude, right order and placement, smallest fix —
  to make the **single highest-value** improvement, not a sweeping rewrite. Soft cap ~150 changed
  lines; if more is warranted, take the top slice and list deferred items in the PR body.
- Pushes the branch and opens a **draft** PR, then removes the worktree.
- Returns one line: the PR URL + what it changed, or "no high-value change."

**3. Verify each PR with a fresh subagent.** Doc edits made unattended risk asserting things the
code doesn't support. For each PR a worker opened, dispatch a verifier with the diff and the base
SHA: it checks every changed or added claim against the code at that ref and reports unsupported
ones. For any PR with findings, apply the correction in a worktree and push it to the PR branch —
or drop the claim, or downgrade it to `TODO(docs):` — before the pass finishes. Never leave a
draft PR standing with a known-unsupported claim. (Verification confirms claims are *true*;
whether a claim is useful and well-placed is the worker's call under the standard above.) Skip
repos that produced no PR.

**4. Report (orchestrator).** Collect the worker + verifier summaries into a short digest: which
repos got a draft PR (with links), which were skipped and why, what verification caught.

**Guardrails**
- Docs-only: no code refactors, no reformatting, no dependency changes.
- Never commit to a default branch; never push without opening the PR as a draft for review.
- An empty pass is success — open nothing.
