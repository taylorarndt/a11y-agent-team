# Agent Reference

This directory contains detailed documentation for every agent in the A11y Agent Team. Each agent has its own page with full usage examples, behavioral constraints, and what it catches.

## How Agents Work — The Mental Model

Think of the A11y Agent Team as a consulting team of accessibility specialists. You do not need to know which specialist to call — that is the lead's job. But you *can* call any specialist directly when you already know what you need.

**The accessibility-lead** is your single point of contact. Tell it what you are building or reviewing, and it will figure out which specialists are needed, invoke them, and compile the findings. If you only remember one agent name, remember this one.

**The nine code specialists** (aria-specialist, modal-specialist, contrast-master, keyboard-navigator, live-region-controller, forms-specialist, alt-text-headings, tables-data-specialist, link-checker) each own one domain of web accessibility. They write code, review code, and report issues within their area. They do not overlap — each has a clear boundary.

**The six document specialists** (word-accessibility, excel-accessibility, powerpoint-accessibility, office-scan-config, pdf-accessibility, pdf-scan-config) scan Office and PDF documents for accessibility issues.

**The web-accessibility-wizard** runs interactive guided web audits. It walks you through your entire project phase by phase, asks questions to understand your context, invokes the right specialists at each step, and produces a prioritized action plan with an accessibility scorecard.

**The document-accessibility-wizard** does the same for Office and PDF documents, with cross-document analysis, severity scoring, remediation tracking, and VPAT/ACR compliance export.

**The testing-coach** does not write product code. It teaches you how to test what the other agents built.

**The wcag-guide** does not write or review code. It explains the Web Content Accessibility Guidelines in plain language.

## Invocation Syntax

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
| Workspace instructions | Automatic — loaded on every conversation | Ensures accessibility guidance is always present |

## Web Accessibility Agents

| Agent | Domain | Documentation |
|-------|--------|---------------|
| [accessibility-lead](accessibility-lead.md) | Orchestrator — coordinates all specialists | [Full docs](accessibility-lead.md) |
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
| [testing-coach](testing-coach.md) | Screen reader and keyboard testing | [Full docs](testing-coach.md) |
| [wcag-guide](wcag-guide.md) | WCAG 2.2 criteria reference | [Full docs](wcag-guide.md) |

## Document Accessibility Agents

| Agent | Domain | Documentation |
|-------|--------|---------------|
| [word-accessibility](word-accessibility.md) | Word (DOCX) scanning | [Full docs](word-accessibility.md) |
| [excel-accessibility](excel-accessibility.md) | Excel (XLSX) scanning | [Full docs](excel-accessibility.md) |
| [powerpoint-accessibility](powerpoint-accessibility.md) | PowerPoint (PPTX) scanning | [Full docs](powerpoint-accessibility.md) |
| [office-scan-config](office-scan-config.md) | Office scan configuration | [Full docs](office-scan-config.md) |
| [pdf-accessibility](pdf-accessibility.md) | PDF scanning (PDF/UA) | [Full docs](pdf-accessibility.md) |
| [pdf-scan-config](pdf-scan-config.md) | PDF scan configuration | [Full docs](pdf-scan-config.md) |
| [document-accessibility-wizard](document-accessibility-wizard.md) | Guided document audit | [Full docs](document-accessibility-wizard.md) |

## Tips for Getting the Best Results

**Be specific about context.** Instead of "review this file," say "review the modal in this file for focus trapping and escape behavior." Specific prompts activate the right specialist knowledge.

**Name the component type.** Instead of "check this code," say "check this combobox" or "review this sortable data table." Component type maps directly to specialist expertise.

**Ask for audits when you want breadth.** Use the accessibility-lead for broad reviews. Use individual specialists when you know exactly what domain you are concerned about.

**Chain specialists for complex components.** A modal with a form inside it? Invoke modal-specialist for the overlay behavior and forms-specialist for the form content. Or just use accessibility-lead and let it coordinate.

**Use testing-coach after building.** The code specialists help you write correct code. Testing-coach helps you verify it actually works. These are different activities.

**Use wcag-guide when debating.** If your team disagrees about what WCAG requires, ask wcag-guide. It gives definitive answers with criterion references, not opinions.
