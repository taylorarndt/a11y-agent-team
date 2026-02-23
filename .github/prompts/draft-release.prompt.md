---
name: draft-release
description: "Draft release notes from merged PRs since last release -- auto-categorized as Features, Bug Fixes, Breaking Changes, with changelog and readiness checklist"
agent: daily-briefing
tools:
  - github/*
  - createFile
  - createDirectory
  - editFiles
  - ask_questions
---

Draft release notes for the next release based on merged PRs since the last release. Save both markdown and HTML versions.

${input:details:Optional: repo name, target version (e.g. 'v2.1.0'), or 'compare v1.0...v2.0'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Identify the target repo (from input or workspace context).
3. Fetch the latest release with #tool:mcp_github_github_list_releases.
4. Find all merged PRs since the last release tag using #tool:mcp_github_github_search_pull_requests with `is:merged merged:>{last_release_date}`.
5. Auto-categorize each PR:
   - **Breaking Changes** -- PRs with `breaking-change` label or "BREAKING" in title/description
   - **Features** -- PRs with `feature` or `enhancement` label, or new functionality
   - **Bug Fixes** -- PRs with `bug` or `fix` label
   - **Performance** -- PRs with `performance` label
   - **Documentation** -- PRs touching only docs
   - **Dependencies** -- Dependabot/Renovate PRs
   - **Other** -- everything else
6. Generate a release readiness checklist:
   - Open milestone items (not yet merged)
   - Failing CI on the release branch
   - Pending reviews on release-targeted PRs
   - Open Dependabot alerts (critical/high)
7. Generate conventional-commit-style changelog.
8. Create BOTH documents:
   - Markdown: `.github/reviews/releases/release-notes-{version}-{date}.md`
   - HTML: `.github/reviews/releases/release-notes-{version}-{date}.html`
   With sections: Release Summary, Breaking Changes, Features, Bug Fixes, Other Changes, Changelog, Readiness Checklist, Post-Release Checklist
9. Present a summary in chat and offer to create the GitHub release draft.

**Post-release checklist items:**
- [ ] Close the milestone
- [ ] Update documentation
- [ ] Announce in discussions/channels
- [ ] Verify deployment
