---
name: pr-description
description: Write a GitHub PR title and description in Ben's authentic engineering voice — prose-first, technically specific, honest about what's verified and what isn't. Use whenever composing or revising a PR description for a benfasoli PR (directly, via `gh pr create`, or when another workflow like /ship needs the body written), and whenever a draft PR body reads like a generated template (## Summary + ## Test plan checklists, exhaustive ## Why/## What/## Risks scaffolding, hedgy filler) that should sound like Ben instead.
---

# PR descriptions in Ben's voice

Ben writes PR descriptions as a terse note to a technical reviewer, not a report. The reviewer is smart and reads the diff; the description explains what changed, why, and what's been verified — nothing more. This skill encodes that voice, derived from ~90 of his hand-written PRs.

The failure mode to avoid is the generated-template look: a `## Summary` bullet list plus a `## Test plan` checklist, or an exhaustive `## Why`/`## What`/`## Testing`/`## Risks` scaffold applied to every change regardless of size, padded with hedgy "Low risk; ..." restatements. That structure is the tell that a description wasn't written by Ben. Match the change's weight instead.

## Structure — match the change, don't template it

**Default is prose.** Most PRs are 1–4 tight paragraphs, no section headers. Open one of three ways:

- **"This diff <verb>s …"** — his most common opener. "This diff consolidates …", "This diff adds …", "This diff wraps …", "This diff gates …".
- **Bare imperative** for small changes — "Adds …", "Bumps …", "Swaps …", "Removes …", "Moves …", "Fixes …".
- **The problem first** for bugs/ops — "The QA deploy has never succeeded: …", "Nodes have less memory than expected …", "Edits to public lots with existing LME bids return 422 in QA: …".

Then, as needed:
- **State the goal** — "Goal is to <intent>." — and the **prior broken state** — "Previously, <what was wrong>." Ben explains *why*, and what the world looked like before, not just the mechanism.
- **"Also <verb>s …"** for secondary changes ("Also refactors …", "Also fixes a bug where …").
- **End with verification** (see below) and **refs** (see below).

**Sectioned only when the change earns it.** For a large or multi-part PR, use `##` headers named after the *subsystems* (`## Postgres: Database abstraction`, `## Query interface: t-strings`, `## Also in this PR`) — not the generic Why/What/Summary/Test-plan scaffold. A focused bug fix can use a minimal `## Problem` / `## Fix` / `## Testing`. The test: would a reviewer need a map to navigate this diff? If not, prose.

When a fixed template *is* imposed on you (e.g. running under /ship, which keeps `## Why` / `## What` / `## Testing` / `## Risks / follow-ups` / `## Related`), keep the sections but write each one in this voice — terse, concrete, no hedging — and **omit a section rather than pad it**. A one-line "## Why" beats three sentences of restatement.

## Restraint — the reviewer reads the diff

This is where drafts go wrong: they narrate the diff instead of summarizing intent. The reviewer will read the code. Your job is to give the essence — what changed and why — and trust them for the rest. Abstract the mechanism to one clause; do not walk through each code path, name every function touched, or enumerate each config value unless a reviewer genuinely can't follow the diff without it. A small or medium PR is usually two or three sentences. When you've written a bulleted breakdown of each branch, stop and ask whether one sentence captures the intent — it almost always does, and that's the version to ship.

Contrast, same real PR (fixing a draft-lot crash):

- **Over-narrated (cut this):** "`deleteDraft` and `publishDraft` both called `queryClient.removeQueries()` after the mutation, which invalidated the still-mounted `useSuspenseQuery(getDraftLotsOptions())` observer and forced a refetch … Delete invalidates the draft lots list with `refetchType: 'none'` … Publish additionally invalidates the public lots list …" — three paragraphs re-deriving the diff.
- **Ben's actual version:** "Publishing or deleting a draft lot from the edit page could crash … when the draft cache was cleared while the edit form was still reading from it. This reorders the cache refresh so the destination page's data is primed and the draft list is only refreshed once the edit form is no longer reading it." — two sentences: the symptom, the essence of the fix. Then the Sentry link.

The reviewer who wants the `refetchType: 'none'` detail reads the diff. Name a specific symbol only when it *is* the point (the failing exception, the one flag that was wrong), not to prove you understood the change.

When a design choice needs justifying, use **first person** — "I opted for this approach instead of downgrading git on the runners since I think it's more maintainable" — not a detached "The trade-off is deliberate." The judgment is yours; say so.

## Voice

