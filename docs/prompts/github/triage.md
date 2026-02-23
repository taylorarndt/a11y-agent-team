# triage

Score and prioritize all open issues in a repository using a structured priority system. The output is a triage report saved as markdown and HTML to `.github/reviews/issues/`.

## When to Use It

- Weekly issue grooming before sprint planning
- After a release when new issues flood in and need sorting
- Before a project milestone to find what is blocking or high-priority
- Getting a snapshot of issue health across a repository

## How to Launch It

**In GitHub Copilot Chat:**
```
/triage owner/repo
```

With date range:
```
/triage owner/repo last 7 days
/triage owner/repo since 2026-02-01
```

## What to Expect

1. **Collect all open issues** — Fetches issues with labels, reactions, comments, and milestone data
2. **Score each issue** — Applies the priority scoring formula
3. **Classify** — Assigns priority tier P0 through P4
4. **Generate report** — Structured triage report with prioritized table and action recommendations
5. **Save** — Written to `.github/reviews/issues/triage-{date}.md` and `.html`

### Priority Scoring Formula

| Signal | Points |
|--------|--------|
| @mention of a maintainer | +3 |
| Linked to current release/milestone | +3 |
| Labeled P0 or P1 | +2 |
| 5+ 👍 reactions | +2 |
| Reply awaited (no maintainer response) | +2 |
| 5+ comments (active discussion) | +1 |
| Older than 30 days (staleness) | +1 |
| Security label | +5 |
| Confirmed reproducible | +1 |

### Priority Tiers

| Tier | Score | Action |
|------|-------|--------|
| P0 | 10+ | Act in current sprint |
| P1 | 7-9 | Plan for next sprint |
| P2 | 4-6 | Backlog — schedule when possible |
| P3 | 2-3 | Low priority — address if time allows |
| P4 | 0-1 | Icebox — revisit in future quarter |

### Sample Report Section

```markdown
## P0 — Critical (2 issues)
| # | Title | Score | Why |
|---|-------|-------|-----|
| 88 | Login fails after session expires | 12 | @mention + milestone + P0 label |
| 91 | Data export corrupts UTF-8 chars  | 10 | Security + 8 reactions |
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/issues/triage-{date}.md` | Full triage report |
| `.github/reviews/issues/triage-{date}.html` | Accessible HTML version |

## Example Variations

```
/triage owner/repo                        # Full triage
/triage owner/repo last 7 days            # Recent issues only
/triage owner/repo label:bug              # Only bug issues
/triage owner/repo milestone:"v2.0"       # Scoped to a milestone
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [my-issues](my-issues.md) — issues assigned to or @mentioning you
- [issue-reply](issue-reply.md) — reply to a specific issue
- [project-status](project-status.md) — per-column project board status
- [refine-issue](refine-issue.md) — add acceptance criteria to an issue
