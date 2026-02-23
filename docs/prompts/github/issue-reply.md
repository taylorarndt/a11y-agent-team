# issue-reply

Read the full thread of a GitHub issue and draft a context-aware reply. The agent previews the draft before posting — it never sends a reply without your explicit confirmation.

## When to Use It

- Responding to a bug report with triage information
- Following up on a feature request with a decision
- Answering a question posted in an issue thread
- Closing out a stale issue with an explanation

## How to Launch It

**In GitHub Copilot Chat:**
```
/issue-reply owner/repo#89
```

With reply intent:
```
/issue-reply owner/repo#89 "this is a known issue, fix is in v2.1"
/issue-reply owner/repo#89 close as won't fix
/issue-reply owner/repo#89 ask for reproduction steps
```

## What to Expect

1. **Read full thread** — Fetches the original issue, all comments, and labels
2. **Understand context** — Identifies the issue type, current state, and any pending questions
3. **Draft reply** — Writes a reply appropriate to the context and your stated intent
4. **Preview** — Shows you the full draft with issue summary and proposed comment
5. **Confirm and post** — Posts only after you say yes

### Reply Intent Detection

| You say | Agent drafts |
|---------|-------------|
| (no intent) | Context-aware response based on thread state |
| "close as won't fix" | Polite won't-fix explanation and closes issue |
| "ask for reproduction steps" | Asks for OS, browser, version, steps |
| "fix is in vX.Y" | Links to version, explains what will change |
| "needs more info" | Asks specific follow-up questions |
| "thank and close" | Grateful acknowledgment and closure |

### Sample Flow

```
You: /issue-reply owner/repo#89 ask for reproduction steps

Agent: Issue #89 — "Login flickers on mobile"
  Current state: Open, awaiting triage, no maintainer reply yet

  Draft reply:
  ────────────────────────────────────
  Thank you for reporting this! To help us investigate, 
  could you provide:
  - Device and OS (e.g., iPhone 14, iOS 17.2)
  - Browser (e.g., Safari 17)
  - Steps to reproduce exactly
  - Does it happen on the first login or only subsequent?
  ────────────────────────────────────

  Post this reply? (yes/no/edit)
```

## Example Variations

```
/issue-reply owner/repo#89                     # Context-aware draft
/issue-reply #89 close as duplicate of #44     # Close as duplicate
/issue-reply #89 "fixed in PR #102"            # Link to fix
/issue-reply #89 needs more info               # Request clarification
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [manage-issue](manage-issue.md) — edit labels, assign, close, or lock issues
- [triage](triage.md) — prioritize issues in bulk
- [my-issues](my-issues.md) — see issues that need your attention
