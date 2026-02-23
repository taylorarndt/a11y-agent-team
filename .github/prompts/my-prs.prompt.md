---
name: my-prs
description: "Dashboard of your open PRs across all repos -- review status, CI, merge state, reactions, release context, and what needs attention"
agent: pr-review
tools:
  - github/*
  - createFile
  - createDirectory
  - ask_questions
---

Get the current authenticated user with #tool:mcp_github_github_get_me, then search for all **open** pull requests authored by or assigned to that user.

By default, search across ALL repos the user has access to (no `repo:` qualifier). Respect repo scope from `.github/agents/preferences.md` if present (discovery mode, include/exclude lists, per-repo overrides with `track.pull_requests` flag).

${input:filter:Optional: repo name, 'org:orgname', 'needs review', 'approved', 'failing CI', or keywords}

## Behavior

Parse the filter:
- **Repo name** --> scope to that repo with `repo:owner/name`
- **Org name** (e.g., "org:microsoft") --> scope to that org with `org:orgname`
- **"needs review"** --> PRs with no reviews yet
- **"approved"** --> PRs with at least one approval
- **"failing"** / **"CI"** --> PRs where checks are failing
- **"draft"** --> only draft PRs
- **"ready"** --> approved + CI passing + no conflicts
- **"release"** --> PRs in a release milestone
- **Keywords** --> search terms
- **No filter** --> search ALL accessible repos

Also search for PRs where your review was requested: `review-requested:USERNAME state:open`

## Enhanced Data Collection

For each PR found, also gather:
- **Reactions** -- on the PR description. Flag Popular/Controversial/Quiet.
- **Release context** -- check if the PR targets a release branch or is in a release milestone.
- **Discussions** -- note related GitHub Discussions.
- **Team reviews** -- who has already reviewed vs. who hasn't.

## Output

**Lead with a status line:** _"You have 5 open PRs (2 ready to merge, 1 needs updates, 1 release-bound)"_

Display two sections:

### Your PRs ({count} items)

| Priority | PR | Repo | Reviews | CI | Merge | Age | Reactions | Release | Action |
|----------|-----|------|---------|-----|-------|-----|-----------|---------|--------|
| 1 | [PR #N: Title](url) | repo | 2 approved | Pass | Clean | 1 day | +1: 3 | v2.0 | Ready to merge |
| 2 | [PR #N: Title](url) | repo | Changes req. | Pass | Clean | 3 days | -- | -- | Address feedback |
| 3 | [PR #N: Title](url) | repo | Pending | Fail | Conflicts | 5 days | -- | -- | Fix CI + conflicts |

### Awaiting Your Review ({count} items)

| Priority | PR | Repo | Author | Files | Changes | Waiting | Reactions | Release |
|----------|-----|------|--------|-------|---------|---------|-----------|---------|
| 1 | [PR #N: Title](url) | repo | @author | 5 | +120/-30 | 2 days | +1: 5, Popular | v2.0 |

**Action signals:**
- **Ready to merge** -- Approved, CI passing, no conflicts
- **Needs your update** -- Changes requested or CI failing
- **Blocked** -- Merge conflicts or blocked by dependencies
- **Awaiting others** -- Waiting for reviews from others
- **Popular** -- Community interest (5+ reactions)
- **Release-bound** -- Targets an upcoming release

After the table, suggest: _"Want to merge a ready PR, start reviewing one, or generate a full PR report?"_
