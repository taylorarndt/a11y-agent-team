---
name: build-a11y-template
description: "Generate a production-ready GitHub accessibility bug report issue template with screen reader, browser, OS, WCAG, and reproduction fields -- ready to save and use immediately"
agent: template-builder
tools:
  - github/*
  - readFile
  - createFile
  - createDirectory
  - listDirectory
  - ask_questions
---

Generate a production-ready accessibility bug report template for your GitHub repository.

${input:customization:Optional: any customization -- e.g. 'add a field for our component names: Sidebar, Header, Modal', 'use our labels: a11y, triage', 'include a field for our app version' -- or leave blank to use the standard template}

## Steps

### Step 1: Confirm Customization

If customization was provided, incorporate it. If not, check one thing:
- Ask: "Should the Component field list your specific component names, or use free text?" (Use #tool:ask_questions with options: "Free text is fine" / "Let me add our component names")
- If they want to add component names, collect them.

### Step 2: Check for Existing Templates

Use #tool:listDirectory to inspect `.github/ISSUE_TEMPLATE/`:
- If an `accessibility` or `a11y` template already exists, warn the user and offer to overwrite or rename.

### Step 3: Generate the Template

Produce this complete accessibility bug report template, incorporating any customizations:

```yaml
name: Accessibility Bug Report
description: Report a screen reader, keyboard navigation, or visual accessibility issue
title: "[A11Y] "
labels: ["accessibility", "bug"]
body:
  - type: markdown
    attributes:
      value: |
        Thank you for helping make this project more accessible. Please provide as much detail as you can -- it helps us reproduce and fix the issue faster.

        **Not sure if this is an accessibility issue?** If someone using a screen reader, keyboard, or other assistive technology would find it harder to use -- it belongs here.

  - type: dropdown
    id: issue-type
    attributes:
      label: Issue Type
      description: What kind of accessibility issue is this?
      options:
        - Screen reader -- content not announced or announced incorrectly
        - Screen reader -- focus not managed correctly
        - Keyboard -- cannot reach or operate a control with keyboard
        - Keyboard -- focus order is confusing or illogical
        - Visual -- insufficient color contrast
        - Visual -- content lost when zoomed or text resized
        - Visual -- animations or motion cause discomfort
        - Cognitive -- unclear labels, instructions, or error messages
        - Other
    validations:
      required: true

  - type: dropdown
    id: screen-reader
    attributes:
      label: Assistive Technology
      description: Which assistive technology were you using? (Select "Not applicable" for visual or keyboard-only issues)
      options:
        - NVDA (Windows)
        - JAWS (Windows)
        - VoiceOver (macOS)
        - VoiceOver (iOS)
        - TalkBack (Android)
        - Narrator (Windows)
        - Dragon NaturallySpeaking
        - Switch Access
        - Keyboard only (no screen reader)
        - Not applicable
        - Other
    validations:
      required: true

  - type: dropdown
    id: browser
    attributes:
      label: Browser
      options:
        - Chrome
        - Firefox
        - Safari
        - Edge
        - Not applicable (desktop app)
        - Other
    validations:
      required: true

  - type: dropdown
    id: os
    attributes:
      label: Operating System
      options:
        - Windows 11
        - Windows 10
        - macOS Sequoia (15)
        - macOS Sonoma (14)
        - macOS Ventura (13)
        - Ubuntu / Linux
        - iOS
        - Android
        - Other
    validations:
      required: true

  - type: input
    id: component
    attributes:
      label: Component or Area
      description: Which part of the app is affected?
      placeholder: e.g. Login form, Navigation menu, Modal dialog, Data table
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      description: What should happen? Describe what an accessible experience looks like.
      placeholder: e.g. "When I press Tab, focus should move to the Submit button. My screen reader should announce 'Submit button'."
    validations:
      required: true

  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
      description: What actually happens? Be specific about what your assistive technology announces, where focus lands, or what is missing.
      placeholder: e.g. "Focus disappears after clicking the dropdown. Nothing is announced by NVDA."
    validations:
      required: true

  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      description: Step-by-step instructions so we can reproduce the issue.
      placeholder: |
        1. Navigate to ...
        2. Press Tab until focus is on ...
        3. Press Enter
        4. Observe that ...
    validations:
      required: true

  - type: dropdown
    id: wcag
    attributes:
      label: WCAG Success Criterion (if known)
      description: Which WCAG guideline does this relate to? Select "Not sure" if you don't know -- that's completely fine.
      options:
        - Not sure
        - 1.1.1 Non-text Content (A)
        - 1.3.1 Info and Relationships (A)
        - 1.3.2 Meaningful Sequence (A)
        - 1.3.3 Sensory Characteristics (A)
        - 1.4.1 Use of Color (A)
        - 1.4.3 Contrast (Minimum) (AA)
        - 1.4.4 Resize Text (AA)
        - 1.4.11 Non-text Contrast (AA)
        - 2.1.1 Keyboard (A)
        - 2.1.2 No Keyboard Trap (A)
        - 2.4.3 Focus Order (A)
        - 2.4.7 Focus Visible (AA)
        - 3.2.1 On Focus (A)
        - 3.3.1 Error Identification (A)
        - 3.3.2 Labels or Instructions (A)
        - 4.1.2 Name, Role, Value (A)
        - 4.1.3 Status Messages (AA)
        - Other

  - type: input
    id: app-version
    attributes:
      label: App Version
      description: What version of the app were you using?
      placeholder: e.g. 1.4.2, main branch, latest

  - type: checkboxes
    id: checklist
    attributes:
      label: Before Submitting
      options:
        - label: I searched for existing issues and this is not a duplicate
          required: true
        - label: I can reproduce this consistently (not a one-time occurrence)
          required: false
        - label: I tested with the latest version of the app
          required: false
```

### Step 4: Apply Customizations and Save

1. Apply any field customizations requested (component names, custom labels, app-specific version numbers, etc.).
2. Show the complete final template.
3. Confirm before saving.
4. Use #tool:createDirectory to ensure `.github/ISSUE_TEMPLATE/` exists.
5. Use #tool:createFile to save as `.github/ISSUE_TEMPLATE/accessibility-bug.yml`.
6. Confirm: _"Accessibility bug template saved to `.github/ISSUE_TEMPLATE/accessibility-bug.yml`"_

### Step 5: Offer Next Steps

- "Want to test it by opening a new issue in your repo?"
- "Want to add this template to your `config.yml` chooser?"
- "Want to also add a `good first issue` label for newcomers to help with accessibility fixes?"
- "Use `@contributions-hub` to check your overall community health, including template coverage."
