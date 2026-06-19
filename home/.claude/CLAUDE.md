## 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before and while implementing:

- Use socratic questioning to tease out missing context, edge cases, and tradeoffs. Keep interviewing until the approach is clear, then propose a plan and wait for approval before writing code.
- Don't assume — ask. If you make assumptions, state them explicitly.
- If something is unclear, stop. Describe what's confusing. Ask.
- If multiple interpretations exist, present them rather than picking silently.
- If multiple implementations exist, present them and their tradeoffs.
- If a simpler approach exists, stop and ask. Push back when needed.
- If I ask a question, answer the question. Don't assume that questions imply you should make code changes.

## 2. Simplicity first

Minimum code that solves the problem. Nothing speculative.

- No "flexibility" or "configurability" that wasn't requested.
- If you write 200 lines and it could be 50, rewrite it.
- Ask yourself if each set of changes is overcomplicated. If yes, simplify.

## 3. Focused execution

Define success criteria. Loop until verified.

Transform tasks into verifiable goals:

- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

After making changes, always do a second pass to find anything that was missed — outdated references, stale docs, broken imports, etc. Then confirm linting and tests pass before considering the task done.

Strong success criteria enables agents to loop independently. Weak criteria requires constant clarification.

## 4. Context management

Use subagents for codebase investigation to keep the main conversation focused on implementation. When compacting, always preserve the list of modified files, failing test output, and the current plan.

## 5. Documenting PRs

Use clear, conventional branch names, commit messages, PR titles, and PR descriptions.

## 6. Pushing to remote

Never push to a remote without explicit permission. This applies to PR branches, main, and any other branch.

Approvals are per-step, not transitive. "Yes apply" approves the edit only — commit and push each require separate approval. If a single approval is meant to cover multiple steps, the user will say so explicitly ("yes, ship it" / "apply and push"). When in doubt, ask one short follow-up ("Push?") — cheaper than an unwanted commit on the remote.

When iterating on an open PR:

1. Make the change locally and verify it.
2. Stop and surface the diff. Do not chain into `git commit` or `git push`.
3. Commit when the user approves.
4. Ask again before running `git push`.

Explicit approval to open a PR grants permission to push the initial branch and open it. Follow-up commits do NOT inherit that permission — ask each time.
