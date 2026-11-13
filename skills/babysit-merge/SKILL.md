---
name: babysit-merge
description: Safely update, validate, and squash-merge a human-approved same-repository pull request with no worthwhile outstanding feedback.
---

# Babysit merge

Finish a human-approved pull request from a checked-out branch that tracks the pull request's head
branch. The local branch name may differ from the remote head branch, including in app-managed
worktrees. Update it with the target branch, wait for required validation, and squash-merge it only
while every gate below remains satisfied and no outstanding discussion would reasonably benefit
from another commit or a human decision.

This workflow supports same-repository pull requests only. Do not use it for fork pull requests.
Do not rebase, force-push, delete the branch, enable auto-merge, or bypass branch protection.

## Establish the deadline

At the start, record the current UTC time and a hard deadline exactly eight hours later. The
deadline is wall-clock time, not accumulated wait time. Before every wait, retry, remote update,
local update, push, or merge attempt, compare the current time with the deadline. If the deadline
has been reached, stop without starting that operation and report the timeout outcome.

Do not reset or extend the deadline after a push, CI restart, target-branch advance, conflict, or
merge race.

## Preflight

Perform every preflight check before changing local or remote state:

1. Require `gh auth status` to succeed for the repository host.
2. Require a completely clean worktree, including tracked, staged, and untracked files.
3. Resolve the current local branch, current repository, `origin` repository, configured upstream,
   local `HEAD`, and upstream remote-tracking head. Require the upstream remote to be `origin`, and
   derive the remote head branch from that upstream. Fetch `origin` before comparing commit IDs.
4. List open pull requests for the upstream remote head branch in the current repository. Require
   exactly one, and require it to be non-draft.
5. Read the pull request's base repository, head repository, base branch, head branch, head commit,
   state, and draft status. Require all of the following:
   - the PR is open and non-draft
   - the base and head repositories are the current repository
   - the PR is not cross-repository
   - `origin` identifies that same repository
   - the PR head branch is the upstream remote head branch
6. Require the authenticated user to have push access to the repository. Repository permissions
   of `WRITE`, `MAINTAIN`, or `ADMIN` qualify; do not assume merge permission merely from
   authentication.
7. Require the branch's configured upstream to be exactly `origin/<PR-head-branch>`. The local
   branch name does not need to match. Require local `HEAD`, that remote-tracking ref after fetch,
   and the PR head commit to be the same commit.
8. Read the complete, paginated review history. Exclude reviews whose author is a bot, including
   GitHub users with type `Bot` and bot-style application logins. Ignore dismissed reviews. For
   each remaining human reviewer, select that reviewer's latest non-dismissed review by submission
   time, using review ID as a deterministic tiebreaker.
9. Require at least one selected latest human review to be an explicitly submitted `APPROVED`
   review. Branch protection, `reviewDecision`, mergeability, labels, bot reviews, and passing
   checks do not substitute for this human approval. If any selected latest human review is
   `CHANGES_REQUESTED`, treat it as blocking and stop. `COMMENTED` and `PENDING` neither approve
   nor block.
10. Read the complete, paginated PR conversation and every review thread, including all comments,
    authors, timestamps, paths, positions, outdated status, and resolution status. Apply the
    outstanding-question judgment below. Do not proceed if it finds a blocking or ambiguous item.

Use complete API pagination for reviews, review threads, review comments, and conversation
comments; summary fields alone are not sufficient. Do not mutate the branch if any preflight
requirement fails.

## Judge outstanding questions

Human approval is necessary but not sufficient to merge. Independently assess whether the PR has
any open question, request, or worthwhile feedback that might reasonably lead to another commit
on the branch or needs a human decision before merging.

Use judgment rather than treating thread-resolution state as the decision:

- Treat an item as blocking when it raises a plausible correctness, security, data-loss,
  acceptance-criteria, behavior, compatibility, maintainability, or meaningful clarity concern
  that the current head does not clearly address.
- Treat a direct unanswered question or requested change as blocking when a reasonable answer
  could change the implementation, tests, documentation, or scope.
- Consider unresolved review threads, pending human reviews, top-level PR comments, and later
  replies. A human approval elsewhere does not cancel a separate outstanding concern.
- Do not block solely because a thread is unresolved when the feedback is clearly obsolete,
  already addressed by the current head, explicitly withdrawn, explicitly accepted as
  non-blocking, purely informational, praise, or a trivial preference that would not justify
  another commit.
- Do not assume a resolved thread is safe when later discussion, the current diff, or another
  comment shows that the underlying question remains open.
- If the disposition is unclear, stop and report the exact item and why it could affect the
  branch. Ask the user to decide; do not merge by default.

Repeat this judgment from freshly paginated discussion data after every push, after each CI wait,
and immediately before the merge attempt.

## State machine

Keep the PR number, base branch, current local branch, upstream remote head branch, last
incorporated target commit, and a set of retried check identities. Re-read GitHub state and the
complete PR discussion after every push and before every merge attempt. Never rely on a previously
read approval, discussion judgment, check result, PR head, or target head.

### 1. Incorporate the target branch

Check the deadline, then fetch the PR's base branch from `origin`. Merge
`origin/<base-branch>` into the current PR branch with a normal merge. Never rebase.

- If the target commit is already an ancestor of `HEAD`, continue without creating a commit.
- If the merge succeeds and changes the branch, run the repository's relevant validation, then
  check the deadline and push normally to the configured upstream. Never force-push.
