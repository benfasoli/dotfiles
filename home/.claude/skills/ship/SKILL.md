---
name: ship
description: Branch, commit, push, and open a PR for the current changes.
---

Ship the current changes as a pull request: $ARGUMENTS

1. Create a branch off the current base branch named `benfasoli/<feature>` where `<feature>` is a short kebab-case slug describing the change. Use `git checkout -b`.

2. Merge changes from the remote main branch. Resolve any merge conflicts to ensure our branch is up to date with the latest changes.

3. Verify linting and tests pass locally. If not, fix the issues before proceeding.

4. Stage and commit the changes. The commit message should complete the sentence "If applied, this change will \_\_\_". e.g. "Add retry logic to webhook delivery". Keep it to one line.

5. Push the branch to GitHub.

6. Open a PR with `gh pr create`. Set the title and body:
   - **Title** completes "If applied, this change will \_\_\_":
     - "Add exponential backoff to worker retry loop"
     - "Fix structured log ingestion"
     - "Configure prometheus scraping for K8s services"
     - "Remove tag browser sidebar from monitor app"
   - **Body** is a short ~1-2 sentence paragraph starting with "This diff ...". Omit test plans unless steps must be taken by reviewers. This should focus on WHY the changes were made and their impact rather than just describing the code changes. After the first 1-2 sentence paragraph, additional paragraphs can be added to provide more context or details if necessary.

If any step fails, stop and report the error — do not continue.
