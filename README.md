# A11y Agent Team

**Accessibility review tools for Claude Code, GitHub Copilot, and Claude Desktop.**

Built by [Taylor Arndt](https://github.com/taylorarndt) because LLMs consistently forget accessibility. Skills get ignored. Instructions drift out of context. ARIA gets misused. Focus management gets skipped. Color contrast fails silently. I got tired of fighting it, so I built a team of agents that will not let it slide.

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely. Studies show that skill auto-activation in Claude Code fails roughly 80% of the time without intervention.

## The Solution

A11y Agent Team works in three ways:

- **Claude Code** (terminal): Eleven specialized agents plus a hook that forces evaluation on every prompt. Each agent has a single focused job it cannot ignore. The Accessibility Lead orchestrator coordinates the team and ensures the right specialists are invoked for every task.
- **GitHub Copilot** (VS Code): The same eleven agents converted to Copilot's custom agent format, plus workspace-level instructions, PR review instructions, commit message guidance, a PR template with an accessibility checklist, a CI workflow, VS Code tasks, recommended extensions, and MCP server configuration. Works with GitHub Copilot Chat in VS Code and other editors that support the `.github/agents/` format.
- **Claude Desktop** (app): An MCP extension (.mcpb) that adds accessibility tools and review prompts directly into the Claude Desktop interface. Check contrast ratios, get component guidelines, and run specialist reviews without leaving the app.

## The Team

| Agent | Role |
|-------|------|
| **accessibility-lead** | Orchestrator. Decides which specialists to invoke and runs the final review before anything ships. |
| **aria-specialist** | ARIA roles, states, properties, widget patterns. Enforces the first rule of ARIA: don't use it if native HTML works. |
| **modal-specialist** | Dialogs, drawers, popovers, alerts. Owns focus trapping, focus return, escape behavior, and heading structure in overlays. |
| **contrast-master** | Color contrast ratios, dark mode, focus indicators, color independence. Includes a contrast calculation script for verification. |
| **keyboard-navigator** | Tab order, focus management, skip links, arrow key patterns, SPA route changes. If it can't be reached by keyboard, it doesn't ship. |
| **live-region-controller** | Dynamic content announcements, toasts, loading states, search results, debouncing. Bridges visual updates to screen reader awareness. |
| **forms-specialist** | Labels, errors, validation, fieldsets, autocomplete, multi-step wizards, search forms, file uploads, custom controls. If users input data, this agent owns it. |
| **alt-text-headings** | Alt text, SVGs, icons, heading hierarchy, landmarks, page titles, language attributes. Can visually analyze images and compare them against their existing alt text. |
| **tables-data-specialist** | Table markup, scope, caption, headers, sortable columns, responsive patterns, ARIA grids. If it displays tabular data, this agent owns it. |
| **testing-coach** | Screen reader testing (NVDA, VoiceOver, JAWS), keyboard testing, automated testing (axe-core, Playwright, Pa11y), test plans. Does not write product code — teaches you how to test. |
| **wcag-guide** | WCAG 2.2 success criteria in plain language, conformance levels, what changed between versions, when criteria apply. Does not write or review code — teaches the standard itself. |

---

## Claude Code Setup

This is for the **Claude Code CLI** (the terminal tool). If you want the Claude Desktop app extension, skip to [Claude Desktop Setup](#claude-desktop-setup) below.

### How It Works

A `UserPromptSubmit` hook fires on every prompt you send to Claude Code. If the task involves web UI code, the hook instructs Claude to delegate to the **accessibility-lead** first. The lead evaluates the task and invokes the relevant specialists. The specialists apply their focused expertise and report findings. Code does not proceed without passing review.

The team includes eleven agents: eight code specialists that write and review code, one orchestrator that coordinates them, one testing coach that teaches you how to verify accessibility, and one WCAG guide that explains the standards themselves.

For tasks that don't involve UI code (backend logic, scripts, database work), the hook is ignored and Claude proceeds normally.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and working
- A Claude Code subscription (Pro, Max, or Team)
- **macOS/Linux:** bash shell (pre-installed)
- **Windows:** PowerShell 5.1+ (pre-installed on Windows 10/11)

### Installation

#### macOS and Linux

```bash
# Clone the repository
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team

# Run the installer
bash install.sh
```

The installer will ask whether to install at the **project level** or **globally**. You can also pass a flag to skip the prompt:

```bash
# Install globally (available in all projects)
bash install.sh --global

# Install to the current project only
bash install.sh --project
```

To remove:

```bash
bash uninstall.sh
bash uninstall.sh --global    # Non-interactive global uninstall
bash uninstall.sh --project   # Non-interactive project uninstall
```

#### Windows (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team

# Run the installer
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer prompts for project-level or global installation, just like the bash version.

To remove:

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

#### Manual Setup

If you prefer to install manually or need to integrate into an existing configuration:

**1. Copy agents**

```bash
# For project install
mkdir -p .claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md .claude/agents/

# For global install
mkdir -p ~/.claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md ~/.claude/agents/
```

**2. Copy the hook**

macOS/Linux:
```bash
# For project install
mkdir -p .claude/hooks
cp path/to/a11y-agent-team/.claude/hooks/a11y-team-eval.sh .claude/hooks/
chmod +x .claude/hooks/a11y-team-eval.sh

# For global install
mkdir -p ~/.claude/hooks
cp path/to/a11y-agent-team/.claude/hooks/a11y-team-eval.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/a11y-team-eval.sh
```

Windows:
```powershell
# For project install
New-Item -ItemType Directory -Force -Path .claude\hooks
Copy-Item path\to\a11y-agent-team\.claude\hooks\a11y-team-eval.ps1 .claude\hooks\

# For global install
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.claude\hooks
Copy-Item path\to\a11y-agent-team\.claude\hooks\a11y-team-eval.ps1 $env:USERPROFILE\.claude\hooks\
```

**3. Add the hook to settings.json**

Merge the hook configuration into your `.claude/settings.json` (project) or `~/.claude/settings.json` (global):

macOS/Linux:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/a11y-team-eval.sh"
          }
        ]
      }
    ]
  }
}
```

For global install, use the absolute path:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/yourname/.claude/hooks/a11y-team-eval.sh"
          }
        ]
      }
    ]
  }
}
```

Windows:
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File '.claude\\hooks\\a11y-team-eval.ps1'"
          }
        ]
      }
    ]
  }
}
```

If you already have hooks configured, add the `UserPromptSubmit` entry alongside your existing hooks.

**4. Verify**

Start Claude Code and type `/agents`. You should see all eleven agents listed:

```
/agents
  accessibility-lead
  alt-text-headings
  aria-specialist
  contrast-master
  forms-specialist
  keyboard-navigator
  live-region-controller
  modal-specialist
  tables-data-specialist
  testing-coach
  wcag-guide
