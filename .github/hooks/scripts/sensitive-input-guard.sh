#!/usr/bin/env bash
# sensitive-input-guard.sh
# UserPromptSubmit hook — detects accidental credential/secret exposure in prompts.

input_json=$(cat)
prompt=$(echo "$input_json" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('prompt',''))" 2>/dev/null || echo "")

block() {
  local label="$1"
  python3 -c "
import json
print(json.dumps({
  'continue': False,
  'hookSpecificOutput': {
    'hookEventName': 'UserPromptSubmit',
    'additionalContext': 'SECURITY: Your prompt appears to contain a ${label}. This has been blocked to prevent accidental secret exposure. Please remove the credential and try again. Never paste secrets or tokens directly into the chat.'
  }
}))
"
  exit 2
}

# GitHub tokens (grep -E for macOS compatibility — no grep -P)
echo "$prompt" | grep -qE 'ghp_[A-Za-z0-9]{36,}'           && block "GitHub Personal Access Token (ghp_...)"
echo "$prompt" | grep -qE 'gho_[A-Za-z0-9]{36,}'           && block "GitHub OAuth token (gho_...)"
echo "$prompt" | grep -qE 'github_pat_[A-Za-z0-9_]{80,}'   && block "GitHub fine-grained PAT"
echo "$prompt" | grep -qE 'ghsr_[A-Za-z0-9]{36,}'           && block "GitHub secret scanning token"
# OpenAI / Anthropic
echo "$prompt" | grep -qE 'sk-[A-Za-z0-9]{40,}'            && block "OpenAI API key"
echo "$prompt" | grep -qE 'sk-ant-api03-[A-Za-z0-9_-]{93,}' && block "Anthropic API key"
# AWS
echo "$prompt" | grep -qE 'AKIA[A-Z0-9]{16}'               && block "AWS Access Key ID"
# Google
echo "$prompt" | grep -qE 'AIza[0-9A-Za-z_-]{35}'          && block "Google API key"
# Stripe
echo "$prompt" | grep -qE 'sk_(live|test)_[A-Za-z0-9]{24,}' && block "Stripe secret key"
# Azure SAS token / Storage connection string
echo "$prompt" | grep -qE 'sig=[A-Za-z0-9%+/]{43,}'        && block "Azure SAS token"
echo "$prompt" | grep -qE 'AccountKey=[A-Za-z0-9+/]{80,}==' && block "Azure Storage account key"
# Private keys
echo "$prompt" | grep -q 'BEGIN.*PRIVATE KEY'               && block "private key / certificate"
# Slack
echo "$prompt" | grep -qE 'xox[baprs]-[0-9A-Za-z-]+'       && block "Slack token"

echo '{"continue":true,"hookSpecificOutput":{"hookEventName":"UserPromptSubmit"}}'
exit 0