- If the merge conflicts, inspect the base, target, and both sides of every conflict. Resolve only
  when the correct result is clear and preserves both the target branch's intent and the PR's
  intent. Run relevant validation, complete the merge commit, and push normally.
- If any resolution is ambiguous or would intentionally change behavior, abort the merge when
  safe, preserve the clean pre-merge state, ask the user to decide, and report the ambiguous
  conflict outcome. Do not guess.

Conflict resolution does not itself require a new approval. However, immediately after every
push, re-read the PR head and the complete review history using the preflight review algorithm.
If GitHub has not yet exposed the pushed commit as the PR head, wait within the deadline and read
it again; stop if it exposes a different unexpected head. If GitHub dismissed the qualifying
approval, stop immediately and report that reapproval is required. Also stop if a latest human
`CHANGES_REQUESTED` review is now blocking. Re-read all PR discussion and stop if the
outstanding-question judgment finds a blocking or ambiguous item.

### 2. Wait for CI

Read all checks reported for the current PR head. Treat only `SUCCESS`, `NEUTRAL`, and `SKIPPED`
as acceptable terminal conclusions. Wait while any check is queued, expected, pending, requested,
waiting, or in progress. A reported non-neutral check must succeed; missing required checks,
failures, errors, cancellations, timeouts, action-required states, and startup failures do not
pass.

Before each wait, check the deadline. After each wait, re-read the PR state, PR head, approvals,
blocking reviews, complete PR discussion, and full check set. Stop immediately if the PR closes,
becomes draft, changes head unexpectedly, loses its current human approval, gains a blocking
review, or has a blocking or ambiguous outstanding question.

For a failed GitHub Actions check:

1. Identify its workflow run and job from check metadata.
2. Inspect run/job conclusions, annotations, and failed logs with `gh run view`, `gh api`, and
   `gh run view --log-failed` as appropriate.
3. Retry only when there is concrete evidence of a flake: runner or service infrastructure
   failure, network interruption, unrelated timeout, or a known nondeterministic failure
   signature. Do not infer flakiness merely because a check passed previously.
4. Treat assertion, compile, lint, type, migration, and test failures as substantive by default.
5. Retry each distinct failed check identity at most once. Prefer a job-level rerun. Use a
   run-level failed-job rerun only when it cannot accidentally retry an already exhausted or
   substantive failure. Record the check identity and evidence before retrying.

Check the deadline immediately before a retry. Non-GitHub-Actions failures are non-rerunnable
unless their provider exposes a safe, explicit retry that obeys the same one-retry limit. Stop on
substantive failures, non-rerunnable failures, or exhausted retries, and report concise evidence.
Include every retried flake in the final outcome even if CI later passes.

### 3. Recheck the target

After CI passes, check the deadline and fetch the base branch again. If its commit differs from the
last incorporated target commit, return to target incorporation: merge it, push any resulting
update, re-read approval state, and restart CI evaluation for the new PR head.

Continue until CI passes for a head that incorporates the freshly fetched target.

### 4. Apply the fresh final gate

Immediately before merging, freshly read local refs and GitHub state. Require all of these at the
same time:

- the PR is open and non-draft
- the PR is mergeable, with no policy or merge-state blocker
- the worktree is clean
- the configured upstream is exactly `origin/<PR-head-branch>`
- local `HEAD`, the fetched upstream commit, and the PR head commit are identical
- the freshly fetched target commit is an ancestor of `HEAD`
- the complete-review-history algorithm finds a current, explicitly submitted human approval
- no human reviewer's latest non-dismissed review is `CHANGES_REQUESTED`
- the freshly paginated PR discussion passes the outstanding-question judgment
- every reported non-neutral check for the current PR head has an acceptable terminal conclusion

If any gate is pending because the target or checks advanced, loop through the corresponding
update and CI states within the original deadline. Stop on approval, policy, permission, or other
non-recoverable failures.

### 5. Squash-merge and confirm

Check the deadline. Run `gh pr merge <number> --squash` for the current PR, guarding the expected
head commit when the installed `gh` version supports it. Do not pass branch deletion, auto-merge,
or administrator-bypass options. Do not answer prompts by enabling auto-merge.

If GitHub rejects the attempt because the target branch or checks advanced, re-read state and loop
through target incorporation, CI, and the fresh final gate within the deadline. Stop rather than
retrying when rejection is due to policy, permission, approval, or a substantive check failure.

After a successful command, query the PR again and require state `MERGED` with a non-null merge
timestamp. Report the squash merge commit when GitHub provides it. Do not delete the local or
remote branch.

## Outcomes

Keep the final report concise and use the applicable outcome:

- **Success:** PR number, confirmed squash merge commit, and any retried flakes with their evidence.
- **Timeout:** the state being attempted when the original eight-hour deadline expired.
- **Dismissed approval:** the push after which approval disappeared and that reapproval is required.
- **Outstanding question:** the exact review thread or conversation item, why it may justify
  another commit or decision, and what must be resolved before merging.
- **Ambiguous conflict:** conflicted paths and the behavior or intent decision the user must make.
- **Retried flake:** check identity, concrete flake evidence, and retry result; include this within
  success or the eventual stopping outcome.
- **Substantive CI failure:** failed check, terminal conclusion, and the shortest useful evidence
  from annotations or logs.
