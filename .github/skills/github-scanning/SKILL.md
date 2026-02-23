---
name: github-scanning
description: GitHub data collection patterns for workflow agents. Covers search query construction by intent, date range handling, repository scope narrowing, preferences.md integration, cross-repo intelligence, parallel stream collection model, and auto-recovery for empty results. Use when building agents that search GitHub for issues, PRs, discussions, releases, security alerts, or CI status.
---

# GitHub Scanning

## Search Query Patterns by Intent

### Issues

| Intent | Query Pattern | Scope |
|--------|--------------|-------|
| Assigned to you | `is:open assignee:USERNAME` | All repos |
| You were @mentioned | `is:open mentions:USERNAME` | All repos |
| Authored by you | `is:open author:USERNAME` | All repos |
| Specific repo | `repo:owner/repo is:open` | Single repo |
| By keyword | `{keyword} is:open` | All repos |
| Org-wide | `org:ORGNAME is:open` | Org repos |
| Closed (for recap) | `is:closed author:USERNAME` | All repos |

### Pull Requests

| Intent | Query Pattern | Scope |
|--------|--------------|-------|
| Awaiting your review | `review-requested:USERNAME state:open` | All repos |
| Your open PRs | `author:USERNAME state:open` | All repos |
| Assigned to you | `assignee:USERNAME state:open` | All repos |
| You reviewed, check for updates | `reviewed-by:USERNAME state:open` | All repos |
| Specific PR | Fetch directly with owner, repo, number | Single repo |
| Org-wide | `org:ORGNAME state:open` | Org repos |

### Discussions

| Intent | Action |
|--------|--------|
| You're mentioned | Search with `mentions:USERNAME` |
| You're participating | Search discussions you've commented on |
| High activity | Filter for 10+ comments in last 24h |
| Linked to your issues | Scan description/comments for issue references |

### Releases

- Use `github_list_releases` per repo — check for recent, draft, and pre-releases.
- Cross-reference merged PRs against release notes to identify unreleased work.
- Compare issue milestones against release schedules to flag upcoming deadline items.

### Security

- Dependabot alerts: critical and high severity across monitored repos.
- Security advisories affecting dependencies.
- Pending dependency update PRs from `dependabot[bot]` or `renovate[bot]`.

### CI/CD

- Fetch recent workflow runs — identify failing workflows, long jobs, and flaky tests.
- For failing workflows: note repo, workflow name, branch, failure reason, and link to run.
- Cross-reference user's open PRs against CI results.

---

## Date Range Handling

Convert natural language to GitHub query qualifiers:

| User Says | GitHub Qualifier |
|-----------|-----------------|
| "last week" | `created:>YYYY-MM-DD` (7 days ago) |
| "this month" | `created:>YYYY-MM-01` |
| "today" | `closed:YYYY-MM-DD` |
| "this week" | `closed:>YYYY-MM-DD` (7 days ago) |
| "between X and Y" | `created:X..Y` |
| Not specified | Use `search.default_window` from preferences (default: `updated:>YYYY-MM-DD` 30 days) — mention this assumption |
| "for current month" (a11y tracker) | `milestone:"{Month} {Year}"` |

---

## Scope Narrowing

Add qualifiers to narrow by scope when the user specifies one:

| Scope | Qualifier |
|-------|-----------|
| Single repo | `repo:owner/name` |
| All org repos | `org:orgname` |
| All repos by user | `user:username` |
| Everything (default) | No qualifier — searches all accessible repos |

---

## Preferences File Integration

Read `.github/agents/preferences.md` and apply these filters before and after searching:

