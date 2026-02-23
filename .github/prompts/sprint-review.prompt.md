---
name: sprint-review
description: "End-of-sprint summary across all repos -- completed items, carryover, velocity trends, blockers, team contributions, and retrospective insights"
agent: analytics
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate an end-of-sprint review summary with completed work, carryover items, velocity metrics, and team contributions. Save both markdown and HTML versions.

${input:details:Optional: sprint/milestone name, date range, repo, or 'org:orgname'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present. By default, aggregate across ALL accessible repos.
3. Identify the sprint scope:
   - If a milestone is specified, use it as the sprint boundary
   - If a date range is given, use those dates
   - Default: last 2 weeks
3. Collect sprint data:
   - **Completed:** Issues closed and PRs merged during the sprint
   - **Carryover:** Issues/PRs that were in the sprint but not completed
   - **New work:** Items added mid-sprint
   - **Blockers:** Items that were blocked or stuck
4. Calculate velocity metrics:
   - Items completed vs. planned
   - Story points (if labels indicate points)
   - Comparison to previous sprint
   - Cycle time distribution
5. Collect team contributions:
   - Items completed per team member
   - Reviews done per team member
   - Highlights and notable contributions
6. Generate BOTH documents:
   - Markdown: `.github/reviews/analytics/sprint-review-{date}.md`
   - HTML: `.github/reviews/analytics/sprint-review-{date}.html`
   With sections: Sprint Summary, Completed Work, Carryover Items, Velocity Metrics, Team Contributions, Blockers & Risks, Retrospective Prompts
7. Include retrospective prompts:
   - What went well this sprint?
   - What could be improved?
   - What should we start/stop/continue?
   - Any recurring blockers to address?

After the review: _"Want to plan the next sprint? Or dive into any specific area?"_
