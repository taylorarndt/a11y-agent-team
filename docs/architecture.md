# Architecture

## Why Agents Instead of Skills or MCP

**Skills** rely on the model deciding to check them. Activation rates are roughly 20% without intervention. Skills are a single block of instructions that get deprioritized as context grows.

**MCP servers** add external tool calls but do not change how the model reasons about code. They are better suited for runtime checks than code-generation-time enforcement.

**Agents** run in their own context window with a dedicated system prompt. The accessibility rules are not suggestions - they are the agent's entire identity. An ARIA specialist cannot forget about ARIA. A contrast master cannot skip contrast checks.

The Desktop Extension uses MCP because Claude Desktop does not have an agent system. The MCP server packs the same specialist knowledge into tools and prompts.

## Why Hooks Instead of Instructions

Agents solve the expertise problem but not the activation problem. Even with CLAUDE.md instructions saying "always delegate to accessibility-lead," LLMs treat text instructions as suggestions. In real-world testing, Claude would read the instruction, understand it, and still write UI code itself without delegating. The user had to manually ask "did you do accessibility review?" every time.

**Instructions are suggestions. Hooks are enforcement.**

The project uses a three-hook enforcement gate that makes it physically impossible for Claude to skip accessibility review:

1. **UserPromptSubmit** (`a11y-team-eval.sh`) — Proactively detects web projects and injects the delegation instruction before Claude starts working.
2. **PreToolUse** (`a11y-enforce-edit.sh`) — Hard blocks any Edit/Write to UI files (`.jsx`, `.tsx`, `.vue`, `.css`, `.html`, etc.) until the accessibility-lead agent has been consulted. Uses the `permissionDecision: "deny"` mechanism to reject the tool call entirely.
3. **PostToolUse** (`a11y-mark-reviewed.sh`) — Creates a session marker when the accessibility-lead agent completes. This marker unlocks the PreToolUse block for the rest of the session.

The result: Claude cannot write to a `.tsx` file without first running the accessibility-lead review. Not because it was told not to. Because the tool call is denied at the hook level.

See the [Hooks Guide](hooks-guide.md) for implementation details.

## Project Structure

```text
accessibility-agents/
  .claude/
    agents/              # Claude Code agents (50 .md files)
    settings.json        # Claude Code settings
  .github/
    agents/              # GitHub Copilot agents (.agent.md files + AGENTS.md)
    copilot-instructions.md         # Workspace-level instructions
    copilot-review-instructions.md  # PR review rules
    copilot-commit-message-instructions.md # Commit message guidance
    PULL_REQUEST_TEMPLATE.md        # Accessibility checklist
    prompts/             # Custom prompt workflows (9 files)
    skills/              # Reusable agent skills (3 skills)
    docs/                # Advanced documentation
    workflows/           # CI workflow (a11y-check.yml)
    scripts/             # CI scripts (lint, office scan, PDF scan)
  .vscode/
    extensions.json      # Recommended extensions
    mcp.json             # MCP server config for Copilot
    settings.json        # VS Code settings
    tasks.json           # Accessibility check tasks
  claude-code-plugin/
    .claude-plugin/
      plugin.json        # Plugin manifest (name, version, author)
    agents/              # 50 agent .md files (plugin distribution)
    commands/            # 17 skill commands (/aria, /audit, etc.)
    hooks/
      hooks.json         # Plugin-level hooks (empty — enforcement is global)
    scripts/             # Helper scripts for hook infrastructure
    CLAUDE.md            # Plugin context (decision matrix, standards)
    AGENTS.md            # Agent team definitions
    README.md            # Plugin documentation
  desktop-extension/
    manifest.json        # Claude Desktop extension manifest
    package.json         # Node.js config
    server/index.js      # MCP server (11 tools + 6 prompts)
  docs/                  # Documentation (you are here)
    agents/              # Individual agent reference docs
    tools/               # MCP tools and integrations
    scanning/            # Document scanning guides
    advanced/            # Advanced topics
    hooks-guide.md       # Hook enforcement system documentation
  example/               # Deliberately broken page for practice
  templates/             # Scan config preset profiles
  install.sh             # Installer (global, project, copilot, codex)
```

### Global hooks (installed to `~/.claude/hooks/`)

```text
~/.claude/hooks/
  a11y-team-eval.sh       # UserPromptSubmit — proactive web project detection
  a11y-enforce-edit.sh     # PreToolUse — blocks UI file edits without review
  a11y-mark-reviewed.sh    # PostToolUse — creates session marker after review
  swift-team-eval.sh       # UserPromptSubmit — Swift/Apple platform detection
```

## Agent Teams

Three coordinated multi-agent workflows defined in `.github/agents/AGENTS.md`:

| Team | Led By | Purpose |
|------|--------|---------|
| **Document Accessibility Audit** | document-accessibility-wizard | Full document scanning pipeline |
| **Web Accessibility Audit** | accessibility-lead | Comprehensive web accessibility review |
| **Full Audit** | accessibility-lead | Combined web + document audit |

## Hidden Helper Sub-Agents

Internal agents not user-invokable, used by orchestrators for parallel work:

| Agent | Used By | Purpose |
|-------|---------|---------|
| document-inventory | document-accessibility-wizard | File discovery and inventory building |
| cross-document-analyzer | document-accessibility-wizard | Pattern detection and severity scoring |

## Agent Skills

Reusable knowledge modules in `.github/skills/`:

| Skill | Domain |
|-------|--------|
| document-scanning | File discovery, delta detection, scan config profiles |
| accessibility-rules | Cross-format rule reference with WCAG 2.2 mapping |
| report-generation | Report formatting, severity scoring, VPAT/ACR export |


