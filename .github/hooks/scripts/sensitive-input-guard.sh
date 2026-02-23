#!/usr/bin/env bash
# sensitive-input-guard.sh
# UserPromptSubmit hook — detects accidental credential/secret exposure in prompts.

set -euo pipefail

input_json=$(cat)
prompt=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null || echo "")

block() {
  local label="$1"
  python3 -c "
import json
print(json.dumps({
  'continue': False,
  'stopReason': 'Potential credential detected in prompt',
  'systemMessage': 'SECURITY: Your prompt appears to contain a ${label}. This has been blocked to prevent accidental secret exposure. Please remove the credential and try again. Never paste secrets or tokens directly into the chat.'
}))
"
  exit 2
}

# GitHub tokens
echo "$prompt" | grep -qP 'ghp_[A-Za-z0-9]{36,}'           && block "GitHub Personal Access Token (ghp_...)"
echo "$prompt" | grep -qP 'gho_[A-Za-z0-9]{36,}'           && block "GitHub OAuth token (gho_...)"
echo "$prompt" | grep -qP 'github_pat_[A-Za-z0-9_]{80,}'   && block "GitHub fine-grained PAT"
# OpenAI
echo "$prompt" | grep -qP 'sk-[A-Za-z0-9]{40,}'            && block "OpenAI API key"
# AWS
echo "$prompt" | grep -qP 'AKIA[A-Z0-9]{16}'               && block "AWS Access Key ID"
# Private keys
echo "$prompt" | grep -q 'BEGIN.*PRIVATE KEY'               && block "private key / certificate"
# Slack
echo "$prompt" | grep -qP 'xox[baprs]-[0-9A-Za-z-]+'       && block "Slack token"

echo '{"continue":true}'
exit 0
