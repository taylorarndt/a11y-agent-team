# ci-status

Show a CI/CD health table for one or more repositories - failing workflows, long-running jobs, and flaky tests with historical context.

## When to Use It

- Morning check to spot failing CI before starting work
- Before merging a PR to confirm all checks are green
- Investigating why the build is taking longer than usual
- Finding tests that have been flaky over the past week

## How to Launch It

**In GitHub Copilot Chat:**

```text
/ci-status owner/repo
```

With multiple repos or an org:

```text
/ci-status owner/repo-1 owner/repo-2
/ci-status org:myorg
```

## What to Expect

1. **Query workflow runs** - Fetches recent workflow runs (default: last 24 hours) for each repo
2. **Classify health** - Green / Yellow / Red per workflow based on run history
3. **Flag issues** - Failing, long-running (30-min threshold), and flaky (3+ failures in 7 days)
4. **Render table** - Per-repo, per-workflow summary with age of failure and most recent run

### Health Classification

| Status | Criteria |
|--------|---------|
| Green  | All recent runs passed |
| Yellow  | Degraded - some passes, some failures; or slow |
| Red  | Last run failed |
| Flaky  | 3 or more failures in last 7 days with passes in between |

### Thresholds

| Signal | Threshold |
|--------|-----------|
| Long-running job | 30+ minutes |
| Flaky detection | 3+ failures in 7 days, with at least 1 passing run |
| Stale CI date | Last run more than 7 days ago |

### Sample Output

```text
CI Status - owner/repo (last 24 hours)

Workflow             Branch     Status  Duration  Last run
          
build-and-test       main              4m 22s    2 hours ago
build-and-test       feature/a         3m 48s    1 hour ago  -> E2E tests
lint                 main              1m 10s    2 hours ago
deploy-preview       main              34m 00s   3 hours ago -> Slow build
security-scan        main              2m 15s    5 hours ago -> 4 fails in 7d
```

### Flaky Test Detail

When a flaky workflow is detected, the agent lists the specific failing tests and dates:

```text
 Flaky: security-scan (4 failures in 7 days)
  Feb 20: FAILED - CVE scan timed out
  Feb 18: passed
  Feb 17: FAILED - same CVE scan timeout
  Feb 15: passed
  Feb 14: FAILED
```

## Example Variations

```text
/ci-status owner/repo                    # Default 24-hour view
/ci-status owner/repo last 7 days        # Extended window
/ci-status owner/repo failing only       # Only show red/flaky
/ci-status org:myorg                     # All org repos
```

## Connected Agents

| Agent | Role |
|-------|------|
| daily-briefing agent | Executes this prompt |

## Related Prompts

- [daily-briefing](daily-briefing.md) - full briefing including CI status
- [security-dashboard](security-dashboard.md) - security alert focus
