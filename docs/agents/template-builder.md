# template-builder - Interactive GitHub Template Wizard

> A step-by-step guided wizard for creating GitHub issue templates, PR templates, and discussion templates. Answer questions in plain English and get production-ready YAML - no manual YAML writing required. Every template is previewed before it is saved.

---

## What This Agent Is For

GitHub issue templates are the front door of your project. A good template collects exactly the information needed to fix a bug or evaluate a feature. A bad one gets ignored or half-filled. Writing the YAML by hand is fiddly, and most people leave it unfinished.

The template-builder removes all of that friction. It asks you the right questions in the right order, drafts the YAML, shows it to you, and saves it to the correct location.

Use template-builder when:

- You want to add or improve issue templates for a repo
- You want to build an accessibility-specific bug report with screen reader and WCAG fields pre-wired
- You want a PR template that enforces a checklist before merge
- You need a discussion category template
- You want to generate a template chooser (`config.yml`) so GitHub shows a nice selection screen instead of a blank issue

**The wizard always runs interactively.** You never have to write YAML. You answer conversational questions and the agent builds the file.

---

## How to Launch It

### GitHub Copilot (VS Code)

```text
@template-builder create accessibility bug template
@template-builder build a feature request template
@template-builder make a security report template
@template-builder what templates do I have?
```

### Claude Code (Terminal)

```bash
/template-builder create issue template
/template-builder build accessibility template
/template-builder list existing templates
```

### Via GitHub Hub

```text
@github-hub build template
@github-hub create issue template
```

---

## What to Expect - Step by Step

The wizard runs in three phases. Here is a complete walkthrough starting from `@template-builder create accessibility bug template`:

### Phase 1 - Template Metadata

The agent asks four questions:

1. **Name** - The display name shown in GitHub's template chooser (e.g., "Accessibility Bug Report")
2. **Description** - One line shown under the template name in the chooser
3. **Default title prefix** - e.g., `[A11Y]` or `[BUG]` - pre-fills the issue title when someone picks this template
4. **Auto-apply labels** - comma-separated labels to attach to every issue from this template (e.g., `bug, accessibility, triage`)

Generated frontmatter:

```yaml
name: Accessibility Bug Report
description: Report a screen reader, keyboard navigation, or WCAG compliance issue
title: "[A11Y] "
labels: ["bug", "accessibility", "triage"]
```

### Phase 2 - Adding Fields One by One

For each field the agent asks:

- **Field type:** `markdown` (instructional text), `input` (one line), `textarea` (multi-line), `dropdown` (select list), `checkboxes`
- **Label** - the heading users see
- **Description / help text** - secondary text below the label
- **Required?** - yes or no
- **For `textarea`:** should code highlighting be enabled? Which language?
- **For `dropdown`:** what are the options? (comma-separated or one per line)
- **Another field?** - continue or move to Phase 3

Example generated field:

```yaml
  - type: dropdown
    id: screen-reader
    attributes:
      label: Screen Reader
      description: Which screen reader are you using?
      options:
        - NVDA
        - JAWS
        - VoiceOver (macOS/iOS)
        - TalkBack (Android)
        - Other
    validations:
      required: true
```

### Phase 3 - Review and Save

1. The agent shows the complete YAML template in a code block.
2. Asks: "Does this capture everything you need? Any fields to reorder or remove?"
3. On confirmation, generates usage instructions: where to save the file, how to test it, and whether you need a `config.yml`.
4. Saves to `.github/ISSUE_TEMPLATE/{slug}.yml`.

---

## Pre-Built: Guided Accessibility Template

The most common use case has a dedicated shortcut. Say "create accessibility template" and the agent pre-populates Phase 2 with the standard accessibility bug fields:

<details>
<summary>Expand pre-built accessibility template field list</summary>

The guided accessibility template includes these fields by default (you can edit each one during the wizard):

| Field | Type | Required |
|-------|------|---------|
| Component affected | dropdown (agent/tool names) | No |
| Screen reader | dropdown (NVDA, JAWS, VoiceOver, TalkBack, Other) | Yes |
| Browser | dropdown (Chrome, Firefox, Safari, Edge, Other) | Yes |
| Operating system | dropdown | No |
| Expected behavior | textarea | Yes |
| Actual behavior | textarea | Yes |
| Steps to reproduce | textarea | Yes |
| WCAG success criterion | dropdown (major criteria) | No |
| Before submitting checklist | checkboxes | Yes |

