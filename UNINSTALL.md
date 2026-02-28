# Manual Uninstall Guide

This guide walks you through removing Accessibility Agents from every platform, step by step. Use this if the automated uninstaller did not fully clean up, or if you prefer to remove things manually.

## Quick automated uninstall

Before going manual, try the automated uninstaller first:

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/uninstall.ps1 | iex
```

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/uninstall.sh | bash
```

If that did not fully clean up, follow the manual steps below for each platform you installed.

---

## How to tell what was installed

Check the manifest file that the installer creates:

- **Project install:** `.claude/.a11y-agent-manifest` in your project directory
- **Global install:** `~/.claude/.a11y-agent-manifest` (or `%USERPROFILE%\.claude\.a11y-agent-manifest` on Windows)

Each line tells you what was installed:

| Prefix | Meaning |
|--------|---------|
| `agents/` | Claude Code agent file |
| `copilot-agents/` | Copilot agent file |
| `copilot-config/` | Copilot config file (copilot-instructions.md, etc.) |
| `copilot-skills/` | Copilot skill file |
| `copilot-instructions/` | Copilot instruction file |
| `copilot-prompts/` | Copilot prompt file |
| `copilot-global/central-store` | Copilot agents installed globally to VS Code profiles |
| `codex/project` or `codex/global` | Codex CLI was installed |
| `gemini/project` or `gemini/global` | Gemini CLI was installed |
| `scope:project` or `scope:global` | Whether this was a project or global install |

If the manifest is missing, that is okay. Follow all the sections below that apply to your setup.

---

## 1. Claude Code agents

Claude Code agents live in a `.claude/agents/` folder.

### Project install

```bash
# From your project root:
rm -rf .claude/agents/*.md
rm -f .claude/.a11y-agent-manifest
rm -f .claude/.a11y-agent-team-version
```

On Windows:

```powershell
Remove-Item .claude\agents\*.md -Force
Remove-Item .claude\.a11y-agent-manifest -Force -ErrorAction SilentlyContinue
Remove-Item .claude\.a11y-agent-team-version -Force -ErrorAction SilentlyContinue
```

### Global install

```bash
rm -rf ~/.claude/agents/*.md
rm -f ~/.claude/.a11y-agent-manifest
rm -f ~/.claude/.a11y-agent-team-version
```

On Windows:

```powershell
Remove-Item "$env:USERPROFILE\.claude\agents\*.md" -Force
Remove-Item "$env:USERPROFILE\.claude\.a11y-agent-manifest" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.claude\.a11y-agent-team-version" -Force -ErrorAction SilentlyContinue
```

**How to verify:** Open Claude Code and type `/agents`. You should see no accessibility agents listed.

---

## 2. GitHub Copilot agents (VS Code)

Copilot agents can be in two places depending on whether you did a project or global install.

### Project install

Agent files, config files, and asset directories live under `.github/` in your project:

```bash
# Remove agent files
rm -f .github/agents/*.agent.md

# Remove config files (ONLY if they contain just our content)
# Check each file first. If you see ONLY content between
# "<!-- a11y-agent-team: start -->" and "<!-- a11y-agent-team: end -->"
# markers, delete the whole file. If you have your own content too,
# just delete the lines between those two markers (inclusive).
cat .github/copilot-instructions.md
cat .github/copilot-review-instructions.md
cat .github/copilot-commit-message-instructions.md

# Remove asset directories
rm -rf .github/skills/
rm -rf .github/instructions/
rm -rf .github/prompts/
```

On Windows:

```powershell
Remove-Item .github\agents\*.agent.md -Force

# Check and remove config files (see note above about section markers)
Get-Content .github\copilot-instructions.md
Remove-Item .github\copilot-instructions.md -Force
Remove-Item .github\copilot-review-instructions.md -Force
Remove-Item .github\copilot-commit-message-instructions.md -Force

Remove-Item .github\skills -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item .github\instructions -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item .github\prompts -Recurse -Force -ErrorAction SilentlyContinue
```

### Global install

Global Copilot agents are stored in two places:

1. **Central store:** `~/.a11y-agent-team/`
2. **VS Code profile:** Inside your VS Code `User/prompts/` folder

#### Remove the central store

```bash
rm -rf ~/.a11y-agent-team/
```

On Windows:

```powershell
Remove-Item "$env:USERPROFILE\.a11y-agent-team" -Recurse -Force
```

#### Remove from VS Code profiles

Find your VS Code User folder:

| OS | VS Code Stable | VS Code Insiders |
|----|----------------|------------------|
| Windows | `%APPDATA%\Code\User\` | `%APPDATA%\Code - Insiders\User\` |
| macOS | `~/Library/Application Support/Code/User/` | `~/Library/Application Support/Code - Insiders/User/` |
| Linux | `~/.config/Code/User/` | `~/.config/Code - Insiders/User/` |

In each profile folder:

```bash
# Remove agent, prompt, and instruction files
rm -f prompts/*.agent.md
rm -f prompts/*.prompt.md
rm -f prompts/*.instructions.md

# Remove asset subdirectories
rm -rf prompts/skills/
rm -rf prompts/instructions/
```

On Windows (example for VS Code Insiders):

```powershell
$Profile = "$env:APPDATA\Code - Insiders\User"
Remove-Item "$Profile\prompts\*.agent.md" -Force -ErrorAction SilentlyContinue
Remove-Item "$Profile\prompts\*.prompt.md" -Force -ErrorAction SilentlyContinue
Remove-Item "$Profile\prompts\*.instructions.md" -Force -ErrorAction SilentlyContinue
Remove-Item "$Profile\prompts\skills" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$Profile\prompts\instructions" -Recurse -Force -ErrorAction SilentlyContinue
```

#### Restore VS Code settings

The installer may have added `chat.agentFilesLocations` to your VS Code settings. To remove it:

1. Open VS Code
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
3. Type "Preferences: Open User Settings (JSON)"
4. Find and remove this block:

```json
"chat.agentFilesLocations": {
    ".github/agents": true,
    ".claude/agents": false
}
```

#### Remove the `a11y-copilot-init` command

If you installed globally on macOS/Linux, the installer added `a11y-copilot-init` to your PATH. Remove these lines from your `~/.zshrc` or `~/.bashrc`:

```bash
# Accessibility Agents - Copilot init command
export PATH="$HOME/.a11y-agent-team:$PATH"
```

Then reload your shell: `source ~/.zshrc` (or `~/.bashrc`).

**How to verify:** In VS Code, open Copilot Chat and type `@`. You should not see any accessibility agents.

---

## 3. Codex CLI

Codex CLI support is a section inside an `AGENTS.md` file.

### Project install

```bash
# If .codex/AGENTS.md contains ONLY our content, delete it:
rm -f .codex/AGENTS.md
rmdir .codex 2>/dev/null

# If it has your own content too, edit it and remove everything between:
# <!-- a11y-agent-team: start -->
# ... (our content) ...
# <!-- a11y-agent-team: end -->
```

### Global install

```bash
# Same approach but in your home directory:
rm -f ~/.codex/AGENTS.md
rmdir ~/.codex 2>/dev/null
```

On Windows:

```powershell
Remove-Item "$env:USERPROFILE\.codex\AGENTS.md" -Force -ErrorAction SilentlyContinue
```

**How to verify:** Run `codex "Build a login form"` and confirm no accessibility rules are mentioned.

---

## 4. Gemini CLI

Gemini CLI support is an extension folder.

### Project install

```bash
rm -rf .gemini/extensions/a11y-agents/
# Clean up empty parent dirs
rmdir .gemini/extensions 2>/dev/null
rmdir .gemini 2>/dev/null
```

### Global install

```bash
rm -rf ~/.gemini/extensions/a11y-agents/
rmdir ~/.gemini/extensions 2>/dev/null
```

On Windows:

```powershell
Remove-Item "$env:USERPROFILE\.gemini\extensions\a11y-agents" -Recurse -Force -ErrorAction SilentlyContinue
```

**How to verify:** Run `gemini "Build a login form"` and confirm no accessibility skills are loaded.

---

## 5. Auto-updates

If you enabled auto-updates during global install, they need to be removed too.

### Windows

```powershell
# Remove the scheduled task
Unregister-ScheduledTask -TaskName "A11yAgentTeamUpdate" -Confirm:$false -ErrorAction SilentlyContinue

# Remove update files
Remove-Item "$env:USERPROFILE\.claude\.a11y-agent-team-update.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.claude\.a11y-agent-team-update.log" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:USERPROFILE\.claude\.a11y-agent-team-repo" -Recurse -Force -ErrorAction SilentlyContinue
```

### macOS

```bash
# Remove the LaunchAgent
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/com.community-access.accessibility-agents-update.plist 2>/dev/null
rm -f ~/Library/LaunchAgents/com.community-access.accessibility-agents-update.plist

# Remove update files
rm -f ~/.claude/.a11y-agent-team-update.sh
rm -f ~/.claude/.a11y-agent-team-update.log
rm -rf ~/.claude/.a11y-agent-team-repo
```

### Linux

```bash
# Remove the cron job
crontab -l 2>/dev/null | grep -v "a11y-agent-team-update" | crontab -

# Remove update files
rm -f ~/.claude/.a11y-agent-team-update.sh
rm -f ~/.claude/.a11y-agent-team-update.log
rm -rf ~/.claude/.a11y-agent-team-repo
```

---

## 6. Final cleanup

After removing everything above:

1. **Restart** Claude Code, VS Code, and any open terminals
2. **Verify** agents are gone by checking each tool's agent/extension list
3. **Delete empty directories** left behind (`.claude/agents/`, `.github/agents/`, `.codex/`, `.gemini/`)

If you still see agents after restarting, check that you removed files from the correct location (project vs global). The manifest file (if it existed) tells you which scope was used.

---

## Need help?

If you run into any trouble:

- Open an issue: [github.com/Community-Access/accessibility-agents/issues](https://github.com/Community-Access/accessibility-agents/issues)
- Include your OS, which platforms you installed (Claude/Copilot/Codex/Gemini), and whether it was project or global

We are happy to help and sorry for any inconvenience.
