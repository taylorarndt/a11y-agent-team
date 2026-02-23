---
applyTo: "**/*.{html,jsx,tsx,vue,svelte,astro}"
---

# Semantic HTML Patterns

Use semantic HTML before reaching for ARIA or generic elements. The correct structural choice is always the first line of defense - it provides meaning to browsers, search engines, and assistive technologies without any ARIA overhead. Apply these patterns when generating or editing any web UI code.

---

## Page Landmark Structure

Every page template must include these landmark elements. Screen reader users navigate pages by jumping between landmarks - a missing or incorrect landmark is a navigation failure.

| Element | Role | Rule |
|---------|------|------|
| `<header>` | banner | Wrap site logo, primary navigation, and global actions |
| `<nav>` | navigation | Wrap every navigation region; use `aria-label` to name each one when multiple navs exist |
| `<main>` | main | Exactly one per page; wraps the primary page content |
| `<footer>` | contentinfo | Wrap copyright, legal links, and secondary site links |
| `<aside>` | complementary | Supplementary content - sidebars, related articles, callout boxes |
| `<section>` | region | Thematic grouping with a heading; add `aria-labelledby` referencing the section's heading |
| `<article>` | article | Self-contained content that makes sense in isolation: blog post, product card, news item |

**Multiple `<nav>` elements:** Distinguish them with `aria-label`:
```html
<nav aria-label="Main">…</nav>
<nav aria-label="Breadcrumb">…</nav>
<nav aria-label="Footer">…</nav>
```

**Skip navigation link** - First focusable element in every page template:
```html
<a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4">
  Skip to main content
</a>
…
<main id="main-content" tabindex="-1">…</main>
```

---

## Buttons vs. Links

This is the most common semantic error in generated UI code. The rule is absolute:

| Situation | Element |
|-----------|---------|
| Opens a dialog, submits a form, triggers an action, changes state | `<button type="button">` |
| Navigates to a URL (same page or different page) | `<a href="…">` |
| Downloads a file | `<a href="…" download>` |
| Jumps to a section on the same page | `<a href="#section-id">` |

- `<a>` without `href` is not a link - it receives no keyboard focus and has no role. Use `<button>` instead.
- `<button>` that navigates to a URL creates a confusing AT experience. Use `<a href>` instead.
- Form submit buttons: `<button type="submit">` (not `<button>` alone, which defaults to submit inside a form).
- Prevent accidental form submission: non-submit buttons inside forms must have `type="button"`.

---

## Lists

- `<ul>` - for unordered collections where sequence does not matter: nav links, feature lists, tag lists.
- `<ol>` - for ordered sequences where position matters: steps, rankings, timelines.
- `<dl>` / `<dt>` / `<dd>` - for name-value pairs: glossaries, metadata, key-value data.

**Navigation menus:**  
For site navigation, use `<nav><ul><li><a>` - this is correct and fully semantic. Screen readers announce "navigation landmark, list of N items."

**Application menus** (keyboard-navigable dropdown menus following the ARIA menu pattern) use `role="menu"` / `role="menuitem"` - but only when the full ARIA keyboard pattern (Arrow keys, Home, End, Escape) is implemented. If in doubt, use `<nav><ul><li><button>` - it is always safe.

---

## Tables

Use `<table>` for tabular data - any data that has a meaningful relationship between rows and columns.

**Required markup for every data table:**
```html
<table>
  <caption>Monthly revenue by product category</caption>
  <thead>
    <tr>
      <th scope="col">Category</th>
      <th scope="col">Q1</th>
      <th scope="col">Q2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Software</th>
      <td>$12,400</td>
      <td>$14,800</td>
    </tr>
  </tbody>
</table>
```

- `<caption>` or `aria-label` on every table - never rely on surrounding text to name a table.
- `<th scope="col">` for column headers. `<th scope="row">` for row headers.
- Complex tables with multiple header levels: use the `headers` attribute on `<td>` cells.
- Never use `<table>` for layout. Use CSS Grid or Flexbox.

---

## Forms

**Labels:**
```html
<!-- Best: visible label associated by for/id -->
<label for="email">Email address</label>
<input id="email" type="email" name="email" autocomplete="email" required>

<!-- Acceptable: when visual label is in a different location -->
<input type="search" aria-label="Search products" name="q">
```

**Grouped fields:**
```html
<!-- Radio group -->
<fieldset>
  <legend>Preferred contact method</legend>
  <label><input type="radio" name="contact" value="email"> Email</label>
  <label><input type="radio" name="contact" value="phone"> Phone</label>
</fieldset>

<!-- Checkbox group -->
<fieldset>
  <legend>Notification preferences</legend>
  <label><input type="checkbox" name="notifications" value="email"> Email</label>
  <label><input type="checkbox" name="notifications" value="sms"> SMS</label>
</fieldset>
```

**Error states:**
```html
<label for="username">Username</label>
<input id="username" type="text" aria-invalid="true" aria-describedby="username-error">
<span id="username-error" role="alert">Username must be at least 3 characters.</span>
```

---

## Disclosure Widgets

**Native `<details>` / `<summary>` for simple show/hide:**
```html
<details>
  <summary>What is your refund policy?</summary>
  <p>You can return any item within 30 days for a full refund.</p>
</details>
```
No JavaScript required. Browser handles open/close, keyboard, and AT announcements.

**When to use ARIA instead:** When visual design requirements exceed what `<details>` supports, use the ARIA accordion pattern (see `aria-patterns.instructions.md`).

---

## Dialogs

**Prefer the native `<dialog>` element:**
```html
<dialog id="confirm-delete" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Delete this file?</h2>
  <p>This action cannot be undone.</p>
  <button type="button" id="cancel-btn">Cancel</button>
  <button type="button" id="confirm-btn">Delete</button>
</dialog>
```
Open with `dialog.showModal()`. The browser handles focus trapping, `Escape` key, and backdrop automatically. When `showModal()` is not available or polyfill constraints apply, use the ARIA dialog pattern (see `aria-patterns.instructions.md`).

---

## Heading Hierarchy

- `<h1>` - page title or view title. Exactly one per page.
- `<h2>` - major sections of the page.
- `<h3>` - sub-sections within an h2 section.
- `<h4>`, `<h5>`, `<h6>` - deeper nesting as required. Never skip a level.

**Never choose a heading level for visual size.** Use CSS to style any heading to any size. Heading level = semantic depth in the document outline.

**Section headings in components:** When a reusable component renders a heading, expose the heading level as a prop so it can be set correctly in context. Hard-coding `<h2>` in a card component that is sometimes the top-level item on a page and sometimes nested three levels deep is a heading structure violation.
