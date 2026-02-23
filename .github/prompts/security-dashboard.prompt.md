---
name: security-dashboard
description: "Security overview -- Dependabot alerts, security advisories, dependency update PRs, and vulnerability status across your repos"
agent: daily-briefing
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Generate a security dashboard showing Dependabot alerts, security advisories, and dependency update PRs across your repos.

${input:scope:Optional: specific repo, 'org:orgname', severity filter (e.g. 'critical only'), or 'just dependabot'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Load repo scope from `.github/agents/preferences.md` if present. Identify target repos (from input, workspace, preferences, or ALL accessible repos by default).
3. For each repo, collect:
   - Open Dependabot alerts by severity (critical, high, medium, low)
   - Security advisories affecting the repo
   - Pending dependency update PRs (from `dependabot[bot]` or `renovate[bot]`)
   - Recently resolved/dismissed alerts
4. Display a dashboard in chat:

   **Security Status across {N} repos**

   | Repo | Critical | High | Medium | Low | Pending PRs |
   |------|----------|------|--------|-----|------------|
   | repo | {count} | {count} | {count} | {count} | {count} |

5. For critical and high alerts, show: package, advisory link, affected versions, fix available (yes/no), and any pending PR to fix it.
6. List dependency update PRs pending review with age and risk assessment.
7. Offer: _"Want to review a specific Dependabot PR? Or see the full advisory details?"_
