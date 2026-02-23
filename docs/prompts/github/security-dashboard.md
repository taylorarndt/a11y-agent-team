# security-dashboard

Show a security alert summary across repositories — Dependabot vulnerability alerts and Renovate PRs — grouped by severity with per-repo tables and remediation recommendations.

## When to Use It

- Weekly security check to find unaddressed Dependabot alerts
- Before a release to verify no critical vulnerabilities are unpatched
- Tracking which repos have the most unresolved security debt
- Getting a quick severity breakdown without navigating each repo's Security tab

## How to Launch It

**In GitHub Copilot Chat:**
```
/security-dashboard owner/repo
```

For an org:
```
/security-dashboard org:myorg
```

## What to Expect

1. **Fetch Dependabot alerts** — Queries open vulnerability alerts with severity, package, and CVE
2. **Fetch security-related PRs** — Finds open Dependabot and Renovate PRs
3. **Group by severity** — Critical → High → Medium → Low → Pending
4. **Render per-repo table** — Each repo shows counts by severity and oldest unfixed alert
5. **Top recommendations** — Calls out critical and high-severity items that need urgent action

### Severity Levels

| Level | CVSS range | Action |
|-------|-----------|--------|
| Critical | 9.0–10.0 | Fix immediately |
| High | 7.0–8.9 | Fix this sprint |
| Medium | 4.0–6.9 | Plan for upcoming sprint |
| Low | 0.1–3.9 | Address when possible |

### Sample Output

```
Security Dashboard — org:myorg (2 repos)
─────────────────────────────────────────
Repo                  Critical  High  Medium  Low  Pending PRs
────────────────────  ────────  ────  ──────  ───  ───────────
owner/auth-app        1         2     4       0    3 Dependabot PRs
owner/docs-site       0         0     1       2    0

⚠ Critical — owner/auth-app
  lodash < 4.17.21 — Prototype pollution (CVE-2021-23337)
  Opened 14 days ago — no action taken

High — owner/auth-app  
  semver < 5.7.2 — ReDoS vulnerability (CVE-2022-25883)
  jsonwebtoken ≤ 8.5.1 — Secret disclosure (CVE-2022-23529)
  Pending Dependabot PR: #104
```

### Dependabot PR Status

The agent also shows:
- Open Dependabot or Renovate PRs and their CI status
- PRs where auto-merge is enabled vs. blocked
- Oldest open security PR (a PR older than 30 days is flagged)

## Example Variations

```
/security-dashboard owner/repo                # One repo
/security-dashboard org:myorg                 # All org repos
/security-dashboard critical only             # Only critical alerts
/security-dashboard owner/repo with prs       # Include PR list
```

## Connected Agents

| Agent | Role |
|-------|------|
| daily-briefing agent | Executes this prompt |

## Related Prompts

- [daily-briefing](daily-briefing.md) — full briefing that includes security summary
- [ci-status](ci-status.md) — CI health including security scan workflows
