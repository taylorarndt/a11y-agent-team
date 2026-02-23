# onboard-repo

Run a first-time health check on a GitHub repository - produces a structured onboarding report covering code quality signals, open issues, CI health, contributor activity, documentation coverage, and accessibility label presence.

## When to Use It

- Joining a new project and wanting a quick orientation
- Inheriting a repository and assessing its health before work begins
- Reviewing an open-source repo before contributing
- Generating an onboarding artifact to share with new team members

## How to Launch It

**In GitHub Copilot Chat:**

```text
/onboard-repo owner/repo
```

## What to Expect

1. **Discover repo** - Reads README, license, description, topics, and contributors
2. **Analyze open issues** - Counts, labels, staleness, and response rate
3. **Check CI** - Workflow configs, last run status, and branch protection
4. **Review PR activity** - Merge rate, review cycle time, stale PRs
5. **Documentation check** - README, contributing guide, code of conduct, issue templates
6. **Save report** - Written to `.github/reviews/onboarding/onboard-{repo}-{date}.md` and `.html`

### Report Sections

| Section | What is covered |
|---------|----------------|
| Repository overview | Name, description, language, topics, license |
| Issue health | Open/closed ratio, avg response time, triage rate |
| PR health | Merge time, stale PRs, review coverage |
| CI/CD | Workflow names, success rate, branch protection |
| Documentation | Presence of README, CONTRIBUTING, CODE_OF_CONDUCT |
| Issue templates | Whether bug/feature templates exist |
| Accessibility labels | Whether a11y/accessibility labels are configured |
| Contributor activity | Active contributors, last commit date, bus factor signal |

### Sample Chat Summary

```text
Onboarding Report - owner/my-project

Repository overview: TypeScript, MIT license, 128 stars
Issues: 34 open, avg response time 4 days, 12 untriaged
PRs: 3 open, avg merge time 6 days, 0 stale
CI: build-and-test workflow - 94% passing rate last 30 days
Docs: README  | CONTRIBUTING  | CODE_OF_CONDUCT 
Templates: Bug  | Feature 
Accessibility labels: None found - consider adding "accessibility" label

Full report saved to .github/reviews/onboarding/onboard-my-project-2026-02-22.md
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/onboarding/onboard-{repo}-{date}.md` | Full onboarding report |
| `.github/reviews/onboarding/onboard-{repo}-{date}.html` | Accessible HTML version |

## Example Variations

```text
/onboard-repo owner/repo                   # Full health check
/onboard-repo owner/repo quick             # Chat summary only, no saved docs
/onboard-repo owner/repo ci only           # Focus on CI health
```

## Connected Agents

| Agent | Role |
|-------|------|
| daily-briefing agent | Executes this prompt |

## Related Prompts

- [daily-briefing](daily-briefing.md) - daily briefing for an already-known repo
- [triage](triage.md) - triage open issues after onboarding
- [ci-status](ci-status.md) - track CI health over time
