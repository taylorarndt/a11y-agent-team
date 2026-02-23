---
name: manage-issue
description: "Manage an issue -- edit, label, assign, close, reopen, lock, set milestone, or transfer"
agent: issue-tracker
tools:
  - github/*
  - ask_questions
---

Manage a GitHub issue -- edit, label, assign, close, or perform any administrative action.

${input:action:What to do -- e.g. 'close owner/repo#42 as completed', 'add bug label to #42', 'assign @alice to #42', 'set milestone v2.0 on #42'}

## Steps

1. Parse the action to determine what management operation is needed.
2. Fetch the issue with #tool:mcp_github_github_issue_read for current state.
3. Perform the requested action:

   **Edit title/body:**
   - Show current title and body
   - Apply the user's changes
   - Preview and confirm before saving

   **Add/remove labels:**
   - Show current labels
   - List available labels in the repo if the user is browsing
   - Apply changes and confirm

   **Assign/unassign:**
   - Show current assignees
   - Add or remove the specified user(s)
   - Confirm: _"Assigned @alice to {repo}#{number}."_

   **Set milestone:**
   - Show current milestone and available milestones
   - Set the specified milestone
   - Confirm

   **Close:**
   - Ask for close reason: **Completed** or **Not planned**
   - Optionally draft a closing comment
   - Confirm (state-modifying action)
   - Close and post comment if provided

   **Reopen:**
   - Show why it was closed
   - Confirm
   - Reopen and optionally add a comment explaining why

   **Lock/unlock:**
   - Explain what locking does
   - Optionally specify lock reason: off-topic, too heated, resolved, spam
   - Confirm

   **Transfer:**
   - Specify target repo
   - Confirm that the issue content will be preserved
   - Transfer and provide new link

4. After any action, confirm with a direct link and updated status.
5. If a workspace document exists for this issue, update it.

**Safety:** All state-modifying actions (close, reopen, lock, transfer) require explicit confirmation. Label and assignment changes are confirmed with a summary.
