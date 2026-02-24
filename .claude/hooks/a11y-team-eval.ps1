# A11y Agent Team - Forced evaluation hook (Windows PowerShell)
# https://github.com/community-access/accessibility-agents
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Place in .claude\hooks\ and reference from .claude\settings.json
# Fires on every UserPromptSubmit to ensure the accessibility-lead
# agent is considered for any UI-related work.

$message = @"
INSTRUCTION: MANDATORY ACCESSIBILITY CHECK
Before proceeding with any task involving web UI code, HTML, JSX, CSS,
React components, Tailwind classes, web pages, forms, modals, or any
user-facing web content:

1. Delegate to the accessibility-lead agent
2. The accessibility-lead will determine which specialist agents are needed
3. Specialists: aria-specialist, modal-specialist, contrast-master,
   keyboard-navigator, live-region-controller, forms-specialist,
   alt-text-headings, tables-data-specialist, link-checker
4. For a full guided audit, use accessibility-wizard
5. For testing guidance, use testing-coach. For WCAG questions, use wcag-guide.
6. For markdown documentation accessibility (.md files), use markdown-a11y-assistant
7. Do NOT write UI code without accessibility-lead review

If the task does not involve any user-facing web content or markdown docs, proceed normally.
"@

@{ continue = $true; additionalContext = $message } | ConvertTo-Json -Compress
