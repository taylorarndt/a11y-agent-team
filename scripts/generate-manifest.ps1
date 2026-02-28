# Generate the canonical agent manifest from the repository source tree.
# Run this before every release or as a pre-commit hook to keep the manifest
# in sync with added/removed agent files.
#
# Usage:
#   powershell -File scripts\generate-manifest.ps1          # prints to stdout
#   powershell -File scripts\generate-manifest.ps1 -Write   # writes .a11y-agent-manifest

param([switch]$Write)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$Lines = [System.Collections.Generic.List[string]]::new()

# Claude Code agents (.claude\agents\*.md)
Get-ChildItem -Path (Join-Path $RepoRoot ".claude\agents") -Filter "*.md" -ErrorAction SilentlyContinue |
    Sort-Object Name | ForEach-Object { $Lines.Add("agents/$($_.Name)") }

# Copilot agents (.github\agents\*.agent.md)
Get-ChildItem -Path (Join-Path $RepoRoot ".github\agents") -Filter "*.agent.md" -ErrorAction SilentlyContinue |
    Sort-Object Name | ForEach-Object { $Lines.Add("copilot-agents/$($_.Name)") }

# Copilot config files (.github\copilot-*.md)
Get-ChildItem -Path (Join-Path $RepoRoot ".github") -Filter "copilot-*.md" -ErrorAction SilentlyContinue |
    Sort-Object Name | ForEach-Object { $Lines.Add("copilot-config/$($_.Name)") }

# Copilot instructions (.github\instructions\*.instructions.md)
$InstructionsDir = Join-Path $RepoRoot ".github\instructions"
if (Test-Path $InstructionsDir) {
    Get-ChildItem -Path $InstructionsDir -Filter "*.instructions.md" -Recurse |
        Sort-Object FullName | ForEach-Object {
            $rel = $_.FullName.Substring($InstructionsDir.Length).TrimStart('\').Replace('\','/')
            $Lines.Add("copilot-instructions/$rel")
        }
}

# Copilot skills (.github\skills\*\SKILL.md)
$SkillsDir = Join-Path $RepoRoot ".github\skills"
if (Test-Path $SkillsDir) {
    Get-ChildItem -Path $SkillsDir -Filter "SKILL.md" -Recurse |
        Sort-Object FullName | ForEach-Object {
            $rel = $_.FullName.Substring($SkillsDir.Length).TrimStart('\').Replace('\','/')
            $Lines.Add("copilot-skills/$rel")
        }
}

# Copilot prompts (.github\prompts\*.prompt.md)
$PromptsDir = Join-Path $RepoRoot ".github\prompts"
if (Test-Path $PromptsDir) {
    Get-ChildItem -Path $PromptsDir -Filter "*.prompt.md" -Recurse |
        Sort-Object FullName | ForEach-Object {
            $rel = $_.FullName.Substring($PromptsDir.Length).TrimStart('\').Replace('\','/')
            $Lines.Add("copilot-prompts/$rel")
        }
}

# Codex CLI (.codex\AGENTS.md)
if (Test-Path (Join-Path $RepoRoot ".codex\AGENTS.md")) {
    $Lines.Add("codex/AGENTS.md")
}

# Gemini CLI extension (.gemini\extensions\a11y-agents\**)
$GeminiDir = Join-Path $RepoRoot ".gemini\extensions\a11y-agents"
if (Test-Path $GeminiDir) {
    Get-ChildItem -Path $GeminiDir -File -Recurse |
        Sort-Object FullName | ForEach-Object {
            $rel = $_.FullName.Substring($GeminiDir.Length).TrimStart('\').Replace('\','/')
            $Lines.Add("gemini/$rel")
        }
}

# Sort and deduplicate
$Sorted = $Lines | Sort-Object -Unique

if ($Write) {
    $ManifestPath = Join-Path $RepoRoot ".a11y-agent-manifest"
    [IO.File]::WriteAllLines($ManifestPath, $Sorted, [Text.Encoding]::UTF8)
    Write-Host "Wrote .a11y-agent-manifest ($($Sorted.Count) entries)"
} else {
    $Sorted | ForEach-Object { Write-Output $_ }
}
