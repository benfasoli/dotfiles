---
name: weekly-status
description: Generate a weekly status report from GitHub PRs, Jira, and Slack, formatted for a Slack message to director/VP/CTO audience
user-invocable: true
---

# Weekly Status Report

Generate a weekly status report for a director/VP/CTO audience. Output ONLY the formatted report — no preamble, explanation, or follow-up.

## Voice

Write as a staff/principal engineer reporting to technical leadership. The reader is smart and technical, so never pad or hedge — but this is a skimmed Slack post, not a design doc. Name the mechanism only when the mechanism is the deliverable: an architecture or migration shape ("one CDK stack, one CI/CD pipeline, one `make serve` dev loop"), a design decision, an incident the audience already knows about. Describe fixes and features at the domain level, by the behavior the product gained ("stakeholders can demo from a desktop browser with no badge reader") — not the code level. Env flags, variable names, Okta policy names, and library commands are the first things the author deletes.

The thing to cut is not technical vocabulary — it is fluff. LLM-generated drafts pad with words that carry no information ("leverage," "robust," "seamless," "enabling the team to," "in order to," "plays a key role"). Every clause should do work: a mechanism, a number, a consequence, or a name. If a clause only frames or restates, delete it. A precise, concrete clause earns its place; a padded or hedgy one does not. Do not editorialize about the work either — no calling a fix "load-bearing," "critical," or "key," or noting that something "genuinely" mattered. State the fact and let it stand. Aim for a draft that needs no trimming, because the alternative is the author deleting half of what you wrote.

## Step 0: Ask for weekly context

Before fetching anything, ask the user one short question:

> "Any context for this week — themes, priorities, things you want to make sure land? (Enter to skip.)"

Whatever they name is the week's focus. Lead the "This week" headline with it so the work they flagged is visible at the top. Do NOT create a dedicated section for the theme — sections stay grouped by project/domain (Step 4); the headline is where the focus gets highlighted, and the underlying work lands in whatever project sections it belongs to. If they skip, infer the headline from the week's biggest outcomes across PRs, Jira, and Slack.

## Step 1: Determine date range

Default range: **Monday through Friday of the current week**. If run mid-week, the range still covers the full Mon–Fri window (Friday is the report's end date even if it hasn't happened yet). Accept `$ARGUMENTS` as an override (e.g. "last week", "since 2026-05-01"). Format dates as YYYY-MM-DD.

## Step 2: Fetch data sources (parallel)

Run these in parallel:

**GitHub PRs:**
```
gh search prs --author=benfasoli --updated=">={MONDAY_DATE}" --json repository,title,number,state,url,closedAt,updatedAt,createdAt,labels,body --limit 100
```

`state` carries merge status (`merged`, `closed`, `open`). There is no `mergedAt` field in `gh search prs --json` — do not include it.