- **Be specifically technical.** Name the exact mechanism, exception, flag, version, or failure mode: `ImageTagAlreadyExistsException`, `--atomic` implies `--wait`, `machine_labels` vs `labels`, "autoStep() returns a string like `30s`". Precision is the whole value; vagueness wastes the reviewer's time.
- **Explain the prior state and the why.** "Previously helm returned as soon as the API server accepted the manifests, so CD reported success even when pods crashlooped." Root causes are first-class content.
- **Be candid.** Flag what isn't done or isn't sure: "I have not yet validated the behavior of …", "WIP …", "Draft until verified: …", "Hacky grep addition but it fills a void that ruff and pyright don't." Honesty over polish.
- **First person where it's natural** — "I opted for this approach since I think it's more maintainable", "I removed view_samples.py since I think it's redundant now", "I flagged the underlying runner issue to DevOps".
- **Name people** for support dependencies and confirmations — "This will require Darren's support for vGPU binding", "✅ Verified this is expected behavior with @Ankit-Redwood", "@corylotze-rw can you deploy this then merge?".
- **Emdashes are fine** (unlike his Slack status posts). Use them freely.
- **No LLM fluff, meta-commentary, or discovery narration.** Cut leverage/utilize/robust/seamless/comprehensive/significant/successfully; cut "load-bearing"/"critical"/"key"/"genuinely"; cut "testing surfaced that"/"it turned out"/"we found that" — state the cause and fix directly. (This mirrors the always-on writing-voice guidance.)
- **Never fabricate.** No invented metrics, user counts, or ticket numbers. State only what's real; if impact is unknown, say what the change enables and stop.

## Verification — how Ben closes a PR

He ends with what he actually ran, not a checklist of intentions:

- **`✅ Verified <what>`** with the real command in a code block, or a screenshot dragged in, or a link to the CI run:
  > ✅ Verified lint command succeeds against core lib with:
  > ```
  > TcAutomation.exe lint --solution rw-core.sln
  > ```
- Or a flat statement when that's the whole story: **"No behavioral changes."**, **"Backward-compatible change."**, **"No source changes were needed — …"**.
- If it's not verified, say so plainly ("Draft until verified: this depends on the runner having a usable local builder, which I can't confirm from here").

Avoid the `- [ ]` / `- [x]` checkbox test-plan format — that's the generated look.

## Refs

At the end, bare and terse — not prosified:
- Jira: `RAD-1246` on its own line (not "Fixes RAD-1246").
- Issues/PRs: `Closes #17`, `See #274`, `Stacked on #28`, `Depends on #10`. Describe stacking relationships when relevant ("finishing the consolidation started in #13 and #15").
- Links to related PRs across repos, or the Slack thread that drove it, as full URLs.

## Title

Imperative and searchable — `[verb] [what] [where/why]` ("Replace runner hard-kill with graceful TwinCAT process cleanup"), or a conventional-commit prefix when the repo uses them (`feat(scanner): …`, `fix(adapters): …`, `docs: …`). Never "fix bug" or "updates".

## Worked examples (real, self-authored)

**Small, prose, verified:**
> Keep red cancel button text red on hover
>
> The red Cancel buttons in the receiving flow use the `ghost` button variant, whose `hover:text-foreground` rule wins on hover. So hovering a Cancel button kept the red background tint but flipped the label from red to near-black, which read like a different button.
>
> Adding `hover:text-red-600` overrides that, so the text stays red and darkens one shade for contrast against the `bg-red-500/10` hover tint. Affects the session-hub Cancel and the container-form Cancel.
>
> ✅ Verified in the 480×800 scanner preview: base text is red-500 and the hover rule resolves to red-600.

**Bug, root-cause first:**
> Make BatteryRepo.set writes atomic via Redis transaction
>
> This diff wraps the three Redis commands in `BatteryRepo.set` (`HSETNX created_at`, `HSET mapping`, `EXPIRE`) in a `MULTI`/`EXEC` transaction so concurrent readers can never observe a partial battery hash. Previously, load tests intermittently surfaced `union_tag_not_found` Pydantic errors because the dashboard's scan caught a freshly-created hash between the `HSETNX` and `HSET`, when only `created_at` was populated and the `state` discriminator was missing.
>
> The race window only exists for the first write of each new battery, which is why the failure was rare and load-dependent. A regression test injects a delay on the standalone `hset` path to deterministically reproduce the original bug.

**Candid / not-yet-verified:**
> This diff folds the standalone `bluegreen-deploy` tool into `TcAutomation` as a new `bluegreen` subcommand family. Workflows no longer need Python on the runner now that all tools are in `TcAutomation.exe`.
>
> I have not yet validated the behavior of the `bluegreen` and `deploy` subcommands. Goal is to do that next from the LH runner machine. CI currently expected to fail due to ongoing firewall troubleshooting with the BMC runners.
>
> Closes #16

**Large, domain-named headers** (only for a PR this big): see `rad-core#9` — sections like `## Postgres: Database abstraction`, `## Query interface: t-strings`, `## Also in this PR`, closing with a bare `RAD-1106`.
