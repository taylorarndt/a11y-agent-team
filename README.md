# A11y Agent Team

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/taylorarndt/a11y-agent-team?include_prereleases)](https://github.com/taylorarndt/a11y-agent-team/releases)
[![GitHub stars](https://img.shields.io/github/stars/taylorarndt/a11y-agent-team)](https://github.com/taylorarndt/a11y-agent-team/stargazers)
[![GitHub contributors](https://img.shields.io/github/contributors/taylorarndt/a11y-agent-team)](https://github.com/taylorarndt/a11y-agent-team/graphs/contributors)
[![WCAG 2.2 AA](https://img.shields.io/badge/WCAG-2.2_AA-green.svg)](https://www.w3.org/TR/WCAG22/)

**Accessibility review agents for Claude Code, GitHub Copilot, and Claude Desktop.**

Built by [Taylor Arndt](https://github.com/taylorarndt) because LLMs consistently forget accessibility. Skills get ignored. Instructions drift out of context. ARIA gets misused. Focus management gets skipped. Color contrast fails silently. I got tired of fighting it, so I built a team of agents that will not let it slide.

---

## The Problem

AI coding tools generate inaccessible code by default. They forget ARIA rules, skip keyboard navigation, ignore contrast ratios, and produce modals that trap screen reader users. Even with skills and CLAUDE.md instructions, accessibility context gets deprioritized or dropped entirely.

## The Solution

A11y Agent Team provides twenty-two specialized agents that enforce WCAG AA standards across three platforms:

- **Claude Code** — Agents + a hook that forces accessibility evaluation on every prompt
- **GitHub Copilot** — Agents + workspace instructions that ensure accessibility guidance in every conversation
- **Claude Desktop** — An MCP extension (.mcpb) with tools and prompts for accessibility review

## Quick Start

### One-liner install

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.ps1 | iex
```

See the full [Getting Started Guide](docs/getting-started.md) for all installation options, manual setup, global vs project install, auto-updates, and platform-specific details.

## The Team

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
| **document-accessibility-wizard** | Guided document audit with cross-document analysis and VPAT export. |

See the [Agent Reference Guide](docs/agents/README.md) for deep dives on every agent, example prompts, and behavioral constraints.

## Documentation

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
| [Configuration](docs/configuration.md) | Character budget, hook management, troubleshooting |
| [Architecture](docs/architecture.md) | Project structure, why agents over skills/MCP, design philosophy |

### Advanced Guides

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
- SARIF 2.1.0 output for CI/CD integration
- Common framework pitfalls (React conditional rendering, Tailwind contrast failures)

## Roadmap

See [ROADMAP.md](ROADMAP.md) for what is planned, in progress, and shipped. Track individual items on the [roadmap issues board](https://github.com/taylorarndt/a11y-agent-team/issues?q=label%3Aroadmap).

## What This Does Not Cover

- Mobile native accessibility (iOS/Android). A separate agent team for that is [planned](https://github.com/taylorarndt/a11y-agent-team/issues/8).
- WCAG AAA compliance (agents target AA as the standard). An AAA agent is [planned](https://github.com/taylorarndt/a11y-agent-team/issues/12).

## Example Project

The `example/` directory contains a deliberately broken web page with 20+ intentional accessibility violations. Use it to practice with the agents and see how they catch real issues. See the [example README](example/README.md) for details.

## Contributing

Found a gap? Open an issue or PR. Contributions are welcome. See the [Contributing Guide](CONTRIBUTING.md) for details.

If you find this useful, please star the repo and watch for releases so you know when updates drop.

## Contributors

Thanks to everyone who has contributed to making AI coding tools more accessible.

<a href="https://github.com/taylorarndt/a11y-agent-team/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=taylorarndt/a11y-agent-team" alt="Contributors" />
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

## Also by the Author

**[Swift Agent Team](https://github.com/taylorarndt/swift-agent-team)** — 9 specialized Swift agents for Claude Code. Swift 6.2 concurrency, Apple Foundation Models, on-device AI, SwiftUI, accessibility, security, testing, and App Store compliance.

## License

MIT

## About the Author

Built by [Taylor Arndt](https://github.com/taylorarndt), COO at [Techopolis](https://github.com/techopolis-group). Developer and accessibility specialist. I built this because accessibility is how I work, not something I bolt on at the end. When I found that AI coding tools consistently failed at accessibility, I built the team I wished existed.