1. **`repos.discovery`** — determines the default search scope (all / starred / owned / configured / workspace).
2. **`repos.include`** — always include these repos even in restricted modes.
3. **`repos.exclude`** — skip these repos in all searches.
4. **`repos.overrides`** — per-repo settings:
   - `track.issues: false` → skip issue searches for this repo
   - `track.pull_requests: false` → skip PR searches for this repo
   - `track.discussions: false` → skip discussions for this repo
   - `track.releases: false` → skip release checks for this repo
   - `track.security: false` → skip security alerts for this repo
   - `track.ci: false` → skip CI status for this repo
   - `labels.include` / `labels.exclude` → filter results by label
   - `paths` → only trigger for changes touching these file paths (for PRs/CI)
   - `assignees` → filter to specific assignees (empty = all)
5. **`search.default_window`** — default time range if the user doesn't specify one.
6. **`briefing.sections`** — which sections to include in the daily briefing.
7. **`accessibility_tracking`** — config for the a11y tracker (repos, labels, channels).

---

## Cross-Repo Intelligence

When results arrive from different repos, look for and surface these patterns:

| Pattern | Action |
|---------|--------|
| Cross-repo references | When issue A contains `owner/repo#N`, fetch and surface item N |
| Shared label patterns | Group items in different repos tagged `P0` together in triage |
| Related PRs in different repos | Flag: _"This issue depends on PR #N in repo-B which is still open"_ |
| Merged PR not yet released | Note: _"Your PR #N is merged but not in any release yet"_ |
| Issue with merged fix PR | Flag: _"This may be resolved — PR #N that closes it was merged on {date}"_ |
| Branch naming patterns | Group PRs in different repos using the same branch naming convention |

---

## Parallel Stream Collection Model

For agents that collect from multiple data streams, run independent streams simultaneously. Don't serialize operations with no dependencies.

### Example: Daily Briefing — 3 Parallel Batches

**Batch 1 — fully independent, run simultaneously:**
- Issues (assigned, mentioned, authored)
- Pull requests (review-requested, authored)
- Releases & deployments
- Accessibility updates

**Batch 2 — run after Batch 1 (CI needs PR list from Batch 1):**
- GitHub Discussions
- CI/CD health (cross-references PR list)
- Security alerts

**Batch 3 — can overlap with Batch 2:**
- Project board status
- Recently closed/merged work

### Example: Analytics — 2 Parallel Batches

**Batch 1 — collection (all independent):**
- Closed/merged PRs in period
- Opened issues in period
- CI workflow runs in period
- Security alerts in period

**Batch 2 — analysis (depends on Batch 1 data):**
- Health score computation
- Velocity metrics calculation
- Bottleneck detection

### Announcement Template for Parallel Work

```
⚙️ Running {N} searches in parallel… ({scope})
✅ Batch 1 complete — {X} items found

⚙️ Running {N} additional searches…
✅ Batch 2 complete — {Y} items found

⚙️ Scoring and prioritizing…
✅ Done — {Z} items need action, {W} to monitor
```

---

## Auto-Recovery for Empty Results

If a search returns 0 results:

1. Automatically broaden: remove date filter, expand scope to `all`, or remove label filters.
2. Tell the user exactly what changed: _"No results in last 7 days — broadened to last 30 days and found 3 items."_
3. Never return 0 results without trying at least one broader query first.

Recovery cascade:
1. First try: Remove date qualifier
2. Second try: Expand scope (add org: or remove repo: qualifier)
3. Third try: Remove label filters
4. Report 0 results only if all three attempts return nothing

---

## Pagination

- Paginate large result sets in batches of 10.
- Ask before loading more: _"Showing 10 of 47. Load more?"_
- Never silently truncate results — always disclose the total count.

---

## Result Deduplication

When the same item appears in multiple searches (e.g., an issue you're both assigned to AND mentioned in):
- Show it once, with all context combined.
- In the Signal column, combine signals: _"Assigned • @mentioned"_.
- In priority calculations, apply the highest-scoring signal, not additive.

---

## Rate Limiting

- If rate-limited (403/429), tell the user the reset time in one sentence.
- Do not retry the same query — wait if reset is <60 seconds; otherwise report and move on.
- For multi-stream collection, skip rate-limited streams and complete them in a follow-up.
