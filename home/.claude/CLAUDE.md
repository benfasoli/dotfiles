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

Branch names use `benfasoli/<descriptive-name>` — never a `claude/` prefix. An agent worktree is created on a `claude/<slug>` branch before the session starts, so rename the working branch (`git branch -m benfasoli/<descriptive-name>`) before the first push. Use clear, conventional commit messages. PR titles and descriptions follow the `pr-description` skill (voice, structure, verification style).

## 6. Pushing to remote

By default, never push to a remote or open a PR without explicit permission — this applies to PR branches, main, and any other branch.

Approvals are per-step, not transitive. "Yes apply" approves the edit only — commit and push each require separate approval. If a single approval is meant to cover multiple steps, the user will say so explicitly ("yes, ship it" / "apply and push"). When in doubt, ask one short follow-up ("Push?") — cheaper than an unwanted commit on the remote.

When iterating on an open PR:

1. Make the change locally and verify it.
2. Stop and surface the diff. Do not chain into `git commit` or `git push`.
3. Commit when the user approves.
4. Ask again before running `git push`.

Explicit approval to open a PR grants permission to push the initial branch and open it. Follow-up commits do NOT inherit that permission — ask each time.

Invoking a workflow whose declared endpoint is a push + PR (e.g. `/ship`) is itself that approval, for that one run: it authorizes pushing a new branch and opening a draft PR, nothing more. It does not cover the default/protected branch, marking ready, reviewers, merging, or any push that isn't cheaply reversible (deploy/notify-on-push, auto-merge, force-push), nor proceeding when a design decision would benefit from my input — each still needs a fresh ask.

## 7. Conventions and principles

Reference docs in `docs/`, applied when writing or reviewing code unless a project's own conventions say otherwise:

- **[docs/engineering.md](docs/engineering.md)** — cross-cutting principles: abstraction payoff, scale-appropriate infrastructure, domain/delivery boundaries, durable side-effects, real-dependency testing, and documenting decisions.
- **[docs/python.md](docs/python.md)** — Python style (docstrings, naming, typing, exceptions); a Backend services section covers FastAPI + Postgres architecture, HTTP/API, and testing — skip it outside services of that shape.
- **[docs/sql.md](docs/sql.md)** — Postgres formatting, naming, and schema conventions.
- **[docs/markdown.md](docs/markdown.md)** — one paragraph per line; document durable conventions, not transient state.

## 8. Writing in my voice

When you draft prose that goes out in my name — PR descriptions, commit messages, tickets, Slack, docs — write as I would, not as a generated report:

- **Technical and specific.** Name the real mechanism, failure mode, flag, or version. Don't sand it down to business/manager terms; the reader is technical.
- **Terse.** State the essence and trust the reader — a reviewer reads the diff. Cut any clause that only frames or restates. If I'd delete a third of it, it was too long to begin with.
- **No LLM tells.** Cut fluff (leverage, utilize, robust, seamless, comprehensive, significant, successfully), meta-commentary grading the work (load-bearing, critical, key, genuinely), and discovery narration (testing surfaced that, it turned out, we found that). State the cause and the fix.
- **Explain the why and the prior state; be candid.** Say what's unverified, WIP, or hacky. Use first person for judgment calls ("I opted for X because…"). Credit people by name.
- **Emdashes** are fine in PRs and prose; avoid them in Slack weekly-status posts.

Applied in skills: `pr-description` for PR titles/descriptions, `weekly-status` for the Slack status report.
