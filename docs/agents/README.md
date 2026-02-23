# Agent Reference

This directory contains detailed documentation for every agent in the A11y Agent Team. Each agent has its own page with full usage examples, behavioral constraints, and what it catches.

## How Agents Work - The Mental Model

Think of the A11y Agent Team as a consulting team of accessibility specialists. You do not need to know which specialist to call - that is the lead's job. But you *can* call any specialist directly when you already know what you need.

**The accessibility-lead** is your single point of contact. Tell it what you are building or reviewing, and it will figure out which specialists are needed, invoke them, and compile the findings. If you only remember one agent name, remember this one.

**The nine code specialists** (aria-specialist, modal-specialist, contrast-master, keyboard-navigator, live-region-controller, forms-specialist, alt-text-headings, tables-data-specialist, link-checker) each own one domain of web accessibility. They write code, review code, and report issues within their area. They do not overlap - each has a clear boundary.

**The six document specialists** (word-accessibility, excel-accessibility, powerpoint-accessibility, office-scan-config, pdf-accessibility, pdf-scan-config) scan Office and PDF documents for accessibility issues.

**The web-accessibility-wizard** runs interactive guided web audits. It walks you through your entire project phase by phase, asks questions to understand your context, invokes the right specialists at each step, and produces a prioritized action plan with an accessibility scorecard.

**The document-accessibility-wizard** does the same for Office and PDF documents, with cross-document analysis, severity scoring, remediation tracking, and VPAT/ACR compliance export.

**The markdown-a11y-assistant** audits Markdown documentation files across 9 accessibility domains: links, alt text, headings, tables, emoji, diagrams, em-dashes, anchor links, and plain language. It runs per-file parallel scans via `markdown-scanner` and applies fixes via `markdown-fixer`.

**The testing-coach** does not write product code. It teaches you how to test what the other agents built.

**The wcag-guide** does not write or review code. It explains the Web Content Accessibility Guidelines in plain language.

## Invocation Syntax

<details>
<summary>Expand invocation syntax reference</summary>

### Claude Code (Terminal)

| Method | Syntax | When to Use |
|--------|--------|-------------|
| Slash command | `/accessibility-lead review this page` | Direct invocation from the prompt |
| At-mention | `@accessibility-lead review this page` | Alternative syntax, same behavior |
| Automatic (hook) | Just type your prompt normally | The hook fires on every prompt and activates the lead for UI tasks |
| List agents | `/agents` | See all installed agents |

### GitHub Copilot (VS Code / Editor)

| Method | Syntax | When to Use |
|--------|--------|-------------|
| At-mention in Chat | `@accessibility-lead review this page` | Direct invocation in Copilot Chat panel |
| With file context | Select code, then `@aria-specialist check this` | Review selected code |
| Workspace instructions | Automatic - loaded on every conversation | Ensures accessibility guidance is always present |

</details>

## Web Accessibility Agents

<details>
<summary>Expand web accessibility agent reference (16 agents)</summary>

| Agent | Domain | Documentation |
|-------|--------|---------------|
| [accessibility-lead](accessibility-lead.md) | Orchestrator - coordinates all specialists | [Full docs](accessibility-lead.md) |
| [aria-specialist](aria-specialist.md) | ARIA roles, states, properties, widget patterns | [Full docs](aria-specialist.md) |
| [modal-specialist](modal-specialist.md) | Dialogs, drawers, popovers, overlays | [Full docs](modal-specialist.md) |
| [contrast-master](contrast-master.md) | Color contrast, dark mode, visual design | [Full docs](contrast-master.md) |
| [keyboard-navigator](keyboard-navigator.md) | Tab order, focus management, skip links | [Full docs](keyboard-navigator.md) |
| [live-region-controller](live-region-controller.md) | Dynamic content, toasts, loading states | [Full docs](live-region-controller.md) |
| [forms-specialist](forms-specialist.md) | Forms, labels, validation, errors | [Full docs](forms-specialist.md) |
| [alt-text-headings](alt-text-headings.md) | Alt text, SVGs, headings, landmarks | [Full docs](alt-text-headings.md) |
| [tables-data-specialist](tables-data-specialist.md) | Data tables, grids, sortable columns | [Full docs](tables-data-specialist.md) |
| [link-checker](link-checker.md) | Ambiguous link text detection | [Full docs](link-checker.md) |
| [web-accessibility-wizard](web-accessibility-wizard.md) | Guided web accessibility audit | [Full docs](web-accessibility-wizard.md) |
| [cognitive-accessibility](cognitive-accessibility.md) | Cognitive accessibility, plain language, COGA, WCAG 2.2 new criteria | [Full docs](cognitive-accessibility.md) |
| [mobile-accessibility](mobile-accessibility.md) | React Native, iOS/Android accessibility, touch targets | [Full docs](mobile-accessibility.md) |
| [design-system-auditor](design-system-auditor.md) | Design token contrast, focus ring compliance, Tailwind/MUI/shadcn audits | [Full docs](design-system-auditor.md) |
| [testing-coach](testing-coach.md) | Screen reader and keyboard testing | [Full docs](testing-coach.md) |
| [wcag-guide](wcag-guide.md) | WCAG 2.2 criteria reference | [Full docs](wcag-guide.md) |

