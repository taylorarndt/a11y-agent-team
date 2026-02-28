# Getting Started

This guide covers installation and setup for all four platforms: Claude Code, GitHub Copilot, Claude Desktop, and Codex CLI.

---

## Claude Code Setup

This is for the **Claude Code CLI** (the terminal tool). If you want the Claude Desktop app extension, skip to [Claude Desktop Setup](#claude-desktop-setup) below.

### How It Works

The accessibility agents are installed as Claude Code agents with a three-hook enforcement gate. You do not need to invoke them manually. The hooks automatically detect web projects and block UI file edits until accessibility-lead has been consulted.

The enforcement flow:

1. **Proactive detection** — A `UserPromptSubmit` hook checks your project directory for web framework indicators (`package.json` with React/Next/Vue, config files, `.tsx`/`.jsx` files). In a web project, the delegation instruction fires on every prompt — even "fix the bug."
2. **Edit gate** — A `PreToolUse` hook blocks any Edit/Write to UI files (`.jsx`, `.tsx`, `.vue`, `.css`, `.html`, etc.) until the accessibility-lead agent has completed a review. The tool call is denied at the system level using `permissionDecision: "deny"`.
3. **Session marker** — A `PostToolUse` hook creates a session marker when accessibility-lead completes. This unlocks the edit gate for the rest of the session.

The team includes twenty-five agents: nine web code specialists that write and review code, six document accessibility specialists that scan Office and PDF files, one document accessibility wizard that runs guided document audits (with two hidden helper sub-agents for parallel scanning), one markdown documentation accessibility orchestrator (markdown-a11y-assistant) that audits .md files across nine accessibility domains (with two hidden helper sub-agents for parallel scanning and fix application), one orchestrator that coordinates them, one interactive wizard that runs guided web audits (with two hidden helper sub-agents for page crawling and parallel scanning), one testing coach that teaches you how to verify accessibility, and one WCAG guide that explains the standards themselves. Three reusable agent skills provide domain knowledge.

For tasks that do not involve UI code (backend logic, scripts, database work), the hooks stay silent and the agents are not invoked.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and working
- A Claude Code subscription (Pro, Max, or Team)
- **macOS/Linux:** bash shell (pre-installed)
- **Windows:** PowerShell 5.1+ (pre-installed on Windows 10/11)

### Installation

#### One-Liner (Recommended)

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.ps1 | iex
```

The installer downloads the repo, copies agents, installs the three enforcement hooks to `~/.claude/hooks/`, registers them in `~/.claude/settings.json`, and optionally sets up daily auto-updates and GitHub Copilot agents. It will prompt you to choose project-level or global install.

**Non-interactive one-liners:**

```bash
# macOS/Linux - install globally, no prompts
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash -s -- --global

# macOS/Linux - install to current project, no prompts
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash -s -- --project

# macOS/Linux - install globally with Copilot agents
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash -s -- --global --copilot
```

#### From Cloned Repo

If you prefer to clone first:

**macOS / Linux:**

```bash
git clone https://github.com/Community-Access/accessibility-agents.git
cd a11y-agent-team
bash install.sh
```

Pass flags to skip prompts: `--global`, `--project`, `--copilot`, `--codex`.

**Windows (PowerShell):**

```powershell
git clone https://github.com/Community-Access/accessibility-agents.git
cd a11y-agent-team
powershell -ExecutionPolicy Bypass -File install.ps1
```

The `--copilot` flag installs the accessibility agents for GitHub Copilot Chat. For **global** installs, this copies `.agent.md` files directly into your VS Code user profile so the agents appear in the Copilot Chat agent picker across all workspaces. For **project** installs, it copies them into the project's `.github/agents/` directory.

To remove:

```bash
bash uninstall.sh
bash uninstall.sh --global    # Non-interactive global uninstall
bash uninstall.sh --project   # Non-interactive project uninstall
```

```powershell
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

#### Manual Setup

If you prefer to install manually or need to integrate into an existing configuration:

##### 1. Copy agents

```bash
# For project install
mkdir -p .claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md .claude/agents/

# For global install
mkdir -p ~/.claude/agents
cp -r path/to/a11y-agent-team/.claude/agents/*.md ~/.claude/agents/
```

##### 2. Copy enforcement hooks (global install only)

```bash
mkdir -p ~/.claude/hooks
cp path/to/accessibility-agents/claude-code-plugin/scripts/a11y-team-eval.sh ~/.claude/hooks/
cp path/to/accessibility-agents/claude-code-plugin/scripts/a11y-enforce-edit.sh ~/.claude/hooks/
cp path/to/accessibility-agents/claude-code-plugin/scripts/a11y-mark-reviewed.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/a11y-*.sh
```

Then register the hooks in `~/.claude/settings.json` (see the [Hooks Guide](hooks-guide.md) for the full JSON).

##### 3. Verify

Start Claude Code and type `/agents`. You should see all agents listed. Then verify enforcement:

1. Open a web project (anything with `package.json` containing React/Next/Vue/etc.)
2. Type any prompt — you should see `DETECTED: This is a web project` in the system reminder
3. If Claude tries to edit a `.tsx` file without consulting accessibility-lead, it should be blocked with `BLOCKED: Cannot edit UI file...`

### Using the Agents in Claude Code

Invoke any agent by name using the slash command or `@` mention:

```text
/accessibility-lead full audit of the checkout flow
/aria-specialist review the ARIA in components/modal.tsx
/contrast-master check all color combinations in globals.css
/keyboard-navigator audit tab order on the settings page
/web-accessibility-wizard run a full guided accessibility audit
/document-accessibility-wizard audit all documents in the docs/ folder
/testing-coach how do I test this modal with NVDA?
/wcag-guide explain WCAG 1.4.11 non-text contrast
```

To see all installed agents at any time, type `/agents` in Claude Code.

### Global vs Project Install

**Project-level** (recommended for teams): Install to `.claude/` in each web project. Check into version control so your whole team benefits. The agents travel with the repo.

**Global** (recommended for individuals): Install to `~/.claude/` to have the team available across all your projects automatically. Nothing to configure per-project. One install covers everything.

You can use both. Project-level agents override global agents with the same name, so you could customize an agent for a specific project while keeping the defaults globally.

### Auto-Updates (Claude Code)

During global installation, the installer asks if you want to enable auto-updates. When enabled, a daily scheduled job checks GitHub for new agent versions and installs them automatically.

- **macOS:** Uses a LaunchAgent (`~/Library/LaunchAgents/com.community-access.accessibility-agents-update.plist`), runs daily at 9:00 AM
- **Linux:** Uses a cron job, runs daily at 9:00 AM
- **Windows:** Uses Task Scheduler (`A11yAgentTeamUpdate`), runs daily at 9:00 AM

Auto-updates keep both Claude Code agents (`~/.claude/agents/`) and Copilot agents in your VS Code user profile folder in sync.

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

This is for **GitHub Copilot Chat** in VS Code (or other editors that support the `.github/agents/` format).

### How It Works

GitHub Copilot supports custom agents via `.github/agents/*.agent.md` files and workspace-level instructions via `.github/copilot-instructions.md`. The A11y Agent Team provides:

- **Twenty-five specialist agents** that you can invoke by name in Copilot Chat
- **Workspace instructions** that remind Copilot to consider accessibility on every UI task
- **PR review instructions** (`.github/copilot-review-instructions.md`) that enforce accessibility standards during Copilot Code Review on pull requests
- **Commit message instructions** (`.github/copilot-commit-message-instructions.md`) that guide Copilot to include accessibility context in commit messages
- **PR template** (`.github/PULL_REQUEST_TEMPLATE.md`) with an accessibility checklist for every pull request
- **CI workflow** (`.github/workflows/a11y-check.yml`) that runs automated accessibility checks on PRs
- **VS Code configuration** (`.vscode/`) with recommended extensions, settings, tasks, and MCP server config

The workspace instructions in `.github/copilot-instructions.md` are automatically loaded into every Copilot Chat conversation, ensuring accessibility guidance is always present.

### Prerequisites

- [GitHub Copilot](https://github.com/features/copilot) subscription (Individual, Business, or Enterprise)
- VS Code with the GitHub Copilot extension installed
- Agent mode and custom agents enabled in VS Code settings

### Installation

#### Option 1: Global (via the installer)

The easiest way to get Copilot agents in every workspace.

```bash
git clone https://github.com/Community-Access/accessibility-agents.git
cd a11y-agent-team
bash install.sh --global --copilot
```

This installs Copilot agents to your VS Code user profile folder. After installing, reload VS Code and open Copilot Chat. The agents will appear in the agent picker dropdown across all workspaces.

> **First use:** After installation, open the agent picker dropdown (the model/agent selector at the top of the Copilot Chat panel) and select the agent you want to use. Custom agents do not appear in `@` autocomplete until you have selected them from the picker at least once.

#### Option 2: Per-project

Copy the `.github` directory into your project so the agents travel with the repo.

```bash
git clone https://github.com/Community-Access/accessibility-agents.git
cd a11y-agent-team
cp -r .github /path/to/your/project/
```

Or use the installer with the project flag:

```bash
cd /path/to/your/project
bash /path/to/a11y-agent-team/install.sh --project --copilot
```

#### Option 3: Per-project (via a11y-copilot-init)

If you installed globally with `--copilot`, run `a11y-copilot-init` inside any project to copy the agents:

```bash
cd /path/to/your/project
a11y-copilot-init
```

### Using the Agents in Copilot Chat

> **Important:** Custom agents must first be selected from the **agent picker dropdown** at the top of the Copilot Chat panel. They will not appear when typing `@` in the chat input until you have selected them from the picker at least once. This is standard VS Code behavior for custom agents, not specific to this project.

Once an agent has been picked, you can mention it by name to invoke it:

```text
@accessibility-lead full audit of the checkout flow
@aria-specialist review the ARIA in components/modal.tsx
@contrast-master check all color combinations in globals.css
@web-accessibility-wizard run a full guided accessibility audit of this project
@document-accessibility-wizard scan all documents in the docs/ folder
@testing-coach how should I test this component with VoiceOver?
@wcag-guide what changed between WCAG 2.1 and 2.2?
```

The workspace instructions in `.github/copilot-instructions.md` are loaded into every Copilot Chat conversation. When you ask Copilot to build or modify UI code, it will automatically consider accessibility requirements.

### Differences from Claude Code

| Feature | Claude Code | GitHub Copilot |
|---------|-------------|----------------|
| Agent location | `.claude/agents/` | `.github/agents/` |
| Activation | `.github/copilot-instructions.md` | `.github/copilot-instructions.md` |
| PR review | N/A | `.github/copilot-review-instructions.md` |
| Commit messages | N/A | `.github/copilot-commit-message-instructions.md` |
| PR template | N/A | `.github/PULL_REQUEST_TEMPLATE.md` |
| CI workflow | N/A | `.github/workflows/a11y-check.yml` |
| VS Code config | N/A | `.vscode/` (extensions, settings, tasks, MCP) |
| Invocation | `/agent-name` or `@agent-name` | `@agent-name` |
| Auto-activation | Invoke agents directly | Workspace instructions provide guidance |
| Global install | `~/.claude/agents/` | VS Code user profile folder or per-project |

---

## Claude Desktop Setup

This is for the **Claude Desktop app** (the standalone application).

### What is the .mcpb Extension?

The `.mcpb` file (MCP Bundle) is Claude Desktop's extension format. It is a packaged bundle that adds tools and prompts directly into the Claude Desktop interface. You download one file, double-click it, and Claude Desktop installs it.

The A11y Agent Team extension adds:

**Tools** (Claude can call these automatically while working):

- **check_contrast**: Calculate WCAG contrast ratios between two hex colors
- **get_accessibility_guidelines**: Get detailed WCAG AA guidelines for specific component types
- **check_heading_structure**: Analyze HTML for heading hierarchy issues
- **check_link_text**: Scan HTML for ambiguous link text
- **check_form_labels**: Validate form inputs have proper label associations
- **generate_vpat**: Generate a VPAT 2.5 / Accessibility Conformance Report template
- **run_axe_scan**: Run axe-core against a live URL and return violations
- **scan_office_document**: Scan DOCX, XLSX, PPTX files for accessibility issues
- **scan_pdf_document**: Scan PDFs for PDF/UA conformance
- **extract_document_metadata**: Extract document properties and metadata
- **batch_scan_documents**: Scan multiple documents in one operation

**Prompts** (you select these from the prompt menu):

- **Full Accessibility Audit**: Comprehensive WCAG 2.1 AA review
- **ARIA Review**: Focused review of ARIA roles, states, and properties
- **Modal/Dialog Review**: Focus trapping, focus return, escape behavior
- **Color Contrast Review**: Color choices checked against AA requirements
- **Keyboard Navigation Review**: Tab order, focus management, skip links
- **Live Region Review**: Dynamic content announcements and screen reader compatibility

### How to Install

1. Go to the [Releases page](https://github.com/Community-Access/accessibility-agents/releases)
2. Download the latest `a11y-agent-team.mcpb` file
3. Double-click the file (or drag it into Claude Desktop)
4. Claude Desktop will open an install dialog. Click Install
5. Done. The tools and prompts are now available in every conversation

### How to Use in Claude Desktop

**Tools activate automatically.** When you ask Claude to review code or build a component, it can call `check_contrast` and `get_accessibility_guidelines` on its own.

**Prompts are available from the prompt menu.** Click the prompt picker (or type `/`) and you will see the six review prompts listed.

### Building from Source

```bash
npm install -g @anthropic-ai/mcpb
git clone https://github.com/Community-Access/accessibility-agents.git
cd a11y-agent-team/desktop-extension
npm install
mcpb validate .
mcpb pack . ../a11y-agent-team.mcpb
```

The output file can be double-clicked to install in Claude Desktop.

---

## Codex CLI Setup

This is for **OpenAI Codex CLI** (the terminal coding agent).

### How It Works

Codex CLI reads `AGENTS.md` files from the project directory tree automatically. The accessibility rules are loaded into every session — no extra flags or configuration needed. When Codex works on any UI task, it applies the WCAG 2.2 AA rules from the AGENTS.md file before considering the work done.

Unlike Claude Code, Codex does not have a sub-agent concept. All accessibility rules are condensed into a single document that covers all nine domains: ARIA, keyboard navigation, modals, forms, color contrast, live regions, headings and landmarks, images, and tables.

### Prerequisites

- [Codex CLI](https://github.com/openai/codex) installed and working
- An OpenAI API key configured

### Installation

#### Via the Installer (Recommended)

```bash
# Project install with Codex support
bash install.sh --project --codex

# Global install with Codex support
bash install.sh --global --codex
```

The interactive installer also prompts for Codex support if you do not pass the flag.

#### One-Liner

```bash
# Install globally with Codex support
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.sh | bash -s -- --global --codex
```

#### Manual Setup

```bash
# For project install
mkdir -p .codex
cp path/to/accessibility-agents/.codex/AGENTS.md .codex/AGENTS.md

# For global install
mkdir -p ~/.codex
cp path/to/accessibility-agents/.codex/AGENTS.md ~/.codex/AGENTS.md
```

For project installs, commit `.codex/AGENTS.md` to your repo so the rules travel with the project.

### Using Codex with Accessibility Rules

Once installed, the rules apply automatically. Just use Codex normally:

```bash
codex "Build a login form"
codex "Add a modal dialog to the settings page"
codex "Create a data table for the analytics dashboard"
```

Codex will apply the accessibility rules from AGENTS.md to all UI code it generates. A pre-commit checklist at the end of the rules file ensures nothing gets missed.

### Removing

```bash
bash uninstall.sh          # Interactive — detects and removes Codex support
bash uninstall.sh --project  # Non-interactive project uninstall
bash uninstall.sh --global   # Non-interactive global uninstall
```
