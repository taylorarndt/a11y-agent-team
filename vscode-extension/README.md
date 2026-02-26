# A11y Agent Team -- VS Code Chat Participant

A VS Code extension that registers an `@a11y` chat participant in GitHub Copilot Chat, giving you instant access to 17 accessibility specialists via slash commands.

## How it works

Type `@a11y` in Copilot Chat to talk to the Accessibility Lead. Add a slash command to route to a specific specialist:

| Command | Specialist | What it covers |
|---------|-----------|---------------|
| `/aria` | ARIA Specialist | Roles, states, properties for custom widgets |
| `/contrast` | Contrast Master | Color ratios, theme review, WCAG AA compliance |
| `/keyboard` | Keyboard Navigator | Tab order, focus management, shortcuts, skip links |
| `/forms` | Forms Specialist | Labels, validation, error handling, autocomplete |
| `/alt-text` | Alt Text and Headings | Alt text, heading hierarchy, landmarks, SVGs |
| `/tables` | Tables Specialist | Headers, scope, caption, sortable columns |
| `/links` | Link Checker | Ambiguous link text detection, link purpose |
| `/modal` | Modal Specialist | Focus trap, return, escape, screen reader announcements |
| `/live-region` | Live Region Controller | Dynamic content announcements, status updates |
| `/audit` | Web Accessibility Wizard | Full WCAG audit with prioritized report |
| `/document` | Document Accessibility Wizard | Word, Excel, PowerPoint, PDF scanning |
| `/markdown` | Markdown Accessibility | Links, alt text, headings, tables, emoji |
| `/test` | Testing Coach | Screen reader, keyboard, and automated testing guidance |
| `/wcag` | WCAG Guide | Success criteria explanations and conformance levels |
| `/cognitive` | Cognitive Accessibility | Plain language, COGA guidance, auth patterns |
| `/mobile` | Mobile Accessibility | React Native, touch targets, screen readers |
| `/design-system` | Design System Auditor | Token contrast, focus rings, spacing, motion |

### Examples

```
@a11y review this component for accessibility issues
@a11y /aria check my tab panel implementation
@a11y /contrast are these colors AA compliant? #1a1a2e on #e0e0e0
@a11y /keyboard audit the focus order of this page
@a11y /forms review my login form
```

## Prerequisites

- VS Code 1.99 or later (Insiders recommended for latest Chat API)
- GitHub Copilot extension installed and signed in
- This repository cloned and open as a workspace folder (the extension reads agent instructions from `.github/agents/`)

## Testing the extension locally

### 1. Install dependencies

```bash
cd vscode-extension
npm install
```

### 2. Compile TypeScript

```bash
npm run compile
```

Or start the watch compiler for iterative development:

```bash
npm run watch
```

### 3. Launch the Extension Development Host

Open the `vscode-extension` folder in VS Code, then press **F5** (or **Run > Start Debugging**). This launches a second VS Code window -- the Extension Development Host -- with the extension loaded.

If there is no launch configuration yet, VS Code will prompt you to select an environment. Choose **VS Code Extension Development**. Or create `.vscode/launch.json` manually:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "args": [
        "--extensionDevelopmentPath=${workspaceFolder}"
      ]
    }
  ]
}
```

### 4. Test in the Extension Development Host

1. In the new window, open the **accessibility-agents** repo as a workspace folder (so the extension can find `.github/agents/`).
2. Open Copilot Chat (**Ctrl+Shift+I** or **Cmd+Shift+I**).
3. Type `@a11y` -- you should see the participant appear with its icon.
4. Try a slash command: `@a11y /aria check my custom combobox`.
5. Verify the specialist context is loaded (the response should reflect the specialist's domain knowledge, not generic advice).

### 5. Package as a VSIX (optional)

To share the extension without publishing to the Marketplace:

```bash
npm run package
```

This produces a `.vsix` file you can install via **Extensions > Install from VSIX** in any VS Code instance.

## Project structure

```
vscode-extension/
  package.json          # Extension manifest with chat participant and slash commands
  tsconfig.json         # TypeScript config
  src/
    extension.ts        # Chat participant handler, agent file loading, LLM routing
  out/                  # Compiled JS (git-ignored)
```

## How routing works

1. The extension registers a single `@a11y` chat participant with 17 slash commands.
2. When a user types `@a11y /contrast ...`, the handler maps `/contrast` to the `contrast-master.agent.md` file.
3. The agent file body (everything after the YAML frontmatter) is loaded as the system prompt.
4. The system prompt plus the user's message are sent to the Copilot language model.
5. The streamed response is rendered in the chat panel.

When no slash command is given, the **Accessibility Lead** agent is used as the default coordinator.

## License

MIT