</details>

## Document Accessibility Agents

<details>
<summary>Expand document accessibility agent reference (9 agents)</summary>

| Agent | Domain | Documentation |
|-------|--------|---------------|
| [word-accessibility](word-accessibility.md) | Word (DOCX) scanning | [Full docs](word-accessibility.md) |
| [excel-accessibility](excel-accessibility.md) | Excel (XLSX) scanning | [Full docs](excel-accessibility.md) |
| [powerpoint-accessibility](powerpoint-accessibility.md) | PowerPoint (PPTX) scanning | [Full docs](powerpoint-accessibility.md) |
| [office-scan-config](office-scan-config.md) | Office scan configuration | [Full docs](office-scan-config.md) |
| [pdf-accessibility](pdf-accessibility.md) | PDF scanning (PDF/UA) | [Full docs](pdf-accessibility.md) |
| [pdf-scan-config](pdf-scan-config.md) | PDF scan configuration | [Full docs](pdf-scan-config.md) |
| [epub-accessibility](epub-accessibility.md) | ePub (EPUB 2/3) scanning | [Full docs](epub-accessibility.md) |
| [epub-scan-config](epub-scan-config.md) | ePub scan configuration | [Full docs](epub-scan-config.md) |
| [document-accessibility-wizard](document-accessibility-wizard.md) | Guided document audit | [Full docs](document-accessibility-wizard.md) |

</details>

## Markdown Accessibility Agents

<details>
<summary>Expand markdown accessibility agent reference (3 agents)</summary>

| Agent | Domain | Documentation |
|-------|--------|--------------|
| [markdown-a11y-assistant](markdown-a11y-assistant.md) | Orchestrator — links, alt text, headings, tables, emoji, diagrams, em-dashes, anchors | [Full docs](markdown-a11y-assistant.md) |
| markdown-scanner | Per-file parallel scanning across all 9 domains (hidden — invoked by orchestrator) | Internal |
| markdown-fixer | Applies auto-fixes and presents human-judgment items (hidden — invoked by orchestrator) | Internal |

</details>

## GitHub Workflow Agents

These agents manage your GitHub repositories, pull requests, issues, and team - the "operating system" layer of a healthy software project. They live alongside the accessibility team but handle an entirely different job: keeping your GitHub world organized, actionable, and fast to navigate.

### The Mental Model

**GitHub Hub** is your single entry point. You never need to know which agent to call. Just describe what you want - "review the PR from this morning," "who's waiting on me?" "onboard our new developer" - and GitHub Hub figures out the rest, asks any clarifying questions intelligently, and routes you to the right specialist with context already loaded.

The ten specialist agents each own a vertical slice of GitHub operations:

- **daily-briefing** owns the *morning picture* - what happened, what needs action
- **pr-review** owns *code review* - diffs, comments, merge decisions
- **issue-tracker** owns *issue work* - triage, response, management
- **analytics** owns *data* - velocity, bottlenecks, health scores
- **insiders-a11y-tracker** owns *accessibility change tracking* - VS Code + your repos
- **repo-admin** owns *access control* - who can do what, branch protection, settings
- **team-manager** owns *people* - onboarding, offboarding, org teams
- **contributions-hub** owns *community* - discussions, health, contributor relationships
- **template-builder** owns *GitHub templates* - issue/PR/discussion templates via guided wizard
- **repo-manager** owns *repo scaffolding* - CI, labels, CONTRIBUTING, SECURITY, README

