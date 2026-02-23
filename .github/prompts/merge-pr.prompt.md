---
name: merge-pr
description: "Merge a pull request -- checks readiness, picks merge strategy, and handles post-merge cleanup"
agent: pr-review
tools:
  - github/*
  - ask_questions
---

Merge a pull request after checking readiness.

${input:pr:PR reference -- e.g. owner/repo#123 or a GitHub PR URL}

## Steps

1. Parse the PR reference to extract owner, repo, and PR number.
2. Fetch PR metadata with #tool:mcp_github_github_pull_request_read (method: `get`).
3. **Check merge readiness:**
   - Is the PR approved? (at least one approval, no outstanding "changes requested")
   - Is CI passing? (all required checks green)
   - Are there merge conflicts?
   - Is the PR a draft? (cannot merge drafts)
   - Any branch protection rules that block merge?
4. **If not ready**, explain what's blocking:
   ```text
   PR #{number} is not ready to merge:
   - Missing required review from @alice
   - CI check "tests" is failing
   - Merge conflicts with base branch

   Want me to help resolve any of these?
   ```
5. **If ready**, present merge options via #tool:ask_questions:
   - **Squash and merge** (recommended -- clean history, single commit)
   - **Create a merge commit** (preserves all commits)
   - **Rebase and merge** (linear history, replays commits)
6. Show the default merge commit message and offer to customize:
   > **Merge commit message:**
   > {title} (#{number})
   >
   > {PR description summary}
7. Final confirmation:
   > Will merge PR #{number} "{title}" into `{base}` using **squash and merge**.
   > This action cannot be undone.
8. Confirm with #tool:ask_questions: **Merge** (recommended), **Edit message**, **Cancel**.
9. Merge the PR.
10. Offer post-merge actions:
    - **Delete source branch** -- clean up the merged branch
    - **Close linked issues** -- if the PR fixes issues, offer to close them
    - **Update briefing** -- note the merge in today's briefing
11. Confirm with link to the merged PR.

**Safety:** Always show what will happen and get explicit confirmation. Never auto-merge.
