# Accessibility Agents

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/community-access/accessibility-agents?include_prereleases)](https://github.com/community-access/accessibility-agents/releases)
[![GitHub stars](https://img.shields.io/github/stars/community-access/accessibility-agents)](https://github.com/community-access/accessibility-agents/stargazers)
[![GitHub contributors](https://img.shields.io/github/contributors/community-access/accessibility-agents)](https://github.com/community-access/accessibility-agents/graphs/contributors)
[![WCAG 2.2 AA](https://img.shields.io/badge/WCAG-2.2_AA-green.svg)](https://www.w3.org/TR/WCAG22/)

> **AI and automated tools are not perfect.** They miss things, make mistakes, and cannot replace testing with real screen readers and assistive technology. Always verify with VoiceOver, NVDA, JAWS, and keyboard-only navigation. This tooling is a helpful starting point, not a substitute for real accessibility testing.

**A community-driven open-source project automating accessibility, efficiency, and productivity through AI-based agents, skills, custom instructions, and prompts.**

A sincere thanks goes out to [Taylor Arndt](https://github.com/taylorarndt) and [Jeff Bishop](https://github.com/jeffreybishop) for leading the charge in building this community project. It started because LLMs consistently forget accessibility - skills get ignored, instructions drift out of context, ARIA gets misused, focus management gets skipped, color contrast fails silently. They got tired of fighting it and built an agent team that will not let it slide. Now we want to make more magic together.

> **We want more contributors!** If you care about making software accessible to blind and low vision users, please consider [submitting a PR](CONTRIBUTING.md). Every improvement to these agents helps developers ship more inclusive software for the people who need it most.

---

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely.

## The Solution

**Accessibility Agents** provides thirty-five specialized agents across two teams and three platforms:

- **Accessibility team** - twenty-five agents that enforce WCAG AA standards for web code, Office/PDF documents, and Markdown documentation
- **GitHub Workflow team** - ten agents that manage repositories, triage issues, review PRs, and keep your team informed

All agents run on:

- **Claude Code** - Agents you invoke directly for accessibility evaluation
- **GitHub Copilot** - Agents + workspace instructions that ensure accessibility guidance in every conversation
- **Claude Desktop** - An MCP extension (.mcpb) with tools and prompts for accessibility review

## Quick Start

### One-liner install

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/community-access/accessibility-agents/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/community-access/accessibility-agents/main/install.ps1 | iex
```

See the full [Getting Started Guide](docs/getting-started.md) for all installation options, manual setup, global vs project install, auto-updates, and platform-specific details.

### One-liner uninstall

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/community-access/accessibility-agents/main/uninstall.sh | bash
```

**Windows (PowerShell):**

```powershell
irm https://raw.githubusercontent.com/community-access/accessibility-agents/main/uninstall.ps1 | iex
```

### Safe installation — your files are never overwritten

The installer is designed to be additive and non-destructive:

- **Agent files** (`~/.claude/agents/`, `.github/agents/`) - existing files are skipped, not replaced. A message tells you which agents were skipped so you know what you already have.
- **Config files** (`copilot-instructions.md`, `copilot-review-instructions.md`, `copilot-commit-message-instructions.md`) - our content is wrapped in `<!-- a11y-agent-team: start/end -->` markers and merged into your existing file. Your content above and below the markers is always preserved. If the file does not exist, it is created.
- **Asset directories** (`skills/`, `instructions/`, `prompts/`) - copied file-by-file; files that already exist are skipped.
- **Manifest file** (`.a11y-agent-manifest`) - tracks every file we installed. The update script uses this list to ensure it only touches files we own, never user-created agents. When contributors add new agents to the repo, those files are automatically installed on next update and added to the manifest.

**Updates are equally safe** - the update script never deletes agent files. If a file is not in the manifest (meaning you created it yourself), it will not be modified or removed.

To reinstall a specific agent from scratch, delete it first and rerun the installer (or update script).

## The Team

The following agents make up the accessibility enforcement team, each owning one domain.

| Agent | Role |
|-------|------|
| **accessibility-lead** | Orchestrator. Decides which specialists to invoke and runs the final review. |
| **aria-specialist** | ARIA roles, states, properties, widget patterns. Enforces the first rule of ARIA. |
| **modal-specialist** | Dialogs, drawers, popovers, alerts. Focus trapping, focus return, escape behavior. |
| **contrast-master** | Color contrast ratios, dark mode, focus indicators, color independence. |
| **keyboard-navigator** | Tab order, focus management, skip links, arrow key patterns, SPA route changes. |
| **live-region-controller** | Dynamic content announcements, toasts, loading states, search results. |
| **forms-specialist** | Labels, errors, validation, fieldsets, autocomplete, multi-step wizards. |
| **alt-text-headings** | Alt text, SVGs, icons, heading hierarchy, landmarks, page titles. |
| **tables-data-specialist** | Table markup, scope, caption, headers, sortable columns, ARIA grids. |
| **link-checker** | Ambiguous link text, "click here" detection, missing new-tab warnings. |
| **accessibility-wizard** | Interactive guided web audit across all eleven accessibility domains. |
| **testing-coach** | Screen reader testing, keyboard testing, automated testing guidance. |
| **wcag-guide** | WCAG 2.2 criteria in plain language, conformance levels, what changed. |
| **word-accessibility** | Microsoft Word (DOCX) document accessibility scanning. |
| **excel-accessibility** | Microsoft Excel (XLSX) spreadsheet accessibility scanning. |
| **powerpoint-accessibility** | Microsoft PowerPoint (PPTX) presentation accessibility scanning. |
| **office-scan-config** | Office scan rule configuration and preset profiles. |
| **pdf-accessibility** | PDF conformance per PDF/UA and the Matterhorn Protocol. |
| **pdf-scan-config** | PDF scan rule configuration and preset profiles. |
| **document-accessibility-wizard** | Guided document audit with cross-document analysis, VPAT export, and CSV export with help links. |
| **markdown-a11y-assistant** | Markdown documentation audit — links, alt text, headings, tables, emoji, diagrams, em-dashes, anchors. |

### GitHub Workflow Agents

The following agents handle GitHub repository management, triage, and workflow automation.

| Agent | Role |
|-------|------|
| **github-hub** | Orchestrator. Routes GitHub management tasks to the right specialist from plain English. |
| **daily-briefing** | Morning overview - open issues, PR queue, CI status, security alerts in one report. |
| **pr-review** | PR diff analysis with confidence per finding, delta tracking, and inline comments. |
| **issue-tracker** | Issue triage - priority scoring, duplicate detection, action inference, project board sync. |
| **analytics** | Repository health scoring (0-100/A-F), velocity metrics, bottleneck detection. |
| **insiders-a11y-tracker** | Track accessibility changes in VS Code Insiders and custom repos with WCAG mapping. |
| **repo-admin** | Collaborator management, branch protection rules, access audits. |
| **team-manager** | Onboarding, offboarding, org team membership, permission management. |
| **contributions-hub** | Discussions, community health metrics, first-time contributor insights. |
| **template-builder** | Guided wizard for issue/PR/discussion templates - no YAML knowledge required. |
| **repo-manager** | Repository scaffolding - labels, CI, CONTRIBUTING, SECURITY, issue templates. |

See the [Agent Reference Guide](docs/agents/README.md) for deep dives on every agent, example prompts, behavioral constraints, and instructor-led walkthroughs.

## Documentation

### Accessibility Docs

The following guides cover web and document accessibility features.

| Guide | What It Covers |
|-------|---------------|
| [Getting Started](docs/getting-started.md) | Installation for Claude Code, Copilot, and Claude Desktop |
| [Agent Reference](docs/agents/README.md) | All 22 agents with invocation syntax, examples, and deep dives |
| [MCP Tools](docs/tools/mcp-tools.md) | Static analysis tools: heading structure, link text, form labels |
| [axe-core Integration](docs/tools/axe-core-integration.md) | Runtime scanning, agent workflow, CI/CD setup |
| [VPAT Generation](docs/tools/vpat-generation.md) | VPAT 2.5 / ACR compliance report generation |
| [Office Scanning](docs/scanning/office-scanning.md) | DOCX, XLSX, PPTX scanning with 46 built-in rules |
| [PDF Scanning](docs/scanning/pdf-scanning.md) | PDF/UA scanning with 56 built-in rules |
| [Scan Configuration](docs/scanning/scan-configuration.md) | Config files, preset profiles, CI/CD templates |
| [Custom Prompts](docs/scanning/custom-prompts.md) | Nine pre-built prompts for one-click document workflows |
| [Markdown Accessibility](docs/prompts/README.md#markdown-accessibility-prompts) | Four prompts for markdown auditing, quick checks, fix mode, and audit comparison |
| [Configuration](docs/configuration.md) | Character budget, troubleshooting |
| [Architecture](docs/architecture.md) | Project structure, why agents over skills/MCP, design philosophy |

### GitHub Workflow Docs

The following guide covers all GitHub workflow agents and their invocation syntax.

| Guide | What It Covers |
|-------|---------------|
| [GitHub Workflow Agents](docs/agents/README.md#github-workflow-agents) | All 10 workflow agents with invocation syntax, examples, and instructor-led walkthroughs |

### Advanced Guides

The following guides cover advanced configuration, cross-platform handoff, and distribution.

| Guide | What It Covers |
|-------|---------------|
| [Cross-Platform Handoff](docs/advanced/cross-platform-handoff.md) | Seamless handoff between Claude Code and Copilot |
| [Advanced Scanning Patterns](docs/advanced/advanced-scanning-patterns.md) | Background scanning, worktree isolation, large libraries |
| [Plugin Packaging](docs/advanced/plugin-packaging.md) | Packaging and distributing agents for different environments |
| [Platform References](docs/advanced/platform-references.md) | External documentation sources with feature-to-source mapping |

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
- Markdown documentation accessibility scanning across 9 domains (links, alt text, headings, tables, emoji, diagrams, em-dashes, anchors, plain language)
- SARIF 2.1.0 output for CI/CD integration
- CSV export with help documentation links for web and document audit findings
- Common framework pitfalls (React conditional rendering, Tailwind contrast failures)

## Roadmap

See [ROADMAP.md](ROADMAP.md) for what is planned, in progress, and shipped. Track individual items on the [roadmap issues board](https://github.com/community-access/accessibility-agents/issues?q=label%3Aroadmap).

## What This Does Not Cover

- Mobile native accessibility (iOS/Android). A separate agent team for that is [planned](https://github.com/community-access/accessibility-agents/issues/8).
- WCAG AAA compliance (agents target AA as the standard). An AAA agent is [planned](https://github.com/community-access/accessibility-agents/issues/12).

## Example Project

The `example/` directory contains a deliberately broken web page with 20+ intentional accessibility violations. Use it to practice with the agents and see how they catch real issues. See the [example README](example/README.md) for details.

## Contributing

This project thrives on community participation. Whether you are a developer, accessibility specialist, screen reader user, or just someone who cares about inclusive software - there is a place for you here.

- **Found an agent gap?** [Open an issue](https://github.com/community-access/accessibility-agents/issues/new?template=agent_gap.yml) describing what the agent missed or got wrong.
- **Know a pattern we should catch?** Open a PR. Agent files are plain Markdown - no special tooling required.
- **Building for the blind and low vision community?** Your lived experience and domain knowledge are exactly what makes these agents better. We would love your involvement.

See the [Contributing Guide](CONTRIBUTING.md) for full details, guidelines, and how to get started.

If you find this project useful, please [star the repo](https://github.com/community-access/accessibility-agents) and watch for releases so you know when updates drop.

## Contributors

A sincere thanks to [Taylor Arndt](https://github.com/taylorarndt) and [Jeff Bishop](https://github.com/jeffreybishop) for leading the charge, and to every community member who has contributed to making AI coding tools more accessible.

<a href="https://github.com/community-access/accessibility-agents/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=community-access/accessibility-agents" alt="Contributors to Accessibility Agents" />
</a>

## Resources

- [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/)
- [WCAG 2.2 Understanding Documents](https://www.w3.org/WAI/WCAG22/Understanding/)
- [WAI-ARIA Authoring Practices Guide](https://www.w3.org/WAI/ARIA/apg/)
- [WAI-ARIA 1.2 Specification](https://www.w3.org/TR/wai-aria-1.2/)
- [Deque axe-core Rules](https://github.com/dequelabs/axe-core/blob/develop/doc/rule-descriptions.md)
- [NVDA User Guide](https://www.nvaccess.org/files/nvda/documentation/userGuide.html)
- [VoiceOver User Guide](https://support.apple.com/guide/voiceover/welcome/mac)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [WebAIM Screen Reader User Survey](https://webaim.org/projects/screenreadersurvey10/)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)
- [Inclusive Components](https://inclusive-components.design/)

## Related Projects

**[Swift Agent Team](https://github.com/taylorarndt/swift-agent-team)** - 9 specialized Swift agents for Claude Code. Swift 6.2 concurrency, Apple Foundation Models, on-device AI, SwiftUI, accessibility, security, testing, and App Store compliance.

## License

MIT

## About This Project

**Accessibility Agents** was founded by [Taylor Arndt](https://github.com/taylorarndt) (COO at [Techopolis](https://github.com/techopolis-group)) and [Jeff Bishop](https://github.com/jeffreybishop) because accessibility is how they work, not something bolted on at the end. When AI coding tools consistently failed at accessibility, they built the team they wished existed - and opened it to the world.

This is a community project. The more perspectives, lived experiences, and domain knowledge that go into it, the better it serves the blind and low vision community. If you have ideas, open a discussion. If you have fixes, open a PR. Every contribution matters.
