---
name: ship
description: End-to-end implementation workflow that branches off a fresh remote base, researches the codebase, front-loads all open questions, then autonomously implements, runs the review loop, and opens a draft PR. Use when you want a self-contained coding task or ticket carried from a clean branch through to a draft PR with a single check-in at the questions gate.
argument-hint: [task description or ticket ID]
allowed-tools: Read, Grep, Glob, Edit, Write, Bash, Task, Skill
---

You are running an end-to-end implementation workflow for: $ARGUMENTS

## Phase 0 — Start from an up-to-date base

Before any research, make sure the base branch is current with remote:

1. `git fetch --prune origin`
2. Determine the base branch (the repo default, usually `main`):
   - Try `git symbolic-ref --short refs/remotes/origin/HEAD`.
   - If that fails (origin/HEAD unset on this clone), run
     `git remote set-head origin -a` and retry, or fall back to
     `gh repo view --json defaultBranchRef -q .defaultBranchRef.name`.
3. Create the work branch off the freshly fetched REMOTE base, not the local
   one, so a stale local base can't poison the diff:
   - New worktree: `git worktree add ../<repo>-<slug> -b benfasoli/<descriptive-few-words> origin/<base>`
   - Same tree: `git switch -c benfasoli/<descriptive-few-words> origin/<base>`
     Use a short kebab-case slug from the task; refine the name later with
     `git branch -m` once scope is clear.
4. If a local base branch exists and has diverged from remote (can't
   fast-forward), surface it to me rather than guessing.

## Phase 1 — Research (delegate, don't pollute main context)

Spawn the Explore subagent to map relevant code. It must read CLAUDE.md, any
ADRs, and the modules neighboring this change — capturing existing patterns,
conventions, and the repo's test/lint commands. Note relevant industry best
practices and any place they conflict with the repo's conventions; prefer the
repo's, but flag a conflict if its convention is clearly wrong. Return a short
distilled summary, not a dump.

## Phase 2 — Front-load ALL questions, then STOP

List every ambiguity you'd otherwise hit mid-implementation, grouped by topic.
For each, give your recommended default so I can reply "defaults are fine."
Do not write a plan doc. Ask, then wait for my answer.

If research surfaced no genuine ambiguities, say so explicitly ("No open
questions; proceeding with: <one-line approach>") and continue — do not invent
questions to fill the phase.

## Phase 3 — Plan internally, then proceed (no approval gate, no plan file)

Once I answer, settle the approach in your head and go straight to
implementation. Do not write a plan to disk and do not ask me to approve it.

## Phase 4 — Implement

Build it. Run the repo's tests and linter (commands per CLAUDE.md). Fix failures
before moving on. Track what you actually tested — you'll need it for the PR.

If you need to investigate how something works elsewhere mid-implementation
("where else is this pattern used?", "what does this helper return?"), delegate
that lookup to the Explore subagent and have it return a short summary. Keep the
main context focused on the change itself, not on spelunking the codebase.

## Phase 5 — Review loop

Run each review pass as a subagent that returns ONLY a structured findings list
(severity + file:line + suggested fix). Reading the whole diff inline across up
to 3 iterations would bloat the main context three times over; isolating it in a
subagent keeps the main loop holding just the findings it needs to act on.

Use `/code-review` at high effort as the reviewer — dispatch it inside a Task
subagent when the diff is large enough that its reading would crowd the main
context; for a small diff, running it inline is fine. Address every Critical and
High finding, then re-review. Loop until no Critical/High remain or after 3
iterations, whichever comes first; surface anything still open instead of
looping forever. Then run `/security-review` the same way and address any real
findings.

## Phase 6 — Ship as a draft PR (then stop)

Pushing the branch and opening a DRAFT PR is the expected end of this workflow —
invoking `/ship` authorizes that single push. Do NOT push again, mark the PR
ready, or merge without separate explicit approval.

1. Commit using the repo's convention.
2. `git push -u origin HEAD`
3. Open a **draft** PR with `gh pr create --draft --base <base>`.
4. Stop and give me the PR URL plus a one-line summary of what's left for me
   (review, mark ready, merge). Do not take further git/PR actions.

### PR title

Imperative and searchable: `[action] [what] [where/why]`
(e.g. "Add idempotency keys to ingest endpoint to prevent duplicate writes").
Not "fix bug" or "updates".

### PR description — describe INTENT (why), kept to the 5-minute rule

## Why

The problem or need, and the impact if it's actually known. State intent from
the task; do NOT fabricate user counts, revenue, or ticket numbers. If impact
is unknown, say what the change is meant to enable and stop there.

## What

High-level approach. Key decisions and the reasoning. Alternatives considered
and why they were rejected. No line-by-line narration.

## Testing

Only what you actually ran (unit/integration commands, manual checks). Be
specific. Never claim coverage you didn't execute.

## Risks / follow-ups

Known limitations, rollback notes, deferred work.

## Related

`Fixes #<n>` only if a real issue exists. Otherwise omit.

Keep the diff reviewable. If it's ballooning past ~800 lines, stop and tell me;
it may need splitting.
