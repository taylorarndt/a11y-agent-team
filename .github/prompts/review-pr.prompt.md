---
name: review-pr
description: "Full PR review with diff analysis, before/after snapshots, reactions, release context, and saved workspace documents in markdown + HTML"
agent: pr-review
tools:
  - github/*
  - fetch
  - readFile
  - codebase
  - createFile
  - createDirectory
  - editFiles
  - ask_questions
---

Perform a comprehensive code review of the specified pull request and save review documents to the workspace in both markdown and HTML formats.

${input:pr:PR reference -- e.g. owner/repo#123 or a GitHub PR URL}

## Steps

1. Parse the PR reference (supports `owner/repo#N`, `#N` with workspace repo, or full URL).
2. Fetch all PR assets in one sweep:
   - Metadata via #tool:mcp_github_github_pull_request_read (method: `get`)
   - Changed files via #tool:mcp_github_github_pull_request_read (method: `get_files`)
   - Full diff via #tool:mcp_github_github_pull_request_read (method: `get_diff`)
   - Review comments via #tool:mcp_github_github_pull_request_read (method: `get_review_comments`)
   - Commits via #tool:mcp_github_github_list_commits
   - Reactions on the PR description and comments
   - Release context -- check if targeting a release branch or in a milestone
   - Related GitHub Discussions
3. For key changed files (not config/lock files), fetch before/after content via #tool:mcp_github_github_get_file_contents for both base and head branches.
4. Classify each file change (Feature / Bug Fix / Refactor / Tests / Config / Docs) and assess risk (High / Medium / Low).
5. For each file, generate:
   - **Change Map** -- a hunk-by-hunk table with old/new line ranges and intent descriptions
   - **Annotated Diff** -- dual line numbers (old/new) on every line, `+`/`-` markers, at least 5 lines of context per hunk
   - **Inline Intent Annotations** -- blockquote explanations between hunks for non-obvious changes
   - **Before/After Snapshots** -- collapsible sections with line numbers on every line and a "Lines to watch" callout
6. Present the review in chat with: overview table, file-by-file analysis with Change Map and line-numbered diffs, developer comments, reactions summary, release context, and verdict.
7. After each file's diff, include the interactive prompt: `"comment on L42"`, `"explain L40-L60"`, `"suggest fix for L42"`.
8. **Save BOTH review documents:**
   - Markdown: `.github/reviews/prs/{repo}-pr-{number}.md`
   - HTML: `.github/reviews/prs/{repo}-pr-{number}.html`
   Include the checklist, action items, Change Map tables, line-numbered diffs, reactions, release context, and a "My Notes" section.
9. After completion, offer: _"Review documents saved. Say 'comment on L42' to leave feedback on any line, or approve/request changes."_
