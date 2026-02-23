# manage-issue

Edit, label, assign, close, reopen, lock, or transfer a GitHub issue. All destructive or irreversible actions require explicit confirmation before executing.

## When to Use It

- Updating an issue's labels after triage
- Reassigning an issue to a different contributor
- Closing or reopening an issue
- Locking a heated discussion thread
- Transferring an issue to a different repository

## How to Launch It

**In GitHub Copilot Chat:**

```text
/manage-issue owner/repo#89 <action>
```

Examples:

```text
/manage-issue owner/repo#89 add label: bug
/manage-issue owner/repo#89 assign to: alice
/manage-issue owner/repo#89 close
/manage-issue owner/repo#89 lock
/manage-issue owner/repo#89 transfer to: owner/other-repo
```

## What to Expect

1. **Parse action** - Identifies the target issue and requested operation
2. **Fetch current state** - Reads the issue to show current labels, assignees, and status
3. **Preview change** - Shows what will change in a before/after summary
4. **Confirm if destructive** - Close, lock, and transfer require a `yes` from you
5. **Execute** - Applies the change and confirms success with the updated state

### Supported Actions

| Action | Syntax | Confirm required? |
|--------|--------|--------------------|
| Add label | `add label: bug` | No |
| Remove label | `remove label: enhancement` | No |
| Assign | `assign to: alice` | No |
| Unassign | `unassign alice` | No |
| Set milestone | `milestone: v2.1` | No |
| Edit title | `title: New title here` | No |
| Close | `close` or `close as won't fix` | Yes |
| Reopen | `reopen` | Yes |
| Lock | `lock` | Yes |
| Unlock | `unlock` | No |
| Transfer | `transfer to: owner/repo` | Yes |

### Sample Flow (close with confirmation)

```text
You: /manage-issue owner/repo#89 close as won't fix

Agent: Issue #89 - "Login flickers on mobile"
  Current state: Open, labeled "bug", assigned to alice

  Action: Close issue with state "won't fix"
  This cannot be undone from chat. Proceed? (yes/no)

You: yes

Agent: Issue #89 closed as "won't fix". 
```

## Example Variations

```text
/manage-issue #89 add label: accessibility
/manage-issue #89 remove label: triage-needed
/manage-issue #89 assign to: alice
/manage-issue #89 milestone: v2.1
/manage-issue #89 close
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [issue-reply](issue-reply.md) - post a comment before managing
- [triage](triage.md) - bulk label and prioritize issues
- [create-issue](create-issue.md) - create a new issue
- [refine-issue](refine-issue.md) - add detail to an existing issue
