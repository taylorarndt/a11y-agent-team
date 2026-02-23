# manage-branches

List, compare, find stale, protect, or delete branches in a repository. The agent is safety-first — for destructive actions like deletion, it always shows a list and waits for explicit confirmation before acting.

## When to Use It

- Cleaning up merged or abandoned branches
- Checking which branches have unmerged commits
- Viewing or configuring branch protection rules
- Comparing two branches to see diff summary

## How to Launch It

**In GitHub Copilot Chat:**
```
/manage-branches owner/repo
```

With a specific action:
```
/manage-branches owner/repo list
/manage-branches owner/repo stale
/manage-branches owner/repo compare feature/auth main
/manage-branches owner/repo cleanup merged
/manage-branches owner/repo protect main
```

## What to Expect

### Capabilities

| Action | Command example | What it does |
|--------|----------------|--------------|
| List all | `list` | Table of all branches with age, author, status |
| Find stale | `stale` | Branches with no commits in 30+ days |
| Compare | `compare branch-a branch-b` | Diff summary between two branches |
| Cleanup merged | `cleanup merged` | List merged branches → confirm → delete |
| Protect | `protect main` | Show/set protection rules for a branch |

### Safety for Destructive Actions

Deletion always follows this flow:

```
Agent: Found 5 merged branches eligible for deletion:

  feature/add-login (merged 14 days ago, author: alice)
  fix/header-bug    (merged 8 days ago, author: bob)
  ...

Delete all 5? (yes/no/select) → 
```

The agent **will not delete any branch without explicit confirmation**.

### Stale Branch Detection

A branch is flagged as stale when:
- Last commit was more than 30 days ago
- It has not been merged into the default branch
- It has no open PRs pointing to it

### Branch Protection Summary

```
Protection rules for main:
  Require PR review: Yes (1 approver)
  Dismiss stale reviews: Yes
  Require CI passing: Yes (required checks: build, test)
  Force push: Disabled
  Allow deletion: Disabled
```

## Example Variations

```
/manage-branches owner/repo list             # All branches
/manage-branches owner/repo stale            # 30+ days inactive
/manage-branches owner/repo stale 14         # Custom threshold (14 days)
/manage-branches owner/repo compare a b      # Branch comparison
/manage-branches owner/repo protect main     # View/set protection
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [merge-pr](merge-pr.md) — merge a PR (and optionally delete its branch)
- [my-prs](my-prs.md) — see PR status by branch
