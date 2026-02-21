# A11y Agent Team Uninstaller (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt

$ErrorActionPreference = "Stop"

$Agents = @(
    "accessibility-lead.md"
    "aria-specialist.md"
    "modal-specialist.md"
    "contrast-master.md"
    "keyboard-navigator.md"
    "live-region-controller.md"
)

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
foreach ($Agent in $Agents) {
    $Path = Join-Path $TargetDir "agents\$Agent"
    if (Test-Path $Path) {
        Remove-Item -Path $Path -Force
        $Name = $Agent -replace '\.md$', ''
        Write-Host "    - $Name"
    }
}

Write-Host ""
Write-Host "  Removing hook..."
$HookPath = Join-Path $TargetDir "hooks\a11y-team-eval.ps1"
if (Test-Path $HookPath) {
    Remove-Item -Path $HookPath -Force
    Write-Host "    - a11y-team-eval.ps1"
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
