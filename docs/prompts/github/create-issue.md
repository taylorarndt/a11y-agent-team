# create-issue

Create a new GitHub issue with the right type, title, description, labels, and assignees - guided by the agent's detection of issue type and pre-filled from available templates.

## When to Use It

- Reporting a bug with all the right context fields
- Filing a feature request that follows project templates
- Creating a simple task or question with minimal friction
- When you want the agent to pre-fill a template so you only review and confirm

## How to Launch It

**In GitHub Copilot Chat:**

```text
/create-issue owner/repo "Login page flickers on mobile Safari"
```

Or describe the issue naturally:

```text
/create-issue owner/repo I found a bug where the login form submits twice
```

## What to Expect

1. **Detect issue type** - Agent classifies as Bug / Feature / Task / Question based on the description
2. **Load template** - Finds the matching issue template from `.github/ISSUE_TEMPLATE/` if one exists
3. **Pre-fill fields** - Populates title, description, labels, and suggested assignee from context
4. **Preview and confirm** - Shows the complete draft before creating
5. **Create issue** - Posts to GitHub only after you confirm; returns the issue URL and number

### Issue Type Detection

| Description signals | Detected type |
|--------------------|--------------|
| "bug", "broken", "error", "fails", "crash" | Bug |
| "feature", "add", "support", "allow", "would be nice" | Feature request |
| "task", "chore", "update", "migrate", "upgrade" | Task |
| "how do I", "question", "wondering", "unclear" | Question |

### Sample Flow

```text
You: /create-issue owner/repo Login form submits twice on mobile

Agent: Detected type: Bug

  Draft issue:
  
  Title: Login form submits twice on mobile
  Type: Bug report
  Labels: bug, mobile
  Assignee: (none detected - add one?)

  **Describe the bug**
  The login form submits twice when tapped on mobile...

  **Steps to reproduce**
  1. Open on iOS Safari
  2. Tap the Login button

  **Expected behavior**
  Form submits once and redirects.
  

  Create this issue? (yes/no/edit)
```

## Example Variations

```text
/create-issue owner/repo "Button has no focus indicator"
/create-issue owner/repo feature: add dark mode support
/create-issue owner/repo task: upgrade eslint to v9
/create-issue owner/repo "Is WCAG 2.2 supported?"
```

## Connected Agents

| Agent | Role |
|-------|------|
| issue-tracker agent | Executes this prompt |

## Related Prompts

- [triage](triage.md) - triage existing open issues
- [manage-issue](manage-issue.md) - edit, label, or close issues
- [refine-issue](refine-issue.md) - add acceptance criteria and technical detail to an issue
- [build-template](build-template.md) - build a custom issue template
