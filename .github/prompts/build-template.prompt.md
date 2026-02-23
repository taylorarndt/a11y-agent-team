---
name: build-template
description: "Interactive wizard to build a GitHub issue template, PR template, or discussion template step-by-step -- no YAML knowledge required"
agent: template-builder
tools:
  - github/*
  - readFile
  - createFile
  - createDirectory
  - listDirectory
  - ask_questions
---

Build a GitHub template interactively. Answer questions and get a production-ready YAML or Markdown template.

${input:goal:Optional: describe what you want -- e.g. 'bug report template', 'feature request template', 'security report', 'PR template' -- or leave blank to be guided}

## Steps

### Step 1: Determine Template Type

If not already clear from the input, ask:
- **Issue template** (`.github/ISSUE_TEMPLATE/name.yml`) -- structured form for filing issues
- **PR template** (`.github/pull_request_template.md`) -- checklist shown when opening a pull request
- **Discussion template** -- guided structure for GitHub Discussions

For **issue templates**, also ask:
- Template name (e.g., "Bug Report", "Feature Request")
- One-line description shown in the template chooser
- Default title prefix (e.g., `[BUG]`, `[FEAT]`, `[A11Y]`)
- Labels to auto-apply (comma-separated)
- Should this template be shown in the template chooser? (yes/no)

### Step 2: Check for Existing Templates

Use #tool:listDirectory to look in `.github/ISSUE_TEMPLATE/`:
- List existing templates so the user can see what already exists
- Warn if a template with the same name already exists

### Step 3: Build Fields Interactively

For each field, use #tool:ask_questions to collect:

1. **Field type** (with descriptions):
   - `markdown` -- informational text the user reads (not a form field)
   - `input` -- single-line text answer
   - `textarea` -- multi-line text (good for descriptions, steps to reproduce)
   - `dropdown` -- pick one from a list
   - `checkboxes` -- check all that apply

2. **Label** -- the question or label shown above the field

3. **Description / placeholder** -- optional helper text

4. **Required?** -- yes or no

5. For `textarea` only: Enable syntax highlighting? If yes, what language?

6. For `dropdown` only:
   - Options (one per line or comma-separated)
   - Allow multiple selections?

7. **Another field?** -- repeat until done

### Step 4: Generate the Template

Produce the complete YAML (for issue templates) or Markdown (for PR/discussion templates).

**Issue template YAML format:**
```yaml
name: Bug Report
description: Report a bug or unexpected behavior
title: "[BUG] "
labels: ["bug", "needs-triage"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to report this. Please fill in as much detail as you can.

  - type: textarea
    id: description
    attributes:
      label: What happened?
      description: A clear description of the bug.
      placeholder: Describe what went wrong...
    validations:
      required: true

  - type: dropdown
    id: severity
    attributes:
      label: Severity
      options:
        - Critical
        - High
        - Medium
        - Low
    validations:
      required: true
```

### Step 5: Review and Save

1. Show the complete template in a syntax-highlighted code block.
2. Ask: any fields to add, reorder, or change?
3. On approval:
   - Use #tool:createDirectory to ensure `.github/ISSUE_TEMPLATE/` exists.
   - Use #tool:createFile to save the template at the correct path.
   - Confirm: _"Template saved to `.github/ISSUE_TEMPLATE/{name}.yml`"_
4. Provide next steps:
   - How to test it (open a new issue in the repo)
   - How to configure the template chooser (`config.yml`)
   - How to update it later

### Tips

- Don't know what fields to add? Describe what information you need from issue reporters and the agent will suggest fields.
- For a full pre-built accessibility bug template: use `/build-a11y-template`
- To edit an existing template: paste the YAML and say what to change.
