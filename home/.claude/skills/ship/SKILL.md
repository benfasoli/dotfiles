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
   one, so a stale local base can't poison the diff. First check whether you
   are ALREADY inside a linked worktree (the desktop "worktree" checkbox puts
   you in one): if `git rev-parse --git-dir` differs from
   `git rev-parse --git-common-dir`, you are. Pick the branching mode from that:
   - Already in a worktree → `git switch -c benfasoli/<descriptive-few-words> origin/<base>`
     in place. Do NOT `git worktree add` — nesting another worktree under the
     same repo multiplies the concurrent-session collision surface (see Phase 4).
   - Not in a worktree, and you want an isolated tree →
     `git worktree add ../<repo>-<slug> -b benfasoli/<descriptive-few-words> origin/<base>`
   - Not in a worktree, working in place → `git switch -c benfasoli/<descriptive-few-words> origin/<base>`

   Use a short kebab-case slug from the task; refine the name later with
   `git branch -m` once scope is clear.
4. If a local base branch exists and has diverged from remote (can't
   fast-forward), surface it to me rather than guessing.
5. **Pin the working root and never edit outside it.** Capture
   `git rev-parse --show-toplevel` — call this `$ROOT`. Every file you Read,
   Edit, or Write for the rest of this run MUST be under `$ROOT`. In a linked
   worktree, the main checkout (e.g. `…/<repo>/packages/foo.ts`) and the
   worktree (`…/<repo>/.claude/worktrees/<name>/packages/foo.ts`) hold separate
   copies of the same file — editing the main-checkout path silently lands your
   change on the wrong tree (an observed, real bug). So: if you ever hold an
   absolute path that does NOT start with `$ROOT`, do not touch it — rewrite it
   to its `$ROOT`-relative equivalent first. Prefer `$ROOT`-relative paths
   everywhere; when you must use an absolute path, confirm it begins with
   `$ROOT`.

## Phase 1 — Research (delegate, don't pollute main context)

Spawn the Explore subagent to map relevant code. It must read CLAUDE.md, any
ADRs, and the modules neighboring this change — capturing existing patterns,
conventions, and the repo's test/lint commands. Note relevant industry best
practices and any place they conflict with the repo's conventions; prefer the
repo's, but flag a conflict if its convention is clearly wrong. Return a short
distilled summary, not a dump.

Tell the subagent the working root is `$ROOT` and require it to report every
location as a path relative to `$ROOT` (or rooted at `$ROOT`) — never an
absolute path into the main checkout. A bare repo subagent may resolve symbols
to the main checkout's copy; before acting on any path it returns, re-anchor it
under `$ROOT` (Phase 0, step 5).

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

Confirm the path is under `$ROOT` BEFORE every edit (Phase 0, step 5), and
verify every edit against disk AFTER, not against the tool's own report. When
several worktree sessions run concurrently on one repo, the Read/Edit/Write
layer can serve another worktree's buffered content or silently fail to flush a
write to this worktree's disk — a real, observed bug. So after editing, confirm
with Bash run from `$ROOT` (`git -C "$ROOT" diff --stat`, `grep -n`), and do NOT
trust an Edit "success" message or re-Read to confirm — Read is the layer that
lies here. If an edit won't stick, write it via Bash (e.g. a `python3` exact-
string replace) and re-check the diff. The collision is per-path, so this mainly
bites when two live sessions touch the same file.

Once you have made your first edit, sanity-check that it landed where you
intended: `git -C "$ROOT" diff --stat` should list your file, and the main
checkout must stay clean. If your changes show up there instead of under `$ROOT`,
you edited the wrong copy — move them (capture the diff, `git checkout --` the
main checkout to revert it, re-apply under `$ROOT`) and fix the offending paths
before continuing.

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
2. Sync with the remote base before pushing — `origin/<base>` will have moved
   while you worked, and the PR should merge cleanly. `git fetch origin <base>`,
   then if `origin/<base>` is ahead of your branch's merge-base, integrate it
   (`git merge origin/<base>` — or rebase if that's the repo's convention).
   Resolve every conflict by combining BOTH sides' intent (your change AND
   theirs), never by blindly taking one side; confirm no conflict markers remain
   (`grep -rn '^<<<<<<<\|^>>>>>>>'`) and no unmerged paths
   (`git diff --name-only --diff-filter=U`). Then re-run the linter and tests,
   and re-verify any behavior the incoming changes touch — a clean text merge can
   still be semantically wrong. Commit the merge.
3. `git push -u origin HEAD`
4. Open a **draft** PR with `gh pr create --draft --base <base>`.
5. Stop and give me the PR URL plus a one-line summary of what's left for me
   (review, mark ready, merge). Do not take further git/PR actions.

If the base moves again after the PR is open and you're asked to re-sync, repeat
step 2 (fetch, integrate, resolve, re-verify) before any further push.

### PR title

Per the `pr-description` skill: imperative and searchable, never "fix bug" or
"updates".

### PR description — describe INTENT (why), kept to the 5-minute rule

Write the prose per the `pr-description` skill
(`~/.claude/skills/pr-description/SKILL.md`). Keep the section headers below,
but **omit a section rather than pad it** — a one-line "## Why" beats three
sentences of filler, and a routine PR does not need every section.

## Why

The problem or need, and the impact if it's actually known. State intent from
the task; do NOT fabricate user counts, revenue, or ticket numbers. If impact
is unknown, say what the change is meant to enable and stop there.

## What

High-level approach. Key decisions and the reasoning. Alternatives considered
and why they were rejected. No line-by-line narration.

## Screenshots (UI changes only)

For a new page or any UI-visible change, include an image — the new screen, or
before/after when changing existing UI. Capture it however the repo runs its app
(preview server, or a headless browser at the app's target viewport), then
attach it by dragging/pasting into the PR description in GitHub's web editor:
that uploads to GitHub's `user-attachments` CDN and renders inline without
committing anything to the repo. There is no `gh`/API equivalent (the upload
needs the browser session), so leave a placeholder in this section and tell me
the local path to drag in — do NOT commit screenshot files to the repo. Omit
this section entirely when the change has no UI surface.

## Testing

Only what you actually ran (unit/integration commands, manual checks). Be
specific. Never claim coverage you didn't execute.

## Risks / follow-ups

Known limitations, rollback notes, deferred work.

## Related

`Fixes #<n>` only if a real issue exists. Otherwise omit.

Keep the diff reviewable. If it's ballooning past ~800 lines, stop and tell me;
it may need splitting.
