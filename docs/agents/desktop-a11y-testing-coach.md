# desktop-a11y-testing-coach - Desktop Accessibility Testing

> Desktop accessibility testing expert -- testing with NVDA, JAWS, Narrator, VoiceOver, and Orca screen readers, Accessibility Insights for Windows, automated UIA testing, keyboard-only testing flows, high contrast verification, and creating desktop accessibility test plans.

## When to Use It

- Learning screen reader commands for desktop app testing (NVDA, JAWS, Narrator, VoiceOver, Orca)
- Creating a desktop accessibility test plan
- Setting up automated UIA testing with pywinauto or comtypes
- Verifying keyboard navigation and focus management
- Testing in Windows High Contrast mode
- Using Accessibility Insights for Windows to inspect the UIA tree
- Auditing the completeness of existing accessibility test coverage

## What It Does NOT Do

- Does not write product code -- teaches testing practices and creates test plans
- Does not implement accessibility fixes (routes to desktop-a11y-specialist or wxpython-specialist)
- Does not handle web accessibility testing (routes to testing-coach)

## Test Coverage Audit Mode

When asked to audit test coverage, the agent uses 10 structured detection rules (TST-A11Y-001 through TST-A11Y-010) that evaluate testing completeness:

| Rule Range | What It Covers |
|---|---|
| TST-A11Y-001..002 | Critical: No automated UIA tests, no screen reader testing documented |
| TST-A11Y-003..005 | Serious: Single SR only, no keyboard plan, no high contrast verification |
| TST-A11Y-006..008 | Moderate: Missing expected announcements, no focus tests, no Accessibility Insights |
| TST-A11Y-009..010 | Minor: Stale test plan, no CI integration |

## What It Covers

<details>
<summary>Expand - full testing coverage list</summary>

- NVDA commands and testing workflow (Windows, free)
- JAWS commands and behavioral differences (Windows, commercial)
- Narrator commands for quick smoke tests (Windows, built-in)
- VoiceOver commands (macOS, built-in)
- Orca commands (Linux/GNOME)
- Accessibility Insights for Windows: Live Inspect, FastPass, Assessment
- Automated UIA testing with pywinauto and comtypes
- Keyboard testing phases: Tab navigation, control interaction, focus management
- High contrast testing workflow
- Test plan templates with expected announcement tables

</details>

## Example Prompts

- "How do I test this with NVDA?"
- "Create an accessibility test plan for my app"
- "Set up automated UIA tests with pywinauto"
- "Verify keyboard navigation through all controls"
- "Audit our accessibility test coverage"
- "What should NVDA announce for a tree control?"

## Skills Used

| Skill | Purpose |
|-------|---------|
| [python-development](../skills/python-development.md) | Desktop accessibility API reference, testing quick reference |

## Related Agents

- [desktop-a11y-specialist](desktop-a11y-specialist.md) -- bidirectional: implement then test
- [wxpython-specialist](wxpython-specialist.md) -- routes here after GUI fixes for verification
- [testing-coach](testing-coach.md) -- web accessibility testing counterpart
- [developer-hub](developer-hub.md) -- routes here for testing tasks
