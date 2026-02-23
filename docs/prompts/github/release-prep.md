# release-prep

Walk through an 8-step guided release readiness workflow — milestone closure, PR inclusion, CI verification, security checks, release notes, checklist sign-off, and saved documentation.

## When to Use It

- Planning a release and want a checklist-driven process
- Leading a release review meeting and need a structured walkthrough
- Ensuring all release gates are satisfied before tagging
- Generating a release prep artifact for audit trails

## How to Launch It

**In GitHub Copilot Chat:**
```
/release-prep owner/repo v2.1.0
```

Or without a version to auto-detect:
```
/release-prep owner/repo
```

## What to Expect

The agent walks through 8 steps in sequence, completing each one and confirming before moving to the next.

### Step 1: Milestone Verification

Check if a milestone for the target version exists and is properly configured:
- Issue count open vs. closed
- Any overdue issues that block the milestone
- Recommendation: close, defer, or block the release

### Step 2: PR Inclusion Review

Confirm all intended PRs are merged and nothing critical is still open:
- PRs merged since last release
- Open PRs targeting this release
- PRs in review that may or may not make the cut

### Step 3: CI Verification

Confirm all CI checks are green on the release branch or `main`:
- All required workflow runs passing
- No flaky tests in the last 7 days
- Branch protection status

### Step 4: Security Check

Verify no unpatched critical or high vulnerabilities:
- Open Dependabot alerts by severity
- Pending security-related PRs
- Any known CVEs in dependencies

### Step 5: Release Notes Draft

Generate or review release notes (delegates to `/draft-release`):
- Auto-categorized changes
- Breaking changes prominently surfaced
- Upgrade instructions if needed

### Step 6: Checklist Sign-off

Interactive sign-off checklist:
```
Release Checklist — v2.1.0:
  [ ] Milestone closed
  [ ] All required PRs merged
  [ ] CI green on main
  [ ] No critical Dependabot alerts
  [ ] Release notes written
  [ ] CHANGELOG.md updated
  [ ] Stakeholders notified
```

### Step 7: Save Documentation

Both `.md` and `.html` saved to `.github/reviews/releases/release-prep-{version}-{date}.*`:
- Full checklist sign-off state
- Included PR list
- CI and security summary

### Step 8: Next Actions

After sign-off:
- Tag and publish GitHub Release
- Link release to milestone
- Announce (if configured)

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/releases/release-notes-{version}-{date}.md` | Release notes |
| `.github/reviews/releases/release-notes-{version}-{date}.html` | Accessible HTML version |

## Example Variations

```
/release-prep owner/repo v2.1.0              # Full guided workflow
/release-prep owner/repo                     # Auto-detect version
/release-prep owner/repo step 4              # Jump to security step
```

## Connected Agents

| Agent | Role |
|-------|------|
| daily-briefing agent | Executes this prompt |

## Related Prompts

- [draft-release](draft-release.md) — generate release notes only
- [ci-status](ci-status.md) — CI status check during step 3
- [security-dashboard](security-dashboard.md) — security check during step 4
