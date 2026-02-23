---
name: github-analytics-scoring
description: Scoring formulas and analytical frameworks for GitHub workflow agents. Covers repository health scoring (0-100, A-F grades), priority scoring for issues/PRs/discussions, confidence levels for analytics findings, delta tracking (Fixed/New/Persistent/Regressed), velocity metrics, contributor metrics, bottleneck detection, and trend classification. Use when computing scores, tracking remediation progress, building prioritized dashboards, or detecting workflow bottlenecks.
---

# GitHub Analytics Scoring

## Repository Health Score

```text
Health Score = 100 - (sum of weighted penalties)

Penalties - CI & Reliability:
  Failing workflow, high confidence:         -10 points
  Flaky test (3+ failures/week):             - 5 points
  No CI configured:                          - 8 points

Penalties - Issues & PRs:
  Critical unresolved bug (P0):             -10 points
  Security alert (critical severity):       -10 points
  Security alert (high severity):           - 5 points
  PR open >14 days (stale):                 - 3 points each (max -9)
  Issue @mentioned, no response >7 days:    - 5 points each (max -10)
  >10 open issues with no labels/triage:    - 3 points

Penalties - Community Health:
  No CONTRIBUTING.md:                        - 5 points
  No CODE_OF_CONDUCT.md:                     - 3 points
  No branch protection on main:              - 5 points
  0 open "good first issue" labels:          - 2 points

Floor: 0 (minimum score)
```

## Score Grades

| Score | Grade | Meaning |
|-------|-------|---------|
| 90-100 | A | Excellent - healthy repo, minimal issues |
| 75-89 | B | Good - minor issues, well-managed |
| 50-74 | C | Needs attention - multiple signals requiring action |
| 25-49 | D | Poor - significant problems impacting velocity |
| 0-24 | F | Critical - major issues blocking team progress |

---

## Priority Scoring for Issues

Internally score each issue to determine sort order in dashboards and reports:

| Signal | Points |
|--------|--------|
| User @mentioned and hasn't responded | +5 |
| `P0`, `P1`, `critical`, `urgent`, `blocker` label | +3 |
| Tied to upcoming release milestone | +3 |
| New comments from others since user's last activity | +2 |
| High community interest (5+ positive reactions) | +2 |
| `bug` label | +1 |
| Assigned to user | +1 |
| Active related discussion thread | +1 |
| `wontfix`, `duplicate`, `question` label | -1 |
| No activity >14 days | -2 |

## Priority Scoring for Pull Requests

| Signal | Points |
|--------|--------|
| Review requested, user hasn't reviewed | +5 |
| PR has "changes requested" - author needs to update | +4 |
| PR is approved and ready to merge | +3 |
| Targets a release branch with upcoming deadline | +3 |
| CI failed on this PR | +2 |
| Merge conflicts present | +2 |
| High community interest (5+ positive reactions) | +2 |
| New comments on the PR | +1 |
| Active discussion thread linked to this PR | +1 |
| Draft PR | -1 |
| No activity >7 days | -2 |

## Priority Scoring for Discussions

| Signal | Points |
|--------|--------|
| User was @mentioned | +3 |
| High activity (10+ comments in 24h) | +2 |
| Linked to an issue/PR the user owns | +1 |
| No activity >7 days | -1 |

---

## Confidence Levels for Analytics Findings

Apply confidence levels to all bottleneck findings, health score deductions, and anomaly detections. Every finding in a report MUST include its confidence level.

| Level | When to Use | Impact on Report |
|-------|-------------|-----------------|
| **High** | Multiple corroborating signals, definitively observed (e.g., CI has failed 5 times this week, confirmed by logs) | Report as fact; recommend remediation |
| **Medium** | Found by one source, likely issue (e.g., PR open 14 days but author may be on leave) | Report as finding; suggest investigation |
| **Low** | Possible pattern, needs human review (e.g., velocity seems low but may be seasonal) | Flag as observation; don't deduct from score |

### Confidence Tag Format in Reports

```markdown
| Finding | Severity | Confidence | Recommendation |
|---------|----------|-----------|----------------|
| 3 PRs stale >14 days | High | **High** | Assign reviewers or close |
| Velocity 40% below 4-week avg | Medium | **Medium** | Verify - may be holiday period |
| Issue activity spike on Fridays | Low | **Low** | Monitor for 2 weeks before acting |
```

---

## Delta Tracking

When re-running an analysis against a previous report, classify every finding by change status:

| Status | Definition |
|--------|-----------|
| **Fixed** | Was in previous report; no longer present |
| **New** | Not in previous report; appears now |
| **Persistent** | Remains from previous report, unchanged |
| **Regressed** | Was previously fixed but has returned |

