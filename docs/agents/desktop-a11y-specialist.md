# desktop-a11y-specialist - Desktop Application Accessibility

> Desktop application accessibility expert -- platform APIs (UI Automation, MSAA/IAccessible2, ATK/AT-SPI, NSAccessibility), accessible control patterns, screen reader Name/Role/Value/State, focus management, high contrast, and custom widget accessibility for Windows, macOS, and Linux desktop applications.

## When to Use It

- Implementing platform accessibility APIs (UIA, MSAA, ATK, NSAccessibility)
- Making custom widgets accessible to screen readers
- Fixing focus management issues (lost focus, wrong focus target)
- Adding high contrast and system color support
- Debugging screen reader announcement issues (wrong name, role, or state)
- Auditing desktop application code for accessibility issues

## What It Does NOT Do

- Does not build wxPython GUI layouts (routes to wxpython-specialist)
- Does not perform screen reader testing (routes to desktop-a11y-testing-coach)
- Does not handle web or document accessibility

## Accessibility Audit Mode

When asked to audit a desktop app for accessibility, the agent uses 12 structured detection rules (DTK-A11Y-001 through DTK-A11Y-012) covering:

| Rule Range | What It Covers |
|---|---|
| DTK-A11Y-001..002 | Critical: Missing accessible name, missing/wrong role |
| DTK-A11Y-003..004 | Serious: Missing state exposure, missing value exposure |
| DTK-A11Y-005 | Critical: Keyboard unreachable control |
| DTK-A11Y-006..010 | Serious: Focus lost, dynamic changes, modal escape |
| DTK-A11Y-007..008 | Moderate: Missing focus indicator, hardcoded colors |
| DTK-A11Y-011..012 | Minor/Moderate: Missing shortcut docs, platform API mismatch |

Returns a structured report with platform API context, expected vs actual behavior, and specific code fixes.

## Example Prompts

- "Make this custom panel accessible to NVDA"
- "Add UIA support to my tree control"
- "Fix focus management after dialog close"
- "Audit this desktop app for accessibility"
- "Why isn't Narrator reading my control's name?"
- "Add high contrast support"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | Desktop accessibility API reference, wxPython accessibility patterns |

## Related Agents

- [wxpython-specialist](wxpython-specialist.md) -- bidirectional handoffs for GUI accessibility patterns
- [desktop-a11y-testing-coach](desktop-a11y-testing-coach.md) -- bidirectional: implement then test
- [developer-hub](developer-hub.md) -- routes here for platform API accessibility work
