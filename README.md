# A11y Agent Team

**Accessibility review tools for Claude Code and Claude Desktop.**

Built by [Taylor Arndt](https://github.com/taylorarndt) because LLMs consistently forget accessibility. Skills get ignored. Instructions drift out of context. ARIA gets misused. Focus management gets skipped. Color contrast fails silently. I got tired of fighting it, so I built a team of agents that will not let it slide.

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely. Studies show that skill auto-activation in Claude Code fails roughly 80% of the time without intervention.

## The Solution

A11y Agent Team works in two ways:

- **Claude Code** (terminal): Six specialized agents plus a hook that forces evaluation on every prompt. Each agent has a single focused job it cannot ignore. The Accessibility Lead orchestrator coordinates the team and ensures the right specialists are invoked for every task.
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

---

## Claude Code Setup

This is for the **Claude Code CLI** (the terminal tool). If you want the Claude Desktop app extension, skip to [Claude Desktop Setup](#claude-desktop-setup) below.

### How It Works

A `UserPromptSubmit` hook fires on every prompt you send to Claude Code. If the task involves web UI code, the hook instructs Claude to delegate to the **accessibility-lead** first. The lead evaluates the task and invokes the relevant specialists. The specialists apply their focused expertise and report findings. Code does not proceed without passing review.

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

Start Claude Code and type `/agents`. You should see all six agents listed:

```
/agents
  accessibility-lead
  aria-specialist
  modal-specialist
  contrast-master
  keyboard-navigator
  live-region-controller
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
```

Or use the `@` mention syntax:

```
@accessibility-lead review this component
@aria-specialist check the ARIA on this dropdown
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
