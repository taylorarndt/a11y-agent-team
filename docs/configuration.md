# Configuration

## Character Budget (Claude Code only)

If you have many agents or skills installed, you may hit Claude Code's description character limit (defaults to 15,000 characters). Agents will silently stop loading. Increase the budget:

**macOS/Linux:**

```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=30000
```

Add to `~/.bashrc`, `~/.zshrc`, or your shell profile.

**Windows (PowerShell):**

```powershell
$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = "30000"
```

Add to your PowerShell profile (`$PROFILE`).

## Disabling the Hook Temporarily (Claude Code only)

Remove or comment out the `UserPromptSubmit` entry in your `settings.json`. Agents remain available for direct invocation with `/agent-name`.

## Troubleshooting

### Agents not appearing (Claude Code)

Type `/agents` to see what is loaded. If agents do not appear:

1. **Check file location:** Agents must be `.md` files in `.claude/agents/` (project) or `~/.claude/agents/` (global)
2. **Check file format:** Each file must start with YAML front matter (`---` delimiters) containing `name`, `description`, and `tools`
3. **Check character budget:** Increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` (see above)

### Hook not firing (Claude Code)

1. **Check settings.json:** Hook must be under `hooks` > `UserPromptSubmit`
2. **Check hook path:** Project install uses relative path; global install needs absolute path
3. **Check permissions (macOS/Linux):** `chmod +x .claude/hooks/a11y-team-eval.sh`
4. **Check PowerShell policy (Windows):** `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

### Extension not working (Claude Desktop)

1. **Check installation:** Settings > Extensions in Claude Desktop
2. **Try reinstalling:** Download latest .mcpb from Releases page
3. **Check version:** Requires Claude Desktop 0.10.0 or later

### Agents activate on non-UI tasks (Claude Code)

The hook fires on every prompt and checks for UI relevance. This is harmless - the agent determines no UI work is needed and lets Claude proceed. Remove the hook if it becomes disruptive.

### Agents seem to miss things

1. Invoke the specific specialist directly: `/aria-specialist review components/modal.tsx`
2. Ask for a full audit: `/accessibility-lead audit the entire checkout flow`
3. Open an issue if a pattern is consistently missed
