# Platform Documentation References

> **Purpose**: This file documents all external platform documentation sources used during the design and implementation of the document-accessibility-wizard agent system. Other agents and contributors can use these references to understand the platform capabilities leveraged by this project, verify implementation patterns, and stay current with upstream changes.

---

## Table of Contents

- [Claude Code (Anthropic)](#claude-code-anthropic)
- [VS Code / GitHub Copilot](#vs-code--github-copilot)
- [Model Context Protocol (MCP)](#model-context-protocol-mcp)
- [Accessibility Standards](#accessibility-standards)
- [Feature-to-Source Mapping](#feature-to-source-mapping)

---

## Claude Code (Anthropic)

Base URL: `https://code.claude.com/docs/en/`

> **Note**: URLs previously hosted at `docs.anthropic.com/en/docs/claude-code/` now redirect to `code.claude.com/docs/en/`.

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Sub-agents** | https://code.claude.com/docs/en/sub-agents | Custom subagent frontmatter fields (`name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`). Built-in subagents: Explore, Plan, General-purpose. Scope hierarchy and memory scopes. Background vs foreground execution. Worktree isolation via `isolation: "worktree"`. |
| **Hooks** | https://code.claude.com/docs/en/hooks | 18 hook events including `SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`, `SubagentStart`, `SubagentStop`, `TeammateIdle`, `TaskCompleted`. Three handler types: `command`, `prompt`, `agent`. Async hooks. Hook locations: user settings, project settings, plugin, skill/agent frontmatter. |
| **Hooks guide** | https://code.claude.com/docs/en/hooks-guide | Practical hook examples and patterns for validation, quality gates, and automation workflows. |
| **Memory** | https://code.claude.com/docs/en/memory | Memory types: managed policy, project (`CLAUDE.md`), project rules (`.claude/rules/*.md` with `paths` frontmatter), user (`~/.claude/CLAUDE.md`), project local (`CLAUDE.local.md`), auto memory (`MEMORY.md` - first 200 lines loaded). Imports with `@path` syntax. |
| **Skills** | https://code.claude.com/docs/en/skills | Agent Skills standard with `SKILL.md` files. Frontmatter: `name`, `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`, `argument-hint`. Supporting files pattern. Skill scopes: enterprise > personal > project. Plugin skills use namespace. Dynamic context injection with `!`command`` syntax. |
| **Agent teams** | https://code.claude.com/docs/en/agent-teams | Experimental multi-agent orchestration. Teams vs subagents comparison. Team lead + teammates + task list + mailbox architecture. Display modes (in-process, split panes via tmux/iTerm2). Quality gates via TeammateIdle and TaskCompleted hooks. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. |
| **Plugins** | https://code.claude.com/docs/en/plugins | Plugin structure (`.claude-plugin/plugin.json` manifest). Plugin components: skills, agents, hooks, MCP servers, LSP servers, settings. Namespaced skills (`/plugin:skill`). Plugin vs standalone comparison. Migration from `.claude/` standalone config. |
| **Plugins reference** | https://code.claude.com/docs/en/plugins-reference | Full plugin manifest schema. Plugin directory structure specification. Debugging and development tools. Version management with semver. |
| **Model configuration** | https://code.claude.com/docs/en/model-config | Model aliases (`default`, `sonnet`, `opus`, `haiku`, `opusplan`). Setting model via CLI, env var, settings. `CLAUDE_CODE_SUBAGENT_MODEL` for subagent model control. 1M token extended context. Effort levels (low/medium/high). Enterprise model restrictions via `availableModels`. |
| **Settings** | https://code.claude.com/docs/en/settings | Settings hierarchy (CLI flag > project > user > plugin). Environment variables. Settings files for permissions, hooks, model config. |
| **MCP in Claude Code** | https://code.claude.com/docs/en/mcp | MCP server integration in Claude Code. Tool matching via `mcp__<server>__<tool>` pattern for hooks. |
| **Checkpointing** | https://code.claude.com/docs/en/checkpointing | File state snapshots for safe rollback during agent operations. |
| **Headless/SDK** | https://code.claude.com/docs/en/headless | Headless mode for CI/CD integration and programmatic Claude Code usage. |
| **CLI reference** | https://code.claude.com/docs/en/cli-reference | Complete CLI flags and options reference. |

---

## VS Code / GitHub Copilot

### VS Code Custom Agents

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Custom agents** | https://code.visualstudio.com/docs/copilot/customization/custom-agents | `.agent.md` file format. YAML frontmatter: `description`, `name`, `tools`, `agents`, `model`, `user-invokable`, `disable-model-invocation`, `target`, `mcp-servers`, `handoffs`. Handoff configuration (`label`, `agent`, `prompt`, `send`, `model`). VS Code also detects `.md` files in `.claude/agents/` for cross-platform compatibility. Claude agent format support with comma-separated tools. Organization-level agent sharing. |
| **Agent overview** | https://code.visualstudio.com/docs/copilot/agents/overview | Built-in agents (Agent, Plan, Ask). Agent types: Local, Background, Cloud, Third-party. Session handoff between agent types. |
| **Chat overview** | https://code.visualstudio.com/docs/copilot/chat/copilot-chat | Chat surfaces (Chat view, Inline chat, Quick chat, CLI). Agent picker, model picker. Context mechanisms (`#`-mentions, `@`-mentions, vision). Review and checkpoint system. |
| **AI extensibility** | https://code.visualstudio.com/api/extension-guides/ai/ai-extensibility-overview | Extension options: Language Model Tools, MCP Tools, Chat Participants, Language Model API. Decision matrix for choosing approach. |
| **Custom instructions** | https://code.visualstudio.com/docs/copilot/customization/custom-instructions | Instruction file types and loading behavior. |
| **MCP servers in VS Code** | https://code.visualstudio.com/docs/copilot/customization/mcp-servers | MCP server configuration in VS Code settings. |
| **Prompt files** | https://code.visualstudio.com/docs/copilot/customization/prompt-files | `.prompt.md` files for reusable workflows. |

### GitHub Copilot Documentation

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Custom instructions** | https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions | Three types: repository-wide (`copilot-instructions.md`), path-specific (`*.instructions.md` with `applyTo` frontmatter), agent instructions (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`). `excludeAgent` frontmatter for targeting specific agents. Priority: personal > repository > organization. |
| **MCP in Copilot** | https://docs.github.com/en/copilot/concepts/context/mcp | MCP protocol overview for Copilot. GitHub MCP server. GitHub MCP Registry. Remote and local MCP server support. Toolset customization. |
| **Copilot extensions** | https://docs.github.com/en/copilot/building-copilot-extensions | Building Copilot extensions with agents and skills. |
| **Agent mode** | https://docs.github.com/en/copilot/using-github-copilot/coding-agent | Copilot coding agent for autonomous task execution. |

---

## Model Context Protocol (MCP)

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **MCP specification** | https://modelcontextprotocol.io/ | Open protocol for LLM-to-tool communication. Tools, resources, prompts, and sampling primitives. JSON-RPC 2.0 transport. |
| **MCP TypeScript SDK** | https://github.com/modelcontextprotocol/typescript-sdk | `@modelcontextprotocol/sdk` package. Server and client implementation. `StdioServerTransport` for stdio-based MCP servers. |
| **MCP servers repo** | https://github.com/modelcontextprotocol/servers | Reference MCP server implementations. Community server examples. |
| **MCP inspector** | https://modelcontextprotocol.io/docs/tools/inspector | Testing and debugging MCP servers during development. |

---

## Accessibility Standards

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **WCAG 2.2** | https://www.w3.org/TR/WCAG22/ | Web Content Accessibility Guidelines version 2.2. Success criteria mapped to document accessibility rules (DOCX-*, XLSX-*, PPTX-*, PDFUA.*, PDFBP.*, PDFQ.*). |
| **PDF/UA (ISO 14289-1)** | https://pdfa.org/resource/iso-14289-pdfua/ | Universal Accessibility standard for PDF documents. Tagged PDF requirements. |
| **Matterhorn Protocol 1.1** | https://pdfa.org/resource/the-matterhorn-protocol/ | PDF/UA conformance testing rules. 136 failure conditions organized into 31 checkpoints. |
| **VPAT 2.5 / ACR** | https://www.itic.org/policy/accessibility/vpat | Voluntary Product Accessibility Template. Accessibility Conformance Report format for compliance documentation. |
| **Section 508** | https://www.section508.gov/ | US federal accessibility requirements. Trusted tester methodology. |
| **EN 301 549** | https://www.etsi.org/deliver/etsi_en/301500_301599/301549/ | European accessibility standard for ICT products and services. |

---

## Feature-to-Source Mapping

This table maps each project feature to the documentation sources that informed its implementation.

| Project Feature | Primary Source(s) | Notes |
|----------------|-------------------|-------|
| **Custom agents (`.agent.md`)** | VS Code Custom agents, Claude Code Sub-agents | Cross-platform format: VS Code detects `.md` files in `.claude/agents/` |
| **Agent frontmatter (`tools`, `model`, `handoffs`)** | VS Code Custom agents | Frontmatter fields, tool arrays, handoff configuration |
| **Hidden helper sub-agents (`user-invokable: false`)** | VS Code Custom agents, Claude Code Sub-agents | `user-invokable: false` hides from picker; `disable-model-invocation` prevents auto-invocation |
| **Agent Skills (`SKILL.md`)** | Claude Code Skills | Skill directories with `SKILL.md` entrypoint. Frontmatter for invocation control. Supporting files pattern. |
| **Lifecycle hooks (SessionStart, SessionEnd)** | Claude Code Hooks | Hook events, handler types (`command`, `prompt`, `agent`). Quality gates via exit codes. |
| **Agent Teams (`AGENTS.md`)** | Claude Code Agent teams, GitHub Custom instructions | Enterprise coordination patterns. GitHub supports `AGENTS.md` for agent instructions. |
| **Persistent memory** | Claude Code Memory | `CLAUDE.md` project memory. Auto memory with `MEMORY.md`. Memory scopes. |
| **MCP server (document scanner tools)** | MCP specification, MCP TypeScript SDK | 11 tools + 6 prompts. `@modelcontextprotocol/sdk` with `StdioServerTransport`. |
| **Batch scanning & severity scoring** | WCAG 2.2, PDF/UA, Matterhorn Protocol | 0-100 severity score with A-F grades. Cross-document pattern detection. |
| **VPAT/ACR compliance export** | VPAT 2.5 / ACR template | Accessibility Conformance Report generation from audit findings. |
| **Cross-platform handoff** | Claude Code Sub-agents, VS Code Custom agents | Shared artifacts, report format compatibility between platforms. |
| **Plugin packaging** | Claude Code Plugins, Claude Code Plugins reference | `.claude-plugin/plugin.json` manifest. Distribution formats: git clone, per-project Copilot, per-project Claude, plugin marketplace. |
| **Background scanning patterns** | Claude Code Sub-agents (background, isolation) | Background subagent execution. Worktree isolation for safe parallel scanning. |
| **Delta scanning (changed files only)** | Git diff integration | `git diff --name-only` for detecting changed documents since last commit. |
| **Path-specific instructions** | GitHub Custom instructions | `applyTo` glob patterns in `.instructions.md` frontmatter. |
| **Custom prompts (`.prompt.md`)** | VS Code Prompt files | 9 prompt files for one-click audit workflows. |

---

## Keeping References Current

These documentation sources are actively maintained by their respective platforms. When working on this project:

1. **Check for breaking changes** - Platform features like agent teams (experimental) and hooks may change between releases.
2. **Verify URLs** - Claude Code docs migrated from `docs.anthropic.com` to `code.claude.com` in 2025. Similar migrations may occur.
3. **Test cross-platform compatibility** - VS Code now supports Claude agent format (`.md` in `.claude/agents/`), but feature parity varies.
4. **Review changelogs** - Claude Code and VS Code release notes document new agent/skill/hook capabilities.

---

*Last updated: Session implementing Tier 1-3 features for document-accessibility-wizard.*