```

If they all show up, you are good to go.

### Using the Agents in Claude Code

#### Automatic (via hook)

Just write code like you normally would. The hook fires on every prompt. If your task involves web UI code, the accessibility-lead activates automatically and brings in the right specialists.

```
You: Build a login form with email and password fields

Claude: [Hook fires, accessibility-lead activates]
        [accessibility-lead invokes aria-specialist, keyboard-navigator, contrast-master]

        The login form includes:
        - Labeled inputs with <label> elements and matching for attributes
        - Error messages linked via aria-describedby
        - Focus moves to first error on invalid submit
        - Submit button is a <button type="submit">
        - Contrast ratios verified for all text
        ...
```

For tasks that don't involve UI code, Claude proceeds normally:

```
You: Write a database migration to add a users table

Claude: [Hook fires, detects no UI code involved, proceeds normally]
        [No agents invoked, works like standard Claude Code]
```

#### Manual (invoke directly)

You can invoke any agent by name using the slash command:

```
/accessibility-lead full audit of the checkout flow
/aria-specialist review the ARIA in components/modal.tsx
/contrast-master check all color combinations in globals.css
/keyboard-navigator audit tab order on the settings page
/modal-specialist review the confirmation dialog
/live-region-controller check search result announcements
/forms-specialist review the registration form
/alt-text-headings audit all images and heading structure
/tables-data-specialist review the pricing comparison table
/testing-coach how do I test this modal with NVDA?
/wcag-guide explain WCAG 1.4.11 non-text contrast
```

Or use the `@` mention syntax:

```
@accessibility-lead review this component
@aria-specialist check the ARIA on this dropdown
@forms-specialist review form validation in this file
@alt-text-headings check alt text on all images in this page
@tables-data-specialist check table markup in the dashboard
@testing-coach what screen reader testing should I do for this?
@wcag-guide what does WCAG 2.5.8 target size require?
```

To see all installed agents at any time, type `/agents` in Claude Code.

### Global vs Project Install

**Project-level** (recommended for teams): Install to `.claude/` in each web project. Check into version control so your whole team benefits. The agents and hook travel with the repo.

**Global** (recommended for individuals): Install to `~/.claude/` to have the team available across all your projects automatically. Nothing to configure per-project. One install covers everything.

You can use both. Project-level agents override global agents with the same name, so you could customize an agent for a specific project while keeping the defaults globally.

### Auto-Updates (Claude Code)

During global installation, the installer asks if you want to enable auto-updates. When enabled, a daily scheduled job checks GitHub for new agent versions and installs them automatically.

- **macOS:** Uses a LaunchAgent (`~/Library/LaunchAgents/com.taylorarndt.a11y-agent-team-update.plist`), runs daily at 9:00 AM
- **Linux:** Uses a cron job, runs daily at 9:00 AM
- **Windows:** Uses Task Scheduler (`A11yAgentTeamUpdate`), runs daily at 9:00 AM

Update log is saved to `~/.claude/.a11y-agent-team-update.log`.

You can also run updates manually at any time:

macOS/Linux:
```bash
bash update.sh
```

Windows:
```powershell
powershell -File update.ps1
```

Auto-updates are fully removed when you run the uninstaller.

---

## GitHub Copilot Setup

This is for **GitHub Copilot Chat** in VS Code (or other editors that support the `.github/agents/` format). If you want the Claude Code CLI agents, see [Claude Code Setup](#claude-code-setup) above. If you want the Claude Desktop app extension, skip to [Claude Desktop Setup](#claude-desktop-setup) below.

### How It Works

GitHub Copilot supports custom agents via `.github/agents/*.md` files and workspace-level instructions via `.github/copilot-instructions.md`. The A11y Agent Team provides:

- **Eight specialist agents** that you can invoke by name in Copilot Chat
- **Workspace instructions** that remind Copilot to consider accessibility on every UI task
- **PR review instructions** (`.github/copilot-review-instructions.md`) that enforce accessibility standards during Copilot Code Review on pull requests
- **Commit message instructions** (`.github/copilot-commit-message-instructions.md`) that guide Copilot to include accessibility context in commit messages
- **PR template** (`.github/PULL_REQUEST_TEMPLATE.md`) with an accessibility checklist for every pull request
- **CI workflow** (`.github/workflows/a11y-check.yml`) that runs automated accessibility checks on PRs
- **VS Code configuration** (`.vscode/`) with recommended extensions, settings, tasks, and MCP server config

Unlike Claude Code's hook system, Copilot does not have a pre-prompt hook. Instead, the workspace instructions in `.github/copilot-instructions.md` are automatically loaded into every Copilot Chat conversation, serving the same purpose — ensuring accessibility is never forgotten.

### Prerequisites

- [GitHub Copilot](https://github.com/features/copilot) subscription (Individual, Business, or Enterprise)
- VS Code with the GitHub Copilot extension installed
- Agent mode and custom agents enabled in VS Code settings

### Installation

```bash
# Clone the repository
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team

# Copy the .github directory into your project
cp -r .github /path/to/your/project/
```

Or manually copy the files:

**1. Copy agents**

```bash
mkdir -p .github/agents
cp path/to/a11y-agent-team/.github/agents/*.md .github/agents/
```

**2. Copy workspace instructions and review configs**

```bash
cp path/to/a11y-agent-team/.github/copilot-instructions.md .github/
cp path/to/a11y-agent-team/.github/copilot-review-instructions.md .github/
cp path/to/a11y-agent-team/.github/copilot-commit-message-instructions.md .github/
cp path/to/a11y-agent-team/.github/PULL_REQUEST_TEMPLATE.md .github/
```

**3. Copy CI workflow**

```bash
mkdir -p .github/workflows
cp path/to/a11y-agent-team/.github/workflows/a11y-check.yml .github/workflows/
```

**4. Copy VS Code configuration (optional but recommended)**

```bash
mkdir -p .vscode
cp path/to/a11y-agent-team/.vscode/extensions.json .vscode/
cp path/to/a11y-agent-team/.vscode/settings.json .vscode/
cp path/to/a11y-agent-team/.vscode/tasks.json .vscode/
cp path/to/a11y-agent-team/.vscode/mcp.json .vscode/
```

If you already have a `.github/copilot-instructions.md`, merge the accessibility content into your existing file.

### Using the Agents in Copilot Chat

#### Invoke by name

In Copilot Chat, mention an agent to invoke it:

```
@accessibility-lead full audit of the checkout flow
@aria-specialist review the ARIA in components/modal.tsx
@contrast-master check all color combinations in globals.css
@keyboard-navigator audit tab order on the settings page
@modal-specialist review the confirmation dialog
@live-region-controller check search result announcements
@forms-specialist review the registration form for label and error handling
@alt-text-headings audit all images and heading structure on the homepage
@tables-data-specialist review all data tables in the admin dashboard
@testing-coach how should I test this component with VoiceOver?
@wcag-guide what changed between WCAG 2.1 and 2.2?
```

#### Automatic guidance

The workspace instructions in `.github/copilot-instructions.md` are loaded into every Copilot Chat conversation. When you ask Copilot to build or modify UI code, it will automatically consider accessibility requirements and reference the specialist agents.

### Differences from Claude Code

| Feature | Claude Code | GitHub Copilot |
|---------|-------------|----------------|
| Agent location | `.claude/agents/` | `.github/agents/` |
| Hook/instructions | `UserPromptSubmit` hook | `.github/copilot-instructions.md` |
| PR review | N/A | `.github/copilot-review-instructions.md` |
| Commit messages | N/A | `.github/copilot-commit-message-instructions.md` |
| PR template | N/A | `.github/PULL_REQUEST_TEMPLATE.md` |
| CI workflow | N/A | `.github/workflows/a11y-check.yml` |
| VS Code config | N/A | `.vscode/` (extensions, settings, tasks, MCP) |
| Invocation | `/agent-name` or `@agent-name` | `@agent-name` |
| Auto-activation | Hook forces evaluation on every prompt | Workspace instructions provide guidance |
| Tool access | Explicit tool list per agent | Copilot manages tool access |
| Global install | `~/.claude/agents/` | Per-project only |

---

## Agent Reference Guide

This section is the comprehensive reference for every agent in the team. It covers what each agent does, when to use it, exactly how to invoke it in both Claude Code and GitHub Copilot, example prompts that demonstrate best practices, what each agent will and will not catch, and the constraints that shape how each agent behaves. Treat this as your instructor in a pocket — everything you need to get the most out of each specialist, whether you have used accessibility tools before or this is your first time.

### How Agents Work — The Mental Model

Think of the A11y Agent Team as a consulting team of accessibility specialists. You do not need to know which specialist to call — that is the lead's job. But you *can* call any specialist directly when you already know what you need.

**The accessibility-lead** is your single point of contact. Tell it what you are building or reviewing, and it will figure out which specialists are needed, invoke them, and compile the findings. If you only remember one agent name, remember this one.

**The eight code specialists** (aria-specialist, modal-specialist, contrast-master, keyboard-navigator, live-region-controller, forms-specialist, alt-text-headings, tables-data-specialist) each own one domain of accessibility. They write code, review code, and report issues within their area. They do not overlap — each has a clear boundary.

**The testing-coach** does not write product code. It teaches you how to test what the other agents built. It knows screen reader commands, keyboard testing workflows, automated testing tools, and how to write test plans.

**The wcag-guide** does not write or review code. It explains the Web Content Accessibility Guidelines in plain language. When you need to understand *why* a rule exists or *what* a specific WCAG criterion requires, this is your reference.

### Invocation Syntax

#### Claude Code (Terminal)

| Method | Syntax | When to Use |
|--------|--------|-------------|
| Slash command | `/accessibility-lead review this page` | Direct invocation from the prompt |
| At-mention | `@accessibility-lead review this page` | Alternative syntax, same behavior |
| Automatic (hook) | Just type your prompt normally | The hook fires on every prompt and activates the lead for UI tasks |
| List agents | `/agents` | See all installed agents |

The hook-based automatic activation means you typically do not need to invoke agents manually — the lead activates on any UI-related prompt. But when you want a specific specialist or want to bypass the lead, invoke directly:

```
# Ask a specific specialist directly
/aria-specialist review the ARIA on this combobox
/contrast-master are these colors accessible?

# Ask for testing guidance (not code)
/testing-coach how do I test this modal with NVDA?

# Ask about the standard (not code)
/wcag-guide what is WCAG 2.4.11 focus not obscured?
```

#### GitHub Copilot (VS Code / Editor)

| Method | Syntax | When to Use |
|--------|--------|-------------|
| At-mention in Chat | `@accessibility-lead review this page` | Direct invocation in Copilot Chat panel |
| With file context | Select code, then `@aria-specialist check this` | Review selected code |
| Workspace instructions | Automatic — loaded on every conversation | Ensures accessibility guidance is always present |

Copilot does not have a hook system like Claude Code. Instead, the `.github/copilot-instructions.md` file is loaded into every Copilot Chat conversation. This means Copilot always has accessibility context, but it applies it as guidance rather than as a forced evaluation step.

```
# In Copilot Chat
@accessibility-lead full audit of the checkout flow
@forms-specialist review the signup form
@testing-coach what automated tests should I add for accessibility?
@wcag-guide does WCAG require 24x24px touch targets?
```

### Agent Deep Dives

---

#### accessibility-lead — The Orchestrator

**What it does:** Coordinates the entire accessibility team. Evaluates your task, decides which specialists are needed, invokes them, synthesizes their findings into a single prioritized report, and makes the ship/no-ship decision.

**When to use it:**
- Any new component or page (it will bring in the right specialists)
- Full accessibility audits
- When you are not sure which specialist you need
- As the default starting point for any UI task

**What it catches:** Everything — by delegating to the right specialists. It also catches cross-cutting issues that span multiple agents (e.g., a modal with a form that has contrast issues — it will invoke modal-specialist, forms-specialist, and contrast-master together).

**What it will not do:** Deep-dive into a single domain on its own. It delegates. If you ask it about ARIA specifics, it invokes the aria-specialist. If you ask about contrast ratios, it invokes contrast-master.

**Example prompts — Claude Code:**
```
/accessibility-lead build a login form with email and password
/accessibility-lead audit the entire checkout flow
/accessibility-lead review components/DataTable.tsx
/accessibility-lead what accessibility issues does this page have?
```

**Example prompts — Copilot:**
```
@accessibility-lead review this component for accessibility
@accessibility-lead full audit of the settings page
@accessibility-lead I'm building a dashboard with charts and tables, what do I need?
```

**Behavioral constraints:**
- Will always invoke at least keyboard-navigator (tab order breaks easily with any change)
- Will not let code ship without verifying the final review checklist
- Reports findings by severity: Critical (blocks access), Major (degrades experience), Minor (room for improvement)
- Flags accessibility conflicts with design requirements explicitly rather than silently compromising

---

#### aria-specialist — ARIA Roles, States, and Properties

**What it does:** Reviews and writes correct ARIA markup. Enforces the First Rule of ARIA: don't use ARIA if native HTML works. Knows every WAI-ARIA role, state, and property. Implements complex widget patterns (combobox, tabs, treegrid, menu).

**When to use it:**
- Custom interactive components (dropdowns, tabs, accordions, carousels, comboboxes)
- Any time you see `role=`, `aria-`, or plan to add them
- When native HTML is insufficient and ARIA is genuinely needed
- Reviewing existing ARIA for correctness

**What it catches:**
- Redundant ARIA on semantic elements (`role="button"` on `<button>`)
- Missing required ARIA attributes (e.g., `role="tabpanel"` without `aria-labelledby`)
- Invalid ARIA attribute combinations
- ARIA states not updating with interactions
- Wrong widget patterns (using `role="menu"` for navigation)
- Missing relationship attributes (`aria-controls`, `aria-describedby`)

**What it will not catch:** Visual issues (contrast), focus management (that is keyboard-navigator), or form labeling specifics (that is forms-specialist). It focuses purely on ARIA correctness.

**Example prompts — Claude Code:**
```
/aria-specialist review the ARIA on this combobox component
/aria-specialist build an accessible tab interface for these 4 sections
/aria-specialist is role="menu" correct for this navigation dropdown?
/aria-specialist check all ARIA attributes in src/components/
```

**Example prompts — Copilot:**
```
@aria-specialist review the ARIA in this dropdown component
@aria-specialist what role should I use for this custom widget?
@aria-specialist audit all ARIA usage in this file
```

**Behavioral constraints:**
- Will always prefer native HTML over ARIA. If you can use `<button>`, `<dialog>`, `<details>`, `<select>`, or any other native element, it will insist on that.
- Will reject ARIA that contradicts native semantics
- References specific WAI-ARIA Authoring Practices patterns with links
- Verifies that ARIA IDs referenced by `aria-controls`, `aria-labelledby`, `aria-describedby` actually exist in the DOM

---

#### modal-specialist — Dialogs, Drawers, and Overlays

**What it does:** Handles everything about overlays that appear above page content. Focus trapping, focus return, escape behavior, heading structure, background inertia, and scrolling behavior.

**When to use it:**
- Modals and dialogs
- Confirmation prompts
- Drawers and slide-out panels
- Popovers and tooltips
- Alert dialogs
- Cookie consent banners
- Any overlay that requires focus management

**What it catches:**
- Focus not trapped inside the modal
- Focus not returning to the trigger on close
- Escape key not closing the modal
- Missing `aria-modal="true"` or `<dialog>` usage
- Background content still interactive (not using `inert`)
- Heading level wrong (must start at H2 inside modals)
- Auto-focus landing on the wrong element
- Nested modals without proper stack management

**What it will not catch:** Content issues inside the modal (form accessibility is forms-specialist, contrast is contrast-master). It owns the modal *container* behavior, not the content within it.

**Example prompts — Claude Code:**
```
/modal-specialist review the confirmation dialog in CheckoutModal.tsx
/modal-specialist build an accessible drawer component
/modal-specialist is focus trapping correct in this modal?
/modal-specialist audit all dialogs in this project
```

**Example prompts — Copilot:**
```
@modal-specialist review this dialog for focus management
@modal-specialist build a cookie consent banner that meets WCAG
@modal-specialist check the drawer component in this file
```

**Behavioral constraints:**
- Requires `<dialog>` with `showModal()` as the preferred implementation. Accepts custom implementations only when `<dialog>` is genuinely insufficient.
- Requires focus to return to the trigger element on close — no exceptions
- Will reject modals that can only be closed by clicking outside (must have Escape support)
- Validates both the opening and closing flows

---

#### contrast-master — Color Contrast and Visual Accessibility

**What it does:** Verifies color contrast ratios, checks dark mode, ensures focus indicators are visible, and validates that no information is conveyed by color alone. Includes a contrast calculation script for programmatic verification.

**When to use it:**
- Choosing colors or creating themes
- CSS styling, Tailwind classes, or design tokens
- Dark mode implementation
- Focus indicator design
- Any use of color to convey state (error, success, warning)
- Design system compliance

**What it catches:**
- Text below 4.5:1 contrast ratio (3:1 for large text)
- UI components below 3:1 contrast
- Focus indicators below 3:1 contrast
- Information conveyed by color alone (red/green for error/success without text or icons)
- Disabled state contrast issues
- Dark mode regressions
- Transparent backgrounds that change with context
- Opacity levels that reduce effective contrast

**What it will not catch:** Non-visual issues (ARIA, keyboard, live regions). It owns the visual/color domain exclusively.

**Example prompts — Claude Code:**
```
/contrast-master check all color combinations in globals.css
/contrast-master is #767676 on white accessible for body text?
/contrast-master review the dark mode theme
/contrast-master check focus indicator visibility in this component
```

**Example prompts — Copilot:**
```
@contrast-master review the color palette in this design system
@contrast-master are these Tailwind colors accessible for text?
@contrast-master check contrast in the error state
```

**Behavioral constraints:**
- Uses exact WCAG contrast ratio math (relative luminance formula, not eyeballing)
- Reports exact ratios, not just pass/fail
- Checks both light and dark modes when both exist
- Flags `opacity` and `rgba` values that may reduce contrast below the context background

---

#### keyboard-navigator — Tab Order and Focus Management

**What it does:** Ensures every interactive element is reachable and operable by keyboard alone. Manages tab order, focus movement on dynamic content changes, skip links, SPA route changes, and arrow key patterns for custom widgets.

**When to use it:**
- Any interactive element (buttons, links, inputs, custom controls)
- Page navigation and routing (especially SPAs)
- Dynamic content that appears or disappears
- Deletion flows (where does focus go after an item is removed?)
- Modal opening/closing (focus management)
- Custom widgets that need arrow key navigation

**What it catches:**
- Interactive elements not in the tab order
- Positive `tabindex` values (breaks natural tab order)
- Focus lost after dynamic content changes
- Keyboard traps (can't Tab out of a section)
- Missing skip link
- `outline: none` without a replacement focus style
- Click handlers without keyboard equivalents
- Focus not managed on SPA route changes
- Missing Home/End/arrow key support in custom widgets

**What it will not catch:** Visual appearance of focus indicators (that is contrast-master), ARIA role correctness (aria-specialist), or modal focus trapping specifics (modal-specialist). It owns the *navigation* dimension.

**Example prompts — Claude Code:**
```
/keyboard-navigator audit tab order on the settings page
/keyboard-navigator check focus management in this SPA router
/keyboard-navigator where should focus go after deleting a list item?
/keyboard-navigator review skip link implementation
```

**Example prompts — Copilot:**
```
@keyboard-navigator check tab order for this component
@keyboard-navigator build focus management for this route change
@keyboard-navigator review keyboard interaction patterns in this dropdown
```

**Behavioral constraints:**
- Rejects any `tabindex` with a value greater than 0
- Requires a skip navigation link as the first focusable element on every page
- Requires focus management on every route change, modal open/close, and content deletion
- Tests focus order against visual layout order

---

#### live-region-controller — Dynamic Content Announcements

**What it does:** Bridges visual changes to screen reader awareness. Handles `aria-live` regions, toast notifications, loading states, search result counts, filter updates, progress indicators, and any content that changes without a full page reload.

**When to use it:**
- Toast notifications and alerts
- Search results (count changes, loading states)
- Filter and sort operations
- AJAX content loading
- Form submission feedback
- Real-time updates (chat, feeds, dashboards)
- Progress indicators and loading spinners
- Any content that appears, disappears, or changes without navigating to a new page

**What it catches:**
- Dynamic content changes with no live region announcement
- Live regions created dynamically (must exist in DOM before content changes)
- Wrong `aria-live` politeness (`assertive` used for routine updates)
- Toast notifications that disappear before screen readers can read them
- Missing loading state announcements
- `role="alert"` overuse (should be rare — only for genuinely urgent content)
- Duplicate announcements (debouncing issues)

**What it will not catch:** Visual styling of notifications (contrast-master), focus management when notifications appear (keyboard-navigator), or the structure of the notification content itself.

**Example prompts — Claude Code:**
```
/live-region-controller check search result announcements
/live-region-controller build toast notifications that work with screen readers
/live-region-controller add loading state announcements for this API call
/live-region-controller review all aria-live usage in this project
```

**Example prompts — Copilot:**
```
@live-region-controller review dynamic content updates in this component
@live-region-controller add a live region for these search filter results
@live-region-controller how should I announce loading states?
```

**Behavioral constraints:**
- Requires live regions to exist in the DOM before content changes (not created dynamically at announcement time)
- Defaults to `aria-live="polite"` — only allows `assertive` for critical alerts
- Requires debouncing for rapid updates (e.g., type-ahead search results, not announcing every keystroke)
- Times toast/notification durations against screen reader reading speed (minimum 5 seconds for short messages)

---

#### forms-specialist — Forms, Labels, Validation, and Errors

**What it does:** Owns every aspect of form accessibility. Labels, error messages, validation, required fields, fieldsets, autocomplete, multi-step wizards, search forms, file uploads, custom controls, and date pickers.

**When to use it:**
- Any form, input, select, textarea, checkbox, radio button
- Login/signup forms
- Search interfaces
- Multi-step wizards and checkout flows
- File uploads
- Date/time pickers
- Custom form controls
- Form validation and error handling

**What it catches:**
- Inputs without labels (or with placeholder-only "labels")
- Error messages not associated with the field via `aria-describedby`
- Missing `required` attribute on required fields
- No `aria-invalid` on fields with errors
- Radio/checkbox groups without `<fieldset>` and `<legend>`
- Missing `autocomplete` attributes for identity/payment fields
- Focus not moving to the first error on invalid submission
- Multi-step wizards without step announcements
- Search forms without proper roles and announcements
- File upload controls without accessible status feedback

**What it will not catch:** Visual styling of errors (contrast-master), ARIA on custom form widgets like comboboxes (aria-specialist), or focus management between form steps (keyboard-navigator).

**Example prompts — Claude Code:**
```
/forms-specialist review the registration form
/forms-specialist build an accessible multi-step checkout wizard
/forms-specialist check error handling on the login form
/forms-specialist audit all form inputs in this file for autocomplete
```

**Example prompts — Copilot:**
```
@forms-specialist review this form for label and error handling
@forms-specialist build accessible validation for these inputs
@forms-specialist check the password reset form
```

**Behavioral constraints:**
- Requires `<label>` with `for`/`id` for every input — `aria-label` only when visual labels are genuinely inappropriate
- Requires error messages to use text and/or icons, never color alone
- Requires `autocomplete` attributes on all identity/payment fields (WCAG 1.3.5)
- Rejects placeholder text as a replacement for labels

---

#### alt-text-headings — Alt Text, SVGs, Headings, and Landmarks

**What it does:** Manages alternative text for images, SVG accessibility, icon handling, heading hierarchy, landmark regions, page titles, and language attributes. Can visually analyze images and compare them against their existing alt text to determine if the description is accurate.

**When to use it:**
- Any page with images, photos, or illustrations
- SVG icons or inline SVGs
- Heading structure review
- Landmark structure (`<header>`, `<nav>`, `<main>`, `<footer>`)
- Page title verification
- Document language attributes
- Charts and infographics

**What it catches:**
- Missing `alt` attributes
- Generic alt text ("image", "photo", filename-based alt text)
- Decorative images missing `alt=""`
- SVGs without `role="img"` and `<title>`
- Icons not hidden from screen readers (`aria-hidden="true"` missing)
- Skipped heading levels (H1 → H3)
- Multiple H1 tags on a page
- Missing landmarks
- Multiple `<nav>` elements without unique labels
- Missing or generic page titles
- Missing `lang` attribute on `<html>`

**What it will not catch:** Interactive behavior (aria-specialist, keyboard-navigator), form content (forms-specialist), or color/contrast of images (contrast-master).

**Example prompts — Claude Code:**
```
/alt-text-headings audit all images and heading structure
/alt-text-headings is this alt text accurate for the hero image?
/alt-text-headings review SVG accessibility in the icon library
/alt-text-headings check landmark structure on the homepage
```

**Example prompts — Copilot:**
```
@alt-text-headings check alt text on all images in this page
@alt-text-headings review heading hierarchy in this template
@alt-text-headings audit SVG icons in the component library
```

**Behavioral constraints:**
- Evaluates alt text based on context, not just image content — the same image may need different alt text on different pages
- Requires `alt=""` on decorative images (not the absence of the `alt` attribute)
- Enforces strict heading sequence: one H1 per page, no skipped levels
- Requires all `<nav>` elements to have unique `aria-label` when multiple exist

---

#### tables-data-specialist — Data Tables, Grids, and Sortable Columns

**What it does:** Ensures data tables are properly structured for screen reader navigation. Covers table markup, header scope, captions, complex multi-level headers, sortable columns, interactive data grids, responsive table patterns, select-all checkboxes, pagination, and empty states.

**When to use it:**
- Any data table or grid
- Sortable/filterable tables
- Comparison tables or pricing tables
- Dashboard data displays
- Spreadsheet-like interfaces
- Tables with interactive elements (checkboxes, edit buttons, dropdowns)
- Responsive tables on mobile

**What it catches:**
- `<div>` grids styled to look like tables (screen readers cannot navigate these)
- `<td>` elements styled as headers instead of `<th>` with `scope`
- Missing `<caption>` on data tables
- Missing `scope="col"` / `scope="row"` on headers
- `aria-sort` not updating when sort changes
- Sortable column buttons outside the `<th>` element
- `role="grid"` on non-interactive tables (adds unnecessary complexity)
- Interactive elements in cells without descriptive `aria-label` (50 "Edit" buttons — edit what?)
- Pagination without `aria-current="page"`
- Layout tables without `role="presentation"`
- Responsive tables that hide columns incorrectly

**What it will not catch:** Content within table cells (form inputs are forms-specialist, links are aria-specialist), visual contrast of table borders (contrast-master), or focus management between pages (keyboard-navigator).

**Example prompts — Claude Code:**
```
/tables-data-specialist review the pricing comparison table
/tables-data-specialist build an accessible sortable data grid
/tables-data-specialist check the admin user table for screen reader nav
/tables-data-specialist audit all tables in the dashboard
```

**Example prompts — Copilot:**
```
@tables-data-specialist review the data table in this component
@tables-data-specialist add proper headers and scope to this table
@tables-data-specialist make this sortable table accessible
```

**Behavioral constraints:**
- Requires `<table>` for tabular data — will never accept `<div>` grid patterns as accessible
- Requires `<caption>` or `aria-label` on every data table
- Requires `scope` on every `<th>` — does not trust screen reader guessing
- Only allows `role="grid"` when cells contain interactive elements

---

#### testing-coach — How to Test Accessibility

**What it does:** Teaches you how to test what the other agents built. Provides screen reader commands (NVDA, VoiceOver, JAWS, Narrator, TalkBack), keyboard testing workflows, automated testing setup (axe-core, Playwright, Pa11y, Lighthouse), browser DevTools accessibility features, and test plan templates.

**When to use it:**
- You have built a component and need to verify it actually works in a screen reader
- Setting up automated accessibility tests in CI
- Learning screen reader commands for manual testing
- Creating an accessibility test plan for a feature
- Choosing the right testing tool combination
- Understanding what automated testing catches vs what requires manual testing

**What it does NOT do:**
- Does not write product code — it teaches testing practices
- Does not replace manual testing (automated tools catch ~30% of issues)
- Does not guarantee compliance (testing reveals issues, not their absence)

**What it covers:**
- NVDA commands (Windows, free) — full command reference
- VoiceOver commands (macOS, built-in) — full command reference including Rotor
- JAWS commands (Windows, enterprise) — essential commands
- Narrator commands (Windows, built-in) — quick-check commands
- The 5-Minute Keyboard Test workflow
- axe-core integration with Playwright, Cypress, Jest, and Storybook
- Pa11y CLI and CI configuration
- Lighthouse accessibility audits
- Chrome, Firefox, and Edge DevTools accessibility features
- Test plan templates for features
- Recommended browser + screen reader testing combinations
- Bug report templates for accessibility issues

**Example prompts — Claude Code:**
```
/testing-coach how do I test this modal with NVDA?
/testing-coach set up axe-core with Playwright for CI
/testing-coach what VoiceOver commands do I need for testing tables?
/testing-coach write an accessibility test plan for the checkout flow
/testing-coach what is the minimum screen reader testing I should do?
```

**Example prompts — Copilot:**
```
@testing-coach how should I test this component with VoiceOver?
@testing-coach what automated accessibility tests should I add?
@testing-coach create a test plan for the login page
@testing-coach what are the essential NVDA commands for testing forms?
```

**Behavioral constraints:**
- Will always emphasize that automated testing catches only ~30% of issues — manual testing is required
- Recommends minimum viable testing as NVDA + Firefox and VoiceOver + Safari
- Will not write product feature code — only test code and test plans
- Provides exact key commands, not vague descriptions

---

#### wcag-guide — Understanding the Standard

**What it does:** Explains WCAG 2.0, 2.1, and 2.2 success criteria in plain language with practical examples. Covers conformance levels, what changed between versions, when criteria apply and don't apply, common misconceptions, and the intent behind the rules. This is your reference for "why does this rule exist?" and "does this criterion apply to my situation?"

**When to use it:**
- Understanding a specific WCAG success criterion
- Learning what changed between WCAG 2.1 and 2.2
- Clarifying when a criterion applies vs doesn't apply
- Settling debates about what WCAG actually requires
- Understanding conformance levels (A, AA, AAA)
- Getting plain-language explanations of technical spec language

**What it does NOT do:**
- Does not write or review code (use the specialist agents for that)
- Does not run tests (use testing-coach for that)
- Does not make legal claims about compliance
- Does not cover WCAG AAA unless specifically asked (the team targets AA)

**Example prompts — Claude Code:**
```
/wcag-guide explain WCAG 1.4.11 non-text contrast
/wcag-guide what changed between WCAG 2.1 and 2.2?
/wcag-guide does 2.5.8 target size apply to inline text links?
/wcag-guide what is the difference between Level A and AA?
/wcag-guide do disabled controls need to meet contrast requirements?
```

**Example prompts — Copilot:**
```
@wcag-guide what does WCAG 2.5.8 target size require?
@wcag-guide what new criteria were added in WCAG 2.2?
@wcag-guide explain accessible authentication (3.3.8)
@wcag-guide when does the orientation criterion (1.3.4) not apply?
```

**Behavioral constraints:**
- Answers with the criterion number, name, conformance level, plain-language explanation, pass/fail examples, and what the criterion does NOT require
- References the correct specialist agent when the user needs code help after understanding the requirement
- Targets AA conformance unless the user specifically asks about AAA
- Corrects common misconceptions explicitly (e.g., "WCAG only applies to screen readers" → false)

---

### Tips for Getting the Best Results

**Be specific about context.** Instead of "review this file," say "review the modal in this file for focus trapping and escape behavior." Specific prompts activate the right specialist knowledge.

**Name the component type.** Instead of "check this code," say "check this combobox" or "review this sortable data table." Component type maps directly to specialist expertise.

**Ask for audits when you want breadth.** Use the accessibility-lead for broad reviews. Use individual specialists when you know exactly what domain you are concerned about.

**Chain specialists for complex components.** A modal with a form inside it? Invoke modal-specialist for the overlay behavior and forms-specialist for the form content. Or just use accessibility-lead and let it coordinate.

**Use testing-coach after building.** The code specialists help you write correct code. Testing-coach helps you verify it actually works. These are different activities.

**Use wcag-guide when debating.** If your team disagrees about what WCAG requires, ask wcag-guide. It gives definitive answers with criterion references, not opinions.

### Resources

- [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/) — The complete standard
- [WCAG 2.2 Understanding Documents](https://www.w3.org/WAI/WCAG22/Understanding/) — W3C's own plain-language explanations with examples
- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/) — Official design patterns for custom widgets
- [WAI-ARIA 1.2 Specification](https://www.w3.org/TR/wai-aria-1.2/) — The complete ARIA spec
- [Deque axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md) — What axe-core tests for
- [NVDA User Guide](https://www.nvaccess.org/files/nvda/documentation/userGuide.html) — Full NVDA reference
- [VoiceOver User Guide](https://support.apple.com/guide/voiceover/welcome/mac) — Full macOS VoiceOver reference
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) — Manual contrast ratio calculator
- [WebAIM Screen Reader User Survey](https://webaim.org/projects/screenreadersurvey10/) — Real data on assistive technology usage
- [A11y Project Checklist](https://www.a11yproject.com/checklist/) — Community-maintained accessibility checklist
- [Inclusive Components](https://inclusive-components.design/) — Accessible component patterns by Heydon Pickering

---

## Claude Desktop Setup

This is for the **Claude Desktop app** (the standalone application). If you want the Claude Code CLI agents, see [Claude Code Setup](#claude-code-setup) above.

### What is the .mcpb Extension?

The `.mcpb` file (MCP Bundle) is Claude Desktop's extension format. It is a packaged bundle that adds tools and prompts directly into the Claude Desktop interface. Think of it like a browser extension, but for Claude Desktop. You download one file, double-click it, and Claude Desktop installs it. No terminal, no git clone, no configuration.

The A11y Agent Team extension adds:

**Tools** (Claude can call these automatically while working):
- **check_contrast** -- Calculate WCAG contrast ratios between two hex colors. Returns the ratio and whether it passes AA for normal text (4.5:1), large text (3:1), and UI components (3:1).
- **get_accessibility_guidelines** -- Get detailed WCAG AA guidelines for specific component types: modal, tabs, accordion, combobox, carousel, form, live-region, navigation, or general. Returns requirements, code examples, and common mistakes.

**Prompts** (you select these from the prompt menu):
- **Full Accessibility Audit** -- Comprehensive WCAG 2.1 AA review covering structure, ARIA, keyboard, contrast, focus, and live regions.
- **ARIA Review** -- Focused review of ARIA roles, states, and properties. Enforces the first rule of ARIA.
- **Modal/Dialog Review** -- Focus trapping, focus return, escape behavior, heading structure in overlays.
- **Color Contrast Review** -- Color choices, CSS, Tailwind classes checked against AA requirements.
- **Keyboard Navigation Review** -- Tab order, focus management, skip links, keyboard traps.
- **Live Region Review** -- Dynamic content announcements, toasts, loading states, screen reader compatibility.

### How to Install

1. Go to the [Releases page](https://github.com/taylorarndt/a11y-agent-team/releases)
2. Download the latest `a11y-agent-team.mcpb` file
3. Double-click the file (or drag it into Claude Desktop)
4. Claude Desktop will open an install dialog -- click Install
5. Done. The tools and prompts are now available in every conversation

### How to Use in Claude Desktop

Once installed, the extension works in two ways:

**Tools activate automatically.** When you ask Claude to review code or build a component, it can call `check_contrast` and `get_accessibility_guidelines` on its own to verify its work.

**Prompts are available from the prompt menu.** Click the prompt picker (or type `/`) in Claude Desktop and you will see the six review prompts listed. Select one, paste your code, and get a focused specialist review.

### Updating the Extension

**Right now, updates are manual.** When a new version is released:

1. Go to the [Releases page](https://github.com/taylorarndt/a11y-agent-team/releases)
2. Download the latest `a11y-agent-team.mcpb` file
3. Double-click it to install -- Claude Desktop will recognize the version bump and update in place

To get notified when new versions are released, click **Watch** on the [GitHub repository](https://github.com/taylorarndt/a11y-agent-team) and select "Releases only." GitHub will email you when a new version drops.

**We have submitted this extension to the Anthropic Connectors Directory.** If accepted, the extension will appear in Claude Desktop's built-in directory (Settings > Connectors) and updates will be fully automatic. You will not need to manually download anything -- Claude Desktop will handle it. We will update this README when that happens.

### Building from Source

If you want to build the .mcpb yourself instead of downloading the pre-built release:

```bash
# Install the mcpb CLI
npm install -g @anthropic-ai/mcpb

# Clone the repo and install dependencies
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team/desktop-extension
npm install

# Validate the manifest
mcpb validate .

# Pack the extension
mcpb pack . ../a11y-agent-team.mcpb
```

The output file can be double-clicked to install in Claude Desktop.

---

## Configuration

### Character Budget (Claude Code only)

If you have many agents or skills installed, you may hit Claude Code's description character limit (defaults to 15,000 characters). The agents will silently stop loading. Increase the budget:

macOS/Linux:
```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000
```

Add this to your `~/.bashrc`, `~/.zshrc`, or shell profile to make it permanent.

Windows (PowerShell):
```powershell
$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = "30000"
```

Add this to your PowerShell profile (`$PROFILE`) to make it permanent.

### Disabling the Hook Temporarily (Claude Code only)

If you need to work without the accessibility check for a session, you can disable the hook in your settings.json temporarily by removing or commenting out the `UserPromptSubmit` entry. The agents will still be available for direct invocation with `/agent-name`.

## What This Covers

- WCAG 2.1 Level AA compliance
- Screen reader compatibility (VoiceOver, NVDA, JAWS)
- Keyboard-only navigation
- Focus management for SPAs, modals, and dynamic content
- Color contrast verification with automated calculation
- Live region implementation for dynamic updates
- Semantic HTML enforcement
- Common framework pitfalls (React conditional rendering, Tailwind contrast failures)

## What This Does Not Cover

- Mobile native accessibility (iOS/Android). A separate agent team for that is in development.
- PDF accessibility
- Automated testing tool integration (axe, Pa11y). The agents review code, they do not run browser-based tests.
- WCAG AAA compliance (agents target AA as the standard)

## Why Agents Instead of Skills or MCP

**Skills** rely on Claude deciding to check them. In practice, activation rates are roughly 20% without intervention. Even with hooks, skills are a single block of instructions that can be deprioritized as context grows.

**MCP servers** add external tool calls but don't change how Claude reasons about the code it writes. They're better suited for runtime checks than code-generation-time enforcement.

**Agents** run in their own context window with a dedicated system prompt. The accessibility rules aren't suggestions -- they're the agent's entire identity. An ARIA specialist cannot forget about ARIA. A contrast master cannot skip contrast checks. The rules are who they are.

The Desktop Extension uses MCP because that is what Claude Desktop supports -- it does not have an agent system like Claude Code. The MCP server packs the same specialist knowledge into tools and prompts that work within Desktop's architecture.

## Troubleshooting

### Agents not appearing (Claude Code)

Type `/agents` in Claude Code to see what is loaded. If the agents don't appear:

1. **Check file location:** Agents must be `.md` files in `.claude/agents/` (project) or `~/.claude/agents/` (global).
2. **Check file format:** Each agent file must start with a YAML front matter block (`---` delimiters) containing `name`, `description`, and `tools`.
3. **Check character budget:** If you have many agents/skills, increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` (see Configuration above).

### Hook not firing (Claude Code)

1. **Check settings.json:** The hook must be registered under `hooks` > `UserPromptSubmit` in your settings file.
2. **Check hook path:** For project install, the path is relative (`.claude/hooks/a11y-team-eval.sh`). For global install, it must be absolute (`/Users/yourname/.claude/hooks/a11y-team-eval.sh` or `C:\Users\yourname\.claude\hooks\a11y-team-eval.ps1`).
3. **Check permissions (macOS/Linux):** The hook script must be executable: `chmod +x .claude/hooks/a11y-team-eval.sh`
4. **Check PowerShell policy (Windows):** You may need to allow script execution: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Extension not working (Claude Desktop)

1. **Check it installed:** Go to Settings > Extensions in Claude Desktop. The A11y Agent Team should be listed.
2. **Try reinstalling:** Download the latest .mcpb from the Releases page and double-click it again.
3. **Check Claude Desktop version:** The extension requires Claude Desktop 0.10.0 or later.

### Agents activate on non-UI tasks (Claude Code)

The hook outputs instructions that tell Claude to check if the task involves UI code. If it still activates on backend tasks, the model is being overly cautious. This is harmless -- the agent will determine no UI work is needed and let Claude proceed. If it becomes disruptive, you can remove the hook and invoke agents manually with `/agent-name`.

### Agents seem to miss things

The agents enforce rules during code generation, but they depend on the model following their instructions. If you notice gaps:

1. Invoke the specific specialist directly: `/aria-specialist review components/modal.tsx`
2. Ask for a full audit: `/accessibility-lead audit the entire checkout flow`
3. Open an issue if a pattern is consistently missed

## Project Structure

```
a11y-agent-team/
  .claude/
    agents/
      accessibility-lead.md    # Orchestrator agent (Claude Code)
      alt-text-headings.md     # Alt text, SVGs, headings, landmarks
      aria-specialist.md       # ARIA roles, states, properties
      contrast-master.md       # Color contrast and visual a11y
      forms-specialist.md      # Forms, labels, validation, errors
      keyboard-navigator.md    # Tab order and focus management
      live-region-controller.md # Dynamic content announcements
      modal-specialist.md      # Dialogs, drawers, overlays
      tables-data-specialist.md # Data tables, grids, sortable columns
      testing-coach.md         # Screen reader and keyboard testing guide
      wcag-guide.md            # WCAG 2.2 criteria reference
    hooks/
      a11y-team-eval.sh        # UserPromptSubmit hook (macOS/Linux)
      a11y-team-eval.ps1       # UserPromptSubmit hook (Windows)
    settings.json              # Example hook configuration
  .github/
    agents/
      accessibility-lead.md    # Orchestrator agent (GitHub Copilot)
      alt-text-headings.md     # Alt text, SVGs, headings, landmarks
      aria-specialist.md       # ARIA roles, states, properties
      contrast-master.md       # Color contrast and visual a11y
      forms-specialist.md      # Forms, labels, validation, errors
      keyboard-navigator.md    # Tab order and focus management
      live-region-controller.md # Dynamic content announcements
      modal-specialist.md      # Dialogs, drawers, overlays
      tables-data-specialist.md # Data tables, grids, sortable columns
      testing-coach.md         # Screen reader and keyboard testing guide
      wcag-guide.md            # WCAG 2.2 criteria reference
    copilot-instructions.md    # Workspace-level accessibility instructions
    copilot-review-instructions.md  # PR review enforcement rules
    copilot-commit-message-instructions.md # Commit message a11y guidance
    PULL_REQUEST_TEMPLATE.md   # Accessibility checklist for PRs
    workflows/
      a11y-check.yml           # CI workflow for a11y checks on PRs
  .vscode/
    extensions.json            # Recommended a11y extensions
    mcp.json                   # MCP server config for Copilot
    settings.json              # VS Code a11y and Copilot settings
    tasks.json                 # A11y check tasks (contrast, alt text, etc.)
  desktop-extension/
    manifest.json              # Claude Desktop extension manifest
    package.json               # Node.js package config
    server/
      index.js                 # MCP server (tools + prompts)
  install.sh                   # Installer (macOS/Linux)
  install.ps1                  # Installer (Windows)
  uninstall.sh                 # Uninstaller (macOS/Linux)
  uninstall.ps1                # Uninstaller (Windows)
  update.sh                    # Manual/auto update (macOS/Linux)
  update.ps1                   # Manual/auto update (Windows)
  LICENSE                      # MIT License
  README.md                    # This file
```

## Contributing

Found a gap? Open an issue or PR. Contributions are welcome. Common contributions:

- Additional patterns for specific frameworks (Vue, Svelte, Angular)
- Edge cases we missed in existing agents
- Framework-specific gotchas (Next.js app router focus management, etc.)
- Improvements to agent instructions that reduce false positives
- New specialist agents for uncovered accessibility domains

If you find this useful, please star the repo and watch for releases so you know when updates drop.

## License

MIT

## About the Author

Built by [Taylor Arndt](https://github.com/taylorarndt), a developer and accessibility specialist who uses assistive technology daily. I built this because accessibility is how I work, not something I bolt on at the end. When I found that AI coding tools consistently failed at accessibility, I built the team I wished existed.
