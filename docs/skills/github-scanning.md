# github-scanning Skill

> GitHub data collection patterns for workflow agents. Covers search query construction by intent, date range handling, repository scope narrowing, preferences.md integration, cross-repo intelligence, parallel stream collection model, and auto-recovery for empty results.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [github-hub](../agents/github-hub.md) | Routing and repo-wide discovery |
| [daily-briefing](../agents/daily-briefing.md) | Multi-stream parallel collection |
| [issue-tracker](../agents/issue-tracker.md) | Issue search queries |
| [pr-review](../agents/pr-review.md) | Pull request search queries |
| [analytics](../agents/analytics.md) | Repository-level data collection |
| [insiders-a11y-tracker](../agents/insiders-a11y-tracker.md) | Accessibility commit and release tracking |

## Search Query Patterns by Intent

### Issues

| Intent | Query Pattern |
|--------|--------------|
| Assigned to you | `is:open assignee:USERNAME` |
| @mentioned | `is:open mentions:USERNAME` |
| Authored by you | `is:open author:USERNAME` |
| Specific repo | `repo:owner/repo is:open` |
| Org-wide | `org:ORGNAME is:open` |
| Closed (for recap) | `is:closed author:USERNAME` |

### Pull Requests

| Intent | Query Pattern |
|--------|--------------|
| Awaiting your review | `review-requested:USERNAME state:open` |
| Your open PRs | `author:USERNAME state:open` |
| You reviewed, check updates | `reviewed-by:USERNAME state:open` |
| Org-wide | `org:ORGNAME state:open` |

### Date Range Handling

| User Says | GitHub Qualifier |
|-----------|-----------------|
| "last week" | `created:>YYYY-MM-DD` (7 days ago) |
| "this month" | `created:>YYYY-MM-01` |
| "today" | `closed:YYYY-MM-DD` |
| "between X and Y" | `created:X..Y` |
| Not specified | `updated:>YYYY-MM-DD` (30 days) - mention the assumption |

## Scope Narrowing

| Scope | Qualifier |
|-------|-----------|
| Single repo | `repo:owner/name` |
| All org repos | `org:orgname` |
| All user repos | `user:username` |
| Everything (default) | No qualifier |

## Preferences File Integration

Read `.github/agents/preferences.md` before searching. Key settings:

| Preference Key | Effect |
|----------------|--------|
| `repos.discovery` | Default scope: `all` / `starred` / `owned` / `configured` / `workspace` |
| `repos.include` | Always include these repos |
| `repos.exclude` | Always skip these repos |
| `repos.overrides` | Per-repo tracking toggles and label/path filters |
| `search.default_window` | Default time range when user doesn't specify |
| `briefing.sections` | Which sections to include in the daily briefing |

## Parallel Stream Collection

Run independent streams simultaneously. Don't serialize calls with no dependencies.

### Daily Briefing - 3 Batches

| Batch | Streams (run in parallel) |
|-------|--------------------------|
| 1 | Issues + Pull Requests + Releases + Accessibility updates |
| 2 | Discussions + CI/CD health + Security alerts |
| 3 | Project board status + Recently closed/merged work |

Batch 2 can overlap with Batch 3. Both depend on Batch 1 completing first.

### Analytics - 2 Batches

| Batch | Streams |
|-------|---------|
| 1 | Closed PRs + Opened issues + CI runs + Security alerts (all independent) |
| 2 | Health score + Velocity + Bottleneck detection (depend on Batch 1) |

### Announcement Template

```text
 Running N searches in parallel...
 Batch 1 complete - X items found

 Running N additional searches...
 All complete - Y items collected
```

## Cross-Repo Intelligence

When results arrive from multiple repos, surface these patterns:

| Pattern | Action |
|---------|--------|
| Cross-repo references | Fetch referenced item and surface both together |
| Shared label patterns | Group P0 items from different repos |
| Merged PR not yet released | Note: "PR #N is merged but not in any release yet" |
| Issue with merged fix PR | Flag: "This may be resolved - PR #N that closes it was merged on {date}" |

## Auto-Recovery for Empty Results

Never return 0 results without trying at least one broader query first:

1. Remove date qualifier
2. Expand scope (add `org:` or remove `repo:` qualifier)
3. Remove label filters
4. Report 0 only after all three attempts return nothing

Always tell the user what was broadened: _"No results in last 7 days - broadened to last 30 days and found 3 items."_

## Pagination Rules

- Batch results in groups of 10
- Always disclose total count: _"Showing 10 of 47. Load more?"_
- Never silently truncate

## Deduplication

When the same item appears in multiple streams, show it once with all signals combined:  
_"Assigned, @mentioned"_ - priority = highest-scoring signal only, not additive.

## Skill Location

`.github/skills/github-scanning/SKILL.md`
