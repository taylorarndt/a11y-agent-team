# build-template

Build a GitHub issue template interactively. The agent guides you through field selection - markdown sections, text inputs, dropdowns, and checkboxes - then outputs valid YAML and confirms before saving.

## When to Use It

- Creating a custom bug report template for your project
- Building a feature request form with structured fields
- Setting up a template for recurring issue types
- Teaching contributors exactly what information to provide

## How to Launch It

**In GitHub Copilot Chat:**

```text
/build-template
```

With a starting description:

```text
/build-template bug report for a web app
/build-template feature request with priority dropdown
```

## What to Expect

1. **Determine template type** - Bug / Feature / Task / Question or custom
2. **Guide field selection** - Interactive builder for each field type
3. **Assemble YAML** - Produces the complete `.github/ISSUE_TEMPLATE/*.yml` output
4. **Preview** - Shows rendered form and raw YAML side by side
5. **Confirm** - Saves only after you confirm the structure

### Supported Field Types

| Type | YAML key | When to use |
|------|---------|-------------|
| markdown | `type: markdown` | Static instructional text or section headers |
| input | `type: input` | Short single-line answers (title, version, URL) |
| textarea | `type: textarea` | Long descriptions, steps to reproduce, logs |
| dropdown | `type: dropdown` | Constrained choices (OS, browser, severity) |
| checkboxes | `type: checkboxes` | Multi-select checklist (tested on, confirms) |

### Interactive Builder Flow

```text
Agent: What type of template are you building?
  (bug / feature / task / question / custom)

You: bug report

Agent: Let's build your fields.
  
  Field 1 of ? - What's the first field?
  e.g. "OS dropdown", "steps to reproduce textarea", "version input"

You: OS dropdown with options: Windows, macOS, Linux, iOS, Android, Other

Agent:  Field added: OS (dropdown)
  Options: Windows | macOS | Linux | iOS | Android | Other

  Next field? (or "done" to finish)
```

### Sample Output

```yaml
name: Bug Report
description: Report a reproducible bug
title: "[Bug]: "
labels: ["bug", "triage-needed"]
body:
  - type: markdown
    attributes:
      value: |
        Thanks for taking the time to report this bug!
  - type: dropdown
    id: os
    attributes:
      label: Operating System
      options:
        - Windows
        - macOS
        - Linux
        - iOS
        - Android
        - Other
    validations:
      required: true
  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      placeholder: "1. Go to... 2. Click..."
    validations:
      required: true
```

## Example Variations

```text
/build-template                              # Start from scratch, interactive
/build-template bug report                  # Pre-fill type, then guided
/build-template feature request with priority dropdown
/build-template see existing               # Show current templates in repo
```

## Connected Agents

| Agent | Role |
|-------|------|
| template-builder agent | Executes this prompt |

## Related Prompts

- [build-a11y-template](build-a11y-template.md) - pre-built accessibility bug template
- [create-issue](create-issue.md) - use the template to file an issue
