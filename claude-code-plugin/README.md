# Accessibility Agents - Claude Code Plugin

WCAG AA accessibility enforcement for Claude Code. 50 specialist agents + 17 skills that activate automatically when you work on web UI code.

## How It Works

Five enforcement layers ensure accessibility-lead always activates for UI tasks:

1. **Proactive detection** (`UserPromptSubmit`) — Checks if the current directory is a web project by scanning for `package.json` with web dependencies, framework config files, and UI file extensions. In a web project, the delegation instruction fires on every prompt regardless of what you typed.
2. **Edit gate** (`PreToolUse`) — Hard blocks any Edit/Write to UI files (`.jsx`, `.tsx`, `.vue`, `.css`, `.html`, etc.) until the accessibility-lead agent has been consulted. Uses `permissionDecision: "deny"` to reject the tool call entirely. Not a reminder. A block.
3. **Session marker** (`PostToolUse`) — When the accessibility-lead agent completes, creates a session marker that unlocks the edit gate for the rest of the session.
4. **Agent tools** — accessibility-lead has `Task, Read, Glob, Grep` only. It MUST delegate to specialists via the Task tool. It cannot write code itself.
5. **CLAUDE.md + Skills** — Decision matrix and non-negotiable standards load every session. Skills (`/aria`, `/audit`, etc.) provide direct specialist access.

See the [Hooks Guide](../docs/hooks-guide.md) for the full technical breakdown of why hooks were chosen over instructions, MCP, or plugin hooks alone.

## Installation

Run the installer from the project root:

```bash
# Install to your project (recommended)
bash install.sh --project

# Install globally
bash install.sh --global
```

The installer copies agents and skills to your `.claude/` directory:

```
.claude/
  agents/       # 50 agent files (auto-delegation)
  skills/       # 17 skills (manual shortcuts)
```

Optionally merges a CLAUDE.md snippet into your project root for rules enforcement.

## Skills

| Skill | Agent | What It Does |
|-------|-------|-------------|
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

Skills are available when you want to target a specific specialist directly.

## Verifying Enforcement

After installing, verify the enforcement gate is working:

### Check proactive detection

1. Start Claude Code in any web project (has `package.json` with React/Next/Vue/etc.)
2. Type any prompt — even something generic like "fix the bug"
3. You should see the accessibility instruction in the system reminder: `DETECTED: This is a web project`

### Check edit gate

1. Ask Claude to create or edit a `.tsx` file without first running the accessibility-lead
2. The Edit/Write should be **denied** with the message: `BLOCKED: Cannot edit UI file...`
3. Claude should then delegate to accessibility-lead
4. After the review completes, Claude should retry the edit successfully

### Check agent tools

Run `/agents` in Claude Code. The `accessibility-lead` agent should show tools: `Task, Read, Glob, Grep` (no Write, Edit, or Bash). This forces it to delegate via the Task tool.

### Troubleshooting

- **Agents not loading:** Restart Claude Code. Check `~/.claude/plugins/installed_plugins.json` for the `accessibility-agents` entry.
- **Edit not blocked:** Check `~/.claude/settings.json` has the `a11y-enforce-edit.sh` hook registered under `PreToolUse`. Verify the script is executable: `chmod +x ~/.claude/hooks/a11y-enforce-edit.sh`.
- **Edit blocked even after review:** Check the session marker: `ls /tmp/a11y-reviewed-*`. If missing, verify `a11y-mark-reviewed.sh` is registered under `PostToolUse` with matcher `Agent`.
- **Hooks not firing at all:** Verify `~/.claude/settings.json` has all three hooks registered. Run `cat ~/.claude/hooks/a11y-team-eval.sh` to verify scripts exist.
- **Wrong agent invoked:** All agents use kebab-case names (e.g., `accessibility-lead`, not `Accessibility Lead`). Internal helpers are prefixed with "Internal helper agent." in their descriptions to prevent accidental routing.
- **accessibility-lead writes code directly:** Verify its tools are `Task, Read, Glob, Grep`. If it has `Write` or `Edit`, the plugin cache may be stale. Reinstall with `bash install.sh --global`.

See the [Hooks Guide](../docs/hooks-guide.md) for detailed testing commands and manual debugging steps.

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