</details>

You still walk through each field to confirm or adjust before the YAML is generated.

---

## Template Types You Can Build

<details>
<summary>Expand all supported template types</summary>

### Issue Templates (YAML form format)

Saved to `.github/ISSUE_TEMPLATE/{name}.yml`. The wizard supports all YAML field types:

- `markdown` - informational text shown in the form but not submitted as a field
- `input` - single-line text (good for URLs, versions, short answers)
- `textarea` - multi-line text with optional syntax highlighting
- `dropdown` - single or multi-select list
- `checkboxes` - multiple required acknowledgments (e.g., "I have searched existing issues")

### Pull Request Template

Saved to `.github/PULL_REQUEST_TEMPLATE.md`. The agent generates a checklist-driven Markdown template with: what the PR does, why, how it was tested, and a pre-submit checklist.

### Template Chooser Config

Saved to `.github/ISSUE_TEMPLATE/config.yml`. Controls what GitHub shows in the "New Issue" chooser:

- Disable blank issues (force template selection)
- Add external links (e.g., link to Discussions for questions, link to Security policy for vulnerabilities)

</details>

---

## Example Prompts

<details>
<summary>Show example prompts</summary>

### Starting the Wizard

```text
@template-builder create a bug report template
@template-builder create accessibility bug template
@template-builder create a feature request template
@template-builder create a security vulnerability report template
```

### Managing Existing Templates

```text
@template-builder list my existing issue templates
@template-builder update the bug report template - add a "Severity" dropdown
@template-builder add a checklist field to my feature request template
@template-builder create the template chooser config for my repo
```

### PR and Discussion Templates

```text
@template-builder create a PR template with an accessibility checklist
@template-builder build a PR template requiring issue linkage and testing notes
@template-builder what templates should my open source project have?
```

</details>

---

## Connections to Other Agents

<details>
<summary>Expand agent connections</summary>

| Handoff | When | Agent |
|---------|------|-------|
| File an issue with the new template | Immediately test the template by creating a real issue | [issue-tracker](issue-tracker.md) |
| Community health check | Review whether all required templates are present | [contributions-hub](contributions-hub.md) |
| Continue with repo setup | Head back to general repo management after templates | [repo-manager](repo-manager.md) |

</details>

---

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- **Wizard mode is the default** - the agent always starts with guided questions rather than generating a template from thin air
- **Never overwrites existing templates without confirming** - checks `.github/ISSUE_TEMPLATE/` for existing files first and shows a diff before replacing
- **YAML form format only** - never generates the legacy Markdown-style `---` frontmatter templates; YAML forms are the current standard
- **Always includes `config.yml`** - every template set generation ends with an offer to create or update the template chooser config
- **Preview before saving** - the full generated YAML is always shown before the file is written to disk
- **Valid field IDs** - YAML `id` fields are silently enforced as lowercase, hyphenated, no spaces

</details>

---

## Troubleshooting

<details>
<summary>Show troubleshooting help</summary>

**"My template does not appear in the GitHub 'New Issue' chooser."**
The template must be in `.github/ISSUE_TEMPLATE/` (not the root). The filename must end in `.yml`. Also make sure there is a `config.yml` in the same folder or `blank_issues_enabled: true`. Ask: "create a template chooser config for my templates."

**"GitHub shows the YAML as raw text instead of a form."**
YAML form templates require the `body:` key and at least one field. If the file is missing `body:` or has invalid YAML, GitHub falls back to displaying raw text. Ask: "validate my issue template YAML."

**"I want to reorder my fields after generating."**
Say: "reorder the fields - put Steps to Reproduce before Expected Behavior." The agent regenerates the YAML with the new order.

**"The dropdown options are showing up in the wrong order."**
Options render in the order listed in the YAML. Say: "reorder the options in the Screen Reader dropdown - put NVDA first" and the agent updates the file.

</details>
