# Hooks Guide

## The Problem Hooks Solve

Text instructions do not work. CLAUDE.md files, plugin hooks that inject reminders, system prompts that say "you MUST delegate" — LLMs treat all of them as suggestions. In practice, Claude reads the instruction, understands it, and then writes UI code without delegating to the accessibility agents. The user has to manually ask "did you do the accessibility review?" every single time.

This happened consistently across projects. The agents were available. The instructions were clear. Claude just ignored them.

## The Solution: A Three-Hook Enforcement Gate

Instead of telling Claude to use the accessibility agents, we make it impossible to skip them. Three hooks work together as a gate:

```text
User prompt
    |
    v
[1. UserPromptSubmit] — Detects web project, tells Claude to delegate
    |
    v
Claude tries to Edit/Write a .tsx file
    |
    v
[2. PreToolUse] — Checks for session marker. No marker? DENIED.
    |                Claude cannot write to the file.
    |
    v
Claude delegates to accessibility-lead (because it has no other choice)
    |
    v
[3. PostToolUse] — accessibility-lead completes. Marker created.
    |
    v
Claude retries Edit/Write — marker exists — ALLOWED.
```

Claude does not use the accessibility agents because it was told to. It uses them because it literally cannot edit UI files without doing so first.

## Hook 1: Proactive Web Project Detection

**File:** `~/.claude/hooks/a11y-team-eval.sh`
**Event:** `UserPromptSubmit`
**Purpose:** Detect web projects and inject the delegation instruction.

This hook runs on every user prompt. It has two detection modes:

### Proactive mode

Before reading the user's prompt, the hook checks the current working directory for web project indicators:

- `package.json` containing React, Next.js, Vue, Svelte, Astro, Angular, Tailwind, or other web framework dependencies
- Config files like `next.config.js`, `vite.config.ts`, `tailwind.config.js`, `angular.json`
- Files with UI extensions (`.jsx`, `.tsx`, `.vue`, `.svelte`, `.astro`) within three directory levels
- Server-side template files (`.html`, `.ejs`, `.hbs`, `.leaf`, `.erb`, `.jinja`, `.twig`, `.blade.php`)

If any indicator is found, the hook fires on **every prompt** regardless of what the user typed. A prompt like "fix the bug" in a Next.js project triggers the instruction.

### Keyword mode

For directories that are not web projects, the hook falls back to keyword matching. If the user's prompt contains UI-related terms (component, modal, button, voiceover, accessibility, tailwind, etc.), the hook fires.

### Output

When triggered, the hook outputs the delegation instruction as a system reminder. Claude sees it before processing the prompt.

## Hook 2: Edit/Write Gate

**File:** `~/.claude/hooks/a11y-enforce-edit.sh`
**Event:** `PreToolUse` (matcher: `Edit|Write`)
**Purpose:** Block writes to UI files until accessibility review is complete.

This is the enforcement hook. When Claude attempts to Edit or Write a file, this hook:

1. Extracts the `file_path` from the tool input JSON
2. Checks if the file is a UI file based on extension (`.jsx`, `.tsx`, `.vue`, `.svelte`, `.astro`, `.html`, `.css`, `.scss`, `.ejs`, `.hbs`, `.leaf`, `.erb`, `.jinja`, `.twig`, `.blade.php`) or path (files in `components/`, `pages/`, `views/`, `layouts/`, `templates/`)
3. If it is a UI file, checks for the session marker at `/tmp/a11y-reviewed-{session_id}`
4. If the marker exists, allows the edit silently
5. If the marker does not exist, **denies the tool call** with a clear reason

