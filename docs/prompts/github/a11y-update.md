# a11y-update

Fetch the latest accessibility-related GitHub issues and discussions across tracked repositories. Results are scoped by keyword, grouped by access need category, and include the relevant WCAG criterion and ARIA pattern for each item.

## When to Use It

- Weekly review of accessibility issues to prioritize
- Preparing for an audit by seeing what known issues exist
- Tracking what the community has identified as broken or missing
- Finding upstream accessibility bugs in dependencies

## How to Launch It

**In GitHub Copilot Chat:**
```
/a11y-update
```

With scope:
```
/a11y-update owner/repo
/a11y-update org:myorg
/a11y-update last 14 days
```

## What to Expect

1. **Scope parsing** — Determines repos to search from parameters or configured preferences
2. **Collect issues** — Finds issues with accessibility-related labels or keywords (`a11y`, `accessibility`, `screen-reader`, `keyboard`, `wcag`, `aria`)
3. **Classify by access need** — Groups findings into 6 categories
4. **Enrich** — Adds the relevant WCAG success criterion and ARIA pattern for each item
5. **Display with impact level** — High / Medium / Low priority based on user impact

### Access Need Categories

| Category | What it covers |
|----------|---------------|
| Screen Reader | ARIA, semantic HTML, announcements, live regions |
| Keyboard | Focus management, tab order, keyboard traps, shortcuts |
| Visual | Color contrast, motion, zoom, high contrast mode |
| Audio | Captions, transcripts, audio controls |
| Cognitive | Plain language, reading level, error clarity, timeouts |
| Other | Uncategorized or multi-category issues |

### Per-Issue Information

Each issue includes:
- Issue number and title with link
- Repo context
- Relevant WCAG success criterion (e.g., WCAG 1.4.3 Contrast)
- Relevant ARIA pattern if applicable (e.g., combobox, dialog)
- Impact: High / Medium / Low
- Days open and last activity

### Sample Output

```
Accessibility Update — last 7 days (owner/repo)

Screen Reader (2 issues)
  #112 Modal close button not announced — 3 days old [High]
       WCAG 4.1.2 | ARIA: dialog pattern

Keyboard (1 issue)
  #108 Dropdown loses focus on Escape — 5 days old [High]
       WCAG 2.1.2 | ARIA: combobox pattern

Visual (1 issue)
  #99  Chart legend contrast 2.8:1 — 10 days old [Medium]
       WCAG 1.4.3 | No ARIA pattern
```

## Example Variations

```
/a11y-update                              # All configured repos
/a11y-update owner/repo                   # One repo
/a11y-update screen reader only          # One category
/a11y-update high impact only            # Filter by impact level
```

## Connected Agents

| Agent | Role |
|-------|------|
| insiders-a11y-tracker agent | Executes this prompt |

## Related Prompts

- [triage](triage.md) — prioritize all issues including accessibility
- [daily-briefing](daily-briefing.md) — full briefing including accessibility updates
