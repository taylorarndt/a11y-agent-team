---
name: my-stats
description: "Your personal GitHub metrics across all repos -- PRs authored/reviewed, issues closed, review turnaround, cycle time, and comparison vs. team averages"
agent: analytics
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate a personal contribution and review metrics report for the authenticated user. Save both markdown and HTML versions.

${input:scope:Optional: date range (e.g. 'this month', 'last quarter'), specific repo, 'org:orgname', or focus area (e.g. 'reviews', 'velocity')}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present. By default, aggregate metrics across ALL accessible repos.
   - PRs authored, merged, and avg cycle time (open --> merge)
   - PRs reviewed and avg review turnaround
   - Issues opened and closed
   - Commit count
3. If team roster is available in preferences, calculate comparison vs. team averages and median.
4. Calculate period-over-period trends (this period vs. last period).
5. Generate BOTH documents:
   - Markdown: `.github/reviews/analytics/my-stats-{date}.md`
   - HTML: `.github/reviews/analytics/my-stats-{date}.html`
   With sections: Summary, Your PRs Performance, Your Reviews Impact, Your Issues, Comparison vs. Team, Insights
6. Present a compact summary in chat with key metrics and trends.

After the report: _"Want to see how your metrics compare to specific team members? Or explore a particular area?"_
