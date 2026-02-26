# Research Sources and Attribution

This document records the authoritative sources consulted during the comprehensive audit and strengthening of all web accessibility agent rules. Each source directly informed specific agent updates, ensuring every rule and guidance in this project is grounded in real-world, standards-based best practices.

## W3C WAI ARIA Authoring Practices Guide (APG)

The W3C APG is the definitive reference for ARIA pattern implementation. It provides design patterns, keyboard interaction models, and code examples for every common interactive widget.

### Landmark Regions Practice

- **URL:** [https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/](https://www.w3.org/WAI/ARIA/apg/practices/landmark-regions/)
- **Agents strengthened:** aria-specialist, web-accessibility-baseline.instructions.md
- **Key findings applied:**
  - Region landmarks should be reserved for "sufficiently important" content -- not every section
  - `aria-labelledby` preferred over `aria-label` when a heading exists
  - Canonical landmark count for typical pages: 5-6 total

### Dialog (Modal) Pattern

- **URL:** [https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/](https://www.w3.org/WAI/ARIA/apg/patterns/dialog-modal/)
- **Agents strengthened:** modal-specialist
- **Key findings applied:**
  - Scenario-based focus placement: least destructive action for confirmations, heading for complex content, first focusable as default
  - `aria-modal="true"` as modern replacement for manual `aria-hidden` toggling on background
  - Visible close button recommendation
  - Non-modal dialog pattern (`dialog.show()` vs `showModal()`)

### Alert and Message Dialogs Pattern

- **URL:** [https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/](https://www.w3.org/WAI/ARIA/apg/patterns/alertdialog/)
- **Agents strengthened:** modal-specialist
- **Key findings applied:**
  - AlertDialog focus on least destructive action (Cancel over Delete)
  - `aria-describedby` usage for dialog descriptions

### Alert Pattern

- **URL:** [https://www.w3.org/WAI/ARIA/apg/patterns/alert/](https://www.w3.org/WAI/ARIA/apg/patterns/alert/)
- **Agents strengthened:** live-region-controller
- **Key findings applied:**
  - Alerts must not affect keyboard focus
  - Alerts present in DOM at page load are NOT announced
  - Avoid auto-disappearing alerts (WCAG 2.2.3, 2.2.4)
  - Avoid frequent alert interruptions

### Developing a Keyboard Interface

- **URL:** [https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/](https://www.w3.org/WAI/ARIA/apg/practices/keyboard-interface/)
- **Agents strengthened:** keyboard-navigator
- **Key findings applied:**
  - Roving tabindex algorithm with complete code pattern
  - `aria-activedescendant` as alternative to roving tabindex
  - When to use which approach (comparison table)
  - Disabled element focus conventions: remove standalone from tab, keep focusable in composites (listbox options, menu items, tabs, tree items, toolbar buttons)
  - `inert` attribute as native replacement for aria-hidden toggling
  - Keyboard shortcut conflicts with OS, AT, and browser reserved keys
  - Scroll containers need `tabindex="0"` for keyboard scrolling

### Combobox Pattern

- **URL:** [https://www.w3.org/WAI/ARIA/apg/patterns/combobox/](https://www.w3.org/WAI/ARIA/apg/patterns/combobox/)
- **Agents strengthened:** forms-specialist
- **Key findings applied:**
  - Two combobox types: editable and select-only
  - Complete structure with required ARIA attributes
  - Four autocomplete behaviors (none, list, both, inline)
  - Use `aria-controls` not `aria-owns` (corrected common mistake)
  - `aria-activedescendant` for option tracking
  - Live region for result count announcements

### Providing Accessible Names and Descriptions

- **URL:** [https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)
- **Agents strengthened:** aria-specialist
- **Key findings applied:**
  - Five cardinal rules for naming elements
  - Name calculation precedence order
  - WARNING: `aria-label` hides descendant content on roles supporting "naming from contents"
  - Composing effective names: function not form, distinguishing word first, 1-3 words, no role name
  - Description techniques (`aria-describedby`, `aria-description`)

## W3C WCAG 2.2 Understanding Documents

The Understanding documents provide detailed explanations, examples, and techniques for each WCAG success criterion.

### Focus Appearance (SC 2.4.13)

- **URL:** [https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html](https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html)
- **Agents strengthened:** contrast-master
- **Key findings applied:**
  - 2px thick perimeter minimum for focus indicators
  - 3:1 change-of-contrast between focused and unfocused states
  - C40 two-color focus technique (inner + outer ring)
  - Inset indicators need thickness greater than 2px
  - Relationship to Non-text Contrast (1.4.11) clarified

### Target Size Minimum (SC 2.5.8)

- **URL:** [https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)
- **Agents strengthened:** contrast-master
- **Key findings applied:**
  - 24x24 CSS pixel minimum for interactive targets
  - Spacing exception with 24px diameter circle test
  - Five exceptions: inline, user agent default, equivalent, essential, legally required
  - C42 technique reference

### Accessible Authentication Minimum (SC 3.3.8)

- **URL:** [https://www.w3.org/WAI/WCAG22/Understanding/accessible-authentication-minimum.html](https://www.w3.org/WAI/WCAG22/Understanding/accessible-authentication-minimum.html)
- **Agents strengthened:** forms-specialist
- **Key findings applied:**
  - Never block paste on password or verification code fields
  - Support password managers via `autocomplete` attributes
  - Provide show/hide toggle for password fields
  - Alternative authentication methods: passkeys, WebAuthn, OAuth, biometrics
  - CAPTCHA must have non-cognitive alternatives

## WebAIM (Web Accessibility In Mind)

WebAIM is one of the most respected accessibility organizations, providing practical, real-world accessibility guidance.

### Keyboard Accessibility

- **URL:** [https://webaim.org/techniques/keyboard/](https://webaim.org/techniques/keyboard/)
- **Agents strengthened:** keyboard-navigator
- **Key findings applied:**
  - Validated Tab/Shift+Tab navigation model
  - Arrow key patterns for composite widgets
  - Focus indicator visibility requirements

### Creating Accessible Forms

- **URL:** [https://webaim.org/techniques/forms/](https://webaim.org/techniques/forms/)
- **Agents strengthened:** forms-specialist
- **Key findings applied:**
  - Label clicking behavior: clicking `<label>` activates the associated control, but ARIA labeling techniques do NOT provide this click-to-activate behavior
  - Implicit label wrapping pattern
  - `<search>` element as replacement for `<form role="search">`
  - Redundant Entry (WCAG 3.3.7) auto-populate patterns

### Alternative Text

- **URL:** [https://webaim.org/techniques/alttext/](https://webaim.org/techniques/alttext/)
- **Agents strengthened:** alt-text-headings
- **Key findings applied:**
  - Context determines alt text -- same image can be informative, functional, or decorative
  - Logo alt text should be the company name, not "logo" or description of appearance
  - Form image buttons describe the function, not the image
  - CSS background images must be decorative only

### Links and Hypertext

- **URL:** [https://webaim.org/techniques/hypertext/](https://webaim.org/techniques/hypertext/)
- **Agents strengthened:** link-checker
- **Key findings applied:**
  - `<a>` without `href` is not keyboard focusable
  - Do not include "link" in link text (screen reader already announces the role)
  - WCAG 2.5.3 Label in Name: `aria-label` must include the visible text
  - `download` attribute patterns for file links

### Creating Accessible Tables (Data Tables)

- **URL:** [https://webaim.org/techniques/tables/data](https://webaim.org/techniques/tables/data)
- **Agents strengthened:** tables-data-specialist
- **Key findings applied:**
  - `<caption>` must be the first child element after `<table>`
  - All `<th>` elements should have explicit `scope` (even in simple tables)
  - `headers`/`id` associations are a last resort only
  - `summary` attribute is deprecated in HTML5
  - Proportional sizing over fixed pixel widths

### Creating Accessible Tables (Layout Tables)

- **URL:** [https://webaim.org/techniques/tables/](https://webaim.org/techniques/tables/)
- **Agents strengthened:** tables-data-specialist
- **Key findings applied:**
  - Layout table detection criteria: no `<th>`, no `<caption>`, no `scope`/`headers`, data nonsensical in cell order
  - `<thead>`/`<tbody>`/`<tfoot>` provide no accessibility semantics
  - Flatten deeply nested `colspan`/`rowspan` tables when possible

## W3C WAI Images Tutorial

- **URL:** [https://www.w3.org/WAI/tutorials/images/](https://www.w3.org/WAI/tutorials/images/)
- **Agents strengthened:** alt-text-headings
- **Key findings applied:**
  - Seven image categories: informative, decorative, functional, text images, complex, groups, image maps
  - Alt Decision Tree for choosing the right approach
  - `<picture>` element: alt goes on the inner `<img>`, not `<picture>`
  - `<figure>`/`<figcaption>`: img still needs alt, figcaption is supplementary, not a replacement
  - Group images: one gets full alt, others get `alt=""`

## W3C HTML Living Standard

- **URL:** [https://html.spec.whatwg.org/](https://html.spec.whatwg.org/)
- **Agents strengthened:** semantic-html.instructions.md, forms-specialist
- **Key findings applied:**
  - `<search>` element: maps to `role="search"` automatically
  - `<output>` element: implicit `role="status"` (polite live region)
  - `<meter>` vs `<progress>`: distinct purposes (scalar value vs task completion)
  - `<time>` element with `datetime` attribute for machine-readable dates
  - Popover API: `popover` attribute, light-dismiss behavior, top layer promotion

## Deque University / axe-core

- **Implicit reference across all agents**
- **Key influence:**
  - Severity classification model (critical, serious, moderate, minor) used in all agent structured output
  - Rule ID patterns informing what to check
  - Testing methodology for automated + manual review

---

## How Sources Were Applied

Each agent was audited against the relevant authoritative sources for its domain. The audit process:

1. **Inventory:** Identified all 11 web accessibility agent files
2. **Research:** Fetched and analyzed 17+ authoritative source documents
3. **Gap analysis:** Compared each agent's existing rules against the authoritative findings
4. **Targeted edits:** Added missing rules, corrected inaccurate guidance, and strengthened existing rules
5. **Dual-platform sync:** All edits applied to both Copilot (`.github/agents/`) and Claude (`.claude/agents/`) agent files
6. **Instruction files:** Updated shared instruction files (`semantic-html.instructions.md`, `web-accessibility-baseline.instructions.md`)

### Files Updated

| File | Changes |
|------|---------|
| keyboard-navigator | Roving tabindex, aria-activedescendant, inert, disabled focus, shortcut conflicts, scroll containers |
| modal-specialist | Scenario-based focus, aria-modal, non-modal dialogs, Popover API, checklist expansion |
| forms-specialist | `<search>` element, combobox pattern, accessible authentication (3.3.8), redundant entry (3.3.7), label behavior |
| contrast-master | Focus Appearance (2.4.13), Target Size (2.5.8), Text Spacing (1.4.12), Content Reflow (1.4.10) |
| live-region-controller | role="log", role="timer", aria-atomic, aria-relevant, aria-busy, `<output>`, alert pattern |
| link-checker | Label in Name (2.5.3), `<a>` without href, "link" in text, download attribute |
| alt-text-headings | 7 W3C image categories, `<picture>`, CSS backgrounds, logos, form image buttons, figure/figcaption |
| tables-data-specialist | caption-first, scope-always, headers/id last resort, summary deprecated, structural clarifications |
| semantic-html.instructions | `<search>`, `<output>`, `<meter>`/`<progress>`, `<time>` elements |
| aria-specialist | Names and Descriptions: 5 cardinal rules, name precedence, aria-label warning, composing names |
