# pr-comment

Add a specific, targeted comment to a pull request — on a specific line, a specific file, or as a general PR comment. The agent batches all your comments into a single pending review and submits once.

## When to Use It

- Leaving feedback on specific lines of a PR
- Asking a clarifying question about a particular change
- Requesting a specific change before approving
- Adding a note to a PR thread for the author

## How to Launch It

**In GitHub Copilot Chat:**
```
/pr-comment owner/repo#123 "Your comment text here"
```

With line targeting:
```
/pr-comment owner/repo#123 src/auth.ts:47 "JWT secret should have a fallback"
```

## What to Expect

1. **Parse comment intent** — Identifies target PR, target file/line (if specified), and comment content
2. **Classify priority** — CRITICAL / IMPORTANT / SUGGESTION / NIT / PRAISE based on content
3. **Build pending review** — Adds to a pending review batch (never posts immediately as isolated comments)
4. **Preview and confirm** — Shows you exactly what will be posted and asks for confirmation
5. **Submit review** — Posts all batched comments as one review with a summary verdict

### Comment Priority Classification

| Label | Auto-detected when content contains... |
|-------|----------------------------------------|
| CRITICAL | security, vulnerability, data loss, breaking |
| IMPORTANT | bug, error, incorrect, missing check |
| SUGGESTION | consider, alternatively, could |
| NIT | minor, style, naming, whitespace |
| PRAISE | great, well done, nice pattern |

### Sample Flow

```
You: /pr-comment owner/repo#123 src/auth.ts:47 "JWT secret will be undefined if env var missing — this will accept all tokens"

Agent: Comment preview:
  File: src/auth.ts, line 47
  Priority: CRITICAL
  Text: "JWT secret will be undefined if env var missing — this will accept all tokens"

Submit? (yes/no/edit)

You: yes

Agent: Comment posted to #123 as part of pending review.
  Use /review-pr to submit the full review when ready.
```

### Important Behavior

The agent **never posts a comment without your confirmation**. All comments go into a pending review and are submitted together — not as scattered inline replies — which is consistent with GitHub's review model.

## Example Variations

```
/pr-comment owner/repo#123 "Overall this looks good, just one concern"
/pr-comment #123 src/utils.ts:88 "This function name is misleading"
/pr-comment #123 nit: "extra blank line on line 22"
/pr-comment #123 praise: "Great test coverage on the edge cases"
```

## Connected Agents

| Agent | Role |
|-------|------|
| pr-review agent | Executes this prompt |

## Related Prompts

- [review-pr](review-pr.md) — full review with all comments at once
- [address-comments](address-comments.md) — track and resolve incoming review comments
- [pr-author-checklist](pr-author-checklist.md) — check your own PR before requesting review
