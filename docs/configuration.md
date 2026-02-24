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

## Troubleshooting

### Agents not appearing (Claude Code)

Type `/agents` to see what is loaded. If agents do not appear:

1. **Check file location:** Agents must be `.md` files in `.claude/agents/` (project) or `~/.claude/agents/` (global)
2. **Check file format:** Each file must start with YAML front matter (`---` delimiters) containing `name`, `description`, and `tools`
3. **Check character budget:** Increase `SLASH_COMMAND_TOOL_CHAR_BUDGET` (see above)

### Extension not working (Claude Desktop)

1. **Check installation:** Settings > Extensions in Claude Desktop
2. **Try reinstalling:** Download latest .mcpb from Releases page
3. **Check version:** Requires Claude Desktop 0.10.0 or later

### Agents seem to miss things

1. Invoke the specific specialist directly: `/aria-specialist review components/modal.tsx`
2. Ask for a full audit: `/accessibility-lead audit the entire checkout flow`
3. Open an issue if a pattern is consistently missed
