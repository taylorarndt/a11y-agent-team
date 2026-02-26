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

### Landmarks and Regions

- `<section>` only becomes a `region` landmark when it has an accessible name (`aria-label` or `aria-labelledby`). Without one, it is just a grouping element. Do not add `aria-label` to every `<section>` -- most sections should NOT be landmarks.
- When a `<section>` already has a heading, prefer `aria-labelledby` pointing to the heading over `aria-label`. This links the landmark name to the visible heading text and avoids duplicate or conflicting names.
- Never use `aria-label` with text that differs from the section's heading. Landmark navigation and heading navigation should present the same name for the same section.
- Keep the total number of named landmarks minimal. The canonical set for a typical informational page is: banner, navigation(s), main, contentinfo -- typically 5-6 total. Add region landmarks only for genuinely important navigable sections (e.g., a search results panel, a dashboard sidebar). If everything is a landmark, nothing is.
- Never use `role="region"` on code snippets, install command blocks, demo panels, or promotional/ephemeral banners. Content inside `<main>` is already in a landmark -- subdivisions need region status only when they represent major navigable destinations that heading navigation alone cannot serve.
- CSS grid/flexbox layouts displaying structured key-value data (stats, metrics, KPIs) need semantic backing -- `<dl>`/`<dt>`/`<dd>` for label-value pairs, `<table>` for multi-dimensional data. Bare `<div>`/`<span>` elements linearize into undifferentiated text for screen readers.

---

## Color and Contrast

- Color must never be the sole means of conveying information, indicating state, or prompting action. Always pair color with text, pattern, shape, or non-color indicator.
- Normal text contrast: minimum **4.5:1** against its background.
- Large text contrast (18pt / 14pt bold or larger): minimum **3:1**.
- UI component contrast (input borders, focus rings, icon buttons, chart lines): minimum **3:1** against adjacent background.
- Focus indicators: minimum **3:1** between focused and unfocused appearance (WCAG 2.4.7, AA).

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
- **Working accessibility beats spec purity.** If code works correctly with screen readers and keyboard navigation but uses a non-standard ARIA pattern, flag it as Minor, not Critical. Never change working ARIA roles without first searching all workspace files for JavaScript/CSS selectors that reference the current role, and never remove documented attributes (`aria-keyshortcuts`, `title`) without explicit user approval.

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

---

## WCAG 2.2 New Criteria (AA)

These six success criteria were added in WCAG 2.2. Apply them to all new and updated web content.

- **Focus Not Obscured (2.4.11):** When an element receives keyboard focus, it must not be entirely hidden by sticky headers, footers, cookie banners, or other fixed-position content. Ensure `scroll-padding` or dynamic offsets account for sticky elements.
- **Dragging Movements (2.5.7):** Any function that uses dragging (drag-to-reorder, sliders, drag-and-drop) must also be operable with a single pointer without dragging. Provide click-to-move, arrow key controls, or alternative UI.
- **Target Size - Minimum (2.5.8):** Interactive targets must be at least 24x24 CSS pixels, or have sufficient spacing from adjacent targets. Inline text links are exempt. Apply `min-width: 24px; min-height: 24px` to icon buttons and small controls.
- **Consistent Help (3.2.6):** If help mechanisms (contact info, chat widget, FAQ link) appear on multiple pages, they must be in the same relative location on each page.
- **Redundant Entry (3.3.7, Level A):** Information previously entered by the user in a multi-step process must be auto-populated or available for selection. Do not force re-entry of address, email, or payment data already provided.
- **Accessible Authentication - Minimum (3.3.8):** Authentication must not require cognitive function tests (memorizing passwords, solving puzzles) unless an alternative method is available. Support password managers (never block paste), passkeys, biometrics, or email/SMS codes.
