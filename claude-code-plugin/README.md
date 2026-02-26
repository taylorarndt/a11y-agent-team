# Accessibility Agents - Claude Code Plugin

WCAG AA accessibility enforcement for Claude Code. 50 specialist agents + 17 slash commands that activate automatically when you work on web UI code.

## How It Works

Three enforcement layers, zero hooks, zero fragile config:

1. **Agent descriptions** - Claude reads all agent descriptions at startup. When you edit HTML/JSX/CSS or ask about UI, Claude matches to `accessibility-lead` automatically because its description says "Use on EVERY task that involves web UI code..."
2. **CLAUDE.md** - Loads every session. Contains the decision matrix and non-negotiable standards. Cannot break.
3. **Slash commands** - Type `/aria` or `/audit` for direct specialist access. Convenience layer on top of auto-delegation.

## Installation

Run the installer from the project root:

```bash
# Install to your project (recommended)
bash install.sh --project

# Install globally
bash install.sh --global
```

The installer copies agents and commands to your `.claude/` directory:

```
.claude/
  agents/       # 50 agent files (auto-delegation)
  commands/     # 17 slash commands (manual shortcuts)
```

Optionally merges a CLAUDE.md snippet into your project root for rules enforcement.

## Slash Commands

| Command | Agent | What It Does |
|---------|-------|-------------|
| `/aria` | aria-specialist | ARIA patterns - roles, states, properties |
| `/contrast` | contrast-master | Color contrast - ratios, themes, visual design |
| `/keyboard` | keyboard-navigator | Keyboard nav - tab order, focus, shortcuts |
| `/forms` | forms-specialist | Forms - labels, validation, error handling |
| `/alt-text` | alt-text-headings | Images/headings - alt text, hierarchy, landmarks |
| `/tables` | tables-data-specialist | Tables - headers, scope, caption, sorting |
| `/links` | link-checker | Links - ambiguous text detection |
| `/modal` | modal-specialist | Modals - focus trap, return, escape |
| `/live-region` | live-region-controller | Live regions - dynamic announcements |
| `/audit` | web-accessibility-wizard | Full guided web accessibility audit |
| `/document` | document-accessibility-wizard | Document audit - Word, Excel, PPT, PDF |
| `/markdown` | markdown-a11y-assistant | Markdown audit - links, headings, emoji |
| `/test` | testing-coach | Testing - screen reader, keyboard, automated |
| `/wcag` | wcag-guide | WCAG reference - criteria explanations |
| `/cognitive` | cognitive-accessibility | Cognitive a11y - COGA, plain language |
| `/mobile` | mobile-accessibility | Mobile - React Native, touch targets |
| `/design-system` | design-system-auditor | Tokens - contrast, focus rings, spacing |

## Agents (50 total)

### User-Facing Specialists

- **accessibility-lead** - Coordinates all specialists, runs final review on any UI task
- **aria-specialist** - ARIA roles, states, properties for custom widgets
- **contrast-master** - Color contrast, visual design, themes
- **keyboard-navigator** - Tab order, focus management, keyboard interaction
- **forms-specialist** - Form labels, validation, error handling
- **alt-text-headings** - Images, alt text, SVGs, heading structure, landmarks
- **tables-data-specialist** - Data tables, grids, sortable columns
- **link-checker** - Ambiguous link text detection
- **modal-specialist** - Dialogs, drawers, overlays, focus trapping
- **live-region-controller** - Dynamic content updates, toasts, loading states
- **cognitive-accessibility** - WCAG 2.2 cognitive SC, COGA guidance, plain language
- **mobile-accessibility** - React Native, Expo, iOS, Android accessibility
- **design-system-auditor** - Color tokens, focus rings, spacing tokens
- **web-accessibility-wizard** - Full guided web accessibility audit
- **document-accessibility-wizard** - Document audit (Word, Excel, PowerPoint, PDF)
- **markdown-a11y-assistant** - Markdown accessibility audit
- **testing-coach** - Screen reader, keyboard, automated testing guidance
- **wcag-guide** - WCAG 2.2 criteria explanations and conformance

### Document Format Specialists

- **word-accessibility** - DOCX scanning and remediation
- **excel-accessibility** - XLSX scanning and remediation
- **powerpoint-accessibility** - PPTX scanning and remediation
- **pdf-accessibility** - PDF scanning and remediation
- **epub-accessibility** - EPUB scanning and remediation

### GitHub Workflow Agents

- **github-hub** / **nexus** - GitHub command center orchestrators
- **daily-briefing** - Daily GitHub summary
- **issue-tracker** - Issue management
- **pr-review** - Pull request review
- **analytics** - Team metrics and velocity
- **insiders-a11y-tracker** - VS Code accessibility change tracking
- **repo-admin** - Repository settings and access
- **team-manager** - Organization team management
- **contributions-hub** - Community management
- **template-builder** - Issue/PR template wizard
- **repo-manager** - Repository infrastructure scaffolding

### Internal Helpers (auto-invoked by orchestrators)

- **document-inventory** - File discovery and delta detection
- **cross-document-analyzer** - Cross-document pattern detection
- **cross-page-analyzer** - Cross-page web pattern detection
- **web-issue-fixer** - Web accessibility fix application
- **scanner-bridge** - GitHub Accessibility Scanner CI bridge
- **lighthouse-bridge** - Lighthouse CI audit bridge
- **markdown-scanner** - Per-file markdown scanning
- **markdown-fixer** - Markdown fix application
- **markdown-csv-reporter** - Markdown findings CSV export
- **web-csv-reporter** - Web findings CSV export
- **document-csv-reporter** - Document findings CSV export
- **office-scan-config** - Office scan configuration management
- **pdf-scan-config** - PDF scan configuration management
- **epub-scan-config** - EPUB scan configuration management

## Auto-Delegation

You do not need to invoke agents manually for most tasks. Claude reads agent descriptions at startup and delegates automatically:

- **"Build a login form"** - accessibility-lead activates, pulls in forms-specialist + keyboard-navigator + aria-specialist
- **"Review this component for accessibility"** - accessibility-lead runs a full specialist review
- **"Check the contrast on this page"** - contrast-master activates directly
- **"Audit this PDF"** - document-accessibility-wizard activates

Slash commands are available when you want to target a specific specialist directly.

## Updating

```bash
bash update.sh              # Update global install
bash update.sh --project    # Update project install
```

## Uninstalling

```bash
bash uninstall.sh              # Interactive
bash uninstall.sh --global     # Remove global install
bash uninstall.sh --project    # Remove project install
```

## License

MIT