**Jira:**
Use `searchJiraIssuesUsingJql` with `cloudId: "252bd8df-52b0-4a5e-a330-499a311140ed"` (Redwood's Atlassian cloud — stable, hard-coded so you can skip `getAccessibleAtlassianResources`):
```
assignee = currentUser() AND updated >= "{MONDAY_DATE}" ORDER BY updated DESC
```

**Slack — authored messages:**
Use `slack_search_public_and_private`. The `from:@me` shortcut does not work — you must use the user's literal Slack ID: `from:<@U076R01BR2M>`.

Issue a single query scoped to the full week and paginate through every page. The tool returns up to 20 results per page; when the response includes a `cursor` (in `pagination_info`), pass it back as the `cursor` param on the next request. Keep going until no cursor is returned. Busy weeks routinely span 8+ pages — do not stop early; you need all of them.

Cursor pagination has a 1-message boundary overlap: each page's first result repeats the previous page's last result. Dedupe stitched results by `Message_ts` (or by permalink) before reading.

```
from:<@U076R01BR2M> after:{MONDAY_DATE-1} before:{FRIDAY_DATE+1}
```

Set `include_context:false`, `sort:timestamp`, `sort_dir:desc` to keep responses tight.

**Slack — threads driven:** scan results for threads with ≥3 replies where the user was the anchor (set direction, made a call, unblocked someone). These often matter more than authored messages.

## Step 3: Filter ruthlessly

Drop before formatting:
- Dep bumps, typo fixes, config tweaks, single-line PRs with no follow-on impact
- Routine standups, one-line acknowledgements, casual chatter
- Jira tickets that duplicate a PR (PR wins)
- Hiring updates, expense receipts, personal logistics
- Onboarding, access grants, and starter-project scoping — team logistics, not report content
- Items whose end-to-end behavior isn't confirmed yet (e.g. an alert migration where the forced test alert never fired) — drop rather than hedge; it's next week's bullet once verified
- Anything you can't write a "why it matters" clause for

Keep:
- Outcomes the audience would ask about ("how's X going?")
- Decisions made, even if they live only in Slack
- Incidents led or co-led
- Cross-team unblocks
- Risks or asks where leadership can help

When picking Slack-sourced items:
- Do not label exploratory discussion as a "decision." Only call something Shipped if there is a concrete, durable outcome the audience could point to next week. A back-and-forth weighing tradeoffs is not a decision.
- Prefer substantive collaboration over advisory help. "Worked with X to fix Z" beats "helped X think about Y." If the user was the senior person in the thread but the artifact lives with someone else, it is probably advisory; weigh whether it belongs in the report.

## Step 4: Group by project, then by status

Group items by project (human-readable name, not repo slug). Convert repo names: strip `rw-`/`rad-` prefixes, capitalize (e.g. `rw-batsort` → "Battery sorting", `rw-twincat-cicd-toolkit` → "Controls CI/CD").

Slack-sourced items should land in the project section they actually belong to. If a conversation advanced Battery sorting — including advisory help, onboarding, or observability work *about* battery sorting — it goes under Battery sorting, not `*Other*`. The test is the subject of the work, not whether you wrote code. Reserve `*Other*` (at the bottom) for cross-cutting items with no home workstream: org-wide tooling, security sweeps, a company-level metric you are flagging. When in doubt, a named workstream beats `*Other*`.

A workstream with a single item still gets its own named section. Do NOT merge a lone workstream item into `*Other*` to avoid a thin section — one-item sections are normal and common in the real posts (e.g. a standalone "CodeArtifact proxy" or "batsort" section with one bullet). Concretely: "Advised Nadia on rw-batsort's Redis queue design" belongs under a *Battery sorting* section, not *Other*, even if it is the only battery-sorting item that week. Mentoring, code review, and observability work on a named workstream is real reportable work under that workstream, not advisory noise to drop. But one collaboration bullet per section is usually plenty — keep the most substantive (a design worked through together, framed by its purpose), and drop pointer-giving, access grants, and orientation help.

Within each project, order by status: **Shipped**, then **In progress**, then **Blocked**, then **Risk**.

`In progress` bullets are rare. If in-flight work is part of the week's focus, state it in the headline ("API client generation is in progress") and cut the bullet; bullet an in-progress item only if leadership would ask about it by name. Internal plumbing (build caching, error-envelope standardization, deploy retargeting) doesn't earn a bullet even when merged, unless it unblocks something the audience tracks.

Order projects by activity (most items first). Omit projects with no meaningful updates.

Blockers and risks live inside the relevant project section, not at the top of the report. Use `Blocked:` for work that is currently stuck on a dependency, and `Risk:` for situations that could break the project even if no work is actively stuck (e.g. fragile hardware, single-points-of-failure, external dependencies, or staffing/ownership gaps such as a departure leaving a system thinly covered or one person on the critical path). Each blocker or risk should name what would resolve it.

When naming a blocker or risk, state the underlying cause, not the surface symptom you noticed first. For a technical risk, name the actual technical cause (e.g. "git for windows submodule regression," not "CI failing"). For a staffing/ownership risk, name the coverage gap and who could resolve it (e.g. "camera-systems coverage thin after Sylvain's departure; asked Enrique and Tyler to consider PLC/HMI ownership"). If you are not sure of the underlying cause, ask the user before publishing.

The Shipped/In progress/Blocked/Risk taxonomy is the default for per-project work where status is meaningful. But plain-verb, label-less bullets are also fine inside a project section for handoffs, collaboration, and advisory work that doesn't fit a status label: `Handed off GPU PCI device automation to Conner.`, `Worked with Cayler + Nadia to remediate the frame-buffer off-by-one.`, `Asked Enrique and Tyler to consider PLC/HMI ownership.` A single straightforward fix may use a plain past-tense verb (`Fixed a 422 error blocking admin lot edits`, `Added ...`) in place of `Shipped:`.

`*Other*` items do not use status prefixes either; begin those lines with a plain verb: `Investigated`, `Worked with`, `Reviewed`, `Coordinated`. But note: collaboration, mentoring, and advisory work are NOT `*Other*` by default. A plain-verb bullet ("Worked with Nadia on ...") belongs inside the workstream it is about — put "Worked with Nadia on rw-batsort's Redis consumer" under *Battery sorting*. Only work with no home workstream at all (a security sweep across many repos, org-wide tooling, a company metric) lands in `*Other*`. Most weeks `*Other*` is empty — onboarding, access grants, and tooling chatter don't clear the bar.

## Step 5: Phrasing

Every item is one line:

> `Shipped:` / `In progress:` / `Blocked:` / `Risk:` `<what changed, and the consequence that makes it matter>` `<link>`

Lead with the label, then say what changed in concrete terms, then fold in the consequence. State the consequence as a technical fact, usually with "so" — never as an editorial "why it matters." That "so" clause is the heart of the report:

- "per-camera trigger diagnostic counters on PLC1 and PLC2, so silent trigger drops are now observable in Ignition."
- "the 1g.24gb profile so each card serves four isolated 24GB workloads."
- "an ID-badge NFC tap for identity and an Okta push for trust, so floor operators never type passwords."
- "GPU PCI passthrough auto-provisioning (with Conner) so GPU VMs always start on a host with a free device, replacing per-upgrade vSphere click-ops."

Credit collaborators inline, first names only: `(with Conner)`, `Worked with Micah + Ian`, `confirmed expected behavior with Ankit`. Full names read as formal in a Slack post where everyone shares the workspace. Collaborator names often live in thread replies rather than authored messages — read the thread before writing a collaboration bullet. Cluster related PRs into one bullet.

**Every bullet is one sentence by default — this is where drafts go wrong.** What changed, plus a short "so" consequence if it isn't obvious. Then stop. A second sentence is rare: reserved for the week's single biggest item, and most reports have none at all. If you are writing a second clause of detail on an ordinary bullet, you are writing the version the author deletes. A real section:

```
*Redwood OS*
- Shipped: Merged rad-rwos-frontend into rad-rwos as a monorepo: one CDK stack, one CI/CD pipeline, and one `make serve` dev loop across all four servers, so coordinated frontend/backend changes ship as one PR instead of two synchronized ones. [rad-rwos#59](url)
- Shipped: Email/password sign-in on the scanner alongside badge tap. Stakeholders can demo from a desktop browser with no badge reader, and scanner users can still sign in if they forget their badge. [frontend#38](url)
- Shipped: Operators now select a facility and business operation after sign-in. [frontend#39](url)
- Worked with Micah + Ian on the scanner PWA update strategy: detect an index.html diff between browser and server, reload during reload-safe navigations.
```

The first bullet's depth is the deliverable itself (the monorepo shape); the auth bullet spends its second sentence on who benefits, not on Okta internals. The generated draft of that auth bullet read: "The shared 'any 2 factor types' Okta policy let a Verify push satisfy both factor slots and skip the password; forced `prompt=login` on that redirect to require it." Accurate, interesting to an engineer — and the author cut it. The failure mechanics live in the PR; the post carries the capability.

Advisory, collaboration, and onboarding bullets stay short — name who and what was decided, scoped, or handed off, in one clause. Do not reproduce the design you discussed. "Worked with Tyler and Enrique to scope NuGet CodeArtifact distribution for rw-twincat-core" is the whole bullet; the API shapes and class names that came up in the thread do not belong in the report.

**When a bullet does earn a second sentence**, spend it on the single detail that changes what the reader knows: the shape of a migration, who a capability unblocks, an incident the audience already heard about. Not construction details (`PKCE`, `localStorage`, `RequireAuth`, exact flag expressions, which files moved), and not failure archaeology for a bug the audience never saw — name what raced or broke at the domain level ("a race condition between an admin draft-lot publish and the redirect to the public lot page"), not the env vars and variable names involved. Ask of each clause: does the reader act differently knowing it? If not, cut it.

**Numbers:** keep the ones that tell the story ("5 minutes to about 30 seconds," "$8M in payable penalties"). Drop decoration, including enumerations the reader doesn't need (element orderings, per-environment label values). Root-cause detail earns a sentence only when the audience already knows about the incident; otherwise state the fix at domain level and leave the diagnosis in the PR.

Generated vs authored — the trims a real edit made:

- Generated: "Shipped: Sentry frontend tracing has sampled 0 in every environment since it was introduced; the gate checked `MODE === 'production'` but our builds use `--mode dev|qa|prod`, so it never fired. Switched to `VITE_ENV_NAME === 'prod'`." Authored: "Shipped: enabled Sentry tracing for improved network performance observability." The diagnosis was the interesting part to the engineer; the reader needed the capability.
- Generated: "Fixed a draft-lot not-found crash on publish/delete by reordering cache refreshes so the edit form stops reading the draft cache before it clears." Authored: "Shipped: fixed a race condition between an admin draft-lot publish and the redirect to the public lot page." Same fix, described by what raced in the product instead of cache mechanics.
- Generated: "Verified via the QA environment; reviewed with Bryan Vicknair." Authored: deleted. The post asserts outcomes; verification narration and reviewer credits live in the PR.

Too thin (no consequence): "Shipped: Added retry logic to webhook delivery [repo#1](url)"

Fluffed (LLM padding — cut it): "Shipped: Successfully re-enabled the TensorRT execution provider on the classifier, leveraging pinned input shapes to enable robust, low-latency inference that significantly improves throughput under production load."

De-fluffed (say the fact): "Shipped: Updated classifier to use the TensorRT execution provider. Load tests stable at 4.5 bat/s with no latency degradation. [repo#337](url)"

Do not narrate discovery ("on-device testing surfaced that," "it turned out," "we found that," "digging in revealed") — delete the lead-in and start at the fact.

## Step 6: Links

Use standard markdown link syntax:

- PR: `[repo#272](https://github.com/org/repo/pull/272)`
- Jira: `[ABC-123](https://....atlassian.net/browse/ABC-123)`
- Slack thread: `[thread](https://....slack.com/archives/.../p..)`. Use sparingly, only when the thread itself is the artifact.

Multiple links on one line are fine: `... [repo#1](url1), [repo#2](url2)`.

## Output format

```
Week ending {FRIDAY_DATE}

*This week:* <one or two sentences, often a fragment, stating the week's top outcome or current state across projects>.

*{Project Name}*
- Shipped: <outcome and why> <link>
- In progress: <outcome and why> <link>
- Blocked: <outcome and why; what would unblock> <link>
- Risk: <situation and why it matters; what would resolve it>
- <plain verb, no label: handoff/collaboration/advisory item> <optional link>

*{Project Name}*
- Shipped: <outcome and why> <link>

*Other*
- <verb> <outcome and why> <link>
- <verb> <outcome and why>
```

Omit empty sections. If the week was quiet, write one honest sentence under "This week" and stop.

## Rules

- Output ONLY the report text, nothing else
- Bullets use `-` (markdown list syntax), never `•` or other Unicode bullet characters — the report gets copy-pasted as markdown
- Markdown link syntax `[text](url)`, never Slack's `<url|text>` syntax
- Cut filler, not substance. Every clause carries a number, consequence, or name. Cluster related PRs. Drop trivia. Every bullet is one sentence by default; at most one or two second sentences across the whole report (Step 5).
- Target 6–9 bullets total, 2–4 per section. If the draft runs longer, cut whole bullets (weakest first), not just their detail.
- Every item pairs what changed with the consequence that makes it matter, folded into the same bullet (usually a "so" clause). If you can't state the consequence, cut the item. No separate "Why it matters" line.
- Headline: one or two sentences, often a fragment. If the user named a focus in Step 0, lead with it. Openers Ben uses: "Focus was X.", "Focused on X.", "Progress on X.", or a plain statement of current state ("Badge-tap scanner sign-in now works end-to-end on the handheld."). State the outcome, not a list of activities.
- Use precise domain language — name the product behavior, decision, or migration shape. Code-level mechanism (flags, env vars, policy names, library commands) belongs in the PR, not the post (Step 5).
- Voice per `~/.claude/docs/writing.md` (the AI-tells section applies in full: filler kill-list, no meta-commentary grading the work, no discovery narration). Additionally for this channel: no manager/corporate idioms ("heads-down," "drove the call," "punt," "circle back"), and no verification narration ("Verified via QA," "reviewed with X," lint/test claims); the post asserts outcomes.
- No emdashes at all (stricter than writing.md's rare allowance). Use periods, commas, semicolons, or parentheses.
