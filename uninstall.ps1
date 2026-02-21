# A11y Agent Team Uninstaller (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt

$ErrorActionPreference = "Stop"

# Auto-detect installed agents rather than using a hardcoded list

Write-Host ""
Write-Host "  A11y Agent Team Uninstaller"
Write-Host "  ==========================="
Write-Host ""
Write-Host "  Where would you like to uninstall from?"
Write-Host ""
Write-Host "  1) Project   - Remove from .claude\ in the current directory"
Write-Host "  2) Global    - Remove from ~\.claude\"
Write-Host ""
$Choice = Read-Host "  Choose [1/2]"

switch ($Choice) {
    "1" {
        $TargetDir = Join-Path (Get-Location) ".claude"
        Write-Host ""
        Write-Host "  Uninstalling from project: $(Get-Location)"
    }
    "2" {
        $TargetDir = Join-Path $env:USERPROFILE ".claude"
        Write-Host ""
        Write-Host "  Uninstalling from: $TargetDir"
    }
    default {
        Write-Host "  Invalid choice. Exiting."
        exit 1
    }
}

Write-Host ""
Write-Host "  Removing agents..."
$AgentsDir = Join-Path $TargetDir "agents"
if (Test-Path $AgentsDir) {
    foreach ($File in Get-ChildItem -Path $AgentsDir -Filter "*.md" -ErrorAction SilentlyContinue) {
        Remove-Item -Path $File.FullName -Force
        Write-Host "    - $($File.BaseName)"
    }
}

Write-Host ""
Write-Host "  Removing hook..."
$HookPath = Join-Path $TargetDir "hooks\a11y-team-eval.ps1"
if (Test-Path $HookPath) {
    Remove-Item -Path $HookPath -Force
    Write-Host "    - a11y-team-eval.ps1"
}

# Remove Copilot agents if installed (project uninstall only)
if ($Choice -eq "1") {
    $CopilotDir = Join-Path (Get-Location) ".github\agents"
    if (Test-Path $CopilotDir) {
        Write-Host ""
        Write-Host "  Removing Copilot agents..."
        foreach ($File in Get-ChildItem -Path $CopilotDir -Filter "*.agent.md" -ErrorAction SilentlyContinue) {
            Remove-Item -Path $File.FullName -Force
            Write-Host "    - $($File.BaseName)"
        }
        if ((Get-ChildItem -Path $CopilotDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
            Remove-Item -Path $CopilotDir -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove Copilot config files
    $GithubDir = Join-Path (Get-Location) ".github"
    foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
        $ConfigPath = Join-Path $GithubDir $Config
        if (Test-Path $ConfigPath) {
            Remove-Item -Path $ConfigPath -Force
            Write-Host "    - $Config"
        }
    }
}

# Remove Copilot agents from VS Code profile folders (global uninstall only)
if ($Choice -eq "2") {
    $VSCodeProfiles = @(
        (Join-Path $env:APPDATA "Code\User"),
        (Join-Path $env:APPDATA "Code - Insiders\User")
    )

    foreach ($ProfileDir in $VSCodeProfiles) {
        $AgentFiles = Get-ChildItem -Path $ProfileDir -Filter "*.agent.md" -ErrorAction SilentlyContinue
        if ($AgentFiles.Count -gt 0) {
            Write-Host ""
            Write-Host "  Removing Copilot agents from VS Code profile: $ProfileDir"
            foreach ($File in $AgentFiles) {
                Remove-Item -Path $File.FullName -Force
                Write-Host "    - $($File.BaseName)"
            }
        }
    }

    # Remove central Copilot store
    $CopilotCentral = Join-Path $env:USERPROFILE ".a11y-agent-team"
    if (Test-Path $CopilotCentral) {
        Write-Host ""
        Write-Host "  Removing Copilot central store..."
        Remove-Item -Path $CopilotCentral -Recurse -Force
        Write-Host "    - $CopilotCentral"
    }
}

# Remove auto-update (global uninstall only)
if ($Choice -eq "2") {
    Write-Host ""
    Write-Host "  Removing auto-update..."

    # Remove scheduled task
    $TaskName = "A11yAgentTeamUpdate"
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($Task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "    - Scheduled task removed"
    }

    # Remove update script, cache, version file, and log
    $FilesToRemove = @(
        (Join-Path $TargetDir ".a11y-agent-team-update.ps1"),
        (Join-Path $TargetDir ".a11y-agent-team-version"),
        (Join-Path $TargetDir ".a11y-agent-team-update.log")
    )
    foreach ($File in $FilesToRemove) {
        if (Test-Path $File) { Remove-Item -Path $File -Force }
    }
    $CacheDir = Join-Path $TargetDir ".a11y-agent-team-repo"
    if (Test-Path $CacheDir) {
        Remove-Item -Path $CacheDir -Recurse -Force
    }
    Write-Host "    - Update files cleaned up"
}

Write-Host ""
Write-Host "  NOTE: The hook entry in settings.json was not removed."
Write-Host "  If you want to fully clean up, remove the UserPromptSubmit"
Write-Host "  hook referencing a11y-team-eval from your settings.json."
Write-Host ""
Write-Host "  Uninstall complete."
Write-Host ""
