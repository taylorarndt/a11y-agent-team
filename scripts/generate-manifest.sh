#!/bin/bash
# Generate the canonical agent manifest from the repository source tree.
# Run this before every release or as a pre-commit hook to keep the manifest
# in sync with added/removed agent files.
#
# Usage:
#   bash scripts/generate-manifest.sh          # prints to stdout
#   bash scripts/generate-manifest.sh --write  # writes .a11y-agent-manifest

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
MANIFEST=""

# Claude Code agents (.claude/agents/*.md)
for f in "$SCRIPT_DIR"/.claude/agents/*.md; do
  [ -f "$f" ] || continue
  MANIFEST+="agents/$(basename "$f")"$'\n'
done

# Copilot agents (.github/agents/*.agent.md)
for f in "$SCRIPT_DIR"/.github/agents/*.agent.md; do
  [ -f "$f" ] || continue
  MANIFEST+="copilot-agents/$(basename "$f")"$'\n'
done

# Copilot config files (.github/copilot-*.md)
for f in "$SCRIPT_DIR"/.github/copilot-*.md; do
  [ -f "$f" ] || continue
  MANIFEST+="copilot-config/$(basename "$f")"$'\n'
done

# Copilot instructions (.github/instructions/*.instructions.md)
if [ -d "$SCRIPT_DIR/.github/instructions" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#$SCRIPT_DIR/.github/instructions/}"
    MANIFEST+="copilot-instructions/$rel"$'\n'
  done < <(find "$SCRIPT_DIR/.github/instructions" -type f -name "*.instructions.md" -print0 | sort -z)
fi

# Copilot skills (.github/skills/*/SKILL.md)
if [ -d "$SCRIPT_DIR/.github/skills" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#$SCRIPT_DIR/.github/skills/}"
    MANIFEST+="copilot-skills/$rel"$'\n'
  done < <(find "$SCRIPT_DIR/.github/skills" -type f -name "SKILL.md" -print0 | sort -z)
fi

# Copilot prompts (.github/prompts/*.prompt.md)
if [ -d "$SCRIPT_DIR/.github/prompts" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#$SCRIPT_DIR/.github/prompts/}"
    MANIFEST+="copilot-prompts/$rel"$'\n'
  done < <(find "$SCRIPT_DIR/.github/prompts" -type f -name "*.prompt.md" -print0 | sort -z)
fi

# Codex CLI (.codex/AGENTS.md)
if [ -f "$SCRIPT_DIR/.codex/AGENTS.md" ]; then
  MANIFEST+="codex/AGENTS.md"$'\n'
fi

# Gemini CLI extension (.gemini/extensions/a11y-agents/**)
if [ -d "$SCRIPT_DIR/.gemini/extensions/a11y-agents" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#$SCRIPT_DIR/.gemini/extensions/a11y-agents/}"
    MANIFEST+="gemini/$rel"$'\n'
  done < <(find "$SCRIPT_DIR/.gemini/extensions/a11y-agents" -type f -print0 | sort -z)
fi

# Sort and deduplicate
MANIFEST="$(echo "$MANIFEST" | sort -u | sed '/^$/d')"

if [ "$1" = "--write" ]; then
  echo "$MANIFEST" > "$SCRIPT_DIR/.a11y-agent-manifest"
  echo "Wrote .a11y-agent-manifest ($(echo "$MANIFEST" | wc -l | tr -d ' ') entries)"
else
  echo "$MANIFEST"
fi
