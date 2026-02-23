# sprint-review

Generate an end-of-sprint analytics report - completed, carryover, new, and blocked items classified by outcome - with velocity metrics and retrospective prompts.

## When to Use It

- End of sprint - generating the sprint review artifact before the retrospective meeting
- Sprint demo preparation - knowing what shipped vs. what did not
- Velocity tracking over multiple sprints
- Discovering patterns in why items are carried over

## How to Launch It

**In GitHub Copilot Chat:**

```text
/sprint-review owner/repo
```

With sprint boundary:

```text
/sprint-review owner/repo sprint:12
/sprint-review owner/repo milestone:"Sprint 12"
/sprint-review owner/repo since 2026-02-10 until 2026-02-22
```

## What to Expect

1. **Determine sprint boundary** - Reads milestone dates or uses date range
2. **Classify every item** - Completed / Carryover / New (added mid-sprint) / Blocker
3. **Compute velocity** - Story points or issue count, comparison to previous sprint
4. **Generate retrospective prompts** - Auto-generated based on blockers and carryovers
5. **Save report** - Written to `.github/reviews/analytics/sprint-review-{date}.md` and `.html`

### Item Classifications

| Classification | Criteria |
|---------------|---------|
| Completed | Closed or merged within the sprint window |
| Carryover | Was in progress at sprint start, not closed by end |
| New | Added after sprint started (scope creep signal) |
| Blocker | Was blocked at any point during the sprint |

### Velocity Table

```text
Sprint Velocity - Sprint 12 vs. Sprint 11

Metric                   Sprint 12  Sprint 11  Change
       
Issues completed         9          7          Up +29%
PRs merged               12         10         Up +20%
Carryover count          3          5          Up improved
Avg cycle time           3.2d       4.1d       Up faster
Scope added mid-sprint   2          1          -> watch
```

### Retrospective Prompts

Based on the data, the agent generates 3-5 retrospective starting points:

```text
Retrospective prompts for Sprint 12:

1. #98 "Fix pagination" carried over for 2 sprints.
   What is preventing completion?

2. 2 items added mid-sprint. Was scope well-defined at start?

3. Cycle time improved from 4.1d to 3.2d. What is working well?
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/analytics/sprint-review-{date}.md` | Sprint review report |
| `.github/reviews/analytics/sprint-review-{date}.html` | Accessible HTML version |

## Example Variations

```text
/sprint-review owner/repo                   # Auto-detect current sprint
/sprint-review owner/repo sprint:12         # Named sprint
/sprint-review owner/repo last 2 weeks      # Date-range sprint
/sprint-review owner/repo demo mode         # Summary for demo, no full report
```

## Connected Agents

| Agent | Role |
|-------|------|
| analytics agent | Executes this prompt |

## Related Prompts

- [team-dashboard](team-dashboard.md) - team-level contributor metrics
- [my-stats](my-stats.md) - individual stats for the sprint
- [project-status](project-status.md) - live project board state mid-sprint
