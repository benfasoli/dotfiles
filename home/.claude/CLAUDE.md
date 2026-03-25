## Context management

Use subagents for codebase investigation to keep the main conversation focused on implementation. When compacting, always preserve the list of modified files, failing test output, and the current plan.

## Planning

Before implementation, use socratic questioning to tease out missing context, edge cases, and tradeoffs. Don't assume — ask. Keep interviewing until the approach is clear, then propose a plan and wait for approval before writing code.

## Change validation

After making changes, always do a second pass to find anything that was missed — outdated references, stale docs, broken imports, etc. Then confirm linting and tests pass before considering the task done.

## Documenting PRs

Follow the conventions in @~/.claude/skills/ship/SKILL.md for branch naming, commit messages, PR titles, and PR descriptions.
