# framework-accessibility Skill

> Framework-specific accessibility patterns, common pitfalls, and code fix templates for React, Next.js, Vue, Angular, Svelte, and Tailwind CSS. Used when generating framework-aware accessibility fixes or checking framework-specific anti-patterns.

## Agents That Use This Skill

| Agent | Why |
|-------|-----|
| [accessibility-lead](../agents/accessibility-lead.md) | Orchestrated framework-aware audits |
| [aria-specialist](../agents/aria-specialist.md) | Framework-specific ARIA misuse patterns |
| [forms-specialist](../agents/forms-specialist.md) | Framework form label and validation patterns |
| [keyboard-navigator](../agents/keyboard-navigator.md) | Route-change focus management patterns |

## React / Next.js

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `onClick` on `<div>` | Not keyboard accessible | Use `<button>` or add `role="button"`, `tabIndex={0}`, `onKeyDown` |
| `dangerouslySetInnerHTML` | May inject inaccessible content | Audit injected HTML for ARIA, headings, alt text |
| Missing `key` on lists | Can cause focus loss on re-render | Use stable keys (not array index) for interactive lists |
| Portal without focus trap | Focus escapes to background | Wrap portal in `FocusTrap` component |
| No `useEffect` focus management on route change | Focus not moved after navigation | Use `useRef` + `useEffect` to move focus to `#main-content` |

### Fix Templates

```jsx
// Route change focus management
useEffect(() => {
  const main = document.getElementById('main-content');
  if (main) { main.focus(); main.scrollIntoView(); }
}, [location]);

// Image with alt (Next.js)
<Image src="/hero.jpg" width={800} height={400} alt="Team collaborating in a modern office" />

// New tab link with warning
<a href={url} target="_blank" rel="noopener noreferrer">
  Resource <span className="sr-only">(opens in new tab)</span>
</a>
```

## Vue

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `v-if` on live regions | Removes element from DOM | Use `v-show` for live regions instead |
| `<transition>` without focus | Focus lost on transition | Manage focus in `@after-enter` hook |
| `<teleport>` to body | Outside app landmark tree | Add landmark roles to teleported content |

### Fix Template

```vue
<!-- v-show keeps element in DOM for live region announcements -->
<div v-show="message" aria-live="polite">{{ message }}</div>
```

## Angular

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `[aria-label]` binding | Invalid - ARIA is not a property | Use `[attr.aria-label]` |
| `*ngFor` without `trackBy` | Focus loss on list re-render | Add `trackBy` function |
| No `LiveAnnouncer` for routes | Navigation not announced | Inject `LiveAnnouncer` and announce route changes |

### Fix Template

```typescript
// Announce route changes
this.router.events.pipe(filter(e => e instanceof NavigationEnd))
  .subscribe(() => this.liveAnnouncer.announce(`Navigated to ${this.getPageTitle()}`));
```

## Svelte

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `{#if}` without focus management | Focus lost when content appears | Use `use:action` to focus new content |
| `transition:` without motion check | Animations play regardless of user preference | Add `prefers-reduced-motion` check |

### Fix Template

```svelte
<script>
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
</script>
<div transition:fly={{ y: reducedMotion ? 0 : 200, duration: reducedMotion ? 0 : 300 }}>
  Content
</div>
```

## Tailwind CSS

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `outline-none` alone | Removes focus indicator | Pair with `focus-visible:ring-2` |
| `text-gray-400` on `bg-white` | 2.85:1 - fails 4.5:1 | Use `text-gray-700` (6.62:1) |
| No `motion-reduce:` variant | Animations ignore user preference | Add `motion-reduce:transition-none` |

### Contrast-Safe Tailwind Pairs

| Background | Minimum Text | Ratio |
|-----------|-------------|-------|
| `bg-white` | `text-gray-600` | 4.55:1 |
| `bg-white` | `text-gray-700` | 6.62:1 |
| `bg-gray-50` | `text-gray-700` | 6.29:1 |
| `bg-gray-900` | `text-gray-300` | 5.92:1 |
| `bg-blue-600` | `text-white` | 5.23:1 |

### Focus Ring Fix

```html
<!-- Bad -->
<button class="outline-none">Submit</button>

<!-- Good -->
<button class="focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
  Submit
</button>
```

## Skill Location

`.github/skills/framework-accessibility/SKILL.md`
