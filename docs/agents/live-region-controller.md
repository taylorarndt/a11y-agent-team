# live-region-controller — Dynamic Content Announcements

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

- Dynamic content changes with no live region announcement
- Live regions created dynamically (must exist in DOM before content changes)
- Wrong `aria-live` politeness (`assertive` used for routine updates)
- Toast notifications that disappear before screen readers can read them
- Missing loading state announcements
- `role="alert"` overuse (should be rare — only for genuinely urgent content)
- Duplicate announcements (debouncing issues)

## What It Will Not Catch

Visual styling of notifications (contrast-master), focus management when notifications appear (keyboard-navigator), or the structure of the notification content itself.

## Example Prompts

### Claude Code

```
/live-region-controller check search result announcements
/live-region-controller build toast notifications that work with screen readers
/live-region-controller add loading state announcements for this API call
/live-region-controller review all aria-live usage in this project
```

### GitHub Copilot

```
@live-region-controller review dynamic content updates in this component
@live-region-controller add a live region for these search filter results
@live-region-controller how should I announce loading states?
```

## Behavioral Constraints

- Requires live regions to exist in the DOM before content changes (not created dynamically at announcement time)
- Defaults to `aria-live="polite"` — only allows `assertive` for critical alerts
- Requires debouncing for rapid updates (e.g., type-ahead search results, not announcing every keystroke)
- Times toast/notification durations against screen reader reading speed (minimum 5 seconds for short messages)
