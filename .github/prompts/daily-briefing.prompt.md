---
name: daily-briefing
description: "Generate your daily GitHub briefing -- issues, PRs, releases, discussions, reactions, accessibility updates, and action items across all your repos in dual markdown + HTML format"
agent: daily-briefing
tools:
  - github/*
  - createFile
  - createDirectory
  - editFiles
  - ask_questions
---

Generate a comprehensive daily briefing document covering everything that needs my attention. Save both markdown and HTML versions.

${input:scope:Optional: 'morning', 'afternoon update', 'weekly', specific repo, 'org:orgname', or 'just PRs' / 'just issues'}

## Behavior

Load repo discovery settings from `.github/agents/preferences.md` (discovery mode, include/exclude lists, per-repo overrides). By default, scan ALL repos the user has access to.

Interpret the scope:

- **No input / "morning"** --> full briefing covering the last 24 hours across all discovered repos
- **"afternoon update"** / **"since this morning"** --> incremental update to today's existing briefing
- **"weekly"** --> extended report covering the last 7 days with reflection
- **Repo name** --> scope to that specific repo
- **"org:orgname"** --> scope to all repos in that organization
- **"just PRs"** / **"just issues"** --> only that category
- **"quick"** --> chat-only summary, skip document generation

Follow the full workflow defined in the daily-briefing agent: collect all data streams (issues, PRs, releases, discussions, reactions, a11y updates), score and prioritize, generate BOTH the markdown and HTML briefing documents at `.github/reviews/briefings/briefing-{date}.md` and `.github/reviews/briefings/briefing-{date}.html`, and present a compact summary in chat.

If a briefing already exists for today, update it incrementally with NEW markers instead of creating a new one.

Include release awareness, community reactions, and discussion threads alongside the standard issue and PR data.
