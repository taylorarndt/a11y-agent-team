---
name: framework-accessibility
description: Framework-specific accessibility patterns, common pitfalls, and code fix templates for React, Next.js, Vue, Angular, Svelte, and Tailwind CSS. Use when generating framework-aware accessibility fixes or checking framework-specific anti-patterns.
---

# Framework-Specific Accessibility Patterns

## React / Next.js

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `onClick` on `<div>` | Not keyboard accessible | Use `<button>` or add `role="button"`, `tabIndex={0}`, `onKeyDown` |
| `dangerouslySetInnerHTML` | May inject inaccessible content | Audit injected HTML for ARIA, headings, alt text |
| `React.Fragment` as root | May break landmark tree | Ensure fragments don't interrupt landmark nesting |
| Missing `key` on lists | Can cause focus loss on re-render | Use stable keys (not array index) for interactive lists |
| Portal without focus trap | Focus can escape to background | Wrap portal content in `FocusTrap` component |
| `useEffect` focus management | Focus may not fire on mount | Use `useRef` + `useEffect` with proper dependency array |

### Fix Templates

```jsx
// Bad: div as button
<div onClick={handleClick}>Submit</div>

// Good: semantic button
<button onClick={handleClick}>Submit</button>

// Bad: image without alt in Next.js
<Image src="/hero.jpg" width={800} height={400} />

// Good: image with alt
<Image src="/hero.jpg" width={800} height={400} alt="Team collaborating in a modern office" />

// Bad: no focus management on route change
useEffect(() => {
  // nothing
}, [location]);

// Good: focus management on route change
useEffect(() => {
  const mainContent = document.getElementById('main-content');
  if (mainContent) {
    mainContent.focus();
    mainContent.scrollIntoView();
  }
}, [location]);

// Bad: link opening new tab
<a href={url} target="_blank">Resource</a>

// Good: link with new tab warning
<a href={url} target="_blank" rel="noopener noreferrer">
  Resource <span className="sr-only">(opens in new tab)</span>
</a>
```

## Vue

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `v-html` with user content | May inject inaccessible markup | Sanitize and audit injected HTML |
| `v-if` on live regions | Removes element from DOM, breaks announcements | Use `v-show` for live regions instead |
| `<transition>` without focus | Focus lost when content transitions | Manage focus in `@after-enter` hook |
| `<teleport>` to body | Content outside app landmark tree | Add landmark roles to teleported content |

### Fix Templates

```vue
<!-- Bad: v-if on live region -->
<div v-if="message" aria-live="polite">{{ message }}</div>

<!-- Good: v-show keeps element in DOM -->
<div v-show="message" aria-live="polite">{{ message }}</div>

<!-- Bad: no focus after transition -->
<transition name="fade">
  <div v-if="showModal" class="modal">...</div>
</transition>

<!-- Good: focus managed after transition -->
<transition name="fade" @after-enter="focusModal">
  <div v-if="showModal" ref="modal" class="modal" tabindex="-1">...</div>
</transition>
```

## Angular

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `[aria-label]` binding | Invalid - ARIA is not a property | Use `[attr.aria-label]` |
| `*ngFor` without `trackBy` | Focus loss on list re-render | Add `trackBy` function |
| No `LiveAnnouncer` | Route changes not announced | Inject `LiveAnnouncer` and announce navigation |
| `OnPush` + live regions | Change detection may not trigger | Use `ChangeDetectorRef.markForCheck()` |

### Fix Templates

```typescript
// Bad: ARIA binding
<button [aria-label]="label">X</button>

// Good: ARIA attribute binding
<button [attr.aria-label]="label">X</button>

// Bad: ngFor without trackBy
<li *ngFor="let item of items">{{ item.name }}</li>

// Good: ngFor with trackBy
<li *ngFor="let item of items; trackBy: trackById">{{ item.name }}</li>

// Route change announcements
constructor(private liveAnnouncer: LiveAnnouncer, private router: Router) {
  this.router.events.pipe(
    filter(event => event instanceof NavigationEnd)
  ).subscribe((event: NavigationEnd) => {
    this.liveAnnouncer.announce(`Navigated to ${this.getPageTitle()}`);
  });
}
```

## Svelte

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `{#if}` without focus management | Focus lost when content appears | Use `use:action` to focus new content |
| `transition:` without motion check | Animations play regardless of user preference | Add `prefers-reduced-motion` check |
| `on:click` on non-interactive | Not keyboard accessible | Use `<button>` or add keyboard handlers |

### Fix Templates

```svelte
<!-- Bad: click on div -->
<div on:click={toggle}>Toggle</div>

<!-- Good: keyboard accessible -->
<button on:click={toggle}>Toggle</button>

<!-- Bad: animation without motion preference -->
<div transition:fly={{ y: 200 }}>Content</div>

<!-- Good: respects motion preference -->
<div transition:fly={{ y: reducedMotion ? 0 : 200, duration: reducedMotion ? 0 : 300 }}>Content</div>

<script>
  const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
</script>
```

## Tailwind CSS

### Common Pitfalls

| Pattern | Issue | Fix |
|---------|-------|-----|
| `outline-none` | Removes focus indicator | Pair with `ring-2 ring-offset-2 focus-visible:ring-blue-500` |
| `text-gray-400` on `bg-white` | Fails 4.5:1 contrast | Use `text-gray-600` or darker |
| No `motion-reduce:` variant | Animations ignore user preference | Add `motion-reduce:transition-none` |
| Missing `focus:` styles | No visible focus indicator | Add `focus:ring-2 focus:ring-blue-500` |
| `sr-only` missing | Screen reader text not available | Add `<span class="sr-only">description</span>` |

### Contrast-Safe Tailwind Pairs

| Background | Minimum Text | Ratio |
|-----------|-------------|-------|
| `bg-white` | `text-gray-600` | 4.55:1 |
| `bg-white` | `text-gray-700` | 6.62:1 |
| `bg-gray-50` | `text-gray-700` | 6.29:1 |
| `bg-gray-900` | `text-gray-300` | 5.92:1 |
| `bg-blue-600` | `text-white` | 5.23:1 |
| `bg-red-600` | `text-white` | 4.54:1 |
| `bg-green-700` | `text-white` | 4.58:1 |

### Fix Templates

```html
<!-- Bad: no focus indicator -->
<button class="bg-blue-500 text-white px-4 py-2 rounded outline-none">
  Submit
</button>

<!-- Good: visible focus indicator -->
<button class="bg-blue-500 text-white px-4 py-2 rounded focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 focus-visible:ring-offset-2">
  Submit
</button>

<!-- Bad: low contrast -->
<p class="text-gray-400">Important information</p>

<!-- Good: adequate contrast -->
<p class="text-gray-700">Important information</p>

<!-- Bad: animation without motion preference -->
<div class="transition-transform duration-300 hover:scale-105">Card</div>

<!-- Good: respects motion preference -->
<div class="transition-transform duration-300 hover:scale-105 motion-reduce:transition-none motion-reduce:hover:scale-100">Card</div>
```