### Invocation

| Platform | Syntax |
|----------|--------|
| GitHub Copilot (VS Code) | `@github-hub what needs my attention today?` |
| GitHub Copilot (VS Code) | `@daily-briefing morning briefing` |
| Claude Code (Terminal) | `/github-hub show my open PRs` |
| Claude Code (Terminal) | `/pr-review owner/repo#42` |

You can invoke any agent directly if you know exactly what you need. Or start at `@github-hub` and let it route you.

### When to Use GitHub Workflow Agents vs. Accessibility Agents

<details>
<summary>Expand decision guide</summary>

| You want to... | Use |
|---------------|-----|
| Review a PR's accessibility | `@pr-review` + `@accessibility-lead` |
| Track a accessibility bug across issues and PRs | `@issue-tracker` |
| Onboard a new developer to the team | `@team-manager` |
| Get a morning status of all open work | `@daily-briefing` |
| Audit who has access to your repos | `@repo-admin` |
| Write a great issue template for a11y bugs | `@template-builder` |
| See velocity metrics and bottlenecks | `@analytics` |
| Track VS Code a11y changes for the month | `@insiders-a11y-tracker` |

</details>

### GitHub Workflow Agent Reference

<details>
<summary>Expand GitHub workflow agent reference (11 agents)</summary>

| Agent | Role | Documentation |
|-------|------|---------------|
| [github-hub](github-hub.md) | Orchestrator - routes GitHub tasks from plain English | [Full docs](github-hub.md) |
| [daily-briefing](daily-briefing.md) | Morning overview of issues, PRs, CI, and security alerts | [Full docs](daily-briefing.md) |
| [pr-review](pr-review.md) | PR diff analysis, commenting, confidence levels, delta tracking | [Full docs](pr-review.md) |
| [issue-tracker](issue-tracker.md) | Issue triage, priority scoring, response, management | [Full docs](issue-tracker.md) |
| [analytics](analytics.md) | Repo health scoring, velocity, bottleneck detection | [Full docs](analytics.md) |
| [insiders-a11y-tracker](insiders-a11y-tracker.md) | Track accessibility changes with WCAG mapping and delta reports | [Full docs](insiders-a11y-tracker.md) |
| [repo-admin](repo-admin.md) | Collaborator access, branch protection, label sync | [Full docs](repo-admin.md) |
| [team-manager](team-manager.md) | Onboarding, offboarding, org team membership | [Full docs](team-manager.md) |
| [contributions-hub](contributions-hub.md) | Discussions, community health, first-time contributors | [Full docs](contributions-hub.md) |
| [template-builder](template-builder.md) | Guided wizard for issue/PR/discussion template creation | [Full docs](template-builder.md) |
| [repo-manager](repo-manager.md) | Repo scaffolding - CI, labels, contributing guides, SECURITY | [Full docs](repo-manager.md) |

</details>

---

## Parallel Agentic Flow

Multi-agent workflows run parallel execution to minimize wait time. Knowing the model helps you understand why responses arrive in bursts.

### Web Accessibility Parallel Groups

When `web-accessibility-wizard` runs a full audit, specialists execute in three simultaneous groups:

| Group | Agents Running in Parallel |
|-------|---------------------------|
| **Group 1** | `aria-specialist` + `keyboard-navigator` + `forms-specialist` |
| **Group 2** | `contrast-master` + `alt-text-headings` + `link-checker` |
| **Group 3** | `modal-specialist` + `live-region-controller` + `tables-data-specialist` |

All three groups run simultaneously. `cross-page-analyzer` then synthesizes results across groups. This is why a full web audit produces all findings at once rather than one specialist at a time.

### Document Accessibility Parallel Groups

When `document-accessibility-wizard` scans a folder, it distributes by type:

| Type | Agent |
|------|-------|
| `.docx` files | `word-accessibility` |
| `.xlsx` files | `excel-accessibility` |
| `.pptx` files | `powerpoint-accessibility` |
| `.pdf` files   | `pdf-accessibility` |
| `.epub` files  | `epub-accessibility` |

