# my-issues

Show a prioritized cross-repo dashboard of all issues assigned to you, @mentioned in, or that you opened - with status signals, staleness indicators, and recommended actions.

## When to Use It

- Morning check to see what issues need your attention
- Before a standup to know your current workload
- Catching issues you were @mentioned in that need a reply
- Finding issues that have been stagnant and need a nudge

## How to Launch It

**In GitHub Copilot Chat:**

```text
/my-issues
```

With optional scope:

```text
/my-issues owner/repo
/my-issues org:myorg
/my-issues last 7 days
```

## What to Expect

1. **Query GitHub** - Finds all open issues assigned to you, @mentioned in the last 30 days (default), or opened by you that are still open
2. **Score each issue** - Priority scoring based on signals
3. **Group and display** - Organized by priority with actionable status signals

### Priority Signals

| Signal | Meaning |
|--------|---------|
| @mentioned | You are directly mentioned - needs reply |
| Release-bound | Linked to an upcoming milestone |
| Popular | Many reactions or recent comments |
| Action needed | Assigned to you with no recent activity |
| Stale | No activity in 14+ days |

### Priority Score Factors

| Factor | Score increase |
|--------|---------------|
| @mention in last 24 hours | +3 |
| Linked to upcoming release | +3 |
| Labeled P0 or P1 | +2 |
| 5+ recent comments | +2 |
| Assigned + no activity 7 days | +2 |

### Sample Output

```text
Your Issues (4 open across 2 repos)

#89  [auth-app] Login page flickering   @mentioned  P1  2 days old
#67  [auth-app] Add session timeout     Action needed   8 days old  -> Reply needed
#201 [docs-site] Update WCAG guide      Release-bound   3 days old
#155 [docs-site] Fix broken link        Stale           22 days old
```

## Example Variations

```text
/my-issues                            # All repos, last 30 days
/my-issues owner/repo                 # Scoped to one repo
/my-issues last 7 days                # Narrower window
/my-issues just assigned              # Only issues assigned to you
/my-issues just mentioned             # Only @mention items
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [triage](triage.md) - full triage of all open issues in a repo
- [issue-reply](issue-reply.md) - draft a reply to a specific issue
- [create-issue](create-issue.md) - create a new issue
- [daily-briefing](daily-briefing.md) - full cross-repo briefing including issues
