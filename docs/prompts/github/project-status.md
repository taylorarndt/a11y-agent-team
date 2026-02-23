# project-status

Generate a snapshot of a GitHub project board - column-by-column metrics, stale and blocked cards, unassigned items, and optional sprint burn-down if milestones are configured.

## When to Use It

- Standup preparation - knowing what is in progress vs. blocked
- Sprint review - what was completed vs. carried over
- Identifying workflow bottlenecks (too many items in one column)
- Finding unassigned cards that should have an owner

## How to Launch It

**In GitHub Copilot Chat:**

```text
/project-status owner/repo
```

With project number (if repo has multiple):

```text
/project-status owner/repo project:2
```

## What to Expect

1. **Discover project board** - Finds GitHub Projects (v2) or classic project if available
2. **Read all columns** - Fetches cards from every column/status with metadata
3. **Apply health flags** - Stale, blocked, unassigned, and overloaded signals
4. **Burn-down if applicable** - If milestone and due date are set, calculates velocity
5. **Render in chat** - Per-column summary table with flagged items highlighted

### Per-Column Metrics

| Metric | How calculated |
|--------|---------------|
| Card count | Total items in column |
| Avg age | Mean days since card was moved to this column |
| Stale | Cards with no activity in 7+ days |
| Blocked | Cards with "blocked" label or @mention waiting |
| Unassigned | Cards with no assignee |

### Health Flags

| Flag | Trigger |
|------|---------|
| Stale | In column 7+ days with no activity |
| Blocked | "blocked" label or outstanding question in comments |
| Unassigned | No assignee on the card |
| Overloaded | Column has more than 5 in-progress items |

### Sample Output

```text
Project: owner/repo - Sprint 12

Column          Cards   Avg Age   Flags
        
Backlog         18      -         2 unassigned
In Progress     6       4 days     OVERLOADED | 1 blocked
Review          3       2 days    1 awaiting re-review
Done            9       -

Sprint burn-down: 9/20 done, 8 days remaining (on track)

 Blocked: #112 "Add CSV export" - waiting on design approval
 Stale: #98 "Fix pagination" - 9 days in Review with no activity
```

## Example Variations

```text
/project-status owner/repo                  # Default project board
/project-status owner/repo project:3        # Specific project number
/project-status owner/repo blocked only     # Show only flagged items
/project-status owner/repo sprint           # Focus on burn-down
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [triage](triage.md) - score and prioritize open issues
- [sprint-review](sprint-review.md) - end-of-sprint analytics
- [my-issues](my-issues.md) - issues assigned to or @mentioning you
