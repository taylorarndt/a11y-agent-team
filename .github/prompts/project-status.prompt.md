---
name: project-status
description: "GitHub Projects overview -- item counts per column, blocked items, stale items, sprint progress, and team assignments"
agent: issue-tracker
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Show the status of a GitHub Project board -- items per column, blocked items, stale items, and team workload.

${input:details:Optional: project number, org/repo name, 'org:orgname', or 'my items'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present.
3. Identify the target project:
   - If a project number is given, use it directly
   - If a repo is given, list available projects for that repo/org
   - If "my items" is specified, show the user's items across all active projects
   - Check preferences.md for configured active projects
3. Fetch project data:
   - All items with their current status/column
   - Item details: type (issue/PR/draft), assignee, labels, last activity
4. Calculate per-column metrics:

   | Column | Items | Assignees | Avg Age | Stale (7+ days) |
   |--------|-------|-----------|---------|-----------------|
   | To Do | {N} | @alice (3), @bob (2) | 5 days | 1 |
   | In Progress | {N} | @charlie (2), @dana (1) | 3 days | 0 |
   | In Review | {N} | -- | 2 days | 0 |
   | Done | {N} | -- | -- | -- |

5. Flag attention items:
   - **Blocked:** Items marked as blocked or with a "blocked" label
   - **Stale:** Items in the same column for 7+ days with no activity
   - **Unassigned:** Items in "In Progress" or "In Review" with no assignee
   - **Overloaded:** Team members with 5+ items in progress
6. Show sprint/iteration progress if applicable:
   - Completion percentage
   - Burn-down status (on track / behind / ahead)
   - Days remaining
7. Present in chat with option to generate a saved document.

After the overview: _"Want to see a specific column, update an item's status, or check a team member's workload?"_
