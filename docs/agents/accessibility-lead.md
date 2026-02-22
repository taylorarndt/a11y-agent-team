# accessibility-lead — The Orchestrator

> Coordinates the entire accessibility team. Evaluates your task, decides which specialists are needed, invokes them, synthesizes their findings into a single prioritized report, and makes the ship/no-ship decision.

## When to Use It

- Any new component or page (it will bring in the right specialists)
- Full accessibility audits
- When you are not sure which specialist you need
- As the default starting point for any UI task

## What It Catches

Everything — by delegating to the right specialists. It also catches cross-cutting issues that span multiple agents (e.g., a modal with a form that has contrast issues — it will invoke modal-specialist, forms-specialist, and contrast-master together).

## What It Will Not Do

Deep-dive into a single domain on its own. It delegates. If you ask it about ARIA specifics, it invokes the aria-specialist. If you ask about contrast ratios, it invokes contrast-master.

## Example Prompts

### Claude Code

```
/accessibility-lead build a login form with email and password
/accessibility-lead audit the entire checkout flow
/accessibility-lead review components/DataTable.tsx
/accessibility-lead what accessibility issues does this page have?
```

### GitHub Copilot

```
@accessibility-lead review this component for accessibility
@accessibility-lead full audit of the settings page
@accessibility-lead I am building a dashboard with charts and tables, what do I need?
```

## Behavioral Constraints

- Will always invoke at least keyboard-navigator (tab order breaks easily with any change)
- Will not let code ship without verifying the final review checklist
- Reports findings by severity: Critical (blocks access), Major (degrades experience), Minor (room for improvement)
- Flags accessibility conflicts with design requirements explicitly rather than silently compromising
