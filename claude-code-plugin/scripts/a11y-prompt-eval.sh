#!/bin/bash
# A11y Agent Team - UserPromptSubmit hook
# Injects accessibility-lead instruction into every prompt.

cat <<'EOF'
{"additionalContext":"INSTRUCTION: MANDATORY ACCESSIBILITY CHECK\nBefore proceeding with any task involving web UI code, HTML, JSX, CSS, React components, Tailwind classes, web pages, forms, modals, or any user-facing web content:\n\n1. Delegate to the accessibility-lead agent\n2. The accessibility-lead will determine which specialist agents are needed\n3. Do NOT write UI code without accessibility-lead review\n\nIf the task does not involve any user-facing web content, proceed normally."}
EOF
