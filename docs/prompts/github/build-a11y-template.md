# build-a11y-template

Generate a complete, pre-built GitHub issue template specifically for accessibility bug reports. Includes fields for screen reader, browser, OS, component, expected/actual behavior, steps to reproduce, WCAG criterion, and a pre-certification checklist.

## When to Use It

- Setting up an accessibility bug report template for a new project
- Replacing a generic bug template with one tailored to accessibility issues
- Ensuring screen reader and keyboard testing context is captured with every accessibility report
- Teaching contributors what information accessibility reviewers need

## How to Launch It

**In GitHub Copilot Chat:**

```text
/build-a11y-template
```

With a target repo:

```text
/build-a11y-template owner/repo
```

## What to Expect

1. **Generate the template** - Produces a complete YAML template immediately (no interactive builder needed)
2. **Preview** - Shows the full rendered form and raw YAML
3. **Offer customization** - Asks if any fields should be altered for your project's stack
4. **Save with confirmation** - Writes to `.github/ISSUE_TEMPLATE/accessibility-bug.yml`

### Pre-Built Template Fields

| Field | Type | Notes |
|-------|------|-------|
| Issue Type | Dropdown | Screen Reader / Keyboard / Visual / Audio / Cognitive / Other |
| Screen Reader | Dropdown | NVDA + Firefox, JAWS + Chrome, VoiceOver + Safari, Narrator + Edge, None, Other |
| Browser | Dropdown | Chrome, Firefox, Safari, Edge, Other |
| OS | Dropdown | Windows, macOS, iOS, Android, Linux |
| Component / Page | Input | Where the issue occurs |
| Expected Behavior | Textarea | What should happen |
| Actual Behavior | Textarea | What actually happens |
| Steps to Reproduce | Textarea | Numbered steps |
| WCAG Criterion | Input | e.g., WCAG 1.4.3, 2.4.7 |
| Product Version | Input | App version or commit SHA |
| Pre-submission Checklist | Checkboxes | Tested, keyboard nav confirmed, AT version noted |

### Sample Output

```yaml
name: Accessibility Bug Report
description: Report an accessibility issue
title: "[A11y]: "
labels: ["accessibility", "bug", "triage-needed"]
body:
  - type: markdown
    attributes:
      value: |
        ## Accessibility Bug Report
        Please fill out all required fields to help us reproduce and fix this issue.
  - type: dropdown
    id: issue-type
    attributes:
      label: Issue Type
      description: What kind of accessibility issue is this?
      options:
        - Screen Reader
        - Keyboard Navigation
        - Visual / Color
        - Audio / Video
        - Cognitive / Language
        - Other
    validations:
      required: true
  - type: dropdown
    id: screen-reader
    attributes:
      label: Screen Reader (if applicable)
      options:
        - NVDA + Firefox
        - JAWS + Chrome
        - VoiceOver + Safari (macOS)
        - VoiceOver + Safari (iOS)
        - Narrator + Edge
        - TalkBack + Chrome (Android)
        - None
        - Other
  ...
```

### Customization Options

After generating the template, the agent offers:

- Add a dropdown for your specific components or pages
- Change required vs. optional status on any field
- Add a severity dropdown (Critical / High / Medium / Low)
- Adjust the label set

## Connected Agents

| Agent | Role |
|-------|------|
| template-builder agent | Executes this prompt |

## Related Prompts

- [build-template](build-template.md) - interactive custom template builder
- [create-issue](create-issue.md) - use the template to file an accessibility bug
- [a11y-update](a11y-update.md) - view recent accessibility issues filed with this template
