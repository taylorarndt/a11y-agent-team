---
name: release-prep
description: "Complete release preparation workflow -- milestone check, open PRs review, release notes, changelog, and readiness checklist"
agent: daily-briefing
tools:
  - github/*
  - createFile
  - createDirectory
  - editFiles
  - ask_questions
---

Run a complete release preparation workflow. This guides you through every step needed before publishing a release.

${input:details:Required: repo name and target version (e.g. 'owner/repo v2.0.0')}

## Workflow Steps

This is a multi-step guided workflow. The agent runs each step and presents results before moving to the next.

### Step 1: Milestone Check
- Fetch the milestone for the target version
- List all items: closed (done), open (remaining), and their status
- Flag blockers: open P0/P1 items, items with no assignee

### Step 2: Open PRs Review
- List all PRs targeting the release branch or milestone
- For each: review status, CI status, merge readiness, and age
- Flag: PRs with failing CI, no reviews, or merge conflicts

### Step 3: CI/CD Health
- Check workflow status on the release branch
- Flag any failing tests or flaky tests
- Verify the build pipeline is green

### Step 4: Security Check
- Check for open Dependabot alerts (critical/high)
- Verify no known vulnerabilities in dependencies shipping with this release
- List any security-related PRs not yet merged

### Step 5: Draft Release Notes
- Collect all merged PRs since last release
- Auto-categorize: Breaking Changes, Features, Bug Fixes, Performance, Dependencies, Other
- Generate conventional-commit-style changelog

### Step 6: Readiness Checklist
Generate a comprehensive checklist:
- [ ] All milestone items closed or deferred
- [ ] All PRs merged or explicitly excluded
- [ ] CI passing on release branch
- [ ] No critical/high Dependabot alerts
- [ ] Release notes reviewed
- [ ] Changelog generated
- [ ] Version bumped (if applicable)

### Step 7: Save Documents
- Markdown: `.github/reviews/releases/release-prep-{version}-{date}.md`
- HTML: `.github/reviews/releases/release-prep-{version}-{date}.html`

### Step 8: Next Actions
Offer to: create the GitHub release draft, close the milestone, or notify the team.
