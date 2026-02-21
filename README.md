# A11y Agent Team

**A team of specialized accessibility agents for Claude Code.**

Built by [Techopolis](https://techopolis.online) because LLMs consistently forget accessibility. Skills get ignored. Instructions drift out of context. ARIA gets misused. Focus management gets skipped. Color contrast fails silently. We got tired of fighting it, so we built a team of agents that will not let it slide.

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely. Studies show that skill auto-activation in Claude Code fails roughly 80% of the time without intervention.

## The Solution

A11y Agent Team is a set of six specialized agents plus a hook that forces evaluation on every prompt. Instead of one generic accessibility reminder that gets forgotten, each agent has a single focused job it cannot ignore. The Accessibility Lead orchestrator coordinates the team and ensures the right specialists are invoked for every task.

## The Team

| Agent | Role |
|-------|------|
| **accessibility-lead** | Orchestrator. Decides which specialists to invoke and runs the final review before anything ships. |
| **aria-specialist** | ARIA roles, states, properties, widget patterns. Enforces the first rule of ARIA: don't use it if native HTML works. |
| **modal-specialist** | Dialogs, drawers, popovers, alerts. Owns focus trapping, focus return, escape behavior, and heading structure in overlays. |
| **contrast-master** | Color contrast ratios, dark mode, focus indicators, color independence. Includes a contrast calculation script for verification. |
| **keyboard-navigator** | Tab order, focus management, skip links, arrow key patterns, SPA route changes. If it can't be reached by keyboard, it doesn't ship. |
| **live-region-controller** | Dynamic content announcements, toasts, loading states, search results, debouncing. Bridges visual updates to screen reader awareness. |

## How It Works

A `UserPromptSubmit` hook fires on every prompt you send to Claude Code. If the task involves web UI code, the hook instructs Claude to delegate to the **accessibility-lead** first. The lead evaluates the task and invokes the relevant specialists. The specialists apply their focused expertise and report findings. Code does not proceed without passing review.

For tasks that don't involve UI code (backend logic, scripts, database work), the hook is ignored and Claude proceeds normally.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and working
- A Claude Code subscription (Pro, Max, or Team)
- **macOS/Linux:** bash shell (pre-installed)
- **Windows:** PowerShell 5.1+ (pre-installed on Windows 10/11)

## Installation

### macOS and Linux

```bash
# Clone the repository
git clone https://github.com/anthropics/a11y-agent-team.git
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

### Windows (PowerShell)

```powershell
# Clone the repository
git clone https://github.com/anthropics/a11y-agent-team.git
cd a11y-agent-team

# Run the installer
powershell -ExecutionPolicy Bypass -File install.ps1
```

The installer prompts for project-level or global installation, just like the bash version.

To remove:

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

### Manual Setup

If you prefer to install manually or need to integrate into an existing configuration:

#### 1. Copy agents

```bash
# For project install
mkdir -p .claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md .claude/agents/

# For global install
mkdir -p ~/.claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md ~/.claude/agents/
```

#### 2. Copy the hook

**macOS/Linux:**
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

**Windows:**
```powershell
# For project install
New-Item -ItemType Directory -Force -Path .claude\hooks
Copy-Item path\to\a11y-agent-team\.claude\hooks\a11y-team-eval.ps1 .claude\hooks\

# For global install
New-Item -ItemType Directory -Force -Path $env:USERPROFILE\.claude\hooks
Copy-Item path\to\a11y-agent-team\.claude\hooks\a11y-team-eval.ps1 $env:USERPROFILE\.claude\hooks\
```

#### 3. Add the hook to settings.json

Merge the hook configuration into your `.claude/settings.json` (project) or `~/.claude/settings.json` (global):

**macOS/Linux:**
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

**Windows:**
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

#### 4. Verify

Start Claude Code and ask it to list available agents. All six should appear. Ask it to build a component and the accessibility-lead should activate automatically.

## Global vs Project Install

**Project-level** (recommended for teams): Install to `.claude/` in each web project. Check into version control so your whole team benefits. The agents and hook travel with the repo.

**Global** (recommended for individuals): Install to `~/.claude/` to have the team available across all your projects automatically. Nothing to configure per-project. One install covers everything.

You can use both. Project-level agents override global agents with the same name, so you could customize an agent for a specific project while keeping the defaults globally.

## Usage Examples

### Building a new component

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

### Reviewing existing code

```
You: Review this component for accessibility issues

Claude: [Hook fires, accessibility-lead activates]
        [accessibility-lead invokes all specialists for a full audit]

        Accessibility Audit Results:

        Critical:
        - Modal missing focus trap (modal-specialist)
        - Search results have no live region (live-region-controller)

        Major:
        - Tab order skips the filter dropdown (keyboard-navigator)
        - Gray placeholder text fails contrast (contrast-master)

        Minor:
        - Icon button missing aria-label (aria-specialist)
        ...
```

### Non-UI tasks

```
You: Write a database migration to add a users table

Claude: [Hook fires, detects no UI code involved, proceeds normally]
        [No agents invoked, works like standard Claude Code]
```

### Using agents directly

You can invoke any agent by name without relying on the hook:

```
You: @aria-specialist review the ARIA in components/modal.tsx
You: @contrast-master check all color combinations in globals.css
You: @keyboard-navigator audit tab order on the settings page
You: @modal-specialist review the confirmation dialog
You: @live-region-controller check search result announcements
You: @accessibility-lead full audit of the checkout flow
```

## Configuration

### Character Budget

If you have many agents or skills installed, you may hit Claude Code's description character limit (defaults to 15,000 characters). The agents will silently stop loading. Increase the budget:

**macOS/Linux:**
```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000
```

Add this to your `~/.bashrc`, `~/.zshrc`, or shell profile to make it permanent.

**Windows (PowerShell):**
```powershell
$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = "30000"
```

Add this to your PowerShell profile (`$PROFILE`) to make it permanent.

### Disabling the Hook Temporarily

If you need to work without the accessibility check for a session, you can disable the hook in your settings.json temporarily by removing or commenting out the `UserPromptSubmit` entry. The agents will still be available for direct invocation with `@agent-name`.

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

## Troubleshooting

### Agents not appearing

Run `claude --print /agents` or ask Claude "What agents are available?" If the agents don't appear:

1. **Check file location:** Agents must be `.md` files in `.claude/agents/` (project) or `~/.claude/agents/` (global).
2. **Check file format:** Each agent file must start with a YAML front matter block (`---` delimiters) containing `name`, `description`, and `tools`.
3. **Check character budget:** If you have many agents/skills, increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` (see Configuration above).

### Hook not firing

1. **Check settings.json:** The hook must be registered under `hooks` > `UserPromptSubmit` in your settings file.
2. **Check hook path:** For project install, the path is relative (`.claude/hooks/a11y-team-eval.sh`). For global install, it must be absolute (`/Users/yourname/.claude/hooks/a11y-team-eval.sh` or `C:\Users\yourname\.claude\hooks\a11y-team-eval.ps1`).
3. **Check permissions (macOS/Linux):** The hook script must be executable: `chmod +x .claude/hooks/a11y-team-eval.sh`
4. **Check PowerShell policy (Windows):** You may need to allow script execution: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Agents activate on non-UI tasks

The hook outputs instructions that tell Claude to check if the task involves UI code. If it still activates on backend tasks, the model is being overly cautious. This is harmless -- the agent will determine no UI work is needed and let Claude proceed. If it becomes disruptive, you can remove the hook and invoke agents manually with `@agent-name`.

### Agents seem to miss things

The agents enforce rules during code generation, but they depend on the model following their instructions. If you notice gaps:

1. Invoke the specific specialist directly: `@aria-specialist review components/modal.tsx`
2. Ask for a full audit: `@accessibility-lead audit the entire checkout flow`
3. Open an issue if a pattern is consistently missed

## Project Structure

```
a11y-agent-team/
  .claude/
    agents/
      accessibility-lead.md    # Orchestrator agent
      aria-specialist.md       # ARIA roles, states, properties
      contrast-master.md       # Color contrast and visual a11y
      keyboard-navigator.md    # Tab order and focus management
      live-region-controller.md # Dynamic content announcements
      modal-specialist.md      # Dialogs, drawers, overlays
    hooks/
      a11y-team-eval.sh        # UserPromptSubmit hook (macOS/Linux)
      a11y-team-eval.ps1       # UserPromptSubmit hook (Windows)
    settings.json              # Example hook configuration
  install.sh                   # Installer (macOS/Linux)
  install.ps1                  # Installer (Windows)
  uninstall.sh                 # Uninstaller (macOS/Linux)
  uninstall.ps1                # Uninstaller (Windows)
  LICENSE                      # MIT License
  README.md                    # This file
```

## Contributing

Found a gap? Open an issue or PR. Common contributions:

- Additional patterns for specific frameworks (Vue, Svelte, Angular)
- Edge cases we missed in existing agents
- Framework-specific gotchas (Next.js app router focus management, etc.)
- Improvements to agent instructions that reduce false positives
- New specialist agents for uncovered accessibility domains

## License

MIT

## About Techopolis

[Techopolis](https://techopolis.online) builds accessible apps for Apple platforms. Our team includes people who use assistive technology daily. We build these tools because accessibility is how we work, not something we bolt on at the end. When we found that AI coding tools consistently failed at accessibility, we built the team we wished existed.
