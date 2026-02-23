---
applyTo: "**/*.{html,jsx,tsx,vue,svelte,astro}"
---

# ARIA Widget Patterns

When generating custom interactive widgets, apply these role-specific ARIA patterns. Each pattern defines the required markup structure, required attributes, and mandatory keyboard behavior. These patterns follow the WAI-ARIA Authoring Practices Guide (APG).

**Golden rule:** Only use `role="menu"` / `role="tab"` / `role="tree"` / etc. when you also implement the full keyboard interaction pattern for that role. Partial ARIA is worse than no ARIA.

---

## Tabs

```html
<div role="tablist" aria-label="Product details">
  <button role="tab" id="tab-overview" aria-selected="true"  aria-controls="panel-overview">Overview</button>
  <button role="tab" id="tab-specs"    aria-selected="false" aria-controls="panel-specs"    tabindex="-1">Specs</button>
  <button role="tab" id="tab-reviews"  aria-selected="false" aria-controls="panel-reviews"  tabindex="-1">Reviews</button>
</div>
<div role="tabpanel" id="panel-overview" aria-labelledby="tab-overview">...</div>
<div role="tabpanel" id="panel-specs"    aria-labelledby="tab-specs"    hidden>...</div>
<div role="tabpanel" id="panel-reviews"  aria-labelledby="tab-reviews"  hidden>...</div>
```

**Required attributes:** `aria-selected` on every tab (true/false), `aria-controls` -> panel `id`, `aria-labelledby` on panels.

**Keyboard - roving tabindex pattern:**
- Only the selected tab has `tabindex="0"`. All others have `tabindex="-1"`.
- `Arrow Left` / `Arrow Right` - move focus between tabs; update `aria-selected`.
- `Home` - move focus to first tab.
- `End` - move focus to last tab.
- Tab key - moves focus into the active panel (not to the next tab).

---

## Dialog (Modal)

```html
<dialog id="confirm-dialog" aria-modal="true" aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm deletion</h2>
  <p id="dialog-desc">This action permanently removes the item and cannot be undone.</p>
  <div aria-describedby="dialog-desc">
    <button type="button" autofocus>Cancel</button>
    <button type="button">Delete</button>
  </div>
</dialog>
```

Use `dialog.showModal()` when using the native element. For the ARIA pattern (non-native):

```html
<div role="dialog" aria-modal="true" aria-labelledby="dialog-title" aria-describedby="dialog-desc" tabindex="-1">
  <h2 id="dialog-title">Confirm deletion</h2>
  <p id="dialog-desc">This action cannot be undone.</p>
  <button type="button">Cancel</button>
  <button type="button">Delete</button>
</div>
```

**Required attributes:** `aria-modal="true"`, `aria-labelledby` pointing to the heading `id`.

**Required behavior:**
- On open: move focus to the first focusable element (or the dialog container if `tabindex="-1"`).
- While open: Tab and Shift+Tab cycle focus only within the dialog. Focus must not leave.
- `Escape`: closes the dialog.
- On close: return focus to the element that triggered the dialog.

---

## Combobox / Autocomplete

```html
<label for="city-input">City</label>
<input
  id="city-input"
  type="text"
  role="combobox"
  aria-autocomplete="list"
  aria-expanded="false"
  aria-controls="city-listbox"
  aria-activedescendant=""
  autocomplete="off"
/>
<ul id="city-listbox" role="listbox" aria-label="City suggestions">
  <li role="option" id="opt-sf" aria-selected="false">San Francisco</li>
  <li role="option" id="opt-sd" aria-selected="false">San Diego</li>
</ul>
```

**Required attributes:** `aria-expanded` (true when list is open), `aria-controls` -> listbox `id`, `aria-activedescendant` -> focused option `id` (or empty string when no option is focused).

**Keyboard:**
- `Down Arrow` - opens list, moves focus to first option (set `aria-activedescendant`).
- `Up/Down Arrow` - moves between options.
- `Enter` - selects the highlighted option, closes list.
- `Escape` - closes list, clears `aria-activedescendant`, returns focus to input.
- `Tab` - accepts current value, closes list, moves focus to next element.

---

## Accordion

```html
<div>
  <h3>
    <button type="button" id="btn-shipping" aria-expanded="true" aria-controls="panel-shipping">
      Shipping information
    </button>
  </h3>
  <div id="panel-shipping" role="region" aria-labelledby="btn-shipping">
    <p>...</p>
  </div>

  <h3>
    <button type="button" id="btn-returns" aria-expanded="false" aria-controls="panel-returns">
      Returns policy
    </button>
  </h3>
  <div id="panel-returns" role="region" aria-labelledby="btn-returns" hidden>
    <p>...</p>
  </div>
</div>
```

**Required attributes:** `aria-expanded` (true/false) on each trigger button, `aria-controls` -> panel `id`, `role="region"` on panel, heading wrapping each trigger.

**Note:** `role="region"` creates a landmark. For accordions with many panels (>6), omit `role="region"` to avoid polluting the landmark list.

**Keyboard:** `Enter`/`Space` toggles the focused panel. Standard Tab navigation between triggers. No required arrow key behavior (unlike tabs).

