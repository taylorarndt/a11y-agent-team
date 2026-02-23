---
name: team-dashboard
description: "Team-wide activity dashboard across all repos -- review load, contribution metrics, bottlenecks, and load balancing insights in dual markdown + HTML format"
agent: analytics
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate a team activity dashboard covering all team members' contributions, review load, and bottlenecks. Save both markdown and HTML versions.

${input:scope:Optional: repo name, 'org:orgname', date range (e.g. 'last 2 weeks', 'this month'), or specific focus (e.g. 'review load', 'bottlenecks')}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope and team roster from `.github/agents/preferences.md` if available. By default, aggregate across ALL accessible repos.
3. For each team member (or infer from repo contributors), collect:
   - PRs authored and merged in the period
   - PRs reviewed in the period
   - Issues opened and closed
   - Pending review requests (current backlog)
4. Calculate:
   - **Review turnaround** -- average time from review request to first review per person
   - **Load balance** -- who has the most pending reviews vs. who has capacity
   - **Contribution distribution** -- PRs and issues per person
   - **Bottlenecks** -- PRs waiting >7 days, overloaded reviewers, unresponded issues
5. Generate BOTH dashboard documents:
   - Markdown: `.github/reviews/analytics/team-dashboard-{date}.md`
   - HTML: `.github/reviews/analytics/team-dashboard-{date}.html`
   With sections: Health Overview, Review Load Distribution, Contribution Activity, Bottlenecks, Recommendations
6. Present a compact summary in chat with top insights and recommendations.

After the dashboard: _"Want to dig into any bottlenecks? Or see individual stats for a team member?"_
