# github-workflow-standards Skill

> Core standards applied by all GitHub workflow agents. Covers authentication, smart defaults, repository discovery modes, how to handle the preferences file, dual Markdown + HTML output requirements, screen-reader-compliant HTML accessibility standards (with the full embedded CSS), progress announcement patterns, parallel execution principles, safety rules, and output quality standards.

## Agents That Use This Skill

All 11 GitHub workflow agents: [github-hub](../agents/github-hub.md), [daily-briefing](../agents/daily-briefing.md), [issue-tracker](../agents/issue-tracker.md), [pr-review](../agents/pr-review.md), [analytics](../agents/analytics.md), [repo-admin](../agents/repo-admin.md), [team-manager](../agents/team-manager.md), [contributions-hub](../agents/contributions-hub.md), [insiders-a11y-tracker](../agents/insiders-a11y-tracker.md), [repo-manager](../agents/repo-manager.md), [template-builder](../agents/template-builder.md).

## Authentication

1. Call `github_get_me` to identify the authenticated user. Cache for the session.
2. Detect workspace context from `.git/config` or `package.json` - use as smart default for repo scope.

## Smart Defaults

- **"My issues"** without a repo -> search all accessible repos
- **"This repo"** or no repo specified -> infer from workspace context
- **No date range** -> default to last 30 days; mention the assumption
- **PR number given, no repo** -> try workspace repo first
- **0 results** -> automatically broaden and tell the user what changed
- **>50 results** -> narrow by most recent; suggest filters
- **Never ask what can be inferred** from context, workspace, or conversation history

## Repository Discovery Modes

| Mode | Behavior |
|------|----------|
| `all` (default) | All repos accessible via the API |
| `starred` | Only repos the user has starred |
| `owned` | Only repos the user owns (excludes org repos) |
| `configured` | Only repos in `repos.include` |
| `workspace` | Only the repo detected from the current workspace |

## Progress Announcements

All long-running operations narrate steps aloud. Format:

```text
 [What you're doing] ([scope, e.g., "3 repos, last 7 days"])

 [Step description]... ([N]/[total])
 [Result summary - always include a count]

 [Next step]...
 [Result summary]

 [Operation complete] - [X key stats]
```

Rules:

- **Never expose tool names or API calls** in progress messages
- Number steps when there are 3 or more: `(1/7)`, `(2/7)`, etc.
- Always show a count or summary after each 

## Dual Output - Markdown + HTML

Every workspace document must be saved in both formats, side by side:

- `briefing-2026-02-23.md` - for VS Code editing and quick scanning
- `briefing-2026-02-23.html` - for screen reader users, browser viewing, team sharing

## HTML Accessibility Requirements

Every HTML document must include:

1. **Skip link** - first focusable element, targets `<main id="main-content">`
2. **Landmark roles** - `<header role="banner">`, `<nav>`, `<main role="main">`, `<footer role="contentinfo">`, `<section aria-labelledby="...">`
3. **Heading hierarchy** - strict h1 -> h2 -> h3 cascade, one h1 per document
4. **Descriptive link text** - never "click here" or bare URLs
5. **Table accessibility** - `<caption>`, `<thead>`, `<th scope="col">`, `<th scope="row">`
6. **Status indicators** - text labels alongside emoji/icons; don't rely on color alone
7. **Contrast** - 4.5:1 for normal text, 3:1 for large text and UI components
8. **Focus indicators** - visible outlines on all interactive elements
9. **Dark mode** - `prefers-color-scheme: dark` variant for all color tokens
10. **Reduced motion** - `prefers-reduced-motion: reduce` resets all animations

## Markdown Output Standards

1. **Heading hierarchy** - `#` -> `##` -> `###`, never skip levels
2. **Descriptive link text** - `[PR #123: Fix login bug](url)`, not `[#123](url)`
3. **Summary before detail** - lead every section with a one-line summary
4. **Section counts in headings** - `## Needs Your Action (3 items)` aids screen reader navigation
5. **Specific action items** - `- [ ] Respond to @alice on repo#42 - she asked about the migration timeline`

## Safety Rules

1. **Never post without confirmation** - always preview, then confirm with structured options
2. **Never modify state** (close, merge, delete, reassign) unless explicitly asked
3. **Never expose tokens** in responses
4. **Destructive actions** require a structured question confirmation
5. **Comment previews** use a quoted block so the user sees exactly what will be posted
6. **Bulk operations** show a complete preview before any action
7. **Org membership removal** is always a separate final step with its own confirmation
8. **Admin grants** get an extra warning
9. **Every successful GitHub API write** is logged to `.github/audit/YYYY-MM-DD.log`

## Parallel Execution

Run independent data streams simultaneously:

- Issues + PRs + Discussions searches
- Activity across multiple repos
- Security alerts + CI status + release checks

Wait for all streams to complete before computing scores, priorities, or summaries.

## Skill Location

`.github/skills/github-workflow-standards/SKILL.md`
