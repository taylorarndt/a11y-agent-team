# review-pr

Run a thorough code review on any pull request. The agent reads the full diff, fetches inline comments and CI status, and produces a structured review saved as markdown and HTML to your `.github/reviews/` folder.

## When to Use It

- Before approving a PR and want a second set of eyes
- Reviewing a large or complex PR and want help organizing feedback
- Want a written review record you can share or reference later
- Catching accessibility, security, or code quality issues before merge

## How to Launch It

**In GitHub Copilot Chat:**
```
/review-pr owner/repo#123
```

Or just provide the PR context:
```
/review-pr https://github.com/owner/repo/pull/123
```

If you are already on the PR branch, you can simply run `/review-pr` and the agent detects the current branch's open PR.

## What to Expect

1. **Fetch diff** — The agent downloads the full unified diff, all changed files, and the PR description
2. **Build Change Map** — A table of every changed file, lines added/removed, and the logical purpose of each change
3. **Per-file analysis** — Line-numbered observations categorized as CRITICAL / IMPORTANT / SUGGESTION / NIT / PRAISE
4. **Before/after snapshots** — For complex logic changes, side-by-side code comparison
5. **Summary verdict** — Overall review outcome: Approve / Approve with nits / Request changes / Block
6. **Save documents** — Writes `.github/reviews/prs/{repo}-pr-{number}.md` and `.html`

### Review Priority Levels

| Level | Meaning | Must fix? |
|-------|---------|-----------|
| **CRITICAL** | Security hole, data loss, or broken functionality | Yes, block merge |
| **IMPORTANT** | Logic error, performance concern, API misuse | Yes, strong preference |
| **SUGGESTION** | Better approach exists, worth discussing | Optional |
| **NIT** | Style, naming, minor clarity | Purely optional |
| **PRAISE** | Highlight good patterns | Informational |

### Sample Output (in chat)

```
## Review — owner/repo #123 "Add authentication middleware"

Change Map:
  src/middleware/auth.ts    +80 / -12   New JWT validation
  src/routes/api.ts         +14 / -3    Apply middleware to routes
  tests/auth.test.ts        +60 / -0    Test coverage

CRITICAL src/middleware/auth.ts:47
  JWT secret read from process.env without fallback check.
  If JWT_SECRET is undefined, all tokens will validate.
  Fix: throw at server startup if secret is missing.

IMPORTANT src/routes/api.ts:22
  Admin route exposed without role check.

SUGGESTION src/middleware/auth.ts:61
  Extract token expiry to a named constant.

Overall: REQUEST CHANGES (1 critical, 1 important)

Saved to .github/reviews/prs/repo-pr-123.md
```

## Example Variations

```
/review-pr owner/docs-site#88            # Review specific PR
/review-pr                               # Detect PR from current branch
/review-pr focus on security            # Emphasize security findings
/review-pr ignore style comments        # Skip NITs
```

## Output Files

| File | Contents |
|------|----------|
| `.github/reviews/prs/{repo}-pr-{number}.md` | Full review in markdown |
| `.github/reviews/prs/{repo}-pr-{number}.html` | Accessible HTML version |

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [pr-report](pr-report.md) — generate a review document without inline comments
- [pr-author-checklist](pr-author-checklist.md) — pre-submit checklist for PR authors
- [pr-comment](pr-comment.md) — add a specific comment to a PR
- [merge-pr](merge-pr.md) — merge after review is complete