The denial uses the `permissionDecision: "deny"` mechanism:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "BLOCKED: Cannot edit UI file 'user-menu.tsx' without accessibility review..."
  }
}
```

This is not a reminder or suggestion. The Edit/Write tool call is rejected at the hook level. Claude receives the reason as feedback and must delegate to the accessibility-lead before retrying.

Non-UI files (`.ts` in `lib/`, `.json`, `.md`, backend code) are always allowed without review.

## Hook 3: Review Marker

**File:** `~/.claude/hooks/a11y-mark-reviewed.sh`
**Event:** `PostToolUse` (matcher: `Agent`)
**Purpose:** Create the session marker when accessibility-lead completes.

After any Agent tool call completes, this hook checks the `subagent_type` in the tool input. If it contains `accessibility-lead`, the hook creates a marker file:

```
/tmp/a11y-reviewed-{session_id}
```

The session ID comes from the hook's stdin JSON, which includes it automatically. The marker is session-specific — each new Claude Code session requires a fresh accessibility review.

Once the marker exists, Hook 2 allows all UI file edits for the rest of the session.

## Registration

All three hooks are registered in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/you/.claude/hooks/a11y-team-eval.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/you/.claude/hooks/a11y-enforce-edit.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "/Users/you/.claude/hooks/a11y-mark-reviewed.sh"
          }
        ]
      }
    ]
  }
}
```

The installer creates these entries automatically during `--global` installation.

## Why Not an MCP Server

An MCP server was considered as an alternative. MCP servers provide tools that Claude can call, which might seem more reliable than hooks. But the fundamental problem is the same: Claude has to choose to call the tool. An MCP server would add accessibility review as an available tool, but Claude would still skip it just like it skips text instructions.

Hooks solve this because they operate at the infrastructure level. The PreToolUse hook does not ask Claude to do anything. It blocks the Edit/Write tool call at the system level. Claude has no option to skip it.

## Why Not Plugin Hooks

The plugin system supports `hooks.json` inside the plugin package. These hooks fire on every prompt. The problem: plugin hooks can only inject text instructions (system reminders). They cannot block tool calls.

The project originally used plugin hooks to inject the delegation instruction on every prompt. Claude received the instruction and still ignored it. The instruction said "MANDATORY" and "NON-OPTIONAL" and "Do NOT skip this step." Claude skipped it anyway.

Plugin hooks remain available as a fallback reminder layer, but enforcement is handled entirely by the global hooks registered in `~/.claude/settings.json`.

## Troubleshooting

### Hook not firing

Verify the hook is registered:

```bash
cat ~/.claude/settings.json | python3 -m json.tool
```

Check that the hook script exists and is executable:

```bash
ls -la ~/.claude/hooks/a11y-enforce-edit.sh
```

### Edit still blocked after accessibility review

Check that the session marker was created:

```bash
ls /tmp/a11y-reviewed-*
```

If no marker exists, the PostToolUse hook may not have fired. Verify the `Agent` matcher is registered in `settings.json` under `PostToolUse`.

### Non-UI file blocked

The hook checks file extensions and directory paths. If a `.ts` file in `lib/` is being blocked, the path-based check may be matching too broadly. Files in `components/`, `pages/`, `views/`, `layouts/`, and `templates/` directories are treated as UI files even with `.ts`/`.js` extensions. Move non-UI code out of these directories or adjust the hook.

### Testing hooks manually

You can test each hook by piping JSON to stdin:

```bash
# Test PreToolUse — should output deny JSON
echo '{"tool_name":"Edit","tool_input":{"file_path":"/path/to/component.tsx"},"session_id":"test-123"}' | bash ~/.claude/hooks/a11y-enforce-edit.sh

# Create marker
echo '{"tool_name":"Agent","tool_input":{"subagent_type":"accessibility-agents:accessibility-lead"},"session_id":"test-123"}' | bash ~/.claude/hooks/a11y-mark-reviewed.sh

# Test PreToolUse again — should output nothing (allowed)
echo '{"tool_name":"Edit","tool_input":{"file_path":"/path/to/component.tsx"},"session_id":"test-123"}' | bash ~/.claude/hooks/a11y-enforce-edit.sh

# Clean up
rm /tmp/a11y-reviewed-test-123
```
