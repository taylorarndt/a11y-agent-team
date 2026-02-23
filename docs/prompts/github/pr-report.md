# pr-report

Generate a written PR review document — the full structured output of a code review saved to `.github/reviews/`, without necessarily posting inline GitHub comments. Use when you need a review artifact to share, reference, or archive.

## When to Use It

- Creating a formal code review document before a review meeting
- Archiving review history for compliance or process tracking
- Generating a report you can attach to a ticket or email
- Reviewing without posting to GitHub (e.g., pre-review draft)

## How to Launch It

**In GitHub Copilot Chat:**
```
/pr-report owner/repo#123
```

Or with a URL:
```
/pr-report https://github.com/owner/repo/pull/456
```

## What to Expect

1. **Fetch PR data** — Diff, description, existing comments, CI status, and reviewer assignments
2. **Change Map** — Table of every changed file with purpose, line counts, and component classification
3. **Per-file findings** — CRITICAL / IMPORTANT / SUGGESTION / NIT / PRAISE findings with line numbers
4. **Before/after code snapshots** — Side-by-side view for complex changes
5. **Summary section** — Overall verdict, blocking items, key recommendations
6. **Save report** — Both `.md` and `.html` versions written to `.github/reviews/prs/`

### Updating an Existing Report

If a report for that PR already exists, the agent performs a diff update:
- New findings are marked with **NEW**
- Resolved findings are marked ~~strikethrough~~
- A change summary is prepended

### Sample Report Structure

```markdown
# PR Review: Add authentication middleware
**Repo:** owner/repo | **PR:** #123 | **Date:** 2026-02-22

## Change Map
| File | +Added | -Removed | Purpose |
|------|--------|----------|---------|
| src/middleware/auth.ts | 80 | 12 | JWT validation |

## Findings
### CRITICAL
- `src/middleware/auth.ts:47` — JWT secret without fallback...

## Summary
Verdict: REQUEST CHANGES
Blocking: 1 critical finding
```

## Example Variations

```
/pr-report owner/repo#123                # Full report for a specific PR
/pr-report                               # Report for current branch PR
/pr-report owner/repo#123 security only  # Security-focused report
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/prs/{repo}-pr-{number}.md` | Review document in markdown |
| `.github/reviews/prs/{repo}-pr-{number}.html` | Accessible HTML version |

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) — review with inline GitHub comment posting
- [pr-author-checklist](pr-author-checklist.md) — pre-submit checklist for authors
- [pr-comment](pr-comment.md) — post a single targeted comment
