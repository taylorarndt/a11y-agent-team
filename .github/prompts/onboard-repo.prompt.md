---
name: onboard-repo
description: "First-time repo onboarding -- scan issues, PRs, releases, CI health, CODEOWNERS, and suggest initial triage and setup actions"
agent: daily-briefing
tools:
  - github/*
  - readFile
  - textSearch
  - createFile
  - createDirectory
  - ask_questions
---

Run a comprehensive first-time scan of a repository to understand its health, activity, and what needs attention. Save both markdown and HTML versions.

${input:repo:Required: repository in owner/repo format}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Fetch repo metadata: description, language, stars, forks, default branch, visibility.
3. If the repo is not already in `.github/agents/preferences.md`, offer to add it to the tracked repos list after onboarding.
3. Scan key files:
   - `README.md` -- project purpose and setup
   - `CODEOWNERS` -- who owns what
   - `.github/ISSUE_TEMPLATE/` -- available issue templates
   - `.github/workflows/` -- CI/CD pipelines configured
   - `CONTRIBUTING.md` -- contribution guidelines
   - `LICENSE` -- licensing
4. Check repo health:
   - **Issues:** Count open, labels used, oldest unresolved, any without labels/assignees
   - **PRs:** Count open, oldest without review, any with merge conflicts
   - **Releases:** Latest release, release frequency, any draft releases
   - **CI/CD:** Recent workflow runs, pass/fail rates
   - **Security:** Open Dependabot alerts, branch protection rules
   - **Discussions:** Active discussions, if enabled
5. Identify quick wins:
   - Issues that can be closed (stale, already fixed)
   - PRs ready to merge (approved, CI passing)
   - Labels that should be added for better organization
   - Missing issue templates or CI workflows
6. Generate BOTH documents:
   - Markdown: `.github/reviews/onboarding/onboard-{repo-slug}-{date}.md`
   - HTML: `.github/reviews/onboarding/onboard-{repo-slug}-{date}.html`
   With sections: Repo Overview, Health Check, Issues Summary, PR Summary, CI/CD Status, Security Status, Quick Wins, Recommended Actions
7. Present a compact summary and offer: _"Want to start triaging issues? Or review the oldest PRs?"_
