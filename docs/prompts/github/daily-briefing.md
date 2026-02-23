# daily-briefing

Generate a comprehensive daily GitHub briefing across all your repos. Covers everything that needs your attention — issues, PRs, releases, CI status, notifications, reactions, and accessibility updates — saved as both markdown and HTML.

## When to Use It

- Every morning, to start your day with a prioritized picture of what needs attention
- After time away (vacation, weekend) to catch up quickly
- For an afternoon update to see what changed since morning
- For a weekly summary with trend reflection

## How to Launch It

**In GitHub Copilot Chat:**
```
/daily-briefing
```

With optional scope:
```
/daily-briefing morning
/daily-briefing afternoon update
/daily-briefing weekly
/daily-briefing owner/my-repo
/daily-briefing just PRs
/daily-briefing quick
```

## What to Expect

### Scope Interpretation

| Input | Behavior |
|-------|----------|
| (none) / `morning` | Full briefing, last 24 hours, all repos |
| `afternoon update` | Incremental update to today's existing briefing |
| `weekly` | Extended 7-day report with reflection |
| Repo name | Scope to that specific repo |
| `org:orgname` | Scope to all repos in an org |
| `just PRs` / `just issues` | Only that category |
| `quick` | Chat-only summary, no saved documents |

### Data Collected

The agent pulls from all enabled streams in parallel:
- Open issues with @mentions, reactions, and release context
- Open PRs with review status, CI state, and merge readiness
- Recent releases and draft releases
- Active GitHub Discussions
- CI/CD workflow health
- Dependabot security alerts
- Accessibility label updates (if configured)

### Output Documents

Both versions are saved to `.github/reviews/briefings/`:

```
briefing-2026-02-22.md
briefing-2026-02-22.html
```

The HTML version is screen-reader-accessible with ARIA landmarks, proper heading hierarchy, and skip navigation.

### Incremental Updates

If a briefing already exists for today, running `/daily-briefing afternoon update` appends new items with **NEW** markers instead of replacing the whole document.

### Chat Summary

After saving the documents, the agent presents a compact summary in chat:

```
Morning Briefing — Feb 22, 2026

3 PRs need your review (1 from @alice is 4 days old)
2 issues were @mentioned with you
1 critical Dependabot alert in owner/repo
CI is failing on feature/auth branch
2 new releases published yesterday

Full briefing saved to .github/reviews/briefings/briefing-2026-02-22.md
```

## Repo Discovery

The agent respects scope configuration from `.github/agents/preferences.md`. If no preferences exist, it scans all repos the authenticated user has access to.

## Example Variations

```
/daily-briefing                               # Full morning briefing
/daily-briefing afternoon update              # Add what changed since morning
/daily-briefing weekly                        # 7-day summary for Monday planning
/daily-briefing owner/my-project             # Focus on one repo
/daily-briefing quick                         # Just the chat summary, no files
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/briefings/briefing-{date}.md` | Full briefing in markdown |
| `.github/reviews/briefings/briefing-{date}.html` | Accessible HTML version |

## Connected Agents

| Agent | Role |
|-------|------|
| [daily-briefing agent](../../agents/web-accessibility-wizard.md) | Executes this prompt |

## Related Prompts

- [my-prs](my-prs.md) — focused PR dashboard
- [my-issues](my-issues.md) — focused issue dashboard
- [ci-status](ci-status.md) — CI/CD health only
- [security-dashboard](security-dashboard.md) — Dependabot alerts only
- [notifications](notifications.md) — manage GitHub notifications
