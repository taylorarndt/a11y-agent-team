---
name: issue-reply
description: "Draft and post a context-aware reply to a GitHub issue with full thread context and reaction awareness"
agent: issue-tracker
tools:
  - github/*
  - ask_questions
---

Help the user reply to a GitHub issue with full context awareness.

${input:issue:Issue reference -- e.g. owner/repo#123 or a GitHub issue URL}

## Steps

1. Parse the issue reference to extract owner, repo, and issue number.
2. Fetch the issue with #tool:mcp_github_github_issue_read -- pull title, body, labels, assignees, reactions, and **all** comments.
3. Check for related GitHub Discussions that provide additional context.
4. Display a concise summary:
   - Issue title and current status
   - Community reactions summary (Popular/Controversial/Quiet)
   - Release context if in a milestone
   - Key discussion points from the last 5 comments
   - Any open questions or action items directed at the user
   - Related discussions with relevant points
5. Ask the user what they want to say. If they give a brief intent (e.g., "agree with the last suggestion"), draft a professional reply that:
   - References specific points from the discussion
   - Is concise and actionable
   - Matches the tone of the thread
   - Acknowledges community reactions when relevant (e.g., "This has strong community support")
6. Preview the reply in a quoted block:
   > **Your reply to #{number}:**
   > {drafted text}
7. Use #tool:ask_questions to confirm: **Post** (recommended), **Edit** (let me refine), **Cancel**.
8. If posting, use #tool:mcp_github_github_add_issue_comment and confirm with a direct link.
9. If editing, incorporate feedback and preview again.

**Never post without explicit confirmation.**
