#!/usr/bin/env pwsh
# sensitive-input-guard.ps1
# UserPromptSubmit hook — detects accidental credential/secret exposure in prompts
# and blocks the request before the agent processes it.

$input_json = $input | Out-String
try {
    $payload = $input_json | ConvertFrom-Json
} catch {
    @{ continue = $true; hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit' } } | ConvertTo-Json -Compress
    exit 0
}

$prompt = $payload.prompt ?? ""

# ─── Patterns that look like real credentials ─────────────────────────────────
$secret_patterns = @(
    @{ pattern = "ghp_[A-Za-z0-9]{36,}";           label = "GitHub Personal Access Token (ghp_...)" },
    @{ pattern = "gho_[A-Za-z0-9]{36,}";           label = "GitHub OAuth token (gho_...)" },
    @{ pattern = "github_pat_[A-Za-z0-9_]{80,}";   label = "GitHub fine-grained PAT (github_pat_...)" },
    @{ pattern = "ghsr_[A-Za-z0-9]{36,}";          label = "GitHub secret scanning token" },
    @{ pattern = "sk-[A-Za-z0-9]{40,}";            label = "OpenAI API key (sk-...)" },
    @{ pattern = "AKIA[A-Z0-9]{16}";               label = "AWS Access Key ID" },
    @{ pattern = "-----BEGIN (RSA |EC )?PRIVATE KEY-----"; label = "Private key / certificate" },
    @{ pattern = "xox[baprs]-[0-9A-Za-z-]+";       label = "Slack token" },
    @{ pattern = "AIza[0-9A-Za-z\-_]{35}";         label = "Google API key" }
)

foreach ($entry in $secret_patterns) {
    if ($prompt -match $entry.pattern) {
        @{
            continue    = $false
            stopReason  = "Potential credential detected in prompt"
            systemMessage = "SECURITY: Your prompt appears to contain a $($entry.label). This has been blocked to prevent accidental secret exposure. Please remove the credential and try again. Never paste secrets or tokens directly into the chat."
        } | ConvertTo-Json -Compress
        exit 2
    }
}

# ─── Safe — allow through ─────────────────────────────────────────────────────
@{ continue = $true; hookSpecificOutput = @{ hookEventName = 'UserPromptSubmit' } } | ConvertTo-Json -Compress
exit 0
