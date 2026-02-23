---
name: notifications
description: "Manage GitHub notifications across all repos -- list unread, mark as read/done, unsubscribe, smart filtering by @mentions, review requests, and CI failures"
agent: daily-briefing
tools:
  - github/*
  - ask_questions
---

Manage your GitHub notifications from the editor. List, filter, and act on notifications without opening a browser.

Notifications are inherently cross-repo. Respect priority and mute settings from `.github/agents/preferences.md` if present.

${input:action:Optional: 'unread', 'review requests', 'mentions', 'mark all read', specific repo, or 'org:orgname'}

## Capabilities

### List Notifications
- Fetch unread notifications grouped by repo, then by type (review requested, mentioned, CI failure, subscribed)
- Show count per group and most recent notification in each
- Apply smart filtering from notification preferences in `.github/agents/preferences.md`:
  - Prioritize repos/labels/events marked as priority
  - Dim or hide repos/labels/events marked as muted

### Filter Views
| Filter | Shows |
|--------|-------|
| `unread` (default) | All unread notifications, grouped by repo |
| `mentions` | Only notifications where you were @mentioned |
| `review requests` | Only PR review request notifications |
| `ci failures` | Only CI/workflow failure notifications |
| `{repo name}` | Notifications for a specific repo |

### Actions
| Action | How |
|--------|-----|
| **Mark as read** | `mark #3 as read` or `mark all from repo as read` |
| **Mark as done** | `done with #3` -- marks as done in GitHub |
| **Unsubscribe** | `unsubscribe from #3` -- stop notifications for that thread |
| **Mark all read** | `mark all read` -- clears all unread notifications |
| **Open in context** | Click through to the related issue/PR for full context |

### Display Format

```
Unread Notifications (15 total)

Priority (5):
  1. [review-requested] owner/repo -- PR #42: Fix auth timeout (@alice requested your review, 2h ago)
  2. [mention] owner/repo -- Issue #15: API breaking change (@bob mentioned you, 4h ago)
  3. [ci-failure] owner/repo -- Build failed on main (30min ago)

Normal (8):
  4. [comment] owner/repo -- Issue #30: New feature proposal (3 new comments, 1h ago)
  ...

Muted (2 -- hidden by preferences):
  Show muted? (y/n)
```

After listing: _"Want to mark some as read, unsubscribe from any threads, or dive into a specific notification?"_