---

## Menu Button

Use `role="menu"` only for application-style action menus (Edit / Delete / Rename), not for site navigation.

```html
<button type="button" id="menu-btn" aria-haspopup="menu" aria-expanded="false" aria-controls="actions-menu">
  Actions
</button>
<ul role="menu" id="actions-menu" aria-labelledby="menu-btn">
  <li role="none"><button type="button" role="menuitem">Edit</button></li>
  <li role="none"><button type="button" role="menuitem">Duplicate</button></li>
  <li role="none"><button type="button" role="menuitem" aria-disabled="true">Delete</button></li>
</ul>
```

**Required attributes:** `aria-haspopup="menu"` on trigger, `aria-expanded` (true/false), `role="menu"` on container, `role="menuitem"` on items, `role="none"` on list items (removes list semantics that would conflict with menu role).

**Keyboard:**
- `Enter`/`Space`/`Down Arrow` - opens menu, moves focus to first item.
- `Up/Down Arrow` - moves between items (roving tabindex).
- `Home`/`End` - jump to first/last item.
- `Escape` - closes menu, returns focus to trigger button.
- Tab - closes menu (focus leaves the menu).

---

## Carousel / Live Region Slider

```html
<section aria-roledescription="carousel" aria-label="Featured products">
  <div aria-live="polite" aria-atomic="true">
    <!-- Updated when slide changes: "Slide 2 of 4" -->
  </div>
  <div role="group" aria-roledescription="slide" aria-label="Slide 1 of 3">
    <h3>Product name</h3>
    <p>...</p>
  </div>
  <button type="button" aria-label="Previous slide"><</button>
  <button type="button" aria-label="Next slide">></button>
  <button type="button" aria-pressed="false" aria-label="Pause auto-rotate"></button>
</section>
```

**Required:** `aria-roledescription="carousel"` on container, `role="group" aria-roledescription="slide"` on each slide, `aria-label="Slide N of M"` on each slide, live region announcing current slide, pause control for auto-advancing carousels.

**Auto-advancing carousels must:**
- Provide a visible pause/stop control.
- Pause automatically when keyboard focus enters the carousel.
- Respect `prefers-reduced-motion` (stop all auto-advancement, keep manual controls).

---

## Tree View

```html
<ul role="tree" aria-label="File system">
  <li role="treeitem" aria-expanded="true">
    <span>src</span>
    <ul role="group">
      <li role="treeitem" aria-expanded="false">
        <span>components</span>
        <ul role="group">
          <li role="treeitem" aria-selected="false">Button.tsx</li>
          <li role="treeitem" aria-selected="false">Input.tsx</li>
        </ul>
      </li>
      <li role="treeitem" aria-selected="false">App.tsx</li>
    </ul>
  </li>
</ul>
```

**Required attributes:** `aria-expanded` on items with children (true = open, false = closed), `role="group"` wrapping child lists, `aria-selected` on all items (for single-select trees).

**Keyboard:**
- `Down/Up Arrow` - moves focus between visible items.
- `Right Arrow` - on collapsed item: expands it. On expanded item: moves to first child.
- `Left Arrow` - on expanded item: collapses it. On collapsed item or leaf: moves to parent.
- `Home`/`End` - first/last visible item.
- Enter or `Space` - activates/selects the focused item.

---

## Switch / Toggle

```html
<button type="button" role="switch" aria-checked="false" id="notifications-toggle">
  <span>Email notifications</span>
</button>
```

Or as a styled checkbox (semantically equivalent):
```html
<label>
  <input type="checkbox" role="switch">
  <span>Email notifications</span>
</label>
```

**Required attributes:** `aria-checked` (true/false), updates on click.

**Keyboard:** `Space` toggles the switch state.

---

## Tooltip

```html
<button type="button" aria-describedby="tooltip-copy" id="copy-btn">
  <svg aria-hidden="true" focusable="false"><!-- copy icon --></svg>
  <span class="sr-only">Copy</span>
</button>
<div role="tooltip" id="tooltip-copy">Copy to clipboard</div>
```

**Tooltip vs. description:** A tooltip supplements an already-named element with additional context. The button above has an accessible name ("Copy" from the visually hidden span) and the tooltip adds clarification. Do not use a tooltip as the sole accessible name.

**Required behavior:**
- Appears on focus and on hover.
- Remains visible while focused (does not auto-dismiss).
- Dismissible with `Escape`.
- `role="tooltip"` on the tooltip container, `aria-describedby` on the trigger pointing to it.

---

## Spinbutton / Number Input with Custom Controls

```html
<div role="group" aria-labelledby="qty-label">
  <span id="qty-label">Quantity</span>
  <button type="button" aria-label="Decrease quantity" tabindex="-1">-</button>
  <input type="number" id="qty" min="1" max="99" value="1" aria-labelledby="qty-label">
  <button type="button" aria-label="Increase quantity" tabindex="-1">+</button>
</div>
```

**Note:** The native `<input type="number">` handles `role="spinbutton"`, `aria-valuemin`, `aria-valuemax`, and `aria-valuenow` automatically. The increment/decrement buttons are supplements - keep Tab focus on the input itself.
