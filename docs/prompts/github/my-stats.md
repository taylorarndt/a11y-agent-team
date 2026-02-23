# my-stats

Generate a personal contribution analytics report — PRs authored and merged, reviews given, issues filed and closed, cycle time trends, and a period-over-period comparison.

## When to Use It

- Weekly self-review to understand your own contribution patterns
- Performance review preparation — gathering concrete metrics
- Identifying where cycle times are slow (reviews taking too long, PRs sitting open)
- Comparing your current period velocity to previous periods

## How to Launch It

**In GitHub Copilot Chat:**
```
/my-stats
```

With period:
```
/my-stats last 30 days
/my-stats this month
/my-stats Q1 2026
/my-stats owner/repo
```

## What to Expect

1. **Collect your activity** — PRs authored, reviewed, issues filed, comments posted across repos
2. **Compute metrics** — Merge rate, review cycle time, issue resolution time
3. **Period comparison** — Current period vs. previous same-length period
4. **Trend indicators** — Up/down/flat per metric
5. **Save report** — Written to `.github/reviews/analytics/my-stats-{date}.md` and `.html`

### Metric Categories

| Category | Metrics measured |
|---------|----------------|
| Authorship | PRs opened, PRs merged, PR merge rate %, avg PR size (lines) |
| Reviews | Reviews given, review cycle time (hours), LGTM rate |
| Issues | Issues filed, issues closed, avg resolution time |
| Engagement | Comments posted, reactions given, discussions participated |
| Cycle time | Time from PR open to first review, time from review to merge |

### Period-Over-Period Table

```
My Stats — Feb 2026 vs. Jan 2026

Metric              Feb     Jan     Change
──────────────────  ──────  ──────  ──────
PRs merged          8       6       ↑ +33%
Avg merge time      2.1d    3.4d    ↑ faster
Reviews given       12      10      ↑ +20%
Avg review time     4.2h    6.8h    ↑ faster
Issues resolved     5       3       ↑ +67%
```

### Team Comparison (optional)

If the agent has access to org-level data, it can show your rank relative to collaborators (anonymized by default):

```
Review responsiveness: You — 4.2h avg | Team median — 6.1h  ↑ Above median
PR merge rate: You — 88% | Team median — 79%  ↑ Above median
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/analytics/my-stats-{date}.md` | Personal stats report |
| `.github/reviews/analytics/my-stats-{date}.html` | Accessible HTML version |

## Example Variations

```
/my-stats                             # Last 30 days, all repos
/my-stats last 90 days                # Longer window
/my-stats owner/repo                  # Scoped to one repo
/my-stats this quarter                # Current quarter
```

## Connected Agents

| Agent | Role |
|-------|------|
| analytics agent | Executes this prompt |

## Related Prompts

- [team-dashboard](team-dashboard.md) — team-wide analytics
- [sprint-review](sprint-review.md) — sprint-scoped velocity metrics
- [daily-briefing](daily-briefing.md) — daily briefing that includes contribution summary