All four type-specialist streams run simultaneously. `cross-document-analyzer` then runs cross-document pattern detection after all scans complete.

### Markdown Accessibility Parallel Groups

When `markdown-a11y-assistant` runs an audit, it dispatches `markdown-scanner` for each file simultaneously:

| What Runs in Parallel | Details |
|-----------------------|---------|
| Per-file `markdown-scanner` calls | One scanner per `.md` file, all running concurrently |
| 9 domain checks per file | Links, alt text, headings, tables, emoji, diagrams, em-dashes, anchors, plain language |

`markdown-fixer` then runs sequentially by file, applying auto-fixable items and surfacing human-judgment items for review.

### GitHub Workflow Parallel Streams

`daily-briefing` runs Batch 1 streams simultaneously:

| Stream | Agent Function |
|--------|---------------|
| Issues | Open issues, @mentions, triage queue |
| PRs | Review requests, authored PRs, CI status |
| Security/CI | Dependabot alerts, failing checks |
| A11y | Latest VS Code Insiders accessibility commits |

`analytics` collects its 5 data streams in parallel: PR metrics, issue metrics, contribution activity, code churn, and bottleneck detection.

### Progress Announcements

Every long-running agent operation narrates its steps aloud. The pattern is universal across all agent teams:

```text
 Starting [operation]…
 Complete - [N items] found
```

You will always know what is happening and when each phase finishes. This is required behavior - no agent silently collects data.

---

## Hook System & Subagent Notification

### Hooks Overview

| Hook | Platform | When It Fires | Purpose |
|------|----------|---------------|---------|
| `SessionStart` | Both | Beginning of session | Injects repo, branch, org, user, and previous audit context into the conversation |
| `SubagentStart` | Both | When an agent is invoked | Forwards session context to the specialist so it never re-asks for what's established |
| `SessionEnd` / Stop | Both | End of session | Quality gate - validates audit report completeness and prompts for missing sections |
| `UserPromptSubmit` | Claude Code | Every prompt | Evaluates whether prompt involves UI code and injects accessibility-lead consideration |

### How Subagent Notification Works

When an orchestrator (e.g., `accessibility-lead`, `web-accessibility-wizard`, `github-hub`) calls a specialist:

1. The orchestrator announces the handoff with an  step narration (e.g., ` Running aria-specialist on interactive components…`)
2. The `SubagentStart` hook passes current session context to the specialist
3. The specialist runs its analysis and returns findings in its **Structured Output** format
4. The orchestrator aggregates findings and announces completion (e.g., ` ARIA scan complete - 3 findings`)
5. All findings are logged to `.github/audit/YYYY-MM-DD.log`

### Audit Log

Every GitHub write action (comment, PR review, label change, merge) and every accessibility report generation is appended to a dated log:

```text
.github/audit/2025-07-01.log
```

You can ask `github-hub` to "show the audit log" for a summary of all actions taken in the current session.

---

## Skills Reference

Skills are reusable knowledge modules loaded by agents at runtime. Each skill defines domain rules, scoring formulas, or scanning patterns that multiple agents share.

