---
name: improve-docs
description: Standard for improving a project's documentation with restraint — focused
  on the stable interface (OpenAPI, --help, public signatures, usage examples) and
  decoupled from churny internals. Use when improving, auditing, or pruning repo docs.
---

# Documentation standard

The goal is better docs, not more docs. A pass succeeds when a reader gets what they need
faster — which often means cutting, consolidating, or rewriting rather than adding. Adding
nothing is a valid outcome; net deletions are a good one.

## What earns a place
Document only what a reader needs and can't easily get by reading the code:
- the contract (how to call it, what comes back, what can go wrong)
- the intent and the non-obvious "why"
- the things that bite (gotchas, invariants, constraints)
Skip the obvious, anything self-evident from a signature, and anything that just narrates code.

## Decouple from churny internals
Docs that mirror implementation detail rot on every refactor and generate low-value diffs.
Raise the abstraction level: document stable contracts and intent, not volatile internals.
- Before writing, ask: will this need editing every time someone refactors the internals?
  If yes, raise the level or don't write it.
- For anything that MUST track the code (API schema, CLI help), prefer a generated or
  exported source of truth over hand-copied text, so it can't silently drift. If you must
  embed output, embed the stable shape (synopsis, key flags) — not an exhaustive dump.

## The interface, in canonical form (usually the highest-value target)
It's the stable contract, so a pass tends to pay off most here:
- HTTP API → OpenAPI. Keep the generated spec correct: accurate request/response models,
  status codes, documented error schema. (FastAPI: `response_model`, explicit `status_code`,
  `responses=` for errors.) Prefer pointing at `/openapi.json` or an export command over
  hand-writing endpoint prose that duplicates the code.
- CLI → `--help`. Make the help text good at the source; reference how to get it, or embed
  only the stable synopsis + primary flags. Don't paste the full dump that rots.
- Library/SDK → public signatures + a few runnable examples for the main entry points.

## README
For a reader who's never seen the project: what it is and the problem it solves, the
interface with real runnable examples, then a separate "Local development" section. Keep it
to what a newcomer actually needs — resist mirroring the whole codebase.

## Docstrings / doc-comments — public surface only
General rule first, then language specifics.
- First line: concise summary, imperative, <80 chars, ends with a period.
- Longer prose only if it adds something the signature doesn't.
- Document parameters only when there are several or any are non-obvious; describe meaning
  and how to choose a value, never restating types.
- Document the errors/exceptions a caller would reasonably handle + their trigger.
- Skip trivial accessors, `self`/`cls`, and private internals. No doc-comment just to have one.
- Python → Google-style docstrings (`Args:`, `Raises:`).
- TypeScript/JS → TSDoc/JSDoc on exported symbols (`@param`, `@throws`, `@returns`); lean on
  the type signature, don't restate it.
- Other languages → the idiomatic doc-comment, same restraint.

## docs/ topic files
Touch only where code clearly supports the claim and the topic is durable enough to be worth
maintaining. architecture = components and boundaries; api = contracts/errors; persistence =
schema/ownership/transactions. No speculative future-state.

## Agent notes (CLAUDE.md)
Small, high-signal: durable invariants, key decisions, gotchas. Prune anything contradicted
by current code; don't restate README/docs; ~150-line budget.

## Each pass
- Removing stale, duplicated, or code-narrating docs is improvement — do it.
- Consolidate overlapping docs instead of adding another.
- If a doc is wrong, fix or delete it rather than layering a correction on top.
- Prefer no change over a low-value change. Read before you write. Leave `TODO(docs):` for
  claims you can't verify instead of inventing. No code refactors, no reformatting.

## Scheduled pass (daily, unattended)
Applies only when invoked by the daily schedule, not in an interactive session. Runs locally
against the local clones. This pass is an orchestrator: it fans the per-repo work out to
subagents and only keeps their summaries, so the main thread never fills with the file dumps
of every repo. (A manual single-repo invocation needs none of this — just apply the standard
inline.)

**1. Pick targets (orchestrator, inline).** Run `scripts/select-repos.sh`. It fetches each
clone and emits one line per eligible repo — `<repo-path>\t<base-branch>\t<base-sha>` —
already filtered to repos you authored commits in within ~2 weeks and skipping any repo that
already has an open `docs/improve-*` PR (so passes don't stack). If it emits nothing, the pass
is done: report "no changes" and stop. The output is small; keep this in the main thread.

**2. Dispatch one worker subagent per repo.** Give each worker the repo path, base branch,
base SHA, and this standard. Workers are independent — run them concurrently. Each worker:
- Creates a throwaway worktree off the base SHA (`git worktree add <tmp> <base-sha>`) so it
  never disturbs the clone you're actively working in, and documents the code at that ref —
  not the possibly-stale working tree.
- Applies the standard to find and make the **single highest-value** improvement — not a
  sweeping rewrite. Soft cap ~150 changed lines; if more is warranted, take the top slice and
  list deferred items in the PR body.
- Pushes the branch and opens a **draft** PR, then removes the worktree.
- Returns one line: the PR URL + what it changed, or "no high-value change."

**3. Verify each PR with a fresh subagent.** Doc edits made unattended risk asserting things
the code doesn't support. For each PR a worker opened, dispatch a verifier with the diff and
the base SHA: it checks every changed or added claim against the code at that ref and reports
unsupported ones. The worker (or orchestrator) then corrects or drops flagged claims, or
downgrades them to `TODO(docs):` rather than shipping a guess. Skip repos that produced no PR.

**4. Report (orchestrator).** Collect the worker + verifier summaries into a short digest:
which repos got a draft PR (with links), which were skipped and why, what verification caught.

**Guardrails**
- Docs-only: no code refactors, no reformatting, no dependency changes.
- Never commit to a default branch; never push without opening the PR as a draft for review.
- An empty pass is success — open nothing.
