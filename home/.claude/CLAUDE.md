## 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:

- Use socratic questioning to tease out missing context, edge cases, and tradeoffs. Keep interviewing until the approach is clear, then propose a plan and wait for approval before writing code.
- Don't assume — ask. If you make assumptions, state them explicitly.
- If something is unclear, stop. Describe what's confusing. Ask.
- If multiple interpretations exist, present them rather than picking silently.
- If multiple implementations exist, present them and their tradeoffs.
- If a simpler approach exists, stop and ask. Push back when needed.

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

Follow the conventions in @~/.claude/skills/ship/SKILL.md for branch naming, commit messages, PR titles, and PR descriptions.
