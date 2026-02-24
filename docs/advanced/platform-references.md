# Platform Documentation References

> **Purpose**: This file documents all external platform documentation sources used during the design and implementation of the document-accessibility-wizard agent system. Other agents and contributors can use these references to understand the platform capabilities leveraged by this project, verify implementation patterns, and stay current with upstream changes.

---

## Table of Contents

- [Claude Code (Anthropic)](#claude-code-anthropic)
- [VS Code / GitHub Copilot](#vs-code--github-copilot)
- [Model Context Protocol (MCP)](#model-context-protocol-mcp)
- [Accessibility Standards](#accessibility-standards)
  - [WCAG and W3C](#wcag-and-w3c)
  - [Compliance Frameworks](#compliance-frameworks)
  - [Microsoft Office Accessibility](#microsoft-office-accessibility)
  - [Adobe PDF Accessibility](#adobe-pdf-accessibility)
  - [Deque University and axe-core](#deque-university-and-axe-core-web-accessibility)
- [Feature-to-Source Mapping](#feature-to-source-mapping)

---

## Claude Code (Anthropic)

Base URL: `https://code.claude.com/docs/en/`

> **Note**: URLs previously hosted at `docs.anthropic.com/en/docs/claude-code/` now redirect to `code.claude.com/docs/en/`.

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Sub-agents** | <https://code.claude.com/docs/en/sub-agents> | Custom subagent frontmatter fields (`name`, `description`, `tools`, `disallowedTools`, `model`, `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`). Built-in subagents: Explore, Plan, General-purpose. Scope hierarchy and memory scopes. Background vs foreground execution. Worktree isolation via `isolation: "worktree"`. |
| **Hooks** | <https://code.claude.com/docs/en/hooks> | 18 hook events including `SessionStart`, `SessionEnd`, `PreToolUse`, `PostToolUse`, `SubagentStart`, `SubagentStop`, `TeammateIdle`, `TaskCompleted`. Three handler types: `command`, `prompt`, `agent`. Async hooks. Hook locations: user settings, project settings, plugin, skill/agent frontmatter. |
| **Hooks guide** | <https://code.claude.com/docs/en/hooks-guide> | Practical hook examples and patterns for validation, quality gates, and automation workflows. |
| **Memory** | <https://code.claude.com/docs/en/memory> | Memory types: managed policy, project (`CLAUDE.md`), project rules (`.claude/rules/*.md` with `paths` frontmatter), user (`~/.claude/CLAUDE.md`), project local (`CLAUDE.local.md`), auto memory (`MEMORY.md` - first 200 lines loaded). Imports with `@path` syntax. |
| **Skills** | <https://code.claude.com/docs/en/skills> | Agent Skills standard with `SKILL.md` files. Frontmatter: `name`, `description`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `context`, `agent`, `hooks`, `argument-hint`. Supporting files pattern. Skill scopes: enterprise > personal > project. Plugin skills use namespace. Dynamic context injection with `!`command`` syntax. |
| **Agent teams** | <https://code.claude.com/docs/en/agent-teams> | Experimental multi-agent orchestration. Teams vs subagents comparison. Team lead + teammates + task list + mailbox architecture. Display modes (in-process, split panes via tmux/iTerm2). Quality gates via TeammateIdle and TaskCompleted hooks. Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`. |
| **Plugins** | <https://code.claude.com/docs/en/plugins> | Plugin structure (`.claude-plugin/plugin.json` manifest). Plugin components: skills, agents, hooks, MCP servers, LSP servers, settings. Namespaced skills (`/plugin:skill`). Plugin vs standalone comparison. Migration from `.claude/` standalone config. |
| **Plugins reference** | <https://code.claude.com/docs/en/plugins-reference> | Full plugin manifest schema. Plugin directory structure specification. Debugging and development tools. Version management with semver. |
| **Model configuration** | <https://code.claude.com/docs/en/model-config> | Model aliases (`default`, `sonnet`, `opus`, `haiku`, `opusplan`). Setting model via CLI, env var, settings. `CLAUDE_CODE_SUBAGENT_MODEL` for subagent model control. 1M token extended context. Effort levels (low/medium/high). Enterprise model restrictions via `availableModels`. |
| **Settings** | <https://code.claude.com/docs/en/settings> | Settings hierarchy (CLI flag > project > user > plugin). Environment variables. Settings files for permissions, hooks, model config. |
| **MCP in Claude Code** | <https://code.claude.com/docs/en/mcp> | MCP server integration in Claude Code. Tool matching via `mcp__<server>__<tool>` pattern for hooks. |
| **Checkpointing** | <https://code.claude.com/docs/en/checkpointing> | File state snapshots for safe rollback during agent operations. |
| **Headless/SDK** | <https://code.claude.com/docs/en/headless> | Headless mode for CI/CD integration and programmatic Claude Code usage. |
| **CLI reference** | <https://code.claude.com/docs/en/cli-reference> | Complete CLI flags and options reference. |

---

## VS Code / GitHub Copilot

### VS Code Custom Agents

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Custom agents** | <https://code.visualstudio.com/docs/copilot/customization/custom-agents> | `.agent.md` file format. YAML frontmatter: `description`, `name`, `tools`, `agents`, `model`, `user-invokable`, `disable-model-invocation`, `target`, `mcp-servers`, `handoffs`. Handoff configuration (`label`, `agent`, `prompt`, `send`, `model`). VS Code also detects `.md` files in `.claude/agents/` for cross-platform compatibility. Claude agent format support with comma-separated tools. Organization-level agent sharing. |
| **Agent overview** | <https://code.visualstudio.com/docs/copilot/agents/overview> | Built-in agents (Agent, Plan, Ask). Agent types: Local, Background, Cloud, Third-party. Session handoff between agent types. |
| **Chat overview** | <https://code.visualstudio.com/docs/copilot/chat/copilot-chat> | Chat surfaces (Chat view, Inline chat, Quick chat, CLI). Agent picker, model picker. Context mechanisms (`#`-mentions, `@`-mentions, vision). Review and checkpoint system. |
| **AI extensibility** | <https://code.visualstudio.com/api/extension-guides/ai/ai-extensibility-overview> | Extension options: Language Model Tools, MCP Tools, Chat Participants, Language Model API. Decision matrix for choosing approach. |
| **Custom instructions** | <https://code.visualstudio.com/docs/copilot/customization/custom-instructions> | Instruction file types and loading behavior. |
| **Agent skills** | <https://code.visualstudio.com/docs/copilot/customization/agent-skills> | Skill directories with `SKILL.md` entrypoint. Workspace paths: `.github/skills/`, `.claude/skills/`, `.agents/skills/`. Personal paths: `~/.copilot/skills/`, `~/.claude/skills/`, `~/.agents/skills/`. |
| **Hooks** | <https://code.visualstudio.com/docs/copilot/customization/hooks> | Published 2026-02-09 (Preview, VS Code 1.109.3+). Eight lifecycle events: `SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`. Hook files: workspace -> `.github/hooks/*.json`; user -> `~/.claude/settings.json`. JSON format: `{ "hooks": { "EventName": [{ "type": "command", "command": "...", "windows": "...", "timeout": 30 }] } }`. Exit code 0 = success, 2 = blocking error. `additionalContext` field injects text into agent conversation. |
| **MCP servers in VS Code** | <https://code.visualstudio.com/docs/copilot/customization/mcp-servers> | MCP server configuration in VS Code settings. |
| **Prompt files** | <https://code.visualstudio.com/docs/copilot/customization/prompt-files> | `.prompt.md` files for reusable workflows. |

### GitHub Copilot Documentation

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Custom instructions** | <https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions> | Three types: repository-wide (`copilot-instructions.md`), path-specific (`*.instructions.md` with `applyTo` frontmatter), agent instructions (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`). `excludeAgent` frontmatter for targeting specific agents. Priority: personal > repository > organization. |
| **MCP in Copilot** | <https://docs.github.com/en/copilot/concepts/context/mcp> | MCP protocol overview for Copilot. GitHub MCP server. GitHub MCP Registry. Remote and local MCP server support. Toolset customization. |
| **Copilot extensions** | <https://docs.github.com/en/copilot/building-copilot-extensions> | Building Copilot extensions with agents and skills. |
| **Agent mode** | <https://docs.github.com/en/copilot/using-github-copilot/coding-agent> | Copilot coding agent for autonomous task execution. |

---

## Model Context Protocol (MCP)

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **MCP specification** | <https://modelcontextprotocol.io/> | Open protocol for LLM-to-tool communication. Tools, resources, prompts, and sampling primitives. JSON-RPC 2.0 transport. |
| **MCP TypeScript SDK** | <https://github.com/modelcontextprotocol/typescript-sdk> | `@modelcontextprotocol/sdk` package. Server and client implementation. `StdioServerTransport` for stdio-based MCP servers. |
| **MCP servers repo** | <https://github.com/modelcontextprotocol/servers> | Reference MCP server implementations. Community server examples. |
| **MCP inspector** | <https://modelcontextprotocol.io/docs/tools/inspector> | Testing and debugging MCP servers during development. |

---

## Accessibility Standards

### WCAG and W3C

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **WCAG 2.2 Specification** | <https://www.w3.org/TR/WCAG22/> | Web Content Accessibility Guidelines version 2.2. Defines 31 Level A and 24 Level AA success criteria. 4.1.1 Parsing removed (always satisfied in modern user agents). New criteria: 2.4.11 Focus Not Obscured, 2.4.13 Focus Appearance (AAA), 2.5.7 Dragging, 2.5.8 Target Size, 3.2.6 Consistent Help, 3.3.7 Redundant Entry, 3.3.8 Accessible Authentication, 3.3.9 Accessible Authentication Enhanced (AAA). |
| **WCAG 2.2 Understanding Docs** | <https://www.w3.org/WAI/WCAG22/Understanding/> | Informative companion to WCAG 2.2. Explains each success criterion with intent, benefits, examples, techniques, and test procedures. URL pattern: `{base}{slug}` where slug is the kebab-case criterion name (e.g., `non-text-content` for 1.1.1). Used by CSV reporters to generate `wcag_url` column values. |
| **WCAG 2.2 Quick Reference** | <https://www.w3.org/WAI/WCAG22/quickref/> | Customizable quick reference to all WCAG success criteria and techniques. Allows filtering by level (A, AA, AAA), technology, and topic. Used for cross-checking criterion levels and applicability. |
| **WCAG 2.2 Techniques** | <https://www.w3.org/WAI/WCAG22/Techniques/> | Sufficient, advisory, and failure techniques for meeting each WCAG criterion. Techniques are informative (not normative). Used to inform fix steps and remediation guidance in agent rules. |

### Compliance Frameworks

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **PDF/UA (ISO 14289-1)** | <https://pdfa.org/resource/iso-14289-pdfua/> | Universal Accessibility standard for PDF documents. Tagged PDF requirements. |
| **Matterhorn Protocol 1.1** | <https://pdfa.org/resource/the-matterhorn-protocol/> | PDF/UA conformance testing rules. 136 failure conditions organized into 31 checkpoints. |
| **VPAT 2.5 / ACR** | <https://www.itic.org/policy/accessibility/vpat> | Voluntary Product Accessibility Template. Accessibility Conformance Report format for compliance documentation. |
| **Section 508** | <https://www.section508.gov/> | US federal accessibility requirements. Trusted tester methodology. |
| **EN 301 549** | <https://www.etsi.org/deliver/etsi_en/301500_301599/301549/> | European accessibility standard for ICT products and services. |

### Microsoft Office Accessibility

These pages define the official Accessibility Checker rules and per-format remediation guidance. They are the authoritative source for our DOCX-\*, XLSX-\*, and PPTX-\* rule IDs, severity classifications (Error/Warning/Tip), and fix step text.

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Accessibility Checker Rules** | <https://support.microsoft.com/en-us/office/rules-for-the-accessibility-checker-651e08f2-0fc3-4e10-aaca-74b4a67101c1> | Complete list of every rule the built-in Accessibility Checker enforces across Word, Excel, PowerPoint, Outlook, OneNote, and Visio. Classifies each rule as Error, Warning, Tip, or Intelligent Services. Covers: alt text on all objects, table column headers, section/slide/sheet naming, document access restrictions, content control field titles, simple table structure, contrast, captions, reading order, heading styles, and unique slide titles. Also documents checker limitations (color-only info, in-band captions). This is the single most important reference for our document rule definitions. |
| **Accessibility Guide for Microsoft 365 Apps** | <https://learn.microsoft.com/en-us/microsoft-365-apps/deploy/accessibility-guide> | Admin-oriented guidance for deploying accessible Microsoft 365 environments. Documents connected experiences for accessibility (live captions, dictation, read aloud, learning tools, automatic alt text, QuickStarter). Covers Group Policy to enable "Check for accessibility issues while editing" for Word, Excel, and PowerPoint. Lists accessibility resources organized by disability category. |
| **Improve Accessibility with the Accessibility Checker** | <https://support.microsoft.com/en-us/office/improve-accessibility-with-the-accessibility-checker-a16f6de0-2f39-4a2b-8bd8-5ad801426c7f> | How-to for running the Accessibility Checker in each Office app. Describes results pane (Errors, Warnings, Tips, Intelligent Services categories). Used as the general fallback help URL for unmapped Office issues. |
| **Word: Make Documents Accessible** | <https://support.microsoft.com/en-us/office/make-your-word-documents-accessible-d9bf3683-87ac-47ea-b91a-78dcacb3c66d> | Format-specific guidance for Word. Bookmark anchors for each topic: `#bkmk_doctitle`, `#bkmk_headings` (now `#bkmk_useheadings`), `#bkmk_tableheaders`, `#bkmk_hyperlinks`, `#bkmk_contrast` (now `#bkmk_color`), `#bkmk_language`, `#bkmk_layout` (now `#bkmk_tableslayouts`), `#bkmk_toc`, `#bkmk_whitespace`, `#bkmk_watermarks`. These anchors are used in `help-url-reference` SKILL to build per-rule help URLs. |
| **Excel: Make Workbooks Accessible** | <https://support.microsoft.com/en-us/office/make-your-excel-documents-accessible-6cc05fc5-1314-48b5-8eb3-683e49b3e593> | Format-specific guidance for Excel. Bookmark anchors: `#bkmk_sheettabs`, `#bkmk_tableheaders`, `#bkmk_mergedcells` (now `#bkmk_simpletablestructure`), `#bkmk_color` (now `#bkmk_usecolor`), `#bkmk_alttext`, `#bkmk_fontformat`, `#bkmk_hyperlinks`, `#bkmk_validation`, `#bkmk_doctitle`. |
| **PowerPoint: Make Presentations Accessible** | <https://support.microsoft.com/en-us/office/make-your-powerpoint-presentations-accessible-6f7772b2-2f33-4bd2-8ca7-dae3b2b3ef25> | Format-specific guidance for PowerPoint. Bookmark anchors: `#bkmk_slidetitles`, `#bkmk_readingorder`, `#bkmk_alttext`, `#bkmk_tableheaders`, `#bkmk_captions`, `#bkmk_contrast` (now `#bkmk_color`), `#bkmk_animations`, `#bkmk_transitions`, `#bkmk_hyperlinks` (now `#bkmk_links`). |
| **Alt Text: Add to Objects** | <https://support.microsoft.com/en-us/office/add-alternative-text-to-a-shape-picture-chart-smartart-graphic-or-other-object-44989b2a-903c-4d9a-b742-6a75b451c669> | Cross-app alt text instructions (Word, Excel, PowerPoint, Outlook). Covers shapes, pictures, charts, SmartArt, and other objects. Used as the help URL for alt text Error rules (DOCX-E001, XLSX-E001, PPTX-E002) and decorative image Warning rules. |
| **Alt Text: Write Effective Alt Text** | <https://support.microsoft.com/en-us/office/everything-you-need-to-know-to-write-effective-alt-text-df98f884-ca3d-456c-807b-1a1fa82f5dc2> | Guidance on writing meaningful alt text. Covers when to use alt text vs marking as decorative, length guidelines, and do/don't examples. Used as help URL for long alt text Warning rules. |
| **Word: Accessible Tables** | <https://support.microsoft.com/en-us/office/create-accessible-tables-in-word-cb464015-59dc-46a0-ac01-6217c62210e5> | Detailed table accessibility in Word. Header row designation, simple structure requirements, avoiding nested/merged/split cells. Used as help URL for DOCX-E003 (table headers). |

### Adobe PDF Accessibility

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **Creating Accessible PDFs** | <https://helpx.adobe.com/acrobat/using/creating-accessible-pdfs.html> | Acrobat Pro guide to PDF accessibility. Anchor-based sections map to our PDFUA.\* and PDFBP.\* rule IDs: `#tag_pdf` (TaggedPDF), `#add_title` (Title), `#set_language` (Language), `#bookmarks` (BookmarksPresent), `#alt_text` (AltText), `#tables` (TableHeaders), `#reading_order` (ReadingOrder), `#headings` (Headings), `#lists` (ListTags), `#contrast` (Contrast), `#scanned` (Scanned), `#ocr` (Searchable). |
| **PDF Accessibility Checker (PAC)** | <https://pdfua.foundation/en/pdf-accessibility-checker-pac> | Free tool for checking PDF/UA conformance. Implements Matterhorn Protocol checks. Used as reference for PDFUA rule definitions. |

### Deque University and axe-core (Web Accessibility)

| Topic | URL | What We Learned |
|-------|-----|-----------------|
| **axe-core Rules Reference** | <https://dequeuniversity.com/rules/axe/4.10/> | Complete reference for axe-core automated accessibility rules. URL pattern: `{base}{rule-id}`. Each rule maps to one or more WCAG success criteria. Used as the `help_url` source for all web CSV findings. Covers 90+ rules including `image-alt`, `color-contrast`, `label`, `button-name`, `link-name`, `html-has-lang`, `document-title`, `heading-order`, `aria-roles`, `aria-required-attr`, `bypass`, `region`, `tabindex`, `meta-viewport`, `autocomplete-valid`, and more. |
| **axe-core GitHub Repository** | <https://github.com/dequelabs/axe-core> | Open-source accessibility testing engine. Rule definitions, checks, and metadata. Version 4.10 is the current reference version in our URL patterns. |
| **Deque University Topic Pages** | <https://dequeuniversity.com/> | Training resources for accessibility topics not covered by axe-core rules. Used for agent-detected issues: focus management (`/class/focus-management2/focus/overview`), live regions (`/library/aria/liveregion-playground`), modal dialogs (`/library/aria/modal-dialog/sf-modal-dialog`), data tables (`/class/tables2/simple/overview`). |
| **axe-core CLI** | <https://www.npmjs.com/package/@axe-core/cli> | CLI tool for running axe-core scans from the terminal. Used by the `A11y: Run axe-core Scan` VS Code task and the web-accessibility-wizard Phase 1 runtime scan. |

---

## Feature-to-Source Mapping

This table maps each project feature to the documentation sources that informed its implementation.

| Project Feature | Primary Source(s) | Notes |
|----------------|-------------------|-------|
| **Custom agents (`.agent.md`)** | VS Code Custom agents, Claude Code Sub-agents | Cross-platform format: VS Code detects `.md` files in `.claude/agents/` |
| **Agent frontmatter (`tools`, `model`, `handoffs`)** | VS Code Custom agents | Frontmatter fields, tool arrays, handoff configuration |
| **Hidden helper sub-agents (`user-invokable: false`)** | VS Code Custom agents, Claude Code Sub-agents | `user-invokable: false` hides from picker; `disable-model-invocation` prevents auto-invocation |
| **Agent Skills (`SKILL.md`)** | Claude Code Skills | Skill directories with `SKILL.md` entrypoint. Frontmatter for invocation control. Supporting files pattern. |
| **Lifecycle hooks (SessionStart, SessionEnd)** | Claude Code Hooks, VS Code Hooks | Hook events, handler types (`command`, `prompt`, `agent`). Quality gates via exit codes. **VS Code**: `.github/hooks/*.json` files, 8 events (`SessionStart`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `PreCompact`, `SubagentStart`, `SubagentStop`, `Stop`). Note: VS Code uses `Stop` - there is **no `SessionEnd`** event in VS Code. |
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
| **Document rule IDs (DOCX-\*, XLSX-\*, PPTX-\*)** | Accessibility Checker Rules, Word/Excel/PowerPoint accessibility pages | Rule severity (Error/Warning/Tip) derived from Checker classification. Rule descriptions and WCAG mappings maintained in `accessibility-rules` skill. |
| **Document help URLs** | Word/Excel/PowerPoint accessibility pages, Alt Text guidance | Bookmark-anchored URLs for per-rule fix guidance. Mapped in `help-url-reference` skill. |
| **PDF rule IDs (PDFUA.\*, PDFBP.\*, PDFQ.\*)** | PDF/UA, Matterhorn Protocol, Creating Accessible PDFs | Rule definitions from ISO 14289-1 and Matterhorn failure conditions. Help URLs from Adobe Acrobat guide. |
| **Web axe-core rule mapping** | axe-core Rules Reference, axe-core GitHub | Rule IDs to Deque University help URLs. WCAG criterion mapping from axe-core metadata. |
| **WCAG criterion-to-slug mapping** | WCAG 2.2 Understanding Docs | URL pattern for linking findings to W3C Understanding documents. Used in CSV `wcag_url` column. |
| **Fix step templates** | Word/Excel/PowerPoint/PDF accessibility pages | Application-specific step-by-step remediation instructions derived from official Microsoft and Adobe documentation. |

---

## Keeping References Current

These documentation sources are actively maintained by their respective platforms. When working on this project:

1. **Check for breaking changes** - Platform features like agent teams (experimental) and hooks may change between releases.
2. **Verify URLs** - Claude Code docs migrated from `docs.anthropic.com` to `code.claude.com` in 2025. Similar migrations may occur.
3. **Test cross-platform compatibility** - VS Code now supports Claude agent format (`.md` in `.claude/agents/`), but feature parity varies.
4. **Review changelogs** - Claude Code and VS Code release notes document new agent/skill/hook capabilities.

---

*Last updated: 2026-02-24. Expanded Accessibility Standards with Microsoft Office Checker rules, WCAG 2.2 Understanding docs, Adobe PDF sources, and Deque/axe-core references.*
