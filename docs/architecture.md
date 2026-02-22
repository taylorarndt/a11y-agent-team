# Architecture

## Why Agents Instead of Skills or MCP

**Skills** rely on the model deciding to check them. Activation rates are roughly 20% without intervention. Skills are a single block of instructions that get deprioritized as context grows.

**MCP servers** add external tool calls but do not change how the model reasons about code. They are better suited for runtime checks than code-generation-time enforcement.

**Agents** run in their own context window with a dedicated system prompt. The accessibility rules are not suggestions — they are the agent's entire identity. An ARIA specialist cannot forget about ARIA. A contrast master cannot skip contrast checks.

The Desktop Extension uses MCP because Claude Desktop does not have an agent system. The MCP server packs the same specialist knowledge into tools and prompts.

## Project Structure

```
a11y-agent-team/
  .claude/
    agents/              # Claude Code agents (22 .md files)
    hooks/               # UserPromptSubmit hook (sh + ps1)
    settings.json        # Hook configuration example
  .github/
    agents/              # GitHub Copilot agents (22 .agent.md files + AGENTS.md)
    copilot-instructions.md         # Workspace-level instructions
    copilot-review-instructions.md  # PR review rules
    copilot-commit-message-instructions.md # Commit message guidance
    PULL_REQUEST_TEMPLATE.md        # Accessibility checklist
    prompts/             # Custom prompt workflows (9 files)
    hooks/               # Lifecycle hooks (SessionStart, SessionEnd)
    skills/              # Reusable agent skills (3 skills)
    docs/                # Advanced documentation
    workflows/           # CI workflow (a11y-check.yml)
    scripts/             # CI scripts (lint, office scan, PDF scan)
  .vscode/
    extensions.json      # Recommended extensions
    mcp.json             # MCP server config for Copilot
    settings.json        # VS Code settings
    tasks.json           # Accessibility check tasks
  desktop-extension/
    manifest.json        # Claude Desktop extension manifest
    package.json         # Node.js config
    server/index.js      # MCP server (11 tools + 6 prompts)
  docs/                  # Documentation (you are here)
    agents/              # Individual agent reference docs
    tools/               # MCP tools and integrations
    scanning/            # Document scanning guides
    advanced/            # Advanced topics
  example/               # Deliberately broken page for practice
  templates/             # Scan config preset profiles
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

## Lifecycle Hooks

Session hooks in `.github/hooks/`:

| Hook | When | Purpose |
|------|------|---------|
| SessionStart | Beginning of session | Auto-detects scan configs and prior reports |
| SessionEnd | End of session | Quality gate for report completeness |
