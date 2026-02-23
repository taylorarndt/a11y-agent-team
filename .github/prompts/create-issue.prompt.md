---
name: create-issue
description: "Create a new GitHub issue with smart drafting -- describe the problem and get a well-structured issue"
agent: issue-tracker
tools:
  - github/*
  - readFile
  - codebase
  - ask_questions
---

Create a new GitHub issue with smart formatting and metadata.

${input:description:Describe the issue -- e.g. 'bug: login timeout after 30 seconds on the auth page' or 'feature: add dark mode to settings panel'}

## Steps

1. Get the authenticated user with #tool:mcp_github_github_get_me.
2. Determine the target repo:
   - If specified in the description (e.g., "in owner/repo") --> use that
   - Otherwise --> use the workspace repo
   - If ambiguous --> ask with #tool:ask_questions
3. Parse the description to determine issue type:
   - **Bug** -- keywords: "bug", "broken", "error", "crash", "fix", "doesn't work"
   - **Feature** -- keywords: "feature", "add", "new", "enhance", "request"
   - **Task** -- keywords: "task", "todo", "chore", "update", "refactor"
   - **Question** -- keywords: "question", "how", "help", "why"
4. Check for available issue templates in the repo:
   - If templates exist and match the type, pre-fill the template
   - If no templates, use a smart default structure
5. Draft a well-structured issue:

   For **bugs**:
   ```markdown
   ## Description
   {expanded description}

   ## Steps to Reproduce
   1. {step 1}
   2. {step 2}

   ## Expected Behavior
   {what should happen}

   ## Actual Behavior
   {what's happening instead}

   ## Environment
   - OS: {if mentioned}
   - Browser/App: {if mentioned}
   - Version: {if mentioned}
   ```

   For **features**:
   ```markdown
   ## Description
   {what the feature should do}

   ## Motivation
   {why this is needed}

   ## Proposed Solution
   {how it could work}

   ## Alternatives Considered
   {other approaches, or "None yet"}
   ```

   For **tasks/chores**:
   ```markdown
   ## Description
   {what needs to be done}

   ## Acceptance Criteria
   - [ ] {criterion 1}
   - [ ] {criterion 2}
   ```

6. Suggest labels based on the issue type and content.
7. Suggest assignees (default: the user themselves).
8. Preview the complete issue:
   > **New issue in {repo}:**
   > **Title:** {title}
   > **Labels:** `bug`, `P2`
   > **Assignees:** @{user}
   >
   > {full body}
9. Confirm with #tool:ask_questions: **Create** (recommended), **Edit title**, **Edit body**, **Change labels**, **Cancel**.
10. Create with #tool:mcp_github_github_create_issue.
11. Confirm with link to the created issue.
