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

## How to Launch It

**In Claude Code:**
```
/accessibility-lead build a login form with email and password
/accessibility-lead audit the entire checkout flow
/accessibility-lead review components/DataTable.tsx
```

**In GitHub Copilot Chat:**
```
@accessibility-lead review this component for accessibility
@accessibility-lead full audit of the settings page
@accessibility-lead I'm building a dashboard with charts and tables
```

**Automatic invocation:** When working in Copilot, the workspace instructions ensure the lead is always available as a first-line coordinator. In Claude Code, the UserPromptSubmit hook evaluates every UI-related prompt and injects the lead's context.

## Step-by-Step: How a Full Audit Works

When you ask the accessibility-lead to audit a component or page, here is exactly what happens.

**You say:**
```
/accessibility-lead audit the checkout form in CheckoutPage.tsx
```

**Phase 1: Component Classification**
The lead reads the component and identifies what specialist domains are involved. For a checkout form, it identifies:
- A form with inputs, labels, and validation → forms-specialist
- Buttons and interactive elements → aria-specialist + keyboard-navigator
- Error messages that appear dynamically → live-region-controller
- Color-coded feedback (red for errors) → contrast-master
- A modal confirmation dialog → modal-specialist

**Phase 2: Parallel Specialist Invocation**
The lead invokes each relevant specialist simultaneously, passing the relevant component sections to each one.

**Phase 3: Finding Synthesis**
Each specialist returns findings. The lead deduplicates (e.g., both aria-specialist and forms-specialist might flag an unlabeled input — the lead keeps one finding, not two), classifies severity, and builds a unified report.

**Phase 4: Prioritized Report**
The report is organized by impact:

```
Audit: CheckoutPage.tsx — Checkout Form

Score: 62/100 (C)

Critical (blocks access):
  1. [keyboard-navigator] Tab order skips the credit card expiry field — users
     who rely on keyboard cannot reach this input.

Major (degrades experience):
  2. [forms-specialist] Error messages use color only (red text) without an icon
     or text prefix — WCAG 1.4.1 Use of Color violation.
  3. [modal-specialist] Confirmation dialog does not trap focus — screen reader
     users can navigate outside the dialog while it is open.

Minor (room for improvement):
  4. [live-region-controller] Form submission spinner has no live region — screen
     readers do not announce that processing has started.

Passed (21 checks):
  [aria-specialist] All ARIA on custom selects is correct.
  [contrast-master] All text color combinations pass 4.5:1.
  ... (expand to see all)
```

**Phase 5: Ship/No-Ship Decision**
The lead makes an explicit recommendation: ship (no critical/major issues), ship with caveats (minor issues, document), or do not ship (critical access barriers present).

## How the Lead Decides Which Specialists to Invoke

| Component type | Specialists always invoked | Additional specialists |
|---------------|--------------------------|------------------------|
| Any component or page | keyboard-navigator | Based on content |
| Has images or headings | + alt-text-headings | |
| Has forms or inputs | + forms-specialist | |
| Has custom widgets / ARIA | + aria-specialist | |
| Has overlays / modals | + modal-specialist | |
| Has dynamic content updates | + live-region-controller | |
| Has data tables | + tables-data-specialist | |
| Has links | + link-checker | |
| Has colors / styling | + contrast-master | |

## Connections

| Connect to | When |
|------------|------|
| [aria-specialist](aria-specialist.md) | Custom widgets, ARIA roles and properties |
| [keyboard-navigator](keyboard-navigator.md) | Always — tab order and focus management |
| [forms-specialist](forms-specialist.md) | Any forms, inputs, or validation |
| [modal-specialist](modal-specialist.md) | Dialogs, drawers, overlays |
| [live-region-controller](live-region-controller.md) | Dynamic content and announcements |
| [contrast-master](contrast-master.md) | Color and visual design |
| [alt-text-headings](alt-text-headings.md) | Images, headings, landmarks |
| [tables-data-specialist](tables-data-specialist.md) | Data tables and grids |
| [link-checker](link-checker.md) | Link text quality |
| [testing-coach](testing-coach.md) | Verification after implementation |

<details>
<summary>Show example prompts</summary>

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

</details>

## Behavioral Constraints

<details>
<summary>Expand constraints</summary>

- Will always invoke at least keyboard-navigator (tab order breaks easily with any change)
- Will not let code ship without verifying the final review checklist
- Reports findings by severity: Critical (blocks access), Major (degrades experience), Minor (room for improvement)
- Flags accessibility conflicts with design requirements explicitly rather than silently compromising

</details>