### Delta Report Section Format

```markdown
## Changes Since Last Report ({previous date})

| Change | Finding | Details |
|--------|---------|---------|
|  Fixed | 3 stale PRs resolved | Team cleared the backlog |
|  New | CI failing on main | Build broke in last 24h |
|  Persistent (#3) | Velocity 30% below baseline | Third consecutive week |
|  Regressed | Security alert reopened | lodash advisory re-filed |

**Progress:** {N} fixed, {M} new, {P} persistent, {Q} regressed
**Score change:** {current_score} ({+/-N} from {previous_score})
```

### Escalation Rule

If a finding is **Persistent for 3+ consecutive reports**, escalate:

>  **Escalation:** [{Finding}] has been present for {N} consecutive reports. Consider a team discussion or explicit ownership assignment to resolve this.

---

## Velocity Metrics

| Metric | Formula | Healthy | Warning | Critical |
|--------|---------|---------|---------|---------|
| PR merge rate | PRs merged / week | >3/week | 1-3/week | <1/week |
| Issue close rate | Issues closed / week | >5/week | 2-5/week | <2/week |
| Review turnaround | Avg hours PR open before first review | <24h | 24-72h | >72h |
| Issue response time | Avg hours until first team response | <8h | 8-48h | >48h |
| Stale PR ratio | PRs open >14 days / total open PRs | <10% | 10-30% | >30% |
| CI reliability | Passing runs / total runs (7-day) | >95% | 80-95% | <80% |

---

## Contributor Metrics

| Metric | Formula | Notes |
|--------|---------|-------|
| PR commit ratio | Commits / PRs merged | High ratio = large PRs, consider splitting |
| Review coverage | PRs reviewed by others / total PRs merged | Low = single-contributor bottleneck |
| First-time contributor rate | New contributors / total active contributors | Healthy community growth signal |
| Contributor retention | Active last month AND active this month / active last month | Engagement health |
| Bus factor | Min contributors whose departure halts 50%+ of commits | <3 is high risk |

---

## Bottleneck Categories

| Category | Signals | Example Finding |
|----------|---------|-----------------    |
| Review bottleneck | High PR open time, review-requested PRs >3 days | "4 PRs waiting for review >3 days - assign or redistribute" |
| CI bottleneck | Frequent failures, long runtimes | "Test suite 45min avg - 2x slower than 4-week average" |
| Stale work | Issues/PRs with no activity >14 days | "7 issues open >30 days with no recent comments" |
| Knowledge concentration | 80%+ commits from one contributor | "3 of 4 core modules have only one contributor - bus factor 1" |
| Response lag | >24h average first response to new issues | "Average first response: 38h - community may feel unsupported" |
| Security debt | Open Dependabot alerts unresolved >7 days | "2 critical alerts open for 12 days" |
| Release congestion | >10 merged PRs unreleased | "11 merged PRs awaiting release - coordinate cut date" |

---

## Trend Classification

| Trend | Definition |
|-------|-----------|
| Improving | Score increased 5+ points vs previous report |
| Stable | Score within 5 points of previous report |
| Declining | Score decreased 5+ points vs previous report |
| Recovering | Score increased after 2+ consecutive Declining reports |
| New | No previous report to compare |

---

## Scorecard Output Format

### Single Repo

```markdown
## Repository Health Score

| Metric | Value |
|--------|-------|
| Repo | [owner/repo](url) |
| Score | {0-100} |
| Grade | {A-F} |
| Trend | {Improving / Stable / Declining} |
| Open Security Alerts | {count} |
| Stale PRs (>14 days) | {count} |
| CI Reliability (7-day) | {%} |
| Unanswered @mentions | {count} |
```

### Multi-Repo Scorecard

```markdown
## Repository Health Scorecard

| Repo | Score | Grade | Trend | Critical Issues | Notes |
|------|-------|-------|-------|-----------------|-------|
| owner/repo-a | 88 | B | Improving | 0 | |
| owner/repo-b | 54 | C | Declining | 1 | Security alert unresolved |
| owner/repo-c | 22 | F | Stable | 3 | Review bottleneck + stale PRs |
| **Average** | **54.7** | **C** | - | **4** | |
```

---

## Sprint & Iteration Metrics

When project boards are configured, track sprint metrics:

| Metric | Formula |
|--------|---------|
| Sprint completion rate | Done items / total sprint items x 100 |
| Carryover rate | Items moved to next sprint / planned items |
| Cycle time | Average days from "In Progress" to "Done" |
| Throughput | Items completed per sprint |
| Blocked rate | Items in "Blocked" state / total in-progress |
