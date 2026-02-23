---
name: my-issues
description: "Smart issue dashboard -- lists your open issues across all repos, sorted by priority with activity signals, reactions, release context, and discussion links"
agent: issue-tracker
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Get the current authenticated user with #tool:mcp_github_github_get_me, then search for all **open** issues created by that user using #tool:mcp_github_github_search_issues.

By default, search across ALL repos the user has access to (no `repo:` qualifier). Respect repo scope from `.github/agents/preferences.md` if present (discovery mode, include/exclude lists, per-repo overrides).

${input:filter:Optional: repo name, 'org:orgname', date range, labels, or keywords}

## Behavior

Parse the filter text:
- **Repo name** --> scope search to that repo with `repo:owner/name`
- **Org name** (e.g., "org:microsoft") --> scope to that org with `org:orgname`
- **Date** ("last week", "past 30 days", "since Jan") --> add `updated:>YYYY-MM-DD`
- **Labels** ("bug", "P0") --> add `label:` qualifier
- **Keywords** --> add to the search query text
- **No filter** --> search ALL accessible repos, issues updated in the **last 30 days**

## Enhanced Data Collection

For each issue found, also gather:
- **Reactions** -- summarize positive/negative reactions. Flag as Popular (5+), Controversial (mixed), or Quiet.
- **Release context** -- check if the issue is in a milestone tied to an upcoming release.
- **Discussions** -- note if there are related GitHub Discussions.
- **Team activity** -- who else is active on the issue.

## Output

**Lead with a one-line status:** _"You have 12 open issues (3 need attention, 2 popular, 1 release-bound)"_

Display results sorted by priority (issues with recent comments, @mentions, reactions, release context, or P0/P1 labels first):

| Priority | Title | Repo | Labels | Comments | Reactions | Updated | Signal |
|----------|-------|------|--------|----------|-----------|---------|--------|
| 1 | [Issue #N: Title](url) | repo | `bug`, `P0` | 5 | +1: 5, Popular | 2 hours ago | Action needed -- @mentioned |
| 2 | [Issue #N: Title](url) | repo | `feature` | 2 | +1: 1 | 1 day ago | New activity |

**Signal legend:**
- **Action needed** -- Needs your reply
- **New activity** -- New comments since your last visit
- **Popular** -- 5+ positive reactions from community
- **Release-bound** -- In an upcoming release milestone
- **Discussion** -- Has related GitHub Discussion
- **Quiet** -- No recent activity
- **Stale** -- No activity for 30+ days

After the table, suggest: _"Want me to generate a triage document for these, or dive into a specific issue?"_
