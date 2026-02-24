#!/bin/bash
# A11y Agent Team - Forced evaluation hook
# https://github.com/community-access/accessibility-agents
#
# Place in .claude/hooks/ and reference from .claude/settings.json
# Fires on every UserPromptSubmit to ensure the accessibility-lead
# agent is considered for any UI-related work.

message="INSTRUCTION: MANDATORY ACCESSIBILITY CHECK\nBefore proceeding with any task involving web UI code, HTML, JSX, CSS,\nReact components, Tailwind classes, web pages, forms, modals, or any\nuser-facing web content:\n\n1. Delegate to the accessibility-lead agent\n2. The accessibility-lead will determine which specialist agents are needed\n3. Specialists: aria-specialist, modal-specialist, contrast-master,\n   keyboard-navigator, live-region-controller, forms-specialist,\n   alt-text-headings, tables-data-specialist, link-checker\n4. For a full guided audit, use accessibility-wizard\n5. For testing guidance, use testing-coach. For WCAG questions, use wcag-guide.\n6. For markdown documentation accessibility (.md files), use markdown-a11y-assistant\n7. Do NOT write UI code without accessibility-lead review\n\nIf the task does not involve any user-facing web content or markdown docs, proceed normally."

printf '{"continue":true,"additionalContext":"%s"}\n' "$message"
