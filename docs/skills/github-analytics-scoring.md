# github-analytics-scoring Skill

> Scoring formulas and analytical frameworks for GitHub workflow agents. Covers repository health scoring (0-100, A-F grades), priority scoring for issues/PRs/discussions, confidence levels for analytics findings, delta tracking (Fixed/New/Persistent/Regressed), velocity metrics, contributor metrics, bottleneck detection, and trend classification.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [analytics](../agents/analytics.md) | Health scoring, velocity metrics, bottleneck detection |
| [daily-briefing](../agents/daily-briefing.md) | Priority scoring for morning triage |
| [issue-tracker](../agents/issue-tracker.md) | Issue priority scoring and delta tracking |
| [pr-review](../agents/pr-review.md) | PR priority scoring |
| [repo-admin](../agents/repo-admin.md) | Repo health assessments |
| [insiders-a11y-tracker](../agents/insiders-a11y-tracker.md) | Change impact scoring |

## Repository Health Score

```text
Health Score = 100 - (sum of weighted penalties)

CI & Reliability:
  Failing workflow (high confidence):        -10
  Flaky test (3+ failures/week):             - 5
  No CI configured:                          - 8

Issues & PRs:
  Critical bug (P0) unresolved:             -10
  Security alert (critical):                -10
  Security alert (high):                    - 5
  PR stale >14 days:                        - 3 each (max -9)
  @mention unanswered >7 days:              - 5 each (max -10)
  >10 open issues with no triage:           - 3

Community Health:
  No CONTRIBUTING.md:                        - 5
  No CODE_OF_CONDUCT.md:                     - 3
  No branch protection on main:              - 5
  0 "good first issue" labels:               - 2

Floor: 0
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - healthy, minimal issues |
| 75-89 | B | Good - minor issues, well-managed |
| 50-74 | C | Needs attention - multiple signals |
| 25-49 | D | Poor - impacting velocity |
| 0-24 | F | Critical - blocking team progress |

## Priority Scoring

### Issues

| Signal | Points |
|--------|--------|
| @mentioned, no response | +5 |
| P0/P1/critical/urgent label | +3 |
| Upcoming release milestone | +3 |
| New comments since last activity | +2 |
| 5+ positive reactions | +2 |
| `bug` label | +1 |
| Assigned to current user | +1 |
| `wontfix`/`duplicate` label | -1 |
| No activity >14 days | -2 |

### Pull Requests

| Signal | Points |
|--------|--------|
| Review requested | +5 |
| "Changes requested" - needs update | +4 |
| Approved, ready to merge | +3 |
| Targets release branch | +3 |
| CI failing | +2 |
| Merge conflicts | +2 |
| Draft PR | -1 |
| No activity >7 days | -2 |

## Confidence Levels

| Level | When to Use |
|-------|------------|
| **High** | Multiple corroborating signals, definitively observed |
| **Medium** | Found by one source, likely issue |
| **Low** | Possible pattern - flag for human review, no score deduction |

## Delta Tracking

| Status | Definition |
|--------|-----------|
|  Fixed | Present in previous report, resolved now |
|  New | Not in previous report, appears now |
|  Persistent | Remains from previous report unchanged |
|  Regressed | Was previously fixed, has returned |

**Escalation rule:** If a finding is Persistent for 3+ consecutive reports, escalate with explicit ownership recommendation.

## Velocity Metrics

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|---------|
| PR merge rate | >3/week | 1-3/week | <1/week |
| Issue close rate | >5/week | 2-5/week | <2/week |
| Review turnaround | <24h | 24-72h | >72h |
| Stale PR ratio | <10% | 10-30% | >30% |
| CI reliability (7-day) | >95% | 80-95% | <80% |

## Bottleneck Categories

| Category | Signals |
|----------|---------|
| Review bottleneck | PRs >3 days awaiting review |
| CI bottleneck | Frequent failures or long runtimes |
| Stale work | Issues/PRs with no activity >14 days |
| Knowledge concentration | 80%+ commits from one contributor |
| Response lag | >24h average first response to new issues |
| Security debt | Dependabot alerts unresolved >7 days |

## Trend Classification

| Trend | Definition |
|-------|-----------|
| Improving | Score up 5+ points vs previous report |
| Stable | Score within 5 points of previous |
| Declining | Score down 5+ points vs previous |
| Recovering | Score up after 2+ consecutive Declining reports |

## Skill Location

`.github/skills/github-analytics-scoring/SKILL.md`
