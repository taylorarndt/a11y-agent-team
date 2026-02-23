# team-dashboard

Generate a team contributions dashboard — per-member PRs, reviews, and pending review requests — with bottleneck detection for PRs waiting 7+ days for review.

## When to Use It

- Engineering manager weekly check on team activity
- Sprint planning — understanding who has bandwidth
- Identifying review bottlenecks (PRs waiting too long)
- Onboarding — seeing how a team is distributed across repos

## How to Launch It

**In GitHub Copilot Chat:**
```
/team-dashboard owner/repo
```

With org scope:
```
/team-dashboard org:myorg
/team-dashboard org:myorg last 14 days
```

## What to Expect

1. **Identify team members** — From repo collaborators, org membership, or PR/issue participants
2. **Collect metrics per member** — PRs authored, PRs merged, reviews given, open review requests
3. **Detect bottlenecks** — PRs waiting 7+ days for review, members with too many pending requests
4. **Render table** — Per-member row with metric summary
5. **Save report** — Written to `.github/reviews/analytics/team-dashboard-{date}.md` and `.html`

### Per-Member Table

```
Team Dashboard — owner/repo (last 14 days)
──────────────────────────────────────────
Member      PRs authored  PRs merged  Reviews given  Pending requests
─────────   ────────────  ──────────  ─────────────  ────────────────
alice       3             3           8              0
bob         2             1           4              2  ← 1 waiting 7d
charlie     0             0           2              1
diana       4             3           5              0

Bottleneck: #112 "CSV export" — waiting 8 days for bob's review
```

### Bottleneck Detection

A bottleneck is flagged when:
- A PR has waited 7+ days for review by a specific person
- A person has 3+ pending review requests simultaneously
- No reviews given in 7+ days (potential capacity issue)

### Coverage Gaps

The agent also checks for:
- Repos with no recent reviewer activity
- Longtime contributors with no recent commits (potential churn signal)
- Single-contributor repos (bus factor = 1)

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/analytics/team-dashboard-{date}.md` | Team dashboard report |
| `.github/reviews/analytics/team-dashboard-{date}.html` | Accessible HTML version |

## Example Variations

```
/team-dashboard owner/repo                 # One repo
/team-dashboard org:myorg                  # Full org
/team-dashboard last 7 days                # Narrower window
/team-dashboard bottlenecks only           # Just show bottlenecks
```

## Connected Agents

| Agent | Role |
|-------|------|
| analytics agent | Executes this prompt |

## Related Prompts

- [my-stats](my-stats.md) — individual contributor stats
- [sprint-review](sprint-review.md) — sprint-scoped velocity
- [pr-author-checklist](pr-author-checklist.md) — help authors improve readiness before requesting review
