# A11y Agent Team

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/taylorarndt/a11y-agent-team?include_prereleases)](https://github.com/taylorarndt/a11y-agent-team/releases)
[![GitHub stars](https://img.shields.io/github/stars/taylorarndt/a11y-agent-team)](https://github.com/taylorarndt/a11y-agent-team/stargazers)
[![GitHub contributors](https://img.shields.io/github/contributors/taylorarndt/a11y-agent-team)](https://github.com/taylorarndt/a11y-agent-team/graphs/contributors)
[![WCAG 2.2 AA](https://img.shields.io/badge/WCAG-2.2_AA-green.svg)](https://www.w3.org/TR/WCAG22/)

**Accessibility review agents for Claude Code, GitHub Copilot, and Claude Desktop.**

Built by [Taylor Arndt](https://github.com/taylorarndt) because LLMs consistently forget accessibility. Skills get ignored. Instructions drift out of context. ARIA gets misused. Focus management gets skipped. Color contrast fails silently. I got tired of fighting it, so I built a team of agents that will not let it slide.

---

## Table of Contents

- [The Problem](#the-problem)
- [The Solution](#the-solution)
- [The Team](#the-team)
- [Claude Code Setup](#claude-code-setup)
  - [How It Works](#how-it-works)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Using the Agents in Claude Code](#using-the-agents-in-claude-code)
  - [Global vs Project Install](#global-vs-project-install)
  - [Auto-Updates](#auto-updates-claude-code)
- [GitHub Copilot Setup](#github-copilot-setup)
  - [How It Works](#how-it-works-1)
  - [Prerequisites](#prerequisites-1)
  - [Installation](#installation-1)
  - [Using the Agents in Copilot Chat](#using-the-agents-in-copilot-chat)
  - [Differences from Claude Code](#differences-from-claude-code)
- [Claude Desktop Setup](#claude-desktop-setup)
  - [What is the .mcpb Extension?](#what-is-the-mcpb-extension)
  - [How to Install](#how-to-install)
  - [How to Use in Claude Desktop](#how-to-use-in-claude-desktop)
  - [Building from Source](#building-from-source)
- [Agent Reference Guide](#agent-reference-guide)
  - [How Agents Work — The Mental Model](#how-agents-work--the-mental-model)
  - [Invocation Syntax](#invocation-syntax)
  - [Agent Deep Dives](#agent-deep-dives)
    - [accessibility-lead](#accessibility-lead--the-orchestrator)
    - [aria-specialist](#aria-specialist--aria-roles-states-and-properties)
    - [modal-specialist](#modal-specialist--dialogs-drawers-and-overlays)
    - [contrast-master](#contrast-master--color-contrast-and-visual-accessibility)
    - [keyboard-navigator](#keyboard-navigator--tab-order-and-focus-management)
    - [live-region-controller](#live-region-controller--dynamic-content-announcements)
    - [forms-specialist](#forms-specialist--forms-labels-validation-and-errors)
    - [alt-text-headings](#alt-text-headings--alt-text-svgs-headings-and-landmarks)
    - [tables-data-specialist](#tables-data-specialist--data-tables-grids-and-sortable-columns)
    - [link-checker](#link-checker--ambiguous-link-text-detection)
    - [accessibility-wizard](#accessibility-wizard--guided-accessibility-audit)
    - [testing-coach](#testing-coach--how-to-test-accessibility)
    - [wcag-guide](#wcag-guide--understanding-the-standard)
    - [word-accessibility](#word-accessibility--microsoft-word-docx-accessibility)
    - [excel-accessibility](#excel-accessibility--microsoft-excel-xlsx-accessibility)
    - [powerpoint-accessibility](#powerpoint-accessibility--microsoft-powerpoint-pptx-accessibility)
    - [office-scan-config](#office-scan-config--office-scan-configuration)
    - [pdf-accessibility](#pdf-accessibility--pdf-document-accessibility)
    - [pdf-scan-config](#pdf-scan-config--pdf-scan-configuration)
  - [Tips for Getting the Best Results](#tips-for-getting-the-best-results)
- [Integrating axe-core into the Agent Workflow](#integrating-axe-core-into-the-agent-workflow)
  - [Automated Scanning During Agent Reviews](#automated-scanning-during-agent-reviews)
  - [CI/CD Pipeline Integration](#cicd-pipeline-integration)
  - [Framework-Specific Setup](#framework-specific-setup)
  - [Agent + axe-core Workflow](#agent--axe-core-workflow)
- [Static Analysis MCP Tools](#static-analysis-mcp-tools)
- [VPAT / ACR Template Generation](#vpat--acr-template-generation)
- [Document Accessibility Scanning](#document-accessibility-scanning)
  - [Office Document Scanning](#office-document-scanning)
  - [PDF Document Scanning](#pdf-document-scanning)
  - [Document Scanning Agents](#document-scanning-agents)
  - [CI/CD Integration for Documents](#cicd-integration-for-documents)
  - [Scan Configuration](#scan-configuration)
- [Example Project](#example-project)
- [Configuration](#configuration)
- [What This Covers](#what-this-covers)
- [What This Does Not Cover](#what-this-does-not-cover)
- [Why Agents Instead of Skills or MCP](#why-agents-instead-of-skills-or-mcp)
- [Future Agents](#future-agents)
- [Troubleshooting](#troubleshooting)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)
- [About the Author](#about-the-author)

---

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely. Studies show that skill auto-activation in Claude Code fails roughly 80% of the time without intervention.

## The Solution

A11y Agent Team works in three ways:

- **Claude Code** (terminal): Nineteen specialized agents plus a hook that forces evaluation on every prompt. Each agent has a single focused job it cannot ignore. The Accessibility Lead orchestrator coordinates the team and ensures the right specialists are invoked for every task.
- **GitHub Copilot** (VS Code): The same nineteen agents converted to Copilot's custom agent format, plus workspace-level instructions, PR review instructions, commit message guidance, a PR template with an accessibility checklist, a CI workflow, VS Code tasks, recommended extensions, and MCP server configuration. Works with GitHub Copilot Chat in VS Code and other editors that support the `.github/agents/` format.
- **Claude Desktop** (app): An MCP extension (.mcpb) that adds accessibility tools and review prompts directly into the Claude Desktop interface. Check contrast ratios, get component guidelines, scan Office documents and PDFs for accessibility, and run specialist reviews without leaving the app.

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
| **link-checker** | Ambiguous link text detection. Catches "click here", "read more", "learn more", repeated identical links, missing new-tab warnings, and links to non-HTML resources without file type indication. |
| **accessibility-wizard** | Interactive guided audit. Walks you through a multi-phase accessibility review using all specialists, asks questions at each step, and produces a prioritized action plan. Best for first-time audits. |
| **testing-coach** | Screen reader testing (NVDA, VoiceOver, JAWS), keyboard testing, automated testing (axe-core, Playwright, Pa11y), test plans. Does not write product code — teaches you how to test. |
| **wcag-guide** | WCAG 2.2 success criteria in plain language, conformance levels, what changed between versions, when criteria apply. Does not write or review code — teaches the standard itself. |
| **word-accessibility** | Microsoft Word (DOCX) document accessibility. Checks alt text, heading structure, table markup, reading order, language settings, and color-only formatting. |
| **excel-accessibility** | Microsoft Excel (XLSX) spreadsheet accessibility. Checks sheet names, table structure, merged cells, chart alt text, input messages, and named ranges. |
| **powerpoint-accessibility** | Microsoft PowerPoint (PPTX) presentation accessibility. Checks slide titles, reading order, alt text, table structure, audio/video descriptions, and speaker notes. |
| **office-scan-config** | Configuration manager for Office document accessibility scans. Manages rule enabling/disabling, severity filters, and preset profiles. |
| **pdf-accessibility** | PDF document accessibility per PDF/UA and the Matterhorn Protocol. Checks tagged structure, metadata, bookmarks, form fields, figure alt text, table structure, and fonts. |
| **pdf-scan-config** | Configuration manager for PDF accessibility scans. Manages rule enabling/disabling, severity filters, file size limits, and preset profiles. |

---

## Claude Code Setup

This is for the **Claude Code CLI** (the terminal tool). If you want the Claude Desktop app extension, skip to [Claude Desktop Setup](#claude-desktop-setup) below.

### How It Works

A `UserPromptSubmit` hook fires on every prompt you send to Claude Code. If the task involves web UI code, the hook instructs Claude to delegate to the **accessibility-lead** first. The lead evaluates the task and invokes the relevant specialists. The specialists apply their focused expertise and report findings. Code does not proceed without passing review.

The team includes nineteen agents: nine web code specialists that write and review code, six document accessibility specialists that scan Office and PDF files, one orchestrator that coordinates them, one interactive wizard that runs guided audits, one testing coach that teaches you how to verify accessibility, and one WCAG guide that explains the standards themselves.

For tasks that don't involve UI code (backend logic, scripts, database work), the hook is ignored and Claude proceeds normally.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and working
- A Claude Code subscription (Pro, Max, or Team)
- **macOS/Linux:** bash shell (pre-installed)
- **Windows:** PowerShell 5.1+ (pre-installed on Windows 10/11)

### Installation

#### One-Liner (Recommended)

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.ps1 | iex
```

The installer downloads the repo, copies agents and hooks, configures `settings.json`, and optionally sets up daily auto-updates and GitHub Copilot agents. It will prompt you to choose project-level or global install.

**Non-interactive one-liners:**

```bash
# macOS/Linux — install globally, no prompts
curl -fsSL https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.sh | bash -s -- --global

# macOS/Linux — install to current project, no prompts
curl -fsSL https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.sh | bash -s -- --project

# macOS/Linux — install globally with Copilot agents
curl -fsSL https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.sh | bash -s -- --global --copilot
```

#### From Cloned Repo

If you prefer to clone first:

**macOS / Linux:**

```bash
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team
bash install.sh
```

Pass flags to skip prompts: `--global`, `--project`, `--copilot`.

**Windows (PowerShell):**

```powershell
git clone https://github.com/taylorarndt/a11y-agent-team.git
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

Start Claude Code and type `/agents`. You should see all thirteen agents listed:

```
/agents
  accessibility-lead
  accessibility-wizard
  alt-text-headings
  aria-specialist
  contrast-master
  excel-accessibility
  forms-specialist
  keyboard-navigator
  link-checker
  live-region-controller
  modal-specialist
  office-scan-config
  pdf-accessibility
  pdf-scan-config
  powerpoint-accessibility
  tables-data-specialist
  testing-coach
  wcag-guide
  word-accessibility
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
/link-checker scan for ambiguous link text on the homepage
/accessibility-wizard run a full guided accessibility audit
/testing-coach how do I test this modal with NVDA?
/wcag-guide explain WCAG 1.4.11 non-text contrast
/word-accessibility scan report.docx for accessibility issues
/excel-accessibility check the budget spreadsheet
/powerpoint-accessibility scan the quarterly deck
/pdf-accessibility scan contract.pdf for PDF/UA conformance
```

Or use the `@` mention syntax:

```
@accessibility-lead review this component
@aria-specialist check the ARIA on this dropdown
@forms-specialist review form validation in this file
@alt-text-headings check alt text on all images in this page
@tables-data-specialist check table markup in the dashboard
@link-checker find all ambiguous links in this file
@accessibility-wizard start a guided audit of this project
@testing-coach what screen reader testing should I do for this?
@wcag-guide what does WCAG 2.5.8 target size require?
@word-accessibility check this Word document for accessibility
@pdf-accessibility scan this PDF for tagged structure and metadata
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

Auto-updates keep both Claude Code agents (`~/.claude/agents/`) and Copilot agents in your VS Code user profile folder in sync. If you installed Copilot agents globally, the update process detects the `.agent.md` files in your VS Code profile and refreshes them automatically.

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

GitHub Copilot supports custom agents via `.github/agents/*.agent.md` files and workspace-level instructions via `.github/copilot-instructions.md`. The A11y Agent Team provides:

- **Nineteen specialist agents** that you can invoke by name in Copilot Chat
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

#### Option 1: Global (via the installer)

The easiest way to get Copilot agents in every workspace. The installer copies `.agent.md` files directly into your VS Code user profile folder. No per-project setup needed.

```bash
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team

# Install Claude Code agents globally AND Copilot agents globally
bash install.sh --global --copilot
```

This installs Copilot agents to:
- **macOS:** `~/Library/Application Support/Code/User/prompts/` and `~/Library/Application Support/Code - Insiders/User/prompts/`
- **Linux:** `~/.config/Code/User/prompts/` and `~/.config/Code - Insiders/User/prompts/`
- **Windows:** `%APPDATA%\Code\User\prompts\` and `%APPDATA%\Code - Insiders\User\prompts\`

After installing, reload VS Code (Cmd+Shift+P > "Developer: Reload Window") and open Copilot Chat. The agents will appear in the agent picker dropdown across all workspaces.

Auto-updates will also keep the VS Code profile agents in sync when new versions are available.

#### Option 2: Per-project

Copy the `.github` directory into your project so the agents travel with the repo.

```bash
git clone https://github.com/taylorarndt/a11y-agent-team.git
cd a11y-agent-team

# Copy into your project
cp -r .github /path/to/your/project/
```

Or use the installer with the project flag:

```bash
cd /path/to/your/project
bash /path/to/a11y-agent-team/install.sh --project --copilot
```

#### Option 3: Per-project (via a11y-copilot-init)

If you installed globally with `--copilot`, you also get the `a11y-copilot-init` command. Run it inside any project to copy the agents into that project's `.github/agents/` for version control:

```bash
cd /path/to/your/project
a11y-copilot-init
```

#### Manual setup

If you prefer to copy files manually:

**1. Copy agents**

```bash
mkdir -p .github/agents
cp path/to/a11y-agent-team/.github/agents/*.agent.md .github/agents/
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
@link-checker find ambiguous link text on the homepage
@accessibility-wizard run a full guided accessibility audit of this project
@testing-coach how should I test this component with VoiceOver?
@wcag-guide what changed between WCAG 2.1 and 2.2?
@word-accessibility scan this Word document for accessibility
@pdf-accessibility check this PDF for PDF/UA conformance
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
| Global install | `~/.claude/agents/` | VS Code user profile folder or per-project |

---

## Agent Reference Guide

This section is the comprehensive reference for every agent in the team. It covers what each agent does, when to use it, exactly how to invoke it in both Claude Code and GitHub Copilot, example prompts that demonstrate best practices, what each agent will and will not catch, and the constraints that shape how each agent behaves. Treat this as your instructor in a pocket — everything you need to get the most out of each specialist, whether you have used accessibility tools before or this is your first time.

### How Agents Work — The Mental Model

Think of the A11y Agent Team as a consulting team of accessibility specialists. You do not need to know which specialist to call — that is the lead's job. But you *can* call any specialist directly when you already know what you need.

**The accessibility-lead** is your single point of contact. Tell it what you are building or reviewing, and it will figure out which specialists are needed, invoke them, and compile the findings. If you only remember one agent name, remember this one.

**The nine code specialists** (aria-specialist, modal-specialist, contrast-master, keyboard-navigator, live-region-controller, forms-specialist, alt-text-headings, tables-data-specialist, link-checker) each own one domain of web accessibility. They write code, review code, and report issues within their area. They do not overlap — each has a clear boundary.

**The six document specialists** (word-accessibility, excel-accessibility, powerpoint-accessibility, office-scan-config, pdf-accessibility, pdf-scan-config) scan Office and PDF documents for accessibility issues. They use the `scan_office_document` and `scan_pdf_document` MCP tools to perform structural analysis of document files without requiring external dependencies.

**The accessibility-wizard** runs interactive guided audits. It walks you through your entire project phase by phase, asks questions to understand your context, invokes the right specialists at each step, and produces a prioritized action plan. Use it for first-time audits or comprehensive reviews.

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

**What it does:** Verifies color contrast ratios, checks dark mode, ensures focus indicators are visible, validates that no information is conveyed by color alone, and provides comprehensive guidance on user preference media queries (`prefers-reduced-motion`, `prefers-contrast`, `prefers-color-scheme`, `forced-colors`, `prefers-reduced-transparency`). Includes a contrast calculation script for programmatic verification.

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

**prefers-* media query coverage:**
- `prefers-reduced-motion` — disabling animations, handling JS-driven motion, framework patterns
- `prefers-contrast: more` — upgrading subtle colors, removing transparency, increasing borders
- `prefers-color-scheme` — dark mode with proper contrast re-verification
- `forced-colors` — Windows Contrast Themes, system color keywords, SVG handling
- `prefers-reduced-transparency` — solid fallbacks for frosted glass and overlays
- Combined preferences (e.g., dark + high contrast) and JavaScript detection

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

#### link-checker — Ambiguous Link Text Detection

**What it does:** Scans your code for link text that would confuse a screen reader user. Screen reader users often navigate by pulling up a list of all links on the page — when every link says "click here" or "read more," that list is useless. This agent finds those patterns and rewrites them so every link makes sense out of context.

**When to use it:**
- You have pages with repeated "Learn more," "Click here," or "Read more" links
- You want to verify all links pass WCAG 2.4.4 (Link Purpose in Context)
- You are building navigation, footers, or content pages with many links
- You want to audit existing link text across an entire codebase
- A screen reader user or QA tester reported that links are confusing

**What it catches:**
| Pattern | Example | Why It Fails |
|---------|---------|-------------|
| Generic exact match | `<a href="/pricing">Click here</a>` | No purpose in link list |
| Generic prefix | `<a href="/docs">Read more about setup</a>` | Starts with filler |
| Repeated identical text | Three links all saying "Learn more" | Indistinguishable in link list |
| URL as link text | `<a href="https://example.com">https://example.com</a>` | Screen reader reads every character |
| Adjacent duplicate links | Image + text link to same URL | Announced twice, confusing |
| Missing new-window warning | `<a href="/file.pdf" target="_blank">Report</a>` | No indication behavior changes |
| Non-HTML resource | `<a href="/file.xlsx">Download</a>` | User does not know the file type or size |

**Example prompts — Claude Code:**
```
/link-checker scan this page for ambiguous link text
/link-checker review the footer component for link accessibility
/link-checker audit all links in the marketing pages directory
/link-checker fix the "read more" links in this blog listing
```

**Example prompts — Copilot:**
```
@link-checker review the navigation links in this component
@link-checker find all ambiguous link text in the project
@link-checker fix the "click here" links in this file
@link-checker audit links across the entire src/ directory
```

**Behavioral constraints:**
- Never suggests `aria-label` as a first fix — always rewrites the visible text first
- Does not flag links with 4+ descriptive words (e.g., "View quarterly earnings report" is fine)
- Catches bare URLs as link text — requires human-readable text instead
- Flags adjacent image + text links to the same destination as requiring combination into a single `<a>`
- Adds `(opens in new tab)` visually and via `aria-label` for `target="_blank"` links
- Adds file type and size for non-HTML resources (e.g., "Annual report (PDF, 2.4 MB)")

---

#### accessibility-wizard — Guided Accessibility Audit

**What it does:** Runs a full, interactive accessibility audit of your project by coordinating all specialist agents in sequence. Instead of dumping a wall of issues at you, it walks you through eleven phases — one accessibility domain at a time — and asks you questions at each step to focus the review on what matters for your specific project.

**When to use it:**
- You want a comprehensive audit but don't know where to start
- You are new to accessibility and want guided, educational reviews
- You need to prepare for a third-party accessibility assessment
- You want a structured VPAT or conformance report
- You are onboarding a team and want to show them the full scope of accessibility
- A feature is shipping and you want a final pre-launch review

**The eleven phases:**

| Phase | Domain | Specialist Used |
|-------|--------|----------------|
| 1 | Project discovery and scope | — |
| 2 | Document structure and semantics | alt-text-headings |
| 3 | Keyboard navigation and focus | keyboard-navigator |
| 4 | Forms and input accessibility | forms-specialist |
| 5 | Color and visual accessibility | contrast-master |
| 6 | Dynamic content and live regions | live-region-controller |
| 7 | ARIA usage review | aria-specialist |
| 8 | Data tables and grids | tables-data-specialist |
| 9 | Link text and navigation | link-checker |
| 10 | Document accessibility (optional) | word/excel/powerpoint/pdf-accessibility |
| 11 | Testing strategy and tools | testing-coach |

At the end, it generates a prioritized report with issues grouped by severity (Critical > Serious > Moderate > Minor), WCAG criterion references, and a suggested fix order.

**Example prompts — Claude Code:**
```
/accessibility-wizard run a full audit on this project
/accessibility-wizard audit the checkout flow
/accessibility-wizard I need to prepare for a VPAT assessment
/accessibility-wizard walk me through accessibility for the dashboard
```

**Example prompts — Copilot:**
```
@accessibility-wizard audit this project for accessibility
@accessibility-wizard guide me through a review of the signup flow
@accessibility-wizard run a full accessibility audit
@accessibility-wizard I'm new to accessibility — walk me through everything
```

**Behavioral constraints:**
- Always asks the user before moving to the next phase — never skips ahead silently
- Presents findings from each phase before proceeding, so the user can fix issues iteratively
- Generates a final report only after all phases complete (or the user chooses to stop early)
- Does not write code itself — delegates to the appropriate specialist agent and reports what it found
- Groups issues by WCAG conformance level and severity, not by file or line number

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

#### word-accessibility — Microsoft Word (DOCX) Accessibility

**What it does:** Scans Microsoft Word documents for accessibility issues. Uses the `scan_office_document` MCP tool to parse DOCX files (ZIP/XML structure) and check for tagged content, alt text on images, heading structure, table markup, reading order, language settings, and color-only formatting.

**When to use it:**
- Reviewing Word documents before publishing or distributing
- Checking templates for accessibility compliance
- Auditing existing DOCX files as part of a document accessibility program
- Preparing documents for PDF conversion (accessibility issues carry over)

**What it catches:**
- Images without alt text (DOCX-E001)
- Missing document title in properties (DOCX-E002)
- No headings used for document structure (DOCX-E003)
- Tables without header rows (DOCX-E004)
- Missing document language (DOCX-E005)
- Color-only formatting conveying meaning (DOCX-E006)
- Very long alt text that needs summarization (DOCX-W001)
- Skipped heading levels (DOCX-W002)
- Merged cells in tables (DOCX-W003)
- Small font sizes below 10pt (DOCX-W004)
- Empty paragraphs used for spacing (DOCX-W005)

**Example prompts:**
```
/word-accessibility scan report.docx for accessibility issues
@word-accessibility review the quarterly report template
@word-accessibility check all Word documents in the docs/ directory
```

---

#### excel-accessibility — Microsoft Excel (XLSX) Accessibility

**What it does:** Scans Microsoft Excel spreadsheets for accessibility issues. Uses the `scan_office_document` MCP tool to parse XLSX files and check for sheet naming, table structure, merged cells, chart alt text, input messages on data-entry cells, and defined names.

**When to use it:**
- Reviewing spreadsheets before publishing or sharing
- Checking budget/data templates for accessibility
- Auditing XLSX files that will be distributed externally
- Preparing spreadsheets for users who rely on screen readers

**What it catches:**
- Default sheet names like "Sheet1" (XLSX-E001)
- Missing defined names for data ranges (XLSX-E002)
- Merged cells that confuse screen readers (XLSX-E003)
- Missing sheet tab color differentiation (XLSX-E004)
- No header row in data tables (XLSX-E005)
- Charts without alt text or descriptions (XLSX-E006)
- Blank cells in data ranges (XLSX-W001)
- Very wide rows beyond column Z (XLSX-W002)
- Hidden sheets that may hide important content (XLSX-W003)
- Missing input messages on data validation cells (XLSX-W004)

**Example prompts:**
```
/excel-accessibility scan budget.xlsx for accessibility
@excel-accessibility review the quarterly data spreadsheet
@excel-accessibility check all spreadsheets in the finance/ directory
```

---

#### powerpoint-accessibility — Microsoft PowerPoint (PPTX) Accessibility

**What it does:** Scans Microsoft PowerPoint presentations for accessibility issues. Uses the `scan_office_document` MCP tool to parse PPTX files and check for slide titles, reading order, alt text on images, table structure, audio/video descriptions, and use of speaker notes.

**When to use it:**
- Reviewing presentations before sharing or presenting
- Checking slide templates for accessibility compliance
- Auditing PPTX files for procurement or public distribution
- Preparing presentations that will be available as shared documents

**What it catches:**
- Slides without titles (PPTX-E001)
- Images without alt text (PPTX-E002)
- Missing reading order definitions (PPTX-E003)
- Tables without header rows (PPTX-E004)
- Audio/video without descriptions (PPTX-E005)
- Missing presentation language (PPTX-E006)
- Multiple slides with identical titles (PPTX-W001)
- Small font sizes below 18pt for slides (PPTX-W002)
- Excessive text on single slides (PPTX-W003)
- Missing speaker notes (PPTX-W004)
- Slide transitions without user control (PPTX-W005)

**Example prompts:**
```
/powerpoint-accessibility scan presentation.pptx for accessibility
@powerpoint-accessibility review the company deck template
@powerpoint-accessibility check all slide decks in assets/
```

---

#### office-scan-config — Office Scan Configuration

**What it does:** Manages `.a11y-office-config.json` configuration files that control which rules the `scan_office_document` MCP tool enforces. Supports per-format rule enabling/disabling, severity filters, and three preset profiles.

**When to use it:**
- Setting up scanning rules for a project's Office documents
- Creating a baseline configuration for a team
- Adjusting scan strictness (e.g., ignoring tips, only showing errors)
- Applying a preset profile (strict, moderate, or minimal)

**Preset profiles:**
- **strict** — All rules enabled, all severities reported
- **moderate** — All rules enabled, only errors and warnings (tips suppressed)
- **minimal** — Only errors reported, warnings and tips suppressed

**Example prompts:**
```
/office-scan-config create a moderate config for this project
@office-scan-config disable DOCX-W005 (empty paragraphs) for this repo
@office-scan-config switch to strict profile
```

---

#### pdf-accessibility — PDF Document Accessibility

**What it does:** Scans PDF documents for conformance with PDF/UA (ISO 14289) and the Matterhorn Protocol. Uses the `scan_pdf_document` MCP tool to parse PDF files and check tagged structure, metadata (title, language), bookmarks, form field labels, figure alt text, table structure, font embedding, and encryption restrictions. Reports findings with three rule layers.

**When to use it:**
- Reviewing PDFs before publishing or distributing
- Checking PDF conformance for procurement (Section 508, EN 301 549)
- Auditing scanned documents for basic structural accessibility
- Verifying PDF/UA compliance after conversion from Office documents

**Rule layers:**
- **PDFUA.*** (30 rules) — PDF/UA conformance, maps to Matterhorn Protocol checkpoints
- **PDFBP.*** (22 rules) — Best practices beyond PDF/UA requirements
- **PDFQ.*** (4 rules) — Quality and pipeline checks (file size, encryption, scan detection)

**Key checks:**
- Missing tagged structure (PDFUA.TAGS.001)
- No document title in metadata (PDFUA.META.001)
- Missing document language (PDFUA.META.002)
- Figures without alt text (PDFUA.TAGS.004)
- Tables without headers (PDFUA.TAGS.005)
- Unlabeled form fields (PDFUA.FORM.001)
- Missing bookmarks (PDFUA.NAV.001)
- Non-embedded fonts (PDFUA.FONT.001)
- Scanned image PDFs (PDFQ.SCAN.001)
- Encryption restricting assistive technology (PDFQ.ENC.001)

**Example prompts:**
```
/pdf-accessibility scan contract.pdf for PDF/UA compliance
@pdf-accessibility review the annual report PDF
@pdf-accessibility check all PDFs in the legal/ directory
@pdf-accessibility what PDFUA rules does this file violate?
```

---

#### pdf-scan-config — PDF Scan Configuration

**What it does:** Manages `.a11y-pdf-config.json` configuration files that control which rules the `scan_pdf_document` MCP tool enforces. Supports rule enabling/disabling, severity filters, max file size limits, and three preset profiles.

**When to use it:**
- Setting up scanning rules for a project's PDF documents
- Adjusting which rule layers to enforce (PDFUA, PDFBP, PDFQ)
- Setting file size limits for scan performance
- Applying a preset profile (strict, moderate, or minimal)

**Preset profiles:**
- **strict** — All 56 rules enabled, all severities
- **moderate** — PDFUA + PDFBP rules, errors and warnings only
- **minimal** — PDFUA rules only, errors only

**Example prompts:**
```
/pdf-scan-config create a strict config for this project
@pdf-scan-config disable PDFBP rules and only check PDF/UA
@pdf-scan-config set max file size to 50MB
```

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
- **check_heading_structure** -- Analyze HTML for heading hierarchy issues: skipped levels, multiple H1 tags, empty headings, and heading order problems.
- **check_link_text** -- Scan HTML for ambiguous link text ("click here", "read more"), URLs used as text, missing new-tab warnings, non-HTML resources without file type, and repeated identical text linking to different destinations.
- **check_form_labels** -- Validate form inputs have proper label associations (for/id, aria-label, aria-labelledby), check for autocomplete on identity fields, and flag radio/checkbox groups without fieldset/legend.
- **generate_vpat** -- Generate a VPAT 2.5 / Accessibility Conformance Report (ACR) template pre-populated with all WCAG 2.2 Level A and AA criteria. Merge in findings from agent reviews to produce a publishable conformance document.
- **run_axe_scan** -- Run axe-core against a live URL and return violations grouped by severity with WCAG criteria references and fix suggestions.
- **scan_office_document** -- Scan a Microsoft Office document (DOCX, XLSX, PPTX) for accessibility issues. Parses the ZIP/XML structure and checks for alt text, headings, tables, language, reading order, and more. Returns findings as SARIF or markdown.
- **scan_pdf_document** -- Scan a PDF document for accessibility conformance against PDF/UA and the Matterhorn Protocol. Checks tagged structure, metadata, bookmarks, form fields, fonts, and encryption. Returns findings as SARIF or markdown.

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

## Integrating axe-core into the Agent Workflow

The agents review your code and enforce accessibility patterns during development. [axe-core](https://github.com/dequelabs/axe-core) tests the rendered page in a real browser. Together, they cover both sides: code-time enforcement and runtime verification.

This integration is built into the system at three levels:

1. **MCP tool (`run_axe_scan`)** — Agents can trigger axe-core scans programmatically via the MCP server
2. **Agent instructions** — The testing-coach and accessibility-wizard know when and how to run scans
3. **VS Code task** — Manual scan trigger available in the VS Code command palette

### How the MCP Tool Works

The MCP server ([desktop-extension/server/index.js](desktop-extension/server/index.js)) includes a `run_axe_scan` tool that:

1. Takes a URL (your running dev server), an optional CSS selector, and an optional report file path
2. Runs `@axe-core/cli` against the live page
3. Parses the JSON results
4. Returns violations grouped by severity (Critical > Serious > Moderate > Minor)
5. Includes affected HTML elements, WCAG criteria, and fix suggestions
6. When `reportPath` is provided, writes a structured markdown report to that file

The tool works in **Claude Desktop** (via the .mcpb extension), **GitHub Copilot** (via `.vscode/mcp.json`), and any MCP-compatible client.

**Prerequisites:**

```bash
# Install axe-core CLI (one-time setup)
npm install -g @axe-core/cli
```

axe-core CLI uses Chromium under the hood to render the page, so Chrome or Chromium must be available on your system.

### Report Generation

The `run_axe_scan` tool generates accessible markdown reports when you provide a `reportPath`. The report includes:

- Scan metadata (URL, date, standard, scanner)
- Summary table of violations by severity
- Each violation with its WCAG criteria, help link, and every affected element
- HTML snippets showing the problematic code
- Fix suggestions from axe-core for each instance
- Next steps for remediation

The **accessibility-wizard** takes this further — it writes a consolidated `ACCESSIBILITY-AUDIT.md` that merges its own code review findings (Phases 1-8) with the axe-core scan results (Phase 9) into a single prioritized report. Issues found by both the agent review and the axe-core scan are marked as high-confidence findings. The wizard deduplicates issues, provides code fixes, and references the original scan report.

**Output files:**

| File | Written By | Contents |
|------|-----------|----------|
| `ACCESSIBILITY-SCAN.md` | `run_axe_scan` tool | Raw axe-core scan results formatted as accessible markdown |
| `ACCESSIBILITY-AUDIT.md` | accessibility-wizard | Consolidated report: agent code review + axe-core scan, deduplicated, with code fixes |

### How Agents Use It

**The accessibility-wizard** (Phase 9) will ask if you have a dev server running. If you do, it runs an axe-core scan, writes the scan report to `ACCESSIBILITY-SCAN.md`, and then consolidates everything into `ACCESSIBILITY-AUDIT.md` at the end:

```
# Claude Code
/accessibility-wizard run a full audit on this project
# → Phases 1-8: reviews code with specialist agents
# → Phase 9: asks "Is your dev server running? What URL?"
# → Runs axe-core scan → writes ACCESSIBILITY-SCAN.md
# → Phase 10: writes consolidated ACCESSIBILITY-AUDIT.md

# Copilot
@accessibility-wizard audit this project for accessibility
```

**The testing-coach** can run ad-hoc scans when you want to check a specific page:

```
# Claude Code
/testing-coach run an axe-core scan on http://localhost:3000/dashboard

# Copilot
@testing-coach scan http://localhost:3000/checkout for accessibility issues
```

**Any agent** can interpret axe-core results if you feed them manually:

```
# Run a scan yourself and save results
npx @axe-core/cli http://localhost:3000 --save results.json

# Feed to an agent
/accessibility-lead triage the violations in results.json
@contrast-master fix the contrast violations axe found on this page
```

### VS Code Task

The workspace includes an `A11y: Run axe-core Scan` task. Run it from the command palette (`Ctrl+Shift+P` → `Tasks: Run Task` → `A11y: Run axe-core Scan`). It prompts for a URL and runs the scan in the terminal.

### CI/CD Pipeline

The project includes a CI workflow at [.github/workflows/a11y-check.yml](.github/workflows/a11y-check.yml) that already runs axe-core and ESLint jsx-a11y on pull requests. To add axe-core to your own CI:

**GitHub Actions with Playwright:**

```yaml
- name: Run axe-core accessibility tests
  run: |
    npx @axe-core/cli http://localhost:3000 \
      --tags wcag2a,wcag2aa,wcag21a,wcag21aa \
      --exit
```

**In your test framework:**

```bash
# Playwright
npm install --save-dev @axe-core/playwright

# Cypress
npm install --save-dev cypress-axe axe-core

# Jest (React)
npm install --save-dev jest-axe
```

See the [testing-coach agent deep dive](#testing-coach--how-to-test-accessibility) for full framework setup examples.

### What Catches What

| Issue Type | Agents | axe-core | Manual Testing |
|-----------|--------|---------|----------------|
| Missing alt text | Yes | Yes | Yes |
| ARIA pattern correctness | Yes | Partial | Yes |
| Computed contrast ratios | No | Yes | Yes |
| Focus management logic | Yes | No | Yes |
| Live region timing | Yes | No | Yes |
| Tab order design | Yes | No | Yes |
| Keyboard trap detection | Yes | No | Yes |
| Third-party widget issues | No | Yes | Yes |
| Screen reader UX | No | No | Yes |

**Agents** catch ~70% of issues during code generation. **axe-core** catches some of the remaining issues by testing the rendered DOM. **Manual testing** (screen readers, keyboard) covers what tools cannot.

---

## Static Analysis MCP Tools

In addition to `check_contrast`, `get_accessibility_guidelines`, and `run_axe_scan`, the MCP server provides three static analysis tools that check HTML source code without needing a running dev server:

### check_heading_structure

Analyzes HTML for heading hierarchy issues. Pass it HTML content and it returns:
- Full heading outline with levels and text
- Multiple H1 detection
- Skipped heading levels (e.g., H1 → H3)
- Empty headings with no text content
- WCAG criterion references (1.3.1, 2.4.6)

### check_link_text

Scans HTML for link accessibility issues. Detects:
- 17 ambiguous text patterns ("click here", "read more", "learn more", "here", "more", etc.)
- URLs used as link text (screen readers read every character)
- Links opening in new tabs (`target="_blank"`) without visual or programmatic warning
- Links to non-HTML resources (PDF, DOCX, XLSX) without file type indication
- Repeated identical link text pointing to different destinations
- WCAG criterion references (2.4.4, 2.4.9)

### check_form_labels

Validates form input accessibility. Checks:
- Every `<input>`, `<select>`, and `<textarea>` has a proper label (`<label for>`, `aria-label`, or `aria-labelledby`)
- `aria-labelledby` references actually exist in the document
- Identity and payment fields have `autocomplete` attributes (WCAG 1.3.5)
- Radio/checkbox groups are wrapped in `<fieldset>` with `<legend>`
- WCAG criterion references (1.3.1, 1.3.5, 3.3.2, 4.1.2)

### Using the Tools

The tools accept HTML as a string input. Agents can read a file and pass its contents to the tool, or you can paste HTML directly:

```
# Claude Code — agents use tools automatically
/accessibility-lead review index.html
# → The lead reads the file, passes HTML to check_heading_structure, check_link_text,
#   check_form_labels as needed

# Copilot — same, agents coordinate tool use
@accessibility-wizard audit the signup page
```

---

## VPAT / ACR Template Generation

The MCP server includes a `generate_vpat` tool that produces a [VPAT 2.5](https://www.itic.org/policy/accessibility/vpat) / Accessibility Conformance Report (ACR) template. This is the standard format used to document accessibility conformance for procurement.

### What It Generates

- Product name, version, and evaluation date
- All WCAG 2.2 Level A criteria (30 criteria) in a structured table
- All WCAG 2.2 Level AA criteria (20 criteria) in a structured table
- Conformance levels: Supports, Partially Supports, Does Not Support, Not Applicable, Not Evaluated
- Remarks and explanations for each criterion
- Summary statistics (how many criteria at each conformance level)
- Terms and definitions section

### How to Use

**With the accessibility-wizard:**
```
/accessibility-wizard I need to prepare for a VPAT assessment
@accessibility-wizard generate a VPAT for this project
```

The wizard will run its full audit (Phases 1-10), then use the `generate_vpat` tool to produce a VPAT pre-populated with findings.

**Directly via the MCP tool:**
```
generate_vpat with:
  productName: "My App"
  productVersion: "2.1.0"
  evaluationDate: "2025-01-15"
  findings: [
    { criterion: "1.1.1", level: "A", conformance: "Partially Supports", remarks: "Most images have alt text, but user-uploaded images lack alt" }
  ]
  reportPath: "VPAT-MyApp-2.1.0.md"
```

### Integration with Agent Reviews

After running a full audit with the accessibility-wizard, findings can be fed into `generate_vpat` to produce a formal conformance report. The workflow is:

1. Run `accessibility-wizard` for a comprehensive audit
2. The wizard produces `ACCESSIBILITY-AUDIT.md` with all findings
3. Use `generate_vpat` to map findings to WCAG criteria and generate the formal VPAT
4. Review and adjust conformance levels as needed (the agents provide evidence, you make the final call)

---

## Document Accessibility Scanning

The A11y Agent Team includes full support for scanning **Microsoft Office documents** (Word, Excel, PowerPoint) and **PDF files** for accessibility issues — without requiring any external dependencies. The scanners parse documents directly using pure Node.js and return findings in SARIF 2.1.0 or human-readable markdown format.

### Office Document Scanning

The `scan_office_document` MCP tool scans DOCX, XLSX, and PPTX files by parsing their ZIP/XML structure. It checks for:

| Format | Rules | Key Checks |
|--------|-------|------------|
| **DOCX** | 16 rules (DOCX-E*, DOCX-W*, DOCX-T*) | Alt text, headings, table headers, language, document title, color-only formatting, empty paragraphs, font sizes |
| **XLSX** | 14 rules (XLSX-E*, XLSX-W*, XLSX-T*) | Sheet names, merged cells, header rows, chart alt text, defined names, hidden sheets, input messages |
| **PPTX** | 16 rules (PPTX-E*, PPTX-W*, PPTX-T*) | Slide titles, reading order, alt text, table headers, audio/video, language, font sizes, speaker notes |

**Using the tool:**

```
# Claude Code — via document agents
/word-accessibility scan docs/report.docx
/excel-accessibility check data/budget.xlsx
/powerpoint-accessibility review slides/deck.pptx

# Copilot
@word-accessibility scan the annual report
@excel-accessibility check the spreadsheet template
@powerpoint-accessibility review the training presentation

# Claude Desktop — tool is available automatically
# Just ask: "Scan this Word document for accessibility issues" and provide the file path
```

**Output formats:**
- **SARIF** (default) — Machine-readable format compatible with GitHub Code Scanning
- **Markdown** — Human-readable report with severity, rule explanations, and remediation guidance

### PDF Document Scanning

The `scan_pdf_document` MCP tool scans PDF files by parsing their binary structure. It checks against three rule layers aligned with the PDF/UA standard (ISO 14289) and the Matterhorn Protocol:

| Layer | Rules | Purpose |
|-------|-------|---------|
| **PDFUA.*** | 30 rules | PDF/UA conformance — tagged structure, metadata, navigation, forms, tables, fonts |
| **PDFBP.*** | 22 rules | Best practices — document properties, content quality, navigation aids |
| **PDFQ.*** | 4 rules | Pipeline quality — file size limits, scan detection, encryption checks |

**Using the tool:**

```
# Claude Code — via PDF agent
/pdf-accessibility scan legal/contract.pdf
/pdf-accessibility check all PDFs in the docs/ directory

# Copilot
@pdf-accessibility review the annual report PDF
@pdf-accessibility scan contract.pdf for PDF/UA conformance

# Claude Desktop — tool is available automatically
# Just ask: "Scan this PDF for accessibility" and provide the file path
```

**What the PDF scanner detects (selected highlights):**
- Missing tagged structure (no structure tree)
- Suspect flags indicating scanned-image PDFs
- Missing or empty document title and language
- Figures without `/Alt` text in the tag tree
- Tables without `/TH` header cells
- Unlabeled form fields
- Missing bookmarks for navigation
- Non-embedded fonts
- Encryption that restricts assistive technology access

### Document Scanning Agents

Six agents specialize in document accessibility:

| Agent | Domain |
|-------|--------|
| **word-accessibility** | DOCX scanning and remediation guidance |
| **excel-accessibility** | XLSX scanning and remediation guidance |
| **powerpoint-accessibility** | PPTX scanning and remediation guidance |
| **office-scan-config** | Office scan rule configuration |
| **pdf-accessibility** | PDF scanning per PDF/UA and Matterhorn Protocol |
| **pdf-scan-config** | PDF scan rule configuration |

These agents coordinate with the MCP tools to scan files, interpret results, and provide actionable remediation guidance. The accessibility-wizard includes document scanning as Phase 10 in its guided audit.

### CI/CD Integration for Documents

Two CI scan scripts mirror the MCP tool logic for use in automated pipelines:

- [.github/scripts/office-a11y-scan.mjs](.github/scripts/office-a11y-scan.mjs) — Scans DOCX, XLSX, PPTX files found in the repository
- [.github/scripts/pdf-a11y-scan.mjs](.github/scripts/pdf-a11y-scan.mjs) — Scans PDF files found in the repository

Both scripts:
- Discover documents recursively (skipping `node_modules`, `.git`, `vendor`)
- Apply `.a11y-office-config.json` or `.a11y-pdf-config.json` if present
- Output SARIF 2.1.0 reports for GitHub Code Scanning integration
- Emit GitHub Actions `::error::` and `::warning::` annotations
- Exit with code 1 if error-severity findings are detected

**Add to your CI workflow:**

```yaml
- name: Scan Office documents for accessibility
  run: node .github/scripts/office-a11y-scan.mjs

- name: Scan PDF documents for accessibility
  run: node .github/scripts/pdf-a11y-scan.mjs
```

### Scan Configuration

Both tools support project-level configuration files that control which rules are enforced:

**Office: `.a11y-office-config.json`**
```json
{
  "docx": {
    "enabled": true,
    "disabledRules": ["DOCX-W005"],
    "severityFilter": ["error", "warning"]
  },
  "xlsx": {
    "enabled": true,
    "disabledRules": [],
    "severityFilter": ["error", "warning", "tip"]
  },
  "pptx": {
    "enabled": true,
    "disabledRules": [],
    "severityFilter": ["error", "warning"]
  }
}
```

**PDF: `.a11y-pdf-config.json`**
```json
{
  "enabled": true,
  "disabledRules": [],
  "severityFilter": ["error", "warning"],
  "maxFileSize": 104857600
}
```

Both config files are searched upward from the scanned file's directory. Use the `office-scan-config` and `pdf-scan-config` agents to generate configurations interactively.

---

## Example Project

The `example/` directory contains a deliberately broken web page with **20+ intentional accessibility violations**. Use it to practice with the agents and see how they catch real issues.

### What's Included

- [example/index.html](example/index.html) — A mock e-commerce page with issues across every accessibility category
- [example/styles.css](example/styles.css) — CSS with contrast failures, outline removal, missing prefers-reduced-motion

### Categories of Issues

| Category | Example Issues |
|---|---|
| Images | Missing alt, decorative image with verbose alt |
| Headings | Multiple H1s, skipped levels (H1→H3, H3→H6), empty heading |
| Links | "Click here" ×3, "read more", URL-as-text, no new-tab warning, PDF without file type |
| Forms | No labels, no autocomplete, no fieldset, positive tabindex |
| Keyboard | Div buttons, outline:none, no skip link |
| Contrast | Gray text on white (2.85:1), low-contrast header, invisible placeholder |
| Motion | Scrolling animation, no prefers-reduced-motion |
| ARIA | No live region for status messages, no dialog role on modal |
| Focus | Modal without focus trap, focus not returned on close |

### How to Try It

```bash
# Run the CI lint script against the example
node .github/scripts/a11y-lint.mjs example/

# Ask an agent to review it
/accessibility-lead review example/index.html
@accessibility-wizard audit the example directory

# Test individual tools
# check_heading_structure → finds: 2 H1s, H1→H3 skip, H3→H6 skip, empty heading
# check_link_text → finds: "click here" ×3, "read more", URL text, no new-tab warning
# check_form_labels → finds: unlabeled input, missing autocomplete, no fieldset
```

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
- WCAG 2.2 Level A and AA criteria (VPAT/ACR generation)
- Screen reader compatibility (VoiceOver, NVDA, JAWS)
- Keyboard-only navigation
- Focus management for SPAs, modals, and dynamic content
- Color contrast verification with automated calculation
- User preference media queries (`prefers-reduced-motion`, `prefers-contrast`, `prefers-color-scheme`, `forced-colors`, `prefers-reduced-transparency`)
- Live region implementation for dynamic updates
- Semantic HTML enforcement
- Static analysis of headings, link text, and form labels
- VPAT 2.5 / Accessibility Conformance Report generation
- Office document accessibility scanning (DOCX, XLSX, PPTX) with 46 built-in rules
- PDF document accessibility scanning per PDF/UA and the Matterhorn Protocol with 56 built-in rules
- SARIF 2.1.0 output for CI/CD integration
- Common framework pitfalls (React conditional rendering, Tailwind contrast failures)

## What This Does Not Cover

- Mobile native accessibility (iOS/Android). A separate agent team for that is in development.
- WCAG AAA compliance (agents target AA as the standard)

## Why Agents Instead of Skills or MCP

**Skills** rely on Claude deciding to check them. In practice, activation rates are roughly 20% without intervention. Even with hooks, skills are a single block of instructions that can be deprioritized as context grows.

**MCP servers** add external tool calls but don't change how Claude reasons about the code it writes. They're better suited for runtime checks than code-generation-time enforcement.

**Agents** run in their own context window with a dedicated system prompt. The accessibility rules aren't suggestions -- they're the agent's entire identity. An ARIA specialist cannot forget about ARIA. A contrast master cannot skip contrast checks. The rules are who they are.

The Desktop Extension uses MCP because that is what Claude Desktop supports -- it does not have an agent system like Claude Code. The MCP server packs the same specialist knowledge into tools and prompts that work within Desktop's architecture. The document scanning tools (`scan_office_document`, `scan_pdf_document`) are also available across all three platforms.

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
      accessibility-wizard.md   # Interactive guided audit wizard
      alt-text-headings.md     # Alt text, SVGs, headings, landmarks
      aria-specialist.md       # ARIA roles, states, properties
      contrast-master.md       # Color contrast and visual a11y
      excel-accessibility.md   # Excel spreadsheet accessibility
      forms-specialist.md      # Forms, labels, validation, errors
      keyboard-navigator.md    # Tab order and focus management
      link-checker.md          # Ambiguous link text detection
      live-region-controller.md # Dynamic content announcements
      modal-specialist.md      # Dialogs, drawers, overlays
      office-scan-config.md    # Office scan configuration manager
      pdf-accessibility.md     # PDF document accessibility (PDF/UA)
      pdf-scan-config.md       # PDF scan configuration manager
      powerpoint-accessibility.md # PowerPoint presentation accessibility
      tables-data-specialist.md # Data tables, grids, sortable columns
      testing-coach.md         # Screen reader and keyboard testing guide
      wcag-guide.md            # WCAG 2.2 criteria reference
      word-accessibility.md    # Word document accessibility
    hooks/
      a11y-team-eval.sh        # UserPromptSubmit hook (macOS/Linux)
      a11y-team-eval.ps1       # UserPromptSubmit hook (Windows)
    settings.json              # Example hook configuration
  .github/
    agents/
      accessibility-lead.agent.md    # Orchestrator agent (GitHub Copilot)
      accessibility-wizard.agent.md   # Interactive guided audit wizard
      alt-text-headings.agent.md     # Alt text, SVGs, headings, landmarks
      aria-specialist.agent.md       # ARIA roles, states, properties
      contrast-master.agent.md       # Color contrast and visual a11y
      excel-accessibility.agent.md   # Excel spreadsheet accessibility
      forms-specialist.agent.md      # Forms, labels, validation, errors
      keyboard-navigator.agent.md    # Tab order and focus management
      link-checker.agent.md          # Ambiguous link text detection
      live-region-controller.agent.md # Dynamic content announcements
      modal-specialist.agent.md      # Dialogs, drawers, overlays
      office-scan-config.agent.md    # Office scan configuration manager
      pdf-accessibility.agent.md     # PDF document accessibility (PDF/UA)
      pdf-scan-config.agent.md       # PDF scan configuration manager
      powerpoint-accessibility.agent.md # PowerPoint presentation accessibility
      tables-data-specialist.agent.md # Data tables, grids, sortable columns
      testing-coach.agent.md         # Screen reader and keyboard testing guide
      wcag-guide.agent.md            # WCAG 2.2 criteria reference
      word-accessibility.agent.md    # Word document accessibility
    copilot-instructions.md    # Workspace-level accessibility instructions
    copilot-review-instructions.md  # PR review enforcement rules
    copilot-commit-message-instructions.md # Commit message a11y guidance
    PULL_REQUEST_TEMPLATE.md   # Accessibility checklist for PRs
    workflows/
      a11y-check.yml           # CI workflow for a11y checks on PRs
    scripts/
      a11y-lint.mjs            # Node.js accessibility linter (used by CI workflow)
      office-a11y-scan.mjs     # Office document accessibility scanner (CI)
      pdf-a11y-scan.mjs        # PDF document accessibility scanner (CI)
  .vscode/
    extensions.json            # Recommended a11y extensions
    mcp.json                   # MCP server config for Copilot
    settings.json              # VS Code a11y and Copilot settings
    tasks.json                 # A11y check tasks (contrast, alt text, axe-core scan)
  desktop-extension/
    manifest.json              # Claude Desktop extension manifest
    package.json               # Node.js package config
    server/
      index.js                 # MCP server (tools: check_contrast, get_accessibility_guidelines, check_heading_structure, check_link_text, check_form_labels, generate_vpat, run_axe_scan, scan_office_document, scan_pdf_document + prompts)
  example/
    README.md                  # Example project documentation
    index.html                 # Deliberately broken page (20+ a11y issues)
    styles.css                 # CSS with contrast failures and missing prefers-*
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

Found a gap? Open an issue or PR. Contributions are welcome. See the [Contributing Guide](CONTRIBUTING.md) for details.

Common contributions:

- Agent gap reports (an agent missed something or gave wrong advice)
- Additional patterns for specific frameworks (Vue, Svelte, Angular)
- Edge cases we missed in existing agents
- Framework-specific gotchas (Next.js app router focus management, etc.)
- Improvements to agent instructions that reduce false positives
- New specialist agents for uncovered accessibility domains

If you find this useful, please star the repo and watch for releases so you know when updates drop.

## Contributors

Thanks to everyone who has contributed to making AI coding tools more accessible.

<a href="https://github.com/taylorarndt/a11y-agent-team/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=taylorarndt/a11y-agent-team" alt="Contributors" />
</a>

## Also by the Author

**[Swift Agent Team](https://github.com/taylorarndt/swift-agent-team)** — 9 specialized Swift agents for Claude Code. Swift 6.2 concurrency, Apple Foundation Models, on-device AI, SwiftUI, accessibility, security, testing, and App Store compliance -- enforced on every prompt. Both projects can coexist: install A11y agents in your web projects and Swift agents in your Swift projects.

## License

MIT

## About the Author

Built by [Taylor Arndt](https://github.com/taylorarndt), a developer and accessibility specialist who uses assistive technology daily. I built this because accessibility is how I work, not something I bolt on at the end. When I found that AI coding tools consistently failed at accessibility, I built the team I wished existed.
