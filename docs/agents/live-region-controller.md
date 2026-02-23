# live-region-controller - Dynamic Content Announcements

> Bridges visual changes to screen reader awareness. Handles `aria-live` regions, toast notifications, loading states, search result counts, filter updates, progress indicators, and any content that changes without a full page reload.

## When to Use It

- Toast notifications and alerts
- Search results (count changes, loading states)
- Filter and sort operations
- AJAX content loading
- Form submission feedback
- Real-time updates (chat, feeds, dashboards)
- Progress indicators and loading spinners
- Any content that appears, disappears, or changes without navigating to a new page

## What It Catches

<details>
<summary>Expand - 7 live region issues detected</summary>

- Dynamic content changes with no live region announcement
- Live regions created dynamically (must exist in DOM before content changes)
- Wrong `aria-live` politeness (`assertive` used for routine updates)
- Toast notifications that disappear before screen readers can read them
- Missing loading state announcements
- `role="alert"` overuse (should be rare - only for genuinely urgent content)
- Duplicate announcements (debouncing issues)

</details>

## What It Will Not Catch

Visual styling of notifications (contrast-master), focus management when notifications appear (keyboard-navigator), or the structure of the notification content itself.

## How to Launch It

**In Claude Code:**

```text
/live-region-controller check search result announcements
/live-region-controller build toast notifications that work with screen readers
/live-region-controller review all aria-live usage in this project
```

**In GitHub Copilot Chat:**

```text
@live-region-controller review dynamic content updates in this component
@live-region-controller add a live region for these search filter results
@live-region-controller how should I announce loading states?
```

## The Problem This Agent Solves

Screen readers only hear what changes in the DOM. When content updates without a page reload - a toast appears, search results load, a filter is applied, a form is submitted - a sighted user sees the change. A screen reader user hears nothing unless a live region is present to announce it.

Live regions bridge this gap. `aria-live="polite"` tells the browser: "When this region's content changes, announce it at the next available pause in reading." `aria-live="assertive"` interrupts immediately (for critical alerts only).

## Step-by-Step: Adding Live Region Coverage

**You say:**

```text
/live-region-controller check search result announcements
```

```jsx
function SearchResults({ results, loading }) {
  return (
    <div>
      {loading && <Spinner />}
      {results.map(r => <ResultCard key={r.id} result={r} />)}
    </div>
  );
}
```

**What the agent finds:**

- No live region - result count changes are silent to screen readers
- Loading state has no accessible announcement

**What the agent produces:**

```jsx
function SearchResults({ results, loading }) {
  return (
    <div>
      {/* Live region: pre-exist in DOM, content changes trigger announcement */}
      <div
        role="status"
        aria-live="polite"
        aria-atomic="true"
        className="sr-only"
      >
        {loading
          ? 'Loading results…'
          : `${results.length} result${results.length !== 1 ? 's' : ''} found`
        }
      </div>

      {loading && <Spinner aria-hidden="true" />}
      {results.map(r => <ResultCard key={r.id} result={r} />)}
    </div>
  );
}
```

**Why it works:**

1. The `role="status"` live region exists in the DOM from initial render (critical requirement - live regions created dynamically at announcement time are ignored by some screen readers)
2. `aria-atomic="true"` means the entire content is announced as a unit rather than just the changed text
3. `aria-live="polite"` does not interrupt ongoing speech
4. The visual spinner is `aria-hidden="true"` because the live region already handles the announcement

## Politeness Guide

| Use `polite` for | Use `assertive` for |
|-----------------|---------------------|
| Search result count updates | Critical error alerts (form submission failed, session expiring) |
| Filter/sort changes | Alerts that require immediate user attention |
| Loading started/finished | Nothing else - assertive is almost always wrong |
| Toast notifications (most) | |
| Step progress in wizards | |
| Auto-save confirmations | |

`assertive` interrupts whatever the screen reader is currently reading. It creates a jarring experience. Reserve it for genuinely urgent content where the user must act immediately.

## The Live Region Must Pre-Exist

This is the most common live region implementation mistake. This does NOT work:

```jsx
// Wrong: Creating the live region at announcement time
function showToast(message) {
  const toast = document.createElement('div');
  toast.setAttribute('aria-live', 'polite');
  toast.textContent = message;
  document.body.appendChild(toast);  // Screen readers ignore dynamically added live regions
}
```

This works:

```jsx
// Correct: Live region already in DOM, update its content
function App() {
  const [announcement, setAnnouncement] = useState('');

  function showToast(message) {
    setAnnouncement(message); // Updates existing live region
    setTimeout(() => setAnnouncement(''), 5000);
  }

  return (
    <>
      <div aria-live="polite" className="sr-only">{announcement}</div>
      {/* rest of app */}
    </>
  );
}
```

## Connections

| Connect to | When |
|------------|------|
| [modal-specialist](modal-specialist.md) | Modals that display status after form submission inside the dialog |
| [keyboard-navigator](keyboard-navigator.md) | When focus should also move to announced content (not just announce - also focus) |
| [forms-specialist](forms-specialist.md) | Form submission feedback and validation status announcements |
| [accessibility-lead](accessibility-lead.md) | Full component reviews that include dynamic content |
| [testing-coach](testing-coach.md) | Verifying that live region announcements are working correctly with actual screen readers |

<details>
<summary>Show example prompts</summary>

### Claude Code

```text
/live-region-controller check search result announcements
/live-region-controller build toast notifications that work with screen readers
/live-region-controller add loading state announcements for this API call
/live-region-controller review all aria-live usage in this project
```

### GitHub Copilot

```text
@live-region-controller review dynamic content updates in this component
@live-region-controller add a live region for these search filter results
@live-region-controller how should I announce loading states?
```

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Requires live regions to exist in the DOM before content changes (not created dynamically at announcement time)
- Defaults to `aria-live="polite"` - only allows `assertive` for critical alerts
- Requires debouncing for rapid updates (e.g., type-ahead search results, not announcing every keystroke)
- Times toast/notification durations against screen reader reading speed (minimum 5 seconds for short messages)

</details>
