---
name: ci-status
description: "CI/CD health dashboard -- workflow runs, failures, flaky tests, and long-running jobs across your repos"
agent: daily-briefing
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate a CI/CD health dashboard showing workflow status, failures, and health across your repos.

${input:scope:Optional: specific repo, 'org:orgname', workflow name, or 'just failures'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present. Identify target repos (from input, workspace, preferences, or ALL accessible repos by default).
3. For each repo, check recent workflow runs:
   - Identify failing workflows with failure details and links to logs
   - Flag long-running jobs exceeding threshold (default 30 min, configurable in preferences)
   - Detect flaky tests (same test failing intermittently 3+ times in 7 days)
   - Check the user's open PRs for CI failures
4. Display a dashboard in chat:

   **CI/CD Health across {N} repos**

   | Repo | Status | Failing Workflows | Long Running | Flaky Tests |
   |------|--------|------------------|-------------|-------------|
   | repo | Healthy / Degraded / Failing | {count} | {count} | {count} |

5. For each failure, show: workflow name, branch, error summary, link to the run, and how long it's been failing.
6. Offer: _"Want to see details on a specific failure? Or check CI for a specific PR?"_
