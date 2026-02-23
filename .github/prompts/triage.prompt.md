---
name: triage
description: "Generate a prioritized triage dashboard document (markdown + HTML) for your open issues across all repos with reactions, release context, and discussion links"
agent: issue-tracker
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate a triage dashboard document and save it to the workspace in both markdown and HTML formats.

${input:scope:Optional: repo name, 'org:orgname', label filter, or date range}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present. By default, search ALL accessible repos.
3. Search for open issues created by or assigned to the user with #tool:mcp_github_github_search_issues. Apply any scope filter provided. If a repo or org is specified, add `repo:` or `org:` qualifier; otherwise search cross-repo.
3. For each issue, fetch full details with #tool:mcp_github_github_issue_read to get comment counts, labels, reactions, and recent activity.
4. Gather enhanced data:
   - **Reactions** on each issue -- flag as Popular (5+), Controversial, or Quiet
   - **Release context** -- check milestones and upcoming releases
   - **Discussions** -- check for related GitHub Discussions
   - **Team activity** -- who else is involved
5. Score each issue using the enhanced priority system:
   - +3 --> @mentioned in recent comments
   - +3 --> Tied to an upcoming release milestone
   - +2 --> P0/P1/critical/urgent labels
   - +2 --> New comments since last visit
   - +2 --> High community interest (5+ positive reactions)
   - +1 --> Bug label
   - +1 --> Has active related discussion
   - -1 --> Wontfix/duplicate labels
   - -2 --> Stale (no activity >30 days)
6. Create BOTH triage dashboard documents:
   - Markdown: `.github/reviews/issues/triage-{date}.md`
   - HTML: `.github/reviews/issues/triage-{date}.html`
   With sections:
   - **Needs Immediate Action** (score >= 4) -- issues with action items, reactions, release context
   - **Review When Possible** (score 1-3) -- issues with activity
   - **Active Discussions** -- related GitHub Discussions needing attention
   - **Monitor** (score <= 0) -- quiet/stale issues
   - Decision checkboxes: Reply, Close, Reassign, Defer
   - Quick-action links to each issue on GitHub
   - Community reactions summary for each issue
7. Confirm: _"Triage dashboard saved to `{md-path}` and `{html-path}` with {N} issues. {X} need immediate action, {Y} are popular with the community."_
