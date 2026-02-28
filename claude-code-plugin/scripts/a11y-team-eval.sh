#!/bin/bash
# Accessibility Agents - Global prompt evaluation hook
# Two detection modes:
#   1. PROACTIVE: Detects if the current directory is a web project (has UI files)
#      and ALWAYS injects the instruction regardless of what the user typed.
#   2. KEYWORD: Falls back to keyword matching for non-web projects where the
#      user might still be doing UI-related work.
# Installed by: accessibility-agents install.sh

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('prompt','').lower())" 2>/dev/null || echo "")

# ── PROACTIVE DETECTION ──
# Check if the current working directory is a web project by looking for
# common web project indicators. If ANY of these exist, this is a web
# project and the accessibility agents should ALWAYS be available.
IS_WEB_PROJECT=false

# Package.json with web framework dependencies
if [ -f "package.json" ]; then
  if grep -qiE '"(react|next|vue|nuxt|svelte|sveltekit|astro|angular|gatsby|remix|solid|qwik|vite|webpack|parcel|tailwindcss|@emotion|styled-components|sass|less)"' package.json 2>/dev/null; then
    IS_WEB_PROJECT=true
  fi
fi

# Common web project config files
if [ "$IS_WEB_PROJECT" = false ]; then
  for f in next.config.js next.config.mjs next.config.ts nuxt.config.ts vite.config.ts vite.config.js svelte.config.js astro.config.mjs angular.json tailwind.config.js tailwind.config.ts postcss.config.js postcss.config.mjs tsconfig.json; do
    if [ -f "$f" ]; then
      IS_WEB_PROJECT=true
      break
    fi
  done
fi

# Has src/ or app/ with UI file extensions
if [ "$IS_WEB_PROJECT" = false ]; then
  if find . -maxdepth 3 -type f \( -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.svelte" -o -name "*.astro" \) -print -quit 2>/dev/null | grep -q .; then
    IS_WEB_PROJECT=true
  fi
fi

# Has HTML templates (server-side rendering)
if [ "$IS_WEB_PROJECT" = false ]; then
  if find . -maxdepth 3 -type f \( -name "*.html" -o -name "*.ejs" -o -name "*.hbs" -o -name "*.leaf" -o -name "*.erb" -o -name "*.jinja" -o -name "*.twig" -o -name "*.blade.php" \) -print -quit 2>/dev/null | grep -q .; then
    IS_WEB_PROJECT=true
  fi
fi

# ── KEYWORD DETECTION ──
# For non-web projects, still catch UI-related prompts
KEYWORDS="html|jsx|tsx|css|tailwind|react|next\.?js|vue|svelte|astro|angular|component|widget|form|modal|dialog|popover|drawer|toast|notification|aria|wcag|a11y|accessibility|accessible|contrast|focus|keyboard|tab order|tabindex|screen ?reader|voiceover|nvda|jaws|talkback|heading|alt text|alt=|landmark|template|leaf|ejs|erb|hbs|jinja|twig|blade|vapor|render|view|page|button|input|select|checkbox|radio|label|dropdown|menu|accordion|carousel|slider|tooltip|card|sidebar|navbar|layout|grid|flex|responsive|theme|dark mode|color|style|font|image|img|svg|icon|video|audio|link|href|navigation|breadcrumb|pagination|loading|spinner|progress|alert|banner|role=|tabpanel|tablist|listbox|combobox|live region|aria-live|aria-label|aria-hidden|sr-only|visually-hidden|skip link|ui|ux|front.?end|client.?side|browser|dom|hydrat|ssr|ssg|not announcing|not reading|not saying|cannot hear|broken announce|announce"
KEYWORD_MATCH=false
if echo "$PROMPT" | grep -qiE "$KEYWORDS"; then
  KEYWORD_MATCH=true
fi

# ── OUTPUT ──
if [ "$IS_WEB_PROJECT" = true ] || [ "$KEYWORD_MATCH" = true ]; then
  if [ "$IS_WEB_PROJECT" = true ]; then
    PROJECT_NOTE="DETECTED: This is a web project. Accessibility agents are ALWAYS required here."
  else
    PROJECT_NOTE="DETECTED: UI-related keywords found in prompt."
  fi

  cat <<HOOK_OUTPUT
INSTRUCTION: MANDATORY ACCESSIBILITY CHECK — YOU MUST FOLLOW THIS
${PROJECT_NOTE}

This is a NON-OPTIONAL instruction. You MUST use the accessibility agents
for ANY task in this project that touches user-facing code. This is proactive —
do not wait for the user to ask. If there is ANY chance the task involves UI,
delegate to the accessibility-lead FIRST.

REQUIRED ACTIONS:
1. Use the Agent tool to delegate to accessibility-agents:accessibility-lead
   (subagent_type: "accessibility-agents:accessibility-lead")
2. The accessibility-lead will coordinate specialist agents as needed
3. Do NOT write or edit UI code without accessibility-lead review FIRST
4. Do NOT skip this step even if you think you can handle it yourself
5. Be PROACTIVE: if the user asks to fix a bug, add a feature, or change
   anything in a web project, assume it involves UI until proven otherwise

This applies to ALL web projects, not just the accessibility-agents repo.

CROSS-TEAM COORDINATION:
- Swift/iOS code -> swift-agent-team:swift-lead handles Swift
- HTML/templates/components -> accessibility-agents:accessibility-lead handles web
- Both leads can run in parallel via separate Agent tool calls.
HOOK_OUTPUT
fi
