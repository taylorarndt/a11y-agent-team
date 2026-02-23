# analytics - Team Velocity and Repository Health

> Turn raw GitHub activity into actionable insight. Measures review turnaround, issue resolution velocity, code churn hotspots, contributor load distribution, and team health - then scores everything 0-100 with an A-F grade and saves a full dashboard to your workspace.

---

## What This Agent Is For

The analytics agent answers the questions team leads and maintainers ask most often but least easily:

- *Who is reviewing everything?* (and is it always the same person?)
- *How long does it take us to merge a PR after approval?*
- *Which files break most often?*
- *Is anyone on the team overloaded?*
- *Are we getting faster or slower?*

It collects data across the GitHub API - PRs, reviews, issues, comments, commits - then scores your team's health against threshold tables to produce an objective grade. The output is a dual Markdown + HTML document you can drop into a team retrospective, status page, or portfolio review.

Use analytics when:

- You want a monthly or quarterly health report
- You are concerned someone is carrying too much review load
- You want to find which parts of the codebase have the highest churn and need refactoring attention
- You want to make a case for hiring or process change with data behind it
- You want to track whether a process improvement (faster reviews, more contributors) is actually working

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@analytics team dashboard
@analytics my stats this month
@analytics who is overloaded?
@analytics review turnaround times for the last 30 days
@analytics code hotspots - which files change most?
```

### Claude Code (Terminal)

```bash
/analytics team dashboard
/analytics review turnaround
/analytics bottleneck detection
/analytics contributor activity last quarter
```

### Via GitHub Hub

```text
@github-hub team analytics
@github-hub show me team velocity
@github-hub generate health report
```

---

## Language That Works

<details>
<summary>Expand language reference table</summary>

| What you say | What it does |
|-------------|--------------|
| `team dashboard` | Full health report across all configured repos |
| `my stats this month` | Your personal contribution metrics |
| `review turnaround times` | Median time from PR submission to first review |
| `who is overloaded?` | Flag contributors with PR/review load >2x the team median |
| `code hotspots` / `churn analysis` | Files with anomalous commit frequency |
| `bottleneck detection` | Find process steps with non-linear wait time |
| `contribution activity` | Commits, PRs, reviews, comments per contributor |
| `issue resolution velocity` | Median issue lifecycle start-to-close |
| `compare Sarah and Alex` | Side-by-side contributor metric comparison |
| `30-day trend` / `quarterly report` | Time-bounded analysis window |
| `health score` / `health grade` | Summary scorecard with A-F grade |

</details>

---

## What to Expect - Step by Step

### Team Dashboard

1. **Scope establishment.** Reads `preferences.md` to find your repos and team members. Defaults to workspace repo if not configured.

2. **Parallel data collection.** All streams run simultaneously:

   ```text
    Collecting analytics across 3 repos...
    PR velocity (84 PRs, last 30d) - loaded
    Review turnaround (avg 1.4d, median 0.8d) - loaded
    Issue resolution (avg 6.2d close time) - loaded
    Contributor load (8 active contributors) - loaded
    Code churn (top 12 hotspot files) - loaded
    Bottleneck detection - flagging 2 anomalies
   ```

3. **Health score computation.** Each metric area is scored 0-100:
   - Review turnaround: 100 - penalty for slow reviews
   - PR merge rate: based on ratio of merged vs. abandoned PRs
   - Issue responsiveness: time to first response
   - Load distribution: Gini coefficient of contribution load
   - Code health: churn rate and test coverage signals

4. **Overall grade.** Scores are weighted into a single health score:

   ```text
   Repo health score: 74 / 100  ->  Grade: C+
   
   Review turnaround:    88 / 100  (B+)
   PR merge rate:        72 / 100  (C+)
   Issue responsive:     61 / 100  (D)
   Load distribution:    80 / 100  (B)
   Code health:          71 / 100  (C+)
   ```

5. **Bottleneck report.** For any metric below 70, the agent identifies the likely cause and suggests a focused action:

   > **Issue Responsiveness - 61/100 (D)**
   > Median first-response time is 8.4 days. 14 issues have no response in 30+ days. Recommended action: reserve 30 minutes per week for issue triage, or route all `bug` issues to `@alice` who has the fastest response rate on the team.

6. **Saves dual output:** Markdown and accessible HTML dashboard.

### Review Turnaround Analysis

1. Pulls all merged PRs in the date range
2. Measures: open -> first review, first review -> approval, approval -> merge
3. Flags outlier PRs (>3x median at any stage)
4. Identifies reviewers who have the fastest and slowest turnaround
5. Shows trend lines: is turnaround improving or degrading?

### Contributor Load Analysis ("Who is overloaded?")

1. Counts PRs authored, PRs reviewed, issues commented, commits pushed per contributor
2. Normalizes by time active in the period
3. Computes team median per metric
4. Flags anyone >2x the median on any dimension
5. Shows the imbalance:

   ```text
    Overload signal: @bob reviewed 34 PRs vs. team median of 12
   This pattern has persisted for 3 consecutive months.
   ```

---

## Health Scoring Details

<details>
<summary>Expand health scoring reference (grade scale + penalty factors)</summary>

### Grade Scale

| Score | Grade | Interpretation |
|-------|-------|----------------|
| 90-100 | A | Excellent - team is performing at high velocity |
| 80-89 | B | Good - minor inefficiencies but healthy overall |
| 70-79 | C | Adequate - noticeable pressure points |
| 60-69 | D | Problematic - bottlenecks affecting output |
| Below 60 | F | Critical - systemic issues need addressing |

### Penalty Factors (lower your score)

| Factor | Penalty |
|--------|---------|
| Review turnaround >5d | -15 per day over threshold |
| >30% of PRs abandoned | -25 |
| First issue response >7d | -20 |
| One contributor >50% of all reviews | -30 (single point of failure) |
| Hotspot file >20% of all commits | -10 |

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Quick Queries

```text
@analytics what is our current health score?
@analytics how long does it take us to merge a PR?
@analytics who reviewed the most PRs this month?
@analytics which issues are taking longest to close?
```

### Deep Analysis

```text
@analytics full team dashboard for Q3
@analytics bottleneck report - where are we losing time?
@analytics contributor activity for @alice this quarter
@analytics churn analysis - which files should we refactor?
@analytics compare this month to last month
```

### Personal Stats

```text
@analytics my contribution stats this month
@analytics how fast am I reviewing PRs compared to the team average?
@analytics what PRs have I reviewed in the last 2 weeks?
```

</details>

---

## Output Files

<details>
<summary>Expand output file details</summary>

| File | Location | Contents |
|------|----------|----------|
| `ANALYTICS-{date}.md` | workspace root | Full analytics dashboard |
| `ANALYTICS-{date}.html` | workspace root | Accessible HTML version |

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| Include in daily briefing | Add health score to morning summary | [daily-briefing](daily-briefing.md) |
| Drill into a specific PR | Investigate a large PR caught in churn | [pr-review](pr-review.md) |
| Action on overloaded contributor | Redistribute or investigate issues | [issue-tracker](issue-tracker.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- All scores are shown with the specific signals that drove them - no opaque grades
- Flagging an individual as "overloaded" always pairs with a note that this is a systemic signal, not a performance issue
- Data is scoped to the configured time window (default: last 30 days)
- Trend comparisons require at least 2 complete time periods of data; otherwise reports "insufficient history"
- Does not make hiring or firing recommendations - suggests process interventions only

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"The score seems too low / too high."**
Scores are relative to threshold tables. If your team is small or in early stages, the load distribution penalty can dominate. Say: "explain the score breakdown" to see exactly which factors pulled the grade down.

**"It only analyzed one repo."**
Add `repos.discovery: all` to `preferences.md` to have it span all your repos. Or name repos explicitly: "analyze taylorarndt/a11y-agent-team and taylorarndt/my-other-repo."

**"The contributor list is missing someone."**
GitHub search is commit-based. If a team member only reviewed and never committed in the window, they may not appear. Add them to `preferences.md` under `team.members` to include them explicitly.

</details>
