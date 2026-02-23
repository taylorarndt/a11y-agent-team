---
applyTo: "**/*.{html,jsx,tsx,vue,svelte,astro}"
---

# Web Accessibility Baseline - WCAG 2.2 AA

These rules apply automatically to every HTML and component file. They represent the minimum non-negotiable requirements for WCAG 2.2 AA conformance. Apply all of them when generating or editing web UI code - no agent invocation required.

---

## Interactive Elements

- Use `<button>` for actions that do not navigate. Use `<a href>` for navigation. Never swap them.
- Never add `onClick` to a non-interactive element (`<div>`, `<span>`, `<p>`) without also adding `role="button"`, `tabIndex={0}`, and keyboard handlers (`onKeyDown`/`onKeyUp` for Enter and Space).
- The preferred fix is always to replace the non-semantic element with a `<button>`.
- No positive `tabindex` values (`tabindex="1"` or higher). Use `tabindex="0"` to add an element to the tab order, `tabindex="-1"` to allow programmatic focus only.
- Never write `outline: none` or `outline: 0` on interactive elements without providing a visible alternative. Always pair with a `:focus-visible` rule that has a `2px solid` outline or an equivalent visible ring.

---

## Images and Media

- Every `<img>` must have an `alt` attribute.
  - Decorative images that convey no information: `alt=""`
  - Content images: a concise, accurate description of what the image conveys (not "image of" or "photo of")
- SVGs used as meaningful content: add `<title>` as the first child of `<svg>`, and either `aria-labelledby="[title-id]"` or `role="img" aria-label="..."` on the `<svg>` element.
- Decorative SVGs and icon sprites: add `aria-hidden="true"` and `focusable="false"`.
- Icon-only buttons (no visible text): must have `aria-label` describing the action (e.g., `aria-label="Close dialog"`).
- `<video>` elements must have a caption track. `<audio>` elements must have a text transcript.

---

## Forms and Inputs

- Every `<input>`, `<select>`, and `<textarea>` must have a programmatic label via one of:
  1. A `<label>` element with `for` matching the input's `id` (preferred)
  2. `aria-label` directly on the input
  3. `aria-labelledby` pointing to a visible text element's `id`
- `placeholder` is never a substitute for a label - it disappears when the user starts typing.
- Required fields must have the `required` attribute (not just a visual asterisk).
- Fields in an error state: set `aria-invalid="true"` and associate the error message via `aria-describedby`.
- On invalid form submission, move focus programmatically to the first field with an error.
- Group related inputs (radio buttons, checkboxes) in `<fieldset>` with `<legend>`.
- Apply `autocomplete` attributes to identity and payment fields: `name`, `email`, `tel`, `street-address`, `postal-code`, `cc-number`, etc.

---

## Headings and Structure

- One `<h1>` per page or view.
- Never skip heading levels: h1 -> h2 -> h3 is correct. h1 -> h3 skips a level and is a violation.
- Headings communicate document hierarchy. Choose the level based on outline structure, not visual appearance.
- Every page must have a `<main>` landmark element wrapping the primary content.
- The first focusable element on every page template must be a skip navigation link targeting `#main-content` (or equivalent).

---

## Color and Contrast

- Color must never be the sole means of conveying information, indicating state, or prompting action. Always pair color with text, pattern, shape, or non-color indicator.
- Normal text contrast: minimum **4.5:1** against its background.
- Large text contrast (18pt / 14pt bold or larger): minimum **3:1**.
- UI component contrast (input borders, focus rings, icon buttons, chart lines): minimum **3:1** against adjacent background.
- Focus indicators: minimum **3:1** between focused and unfocused appearance (WCAG 2.4.11, AA).

---

## Dynamic Content and Live Regions

- When content updates in place without a page reload, announce the change to screen readers using a live region.
- Use `role="status"` (or `aria-live="polite"`) for routine non-critical updates: search result counts, filter changes, "Saved" confirmations, loading complete.
- Use `role="alert"` (or `aria-live="assertive"`) only for urgent, time-sensitive messages: authentication errors, destructive action confirmations, session expiry warnings. Do not use assertive for routine updates.
- Live region containers must exist in the DOM before content is injected into them - do not dynamically insert `aria-live` elements.
- Toast/notification components that disappear automatically must remain visible for at least 5 seconds and must not disappear while keyboard focus is inside them.

---

## ARIA

- Prefer semantic HTML over ARIA. `<button>` is always better than `<div role="button">`. Only use ARIA when no native HTML element provides the required semantics.
- Do not add redundant ARIA to semantic elements: `role="button"` on `<button>` is noise, not help.
- Every element with an ARIA `role` must have all required ARIA attributes for that role (e.g., `role="checkbox"` requires `aria-checked`).
- All `aria-controls`, `aria-labelledby`, and `aria-describedby` attribute values must be IDs of elements that exist in the DOM.
- `aria-hidden="true"` must never be placed on a focused element or on an element that contains a focused element.
- Do not nest interactive elements (e.g., a `<button>` inside an `<a href>` is invalid HTML and causes AT failures).

---

## Motion and Animation

- Wrap all transitions, animations, and auto-playing motion in a `prefers-reduced-motion` media query:
  ```css
  @media (prefers-reduced-motion: reduce) {
    *, *::before, *::after { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
  }
  ```
- Auto-playing carousels and animations must provide a visible pause control.
- No content may flash more than 3 times per second (WCAG 2.3.1, Level A).
