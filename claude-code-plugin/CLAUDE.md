# Accessibility-First Development

This project enforces WCAG AA accessibility standards for all web UI code.

## Mandatory Accessibility Check

Before writing or modifying any web UI code - including HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content - you MUST:

1. Consider which accessibility specialist agents are needed for the task
2. Apply the relevant specialist knowledge before generating code
3. Verify the output against the appropriate checklists

**Automatic trigger detection:** If a user prompt involves creating, editing, or reviewing any file matching `*.html`, `*.jsx`, `*.tsx`, `*.vue`, `*.svelte`, `*.astro`, or `*.css` - or if the prompt describes building UI components, pages, forms, or visual elements - treat it as a web UI task and apply the Decision Matrix below.

## Available Specialist Agents

| Agent | When to Use |
|-------|------------|
| Accessibility Lead | Any UI task - coordinates all specialists and runs final review |
| ARIA Specialist | Interactive components, custom widgets, ARIA usage |
| Modal Specialist | Dialogs, drawers, popovers, overlays |
| Contrast Master | Colors, themes, CSS styling, visual design |
| Keyboard Navigator | Tab order, focus management, keyboard interaction |
| Live Region Controller | Dynamic content updates, toasts, loading states |
| Forms Specialist | Forms, inputs, validation, error handling, multi-step wizards |
| Alt Text & Headings | Images, alt text, SVGs, heading structure, page titles, landmarks |
| Tables Specialist | Data tables, sortable tables, grids, comparison tables |
| Link Checker | Ambiguous link text, "click here"/"read more" detection |
| Cognitive Accessibility | WCAG 2.2 cognitive SC, COGA guidance, plain language |
| Mobile Accessibility | React Native, Expo, iOS, Android - touch targets, screen readers |
| Design System Auditor | Color token contrast, focus ring tokens, spacing tokens |
| Web Accessibility Wizard | Full guided web accessibility audit |
| Document Accessibility Wizard | Document audit for .docx, .xlsx, .pptx, .pdf |
| Markdown Accessibility | Markdown audit - links, headings, emoji, tables |
| Testing Coach | Screen reader testing, keyboard testing, automated testing |
| WCAG Guide | WCAG 2.2 criteria explanations, conformance levels |

## Slash Commands

Type `/` followed by any command name to invoke the corresponding specialist directly:

| Command | Specialist | Purpose |
|---------|-----------|---------|
| `/aria` | ARIA Specialist | ARIA patterns - roles, states, properties |
| `/contrast` | Contrast Master | Color contrast - ratios, themes, visual design |
| `/keyboard` | Keyboard Navigator | Keyboard nav - tab order, focus, shortcuts |
| `/forms` | Forms Specialist | Forms - labels, validation, error handling |
| `/alt-text` | Alt Text & Headings | Images/headings - alt text, hierarchy, landmarks |
| `/tables` | Tables Specialist | Tables - headers, scope, caption, sorting |
| `/links` | Link Checker | Links - ambiguous text detection |
| `/modal` | Modal Specialist | Modals - focus trap, return, escape |
| `/live-region` | Live Region Controller | Live regions - dynamic announcements |
| `/audit` | Web Accessibility Wizard | Full guided web accessibility audit |
| `/document` | Document Accessibility Wizard | Document audit - Word, Excel, PPT, PDF |
| `/markdown` | Markdown Accessibility | Markdown audit - links, headings, emoji |
| `/test` | Testing Coach | Testing - screen reader, keyboard, automated |
| `/wcag` | WCAG Guide | WCAG reference - criteria explanations |
| `/cognitive` | Cognitive Accessibility | Cognitive a11y - COGA, plain language |
| `/mobile` | Mobile Accessibility | Mobile - React Native, touch targets |
| `/design-system` | Design System Auditor | Tokens - contrast, focus rings, spacing |

## Decision Matrix

- **New component or page:** Always apply aria-specialist + keyboard-navigator + alt-text-headings. Add forms-specialist for inputs, contrast-master for styling, modal-specialist for overlays, live-region-controller for dynamic updates, tables-data-specialist for data tables.
- **Modifying existing UI:** At minimum apply keyboard-navigator. Add others based on what changed.
- **Code review/audit:** Apply all specialist checklists. Use web-accessibility-wizard for guided audits.
- **Document audit:** Use document-accessibility-wizard for Office and PDF accessibility audits.
- **Mobile app:** Use mobile-accessibility for touch targets, labels, and screen reader compatibility.
- **Cognitive / UX clarity:** Use cognitive-accessibility for WCAG 2.2 SC 3.3.7, 3.3.8, 3.3.9, COGA guidance.
- **Design system / tokens:** Use design-system-auditor to validate color token pairs, focus ring tokens, spacing tokens.
- **Data tables:** Always apply tables-data-specialist.
- **Links:** Always apply link-checker when pages contain hyperlinks.
- **Images or media:** Always apply alt-text-headings.

## Non-Negotiable Standards

- Semantic HTML before ARIA (`<button>` not `<div role="button">`)
- One H1 per page, never skip heading levels
- Every interactive element reachable and operable by keyboard
- Text contrast 4.5:1, UI component contrast 3:1
- No information conveyed by color alone
- Focus managed on route changes, dynamic content, and deletions
- Modals trap focus and return focus on close
- Live regions for all dynamic content updates

For tasks that do not involve any user-facing web content (backend logic, scripts, database work), these requirements do not apply.
