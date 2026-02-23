---
name: pr-report
description: "Save a full PR review as dual workspace documents (markdown + HTML) for offline review and action tracking"
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

Generate a comprehensive PR review document and save it to the workspace in both markdown and HTML formats for offline review.

${input:pr:PR reference -- e.g. owner/repo#123 or a GitHub PR URL}

## Steps

1. Parse the PR reference (supports `owner/repo#N`, `#N`, or full URL).
2. Pull all PR assets:
   - Metadata, files, diff, review comments, commits
   - Before/after content for key changed files
   - Reactions on PR description and comments
   - Release context -- milestone, release branch targeting
   - Related GitHub Discussions
3. Analyze changes: classify each file (Feature / Bug Fix / Refactor / Tests / Config), assess risk (High / Medium / Low), note community reactions, and detect patterns.
4. For each file, generate the line-numbered display:
   - **Change Map** -- hunk-by-hunk table with old/new line ranges and intent descriptions
   - **Annotated Diff** -- dual line numbers, `+`/`-` markers, 5+ lines of context per hunk
   - **Intent Annotations** -- blockquote explanations for non-obvious changes
   - **Before/After Snapshots** -- collapsible sections with line numbers and "Lines to watch" callouts
5. Check if `.github/reviews/prs/{repo}-pr-{number}.md` and `.html` already exist:
   - **Exists:** Update both with new data and mark what changed since last generation using #tool:editFiles.
   - **New:** Create both review documents using #tool:createFile.
5. Both documents include:
   - Overview table with PR metadata, reactions, and release context
   - File-by-file analysis with Change Map tables, line-numbered before/after code, annotated diffs with dual line numbers, and intent annotations
   - "Lines to watch" callouts highlighting the most review-worthy sections per file
   - All developer comments and review threads with reactions
   - Related GitHub Discussions
   - Review checklist (code quality, architecture, security, tests, docs, accessibility)
   - Verdict and recommendations with release context
   - "My Notes" section for user annotations
6. Confirm: _"PR review documents saved to `{md-path}` and `{html-path}`. Say 'comment on L42' to leave feedback on any line. Open the docs, check off items, and add your notes."_

**Tip:** After annotating the documents, use `/pr-comment` to turn your notes into actual PR comments.
