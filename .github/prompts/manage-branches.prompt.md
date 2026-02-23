---
name: manage-branches
description: "Branch management -- list branches with activity, detect stale branches, compare ahead/behind, delete merged branches, show protection rules"
agent: pr-review
tools:
  - github/*
  - ask_questions
---

Manage branches in a repository -- list, compare, clean up stale branches, and check protection rules.

${input:action:Optional: 'list', 'stale', 'compare branch-a branch-b', 'cleanup', 'protection', or specific repo}

## Capabilities

### List Branches
- Fetch all branches with last commit date and author
- Sort by most recently active
- Show ahead/behind status relative to the default branch
- Flag: stale (no activity 30+ days), merged (can be deleted), protected

### Detect Stale Branches
- Identify branches with no commits in 30+ days (configurable)
- Show last commit author and date
- Distinguish between: merged (safe to delete), unmerged (needs review), protected (can't delete)

### Compare Branches
- Show commits ahead/behind between two branches
- List unique commits on each side
- Flag potential merge conflicts

### Delete Merged Branches
**Safety-first approach:**
1. List all branches that have been merged into the default branch
2. Exclude protected branches and the default branch
3. Show the full list with last activity date
4. Require explicit confirmation before deletion
5. Delete one at a time, confirming each (or batch with single confirmation if user requests)

### Branch Protection Rules
- Show protection rules for the default branch and any other protected branches
- Note: required reviews, status checks, enforcement level

### Display Format

```
Branches in owner/repo (15 total)

Active (8):
  main (default, protected) -- latest: 2h ago
  feature/auth-redesign -- 3 commits ahead, 0 behind -- latest: 1 day ago
  fix/login-timeout -- 1 commit ahead, 5 behind -- latest: 3 days ago

Stale (5 -- no activity in 30+ days):
  old/experiment -- merged, safe to delete -- last: 45 days ago
  feature/abandoned -- NOT merged, 12 commits ahead -- last: 60 days ago

Protected (2):
  main -- requires 2 reviews, CI must pass
  release/v2 -- requires 1 review
```

After listing: _"Want to clean up the merged stale branches? Or compare two branches?"_
