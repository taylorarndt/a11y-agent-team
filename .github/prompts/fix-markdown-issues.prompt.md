---
description: Interactive fix mode for markdown accessibility issues. Applies auto-fixable items and walks through human-judgment items one at a time. Uses the most recent MARKDOWN-ACCESSIBILITY-AUDIT.md or runs a fresh scan first.
mode: agent
agent: markdown-a11y-assistant
---

# Fix Markdown Accessibility Issues

Apply accessibility fixes to your markdown files using interactive fix mode. Handles auto-fixable items immediately and walks you through human-judgment items (alt text, complex diagrams, link rewrites) one at a time with before/after previews.

## How to Use

Tell the agent what to fix:

- Fix from a saved report: `fix issues from MARKDOWN-ACCESSIBILITY-AUDIT.md`
- Fix specific files: `fix accessibility issues in README.md`
- Fix a specific domain only: `fix all broken anchor links in this repo`
- Fix after a quick check: `fix the errors found in the quick check`

## What Gets Fixed Automatically

| Domain | Examples |
|--------|---------|
| Ambiguous links | `[here](url)` -> `[installation guide](url)` |
| Heading hierarchy | Skipped levels interpolated; multiple H1s demoted |
| Emoji removal | Removed from headings, bullets, consecutive sequences |
| Emoji translation | Replaced with `(English)` if translate mode chosen |
| Em-dash normalization | `—` and `--` -> ` - ` |
| Table descriptions | One-sentence summary prepended to tables missing one |
| Mermaid diagrams | Auto-described + wrapped in `<details>` (simple types) |
| ASCII diagrams | Wrapped in `<details>` with description (when auto-gen possible) |

## What Requires Your Review

- Alt text for images (visual judgment required)
- Complex Mermaid diagrams (generated description needs your verification)
- ASCII art diagrams where description cannot be auto-generated
- Link text rewrites where surrounding context is insufficient
- Plain language improvements

## Instructions for the Agent

1. If a `MARKDOWN-ACCESSIBILITY-AUDIT.md` exists: ask whether to use it or run a fresh scan
2. If no report exists or user requests fresh scan: run `markdown-scanner` now, skip Phase 0 except asking emoji and dash preferences
3. Invoke `markdown-fixer` with the full approved issue list
4. Apply all auto-fixes in a single pass per file
5. Present each human-judgment item with before/after preview and ask for approval
6. After all fixes: show a summary table of what was fixed vs. what remains
7. Offer to save an updated audit report reflecting the new state

## Handoff Transparency

This workflow delegates to the `markdown-fixer` sub-agent. Announce transitions:
- **Before delegation:** "Applying [N] fixes to [filename] ([N] auto-fixable, [N] human-judgment)"
- **Per fix:** Show before/after with accessibility impact
- **After completion:** "Fix pass complete: [N] applied, [N] skipped, [N] need review. Score: [before] -> [after]"
- **On failure:** "Fix failed for [target]: [reason]. File left unchanged."
