---
name: pr-description
description: Write a GitHub PR title and description that opens with the problem and spends its words on the reasoning, in Ben's voice (clear conversational prose, no AI tells, candid about what's unverified). Use whenever composing or revising a PR description for a benfasoli PR (directly, via `gh pr create`, or when another workflow like /ship needs the body written), and whenever a draft PR body reads like a generated template (## Summary + ## Test plan checklists, changeset narration, hedgy filler) that should sound like Ben instead.
---

# PR descriptions

A PR description explains the problem and the reasoning to a reviewer who will read the diff. Voice follows `~/.claude/docs/writing.md`; this skill covers what is specific to PRs.

The failure mode to avoid is describing the changeset. The reviewer can see what changed. They cannot see why the problem existed, what constraint shaped the fix, or which alternative you rejected, and those are the description's job. The generated-template look (## Summary bullets plus a ## Test plan checklist) and the diff-walk (file lists, function-by-function narration) fail the same way: all what, no why.

## Structure

Prose paragraphs with no section headers, for nearly every PR.

- The first sentence states the problem, meaning what was broken, missing, or costly. "Concurrent first logins for the same email could return 500." For a change with no problem story (a version bump, checked-in configs), open with what it does and keep the whole thing to a few sentences.
- Then the reasoning, as readable prose. How the problem arises, what the fix does about it, and why this shape rather than another. Use first person for judgment calls ("I chose X over Y because...").
- Weight tracks the story, not the diff or the effort behind it. A subtle bug earns three or four paragraphs. A config bump earns two sentences even when hours of debugging led there.
- Name a symbol when it is the point (the exception raised, the flag that was wrong), not to prove you read the code.
- Per writing.md's freshness rule, note the doc-review outcome when the change alters behavior or architecture ("No doc updates needed; nothing documents the removed error type.").

Sections only when the diff needs a map. A very large PR uses ## headers named after subsystems, opens with a TLDR naming what the bulk of the lines are (generated code, vendored assets, a mechanical rename), and states what it deliberately does not do. When a template is imposed (e.g. running under /ship), write its ## Why and ## What in this voice and omit any section you would otherwise pad.

## Verification

Almost never include a verification line. Lint, tests, type checks, and CI runs are assumed, and reporting them adds nothing. Include verification only when it is a human-in-the-loop step the reviewer cannot infer and it would establish trust, like "Deployed to QA and verified the full badge-login flow" or "Checked the hover state in the 480×800 scanner preview."

What is not verified matters more. Say plainly when something is untested, WIP, or blocked ("Draft until verified: this depends on the runner having a usable local builder, which I can't confirm from here").

## Refs

At the end, bare and terse. `RAD-1246` on its own line, `Closes #17`, `See #274`, `Stacked on #28`, full URLs to related PRs in other repos or the Slack thread that drove the change.

## Title

Imperative and searchable, shaped like verb, what, where ("Replace runner hard-kill with graceful TwinCAT process cleanup"), or a conventional-commit prefix when the repo uses them (`fix(users): ...`, `docs: ...`). Never "fix bug" or "updates".

## Examples

A bug fix. Problem in the first sentence, then the mechanism and the reasoning as prose, and no verification line because the tests speak for themselves:

> Concurrent first logins for the same email could return 500. The user lookup runs in one transaction that reads, inserts on a miss, and reads again if the insert loses a race. When two first logins arrive together, both reads miss and both insert. Postgres marks the loser's transaction failed the moment its insert violates the unique constraint, so the recovery read runs inside a dead transaction and raises `InFailedSqlTransaction` instead of returning the winner's row.
>
> The fix treats the conflict as an expected outcome rather than an exception. `create_user_for_email` now inserts with `ON CONFLICT (email) DO NOTHING` and returns `None` when the row already exists. Nothing raises, the transaction stays healthy, and the follow-up read returns the winner's row. I chose this over wrapping the old insert in a savepoint because it's a single statement and it retires `UserAlreadyExistsError` entirely.
>
> The race only exists on the first login for a given email, which is why sequential tests never caught it. The new test reproduces it deterministically. One transaction inserts the row and holds it uncommitted, a second calls `get_or_create_user` for the same email and blocks on the conflict, and the holder commits once `pg_stat_activity` shows the caller waiting on the lock.
>
> No doc updates needed. The fix is internal to the users service and nothing documents the removed error type.

A small UI fix, where the one verification line is a manual check the reviewer can't infer:

> Hovering a red Cancel button in the receiving flow kept the red background tint but flipped the label to near-black, which read like a different button. The buttons use the `ghost` variant, whose `hover:text-foreground` rule wins on hover.
>
> Adding `hover:text-red-600` overrides that. The text stays red and darkens one shade for contrast against the hover tint. Affects the session-hub Cancel and the container-form Cancel.
>
> ✅ Checked the hover state in the 480×800 scanner preview.

Tooling with no problem story. Opens with what it does and stops:

> Checks in vscode configs to auto-configure python and typescript tools.
>
> This configures static analysis across frontend and backend file types for working in the IDE, plus test runner configs that allow running tests under the debugger.
>
> No behavioral changes.

Candid about what isn't done:

> Workflows need Python on the runner only because `bluegreen-deploy` is a standalone script. This folds it into `TcAutomation` as a `bluegreen` subcommand family, so every tool ships in `TcAutomation.exe` and the Python dependency goes away.
>
> I have not yet validated the `bluegreen` and `deploy` subcommands. Goal is to do that next from the LH runner machine. CI is currently expected to fail due to ongoing firewall troubleshooting with the BMC runners.
>
> Closes #16
