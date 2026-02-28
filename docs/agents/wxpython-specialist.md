# wxpython-specialist - wxPython GUI Expert

> wxPython GUI expert -- sizer layouts, event handling, AUI framework, custom controls, threading (wx.CallAfter/wx.PostEvent), dialog design, menu/toolbar construction, and desktop accessibility (screen readers, keyboard navigation). Covers cross-platform gotchas for Windows, macOS, and Linux.

## When to Use It

- Building or fixing wxPython GUI layouts with sizers
- Handling events, custom events, or UI update events
- Working with AUI (Advanced User Interface) panes and docking
- Creating dialogs, menus, toolbars, or accelerator tables
- Threading in wxPython (wx.CallAfter, wx.PostEvent, wx.Timer)
- Making wxPython controls accessible to screen readers
- Auditing wxPython code for accessibility issues

## What It Does NOT Do

- Does not handle pure Python language issues unrelated to wxPython (routes to python-specialist)
- Does not implement platform accessibility APIs directly (routes to desktop-a11y-specialist)
- Does not perform screen reader testing (routes to desktop-a11y-testing-coach)

## Accessibility Audit Mode

When asked to audit a wxPython project for accessibility, the agent uses 12 structured detection rules (WX-A11Y-001 through WX-A11Y-012) covering:

| Rule Range | What It Covers |
|---|---|
| WX-A11Y-001..003 | Critical: Missing SetName(), no AcceleratorTable, mouse-only events |
| WX-A11Y-004..006 | Serious: Dialog UX, focus on ShowModal, bitmap labels |
| WX-A11Y-007..009 | Moderate: Color-only state, silent status changes, custom-drawn panels |
| WX-A11Y-010..012 | Minor/Moderate: Tab order, virtual lists, menu accelerators |

Returns a structured report with file, line number, and concrete code fix for each finding.

## Example Prompts

- "Fix my sizer layout -- controls aren't expanding"
- "Add keyboard shortcuts to my app"
- "Make this dialog accessible to screen readers"
- "Audit this wxPython project for accessibility"
- "Help me with AUI pane management"
- "My app crashes when I update the GUI from a thread"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | wxPython sizer/event/threading cheat sheets, accessibility reference |

## Related Agents

- [python-specialist](python-specialist.md) -- bidirectional handoffs for Python language work
- [desktop-a11y-specialist](desktop-a11y-specialist.md) -- bidirectional handoffs for platform API accessibility
- [desktop-a11y-testing-coach](desktop-a11y-testing-coach.md) -- screen reader verification after fixes
- [developer-hub](developer-hub.md) -- routes here for GUI tasks
