# Personal Copilot instructions

## Pull request review comments

- Treat review comments as input to evaluate, not requirements to implement automatically.
- Evaluate each comment against correctness, practical risk, likelihood, acceptance criteria, intended scope, and implementation cost.
- Classify feedback as blocking/high priority, medium priority, low priority, informational, or incorrect.
- Automatically address only high-confidence correctness, security, data-loss, or acceptance-criteria issues that remain within the pull request's intended scope.
- Before implementing medium- or low-priority feedback, scope-expanding hardening, architectural changes, or speculative edge cases, summarize the practical risk, likelihood, implementation scope, tradeoffs, and recommendation, then ask me to decide.
- When I ask to "review PR comments," triage and report them without implementing changes unless I explicitly ask to address them. Include a suggestion of what comments are worthwhile to immediately address.
- An unresolved review thread does not imply that code must change. If I decide to defer or reject feedback, reply with the rationale and resolve the thread.
