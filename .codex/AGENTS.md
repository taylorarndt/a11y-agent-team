# Accessibility Agents — Codex CLI

This project enforces WCAG 2.2 AA accessibility. When writing or modifying any
web UI code — HTML, JSX, TSX, Vue, Svelte, CSS, or any user-facing component —
you must apply the rules below before considering the work done.

> These rules are derived from the [Accessibility Agents](https://github.com/Community-Access/accessibility-agents)
> project, a community initiative ensuring AI coding tools stop generating
> inaccessible code by default.

---

## Pre-flight: Is This a UI Task?

If the file or prompt involves **HTML, JSX/TSX, CSS, Vue, Svelte, forms,
modals, tables, images, interactive components, or any visual output**, treat
it as a UI task. Apply the relevant sections below. Do not skip this even if
the user does not ask for an accessibility review.

---

## 1. ARIA — Use It Correctly or Not At All

**First rule:** If native HTML expresses the semantics, do not add ARIA.
A `<button>` beats `<div role="button">` every time.

**Never add ARIA to these** (they already have implicit roles):
- `<header>`, `<nav>`, `<main>`, `<footer>`, `<aside>`
- `<button>`, `<a href>`, `<input>`, `<select>`, `<textarea>`
- `<h1>`–`<h6>`, `<ul>`, `<ol>`, `<li>`, `<table>`, `<form>`

**Always required:**
- Every interactive element needs an accessible name:
  `aria-label`, `aria-labelledby`, or visible text.
- Icon-only buttons: `<button aria-label="Close">` — not empty.
- Multiple `<nav>` elements on one page: each needs `aria-label`.
- Images: `alt=""` for decorative, meaningful alt text for informative.
  Never use the filename as alt text.

**State attributes — keep them live:**
- Toggle buttons: `aria-pressed="true/false"` (must update on click)
- Expandable sections: `aria-expanded="true/false"` on the trigger
- Invalid inputs: `aria-invalid="true"` + `aria-describedby` pointing to error message
- Loading: `aria-busy="true"` on the region being updated
- Required fields: `aria-required="true"` or native `required`

---

## 2. Keyboard Navigation

Every interactive element must be reachable and operable by keyboard alone.

**Focus management rules:**
- Tab order must follow visual/reading order — never use `tabindex > 0`.
- Use `tabindex="0"` only to make non-interactive elements focusable when necessary.
- Use `tabindex="-1"` for elements you manage focus to programmatically.
- Focus must be visible at all times — never `outline: none` without a custom
  focus style with ≥3:1 contrast against the background.

**Keyboard patterns for common components:**

| Component | Keys |
|-----------|------|
| Button | `Enter`, `Space` |
| Link | `Enter` |
| Checkbox | `Space` to toggle |
| Radio group | `Arrow` keys to move, `Tab` to exit group |
| Select / listbox | `Arrow` keys to navigate, `Enter` to select |
| Tabs | `Arrow` keys between tabs, `Tab` into panel |
| Modal | `Tab`/`Shift+Tab` trapped inside, `Escape` closes |
| Menu | `Arrow` keys to navigate, `Escape` closes, `Enter`/`Space` selects |
| Combobox | `Arrow` keys in list, `Escape` collapses, `Enter` selects |

**Focus trap in modals:** When a modal opens, focus must move inside it.
When it closes, focus must return to the trigger element.

---

## 3. Modals and Dialogs

```html
<dialog aria-modal="true" aria-labelledby="dialog-title">
  <button aria-label="Close dialog">✕</button>
  <h2 id="dialog-title">Dialog Title</h2>
  <!-- content -->
</dialog>
```

Requirements:
- `aria-modal="true"` and `aria-labelledby` on `<dialog>`
- Close button is the **first focusable element** inside
- Focus moves **into** the dialog on open
- `Escape` closes and returns focus to the trigger
- Background content is `inert` or `aria-hidden="true"` while modal is open
- Heading starts at H2 (H1 is reserved for the page)

---

## 4. Forms

```html
<div>
  <label for="email">Email address</label>
  <input id="email" type="email" aria-required="true"
         aria-describedby="email-error email-hint" />
  <span id="email-hint">We will never share your email.</span>
  <span id="email-error" role="alert" aria-live="polite"></span>
</div>
```

Rules:
- Every `<input>`, `<select>`, `<textarea>` must have a visible `<label>`.
  No placeholder-only labels — placeholder disappears on focus.
- Error messages must be announced: `role="alert"` or `aria-live="polite"`.
- Error message must be linked to the field via `aria-describedby`.
- Group related inputs in `<fieldset>` with `<legend>` (radio/checkbox groups).
- On submit failure: move focus to the first error or an error summary at the top.
- Do not disable the submit button to indicate errors — show messages instead.

---

## 5. Color Contrast

- Normal text (< 18pt / 14pt bold): **4.5:1** minimum against background
- Large text (≥ 18pt / 14pt bold): **3:1** minimum
- UI components and focus indicators: **3:1** against adjacent colors
- Never convey information with color alone — pair with text, icon, or pattern

**Never assume a color passes.** Use values or reference your design tokens.
If the contrast ratio is unknown, flag it with a comment for human verification.

---

## 6. Dynamic Content and Live Regions

When content updates without a page reload, screen readers must be notified.

```html
<!-- Status messages (non-urgent) -->
<div aria-live="polite" aria-atomic="true"></div>

<!-- Urgent alerts -->
<div role="alert"></div>

<!-- Loading state -->
<div aria-busy="true" aria-live="polite">Loading results…</div>
```

Rules:
- `aria-live="polite"` for status updates (toasts, search results, counts)
- `role="alert"` (implies `aria-live="assertive"`) for errors only
- Live regions must be in the DOM **before** content is injected — do not
  create and populate them in the same tick
- `aria-atomic="true"` when the whole region should be read as one unit

---

## 7. Heading Structure and Landmarks

- One `<h1>` per page — the page title or main content title
- Headings must be hierarchical: never skip from H2 to H4
- Use headings for structure, not for styling — use CSS for visual size
- Landmark regions: `<header>`, `<nav>`, `<main>`, `<footer>`, `<aside>`
- Page must have exactly one `<main>`
- Every page needs a `<title>` that describes its unique content

---

## 8. Images

- Informative images: meaningful `alt` text describing content or function
- Decorative images: `alt=""` (empty string, not omitted)
- Functional images (buttons/links): alt describes the action, not the image
- Complex images (charts, graphs): provide a text alternative or `<figcaption>`
- Never use the filename, "image of", or "photo of" as alt text

---

## 9. Tables

Data tables only — never use tables for layout.

```html
<table>
  <caption>Monthly sales by region</caption>
  <thead>
    <tr>
      <th scope="col">Region</th>
      <th scope="col">Q1</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">North</th>
      <td>$42,000</td>
    </tr>
  </tbody>
</table>
```

- `<caption>` describes the table purpose
- `<th scope="col">` for column headers, `<th scope="row">` for row headers
- Complex tables: use `id` on headers and `headers` attribute on cells

---

## 10. Pre-Commit Checklist

Before completing any UI task, verify:

- [ ] All interactive elements have accessible names
- [ ] Tab order is logical; no positive `tabindex`
- [ ] Focus is visible on every focusable element
- [ ] All form fields have visible, programmatically associated labels
- [ ] Error messages are linked to fields and announced to screen readers
- [ ] Modals trap focus and return it on close
- [ ] Dynamic updates use live regions
- [ ] No color-only information conveyance
- [ ] Heading hierarchy is valid (no skipped levels)
- [ ] Images have appropriate alt text
- [ ] ARIA is not used where native HTML suffices
- [ ] All ARIA state attributes update dynamically

If any item cannot be verified from the code alone, add a `<!-- a11y: needs
manual verification — [reason] -->` comment so it is not silently dropped.
