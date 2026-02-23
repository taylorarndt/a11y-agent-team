# my-prs

Show a prioritized dashboard of all your open pull requests — split into "Your PRs" (authored) and "Awaiting Your Review" — with status signals and recommended actions.

## When to Use It

- Morning check to see what PRs need attention today
- Quick scan during the day for new review requests
- Before a standup to know the status of your PRs
- Catching PRs that are stale or blocked

## How to Launch It

**In GitHub Copilot Chat:**
```
/my-prs
```

With optional scope:
```
/my-prs owner/repo
/my-prs all repos
```

## What to Expect

1. **Query GitHub** — Find all open PRs you authored and all open PRs that have requested your review
2. **Classify each PR** — Assign a status signal based on review state, CI, and age
3. **Render dashboard** — Two-section table output in chat

### Status Signals

| Signal | Meaning |
|--------|---------|
| Ready to merge | Approved + CI passing + no conflicts |
| Needs update | Review requested changes |
| Blocked | CI failing or merge conflicts unresolved |
| Awaiting review | Draft or waiting for reviewers |
| Stale | No activity in 7+ days |

### Sample Output

```
Your PRs (3 open)
─────────────────
#123  Add auth middleware          Ready to merge   0 days old
#118  Refactor login flow          Needs update     3 days old  ● 2 comments
#109  Docs update                  Stale            12 days old → Action needed

Awaiting Your Review (2 requests)
──────────────────────────────────
#241  feat: add CSV export         alice            2 days old  ▶ Ready for review
#238  fix: broken pagination       bob              4 days old  ▶ Ready for review
```

## Example Variations

```
/my-prs                            # All repos, your PRs + your review queue
/my-prs owner/repo                 # Scoped to one repo
/my-prs all repos                  # Force cross-org scan
/my-prs just mine                  # Only PRs you authored
/my-prs just reviews               # Only your review queue
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) — do a full review of a specific PR
- [pr-author-checklist](pr-author-checklist.md) — check a PR before requesting review
- [merge-pr](merge-pr.md) — merge a PR that is ready
- [daily-briefing](daily-briefing.md) — full cross-repo briefing including PRs