| Skill | Domain | Used By |
|-------|--------|---------|
| [`accessibility-rules`](../skills/accessibility-rules.md) | WCAG rule IDs for DOCX, XLSX, PPTX, PDF, EPUB | document-accessibility-wizard, word-accessibility, excel-accessibility, powerpoint-accessibility, pdf-accessibility, epub-accessibility, cross-document-analyzer |
| [`document-scanning`](../skills/document-scanning.md) | File discovery, delta detection, scan profiles | document-accessibility-wizard, document-inventory |
| [`report-generation`](../skills/report-generation.md) | Severity scoring formulas (0-100/A-F), VPAT/ACR export, scorecard format | document-accessibility-wizard, cross-document-analyzer |
| [`web-scanning`](../skills/web-scanning.md) | Web content discovery, URL crawling, axe-core CLI | web-accessibility-wizard, cross-page-analyzer |
| [`web-severity-scoring`](../skills/web-severity-scoring.md) | Web severity 0-100 scores, confidence levels, delta tracking | web-accessibility-wizard, cross-page-analyzer, accessibility-lead |
| [`framework-accessibility`](../skills/framework-accessibility.md) | React, Vue, Angular, Svelte, Tailwind fix templates | accessibility-lead, aria-specialist, forms-specialist, keyboard-navigator |
| [`cognitive-accessibility`](../skills/cognitive-accessibility.md) | WCAG 2.2 cognitive SC, COGA guidance, plain language, reading level, auth patterns | cognitive-accessibility, web-accessibility-wizard, accessibility-lead, forms-specialist |
| [`mobile-accessibility`](../skills/mobile-accessibility.md) | React Native prop reference, iOS/Android accessibility, touch targets | mobile-accessibility |
| [`design-system`](../skills/design-system.md) | Design token contrast formulas, WCAG 2.4.11 focus ring, framework token paths | design-system-auditor, contrast-master |
| [`github-workflow-standards`](../skills/github-workflow-standards.md) | Auth, dual MD+HTML output, HTML accessibility, safety rules, parallel execution | github-hub, daily-briefing, issue-tracker, pr-review, analytics, repo-admin, team-manager, contributions-hub, insiders-a11y-tracker, repo-manager, template-builder |
| [`github-scanning`](../skills/github-scanning.md) | Search query construction, date ranges, cross-repo parallel streams, auto-recovery | github-hub, daily-briefing, issue-tracker, pr-review, analytics, insiders-a11y-tracker |
| [`github-analytics-scoring`](../skills/github-analytics-scoring.md) | Repo health 0-100/A-F, priority scoring, bottleneck detection, velocity metrics | daily-briefing, issue-tracker, pr-review, analytics, repo-admin, insiders-a11y-tracker |
| [`markdown-accessibility`](../skills/markdown-accessibility.md) | Ambiguous link/anchor patterns, emoji handling (remove/translate), Mermaid/ASCII diagram replacement, heading rules, severity scoring | markdown-a11y-assistant, markdown-scanner, markdown-fixer |

---

## Environment Parity

Agents exist in two environments with identical behavior but different file formats.

| Property | GitHub Copilot | Claude Code |
|----------|---------------|-------------|
| Agent directory | `.github/agents/*.agent.md` | `.claude/agents/*.md` |
| Team config | `.github/agents/AGENTS.md` | `.claude/agents/AGENTS.md` |
| Frontmatter model | `model: [Claude Sonnet 4 (copilot)]` | `model: inherit` |
| Handoffs declaration | `handoffs:` block in frontmatter | Described in agent body text |
| Agent cross-calling | `agents:` frontmatter list | Agent body text describes delegation |
| Skills path | `../skills/[skill]/SKILL.md` | `../../.github/skills/[skill]/SKILL.md` |
| Shared instructions | `shared-instructions.md` (relative) | `../../.github/agents/shared-instructions.md` |
| Hooks location | `.github/hooks/` (session lifecycle) | `.claude/settings.json` + `.claude/hooks/` |

Both environments share:

- Identical agent body content (behavioral rules, capabilities, workflows)
- The same 9 `.github/skills/` knowledge files
- The same `preferences.md` format for user configuration
- The same dual `.md` + `.html` output requirement
- The same / progress announcement pattern
- The same High / Medium / Low confidence level system
- The same  /  /  /  delta tracking notation

---

## Tips for Getting the Best Results

<details>
<summary>Expand tips for effective agent use</summary>

**Be specific about context.** Instead of "review this file," say "review the modal in this file for focus trapping and escape behavior." Specific prompts activate the right specialist knowledge.

**Name the component type.** Instead of "check this code," say "check this combobox" or "review this sortable data table." Component type maps directly to specialist expertise.

**Ask for audits when you want breadth.** Use the accessibility-lead for broad reviews. Use individual specialists when you know exactly what domain you are concerned about.

**Chain specialists for complex components.** A modal with a form inside it? Invoke modal-specialist for the overlay behavior and forms-specialist for the form content. Or just use accessibility-lead and let it coordinate.

**Use testing-coach after building.** The code specialists help you write correct code. Testing-coach helps you verify it actually works. These are different activities.

**Use wcag-guide when debating.** If your team disagrees about what WCAG requires, ask wcag-guide. It gives definitive answers with criterion references, not opinions.

</details>
