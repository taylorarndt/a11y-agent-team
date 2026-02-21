# A11y Agent Team Installer (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AgentsSrc = Join-Path $ScriptDir ".claude\agents"
$HookSrc = Join-Path $ScriptDir ".claude\hooks\a11y-team-eval.ps1"

$Agents = @(
    "accessibility-lead.md"
    "aria-specialist.md"
    "modal-specialist.md"
    "contrast-master.md"
    "keyboard-navigator.md"
    "live-region-controller.md"
)

Write-Host ""
Write-Host "  A11y Agent Team Installer"
Write-Host "  Built by Taylor Arndt"
Write-Host "  ========================="
Write-Host ""
Write-Host "  Where would you like to install?"
Write-Host ""
Write-Host "  1) Project   - Install to .claude\ in the current directory"
Write-Host "                  (recommended, check into version control)"
Write-Host ""
Write-Host "  2) Global    - Install to ~\.claude\"
Write-Host "                  (available in all your projects)"
Write-Host ""
$Choice = Read-Host "  Choose [1/2]"

switch ($Choice) {
    "1" {
        $TargetDir = Join-Path (Get-Location) ".claude"
        $SettingsFile = Join-Path $TargetDir "settings.json"
        $HookCmd = ".claude\hooks\a11y-team-eval.ps1"
        Write-Host ""
        Write-Host "  Installing to project: $(Get-Location)"
    }
    "2" {
        $TargetDir = Join-Path $env:USERPROFILE ".claude"
        $SettingsFile = Join-Path $TargetDir "settings.json"
        $HookCmd = Join-Path $env:USERPROFILE ".claude\hooks\a11y-team-eval.ps1"
        Write-Host ""
        Write-Host "  Installing globally to: $TargetDir"
    }
    default {
        Write-Host "  Invalid choice. Exiting."
        exit 1
    }
}

# Create directories
New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "agents") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "hooks") | Out-Null

# Copy agents
Write-Host ""
Write-Host "  Copying agents..."
foreach ($Agent in $Agents) {
    $Src = Join-Path $AgentsSrc $Agent
    $Dst = Join-Path $TargetDir "agents\$Agent"
    Copy-Item -Path $Src -Destination $Dst -Force
    $Name = $Agent -replace '\.md$', ''
    Write-Host "    + $Name"
}

# Copy hook
Write-Host ""
Write-Host "  Copying hook..."
$HookDst = Join-Path $TargetDir "hooks\a11y-team-eval.ps1"
Copy-Item -Path $HookSrc -Destination $HookDst -Force
Write-Host "    + a11y-team-eval.ps1"

# Handle settings.json
Write-Host ""
if (Test-Path $SettingsFile) {
    $Content = Get-Content $SettingsFile -Raw
    if ($Content -match "a11y-team-eval") {
        Write-Host "  Hook already configured in settings.json. Skipping."
    } else {
        Write-Host "  Existing settings.json found."
        Write-Host "  You need to add the hook manually. Add this to your settings.json"
        Write-Host "  under `"hooks`" > `"UserPromptSubmit`":`n"
        Write-Host "    {"
        Write-Host "      `"hooks`": ["
        Write-Host "        {"
        Write-Host "          `"type`": `"command`","
        Write-Host "          `"command`": `"powershell -File '$HookCmd'`""
        Write-Host "        }"
        Write-Host "      ]"
        Write-Host "    }"
        Write-Host ""
    }
} else {
    $Settings = @"
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell -File '$HookCmd'"
          }
        ]
      }
    ]
  }
}
"@
    $Settings | Out-File -FilePath $SettingsFile -Encoding utf8
    Write-Host "  Created settings.json with hook configured."
}

# Done
Write-Host ""
Write-Host "  ========================="
Write-Host "  Installation complete!"
Write-Host ""
Write-Host "  Agents installed:"
Write-Host "    - accessibility-lead (orchestrator)"
Write-Host "    - aria-specialist"
Write-Host "    - modal-specialist"
Write-Host "    - contrast-master"
Write-Host "    - keyboard-navigator"
Write-Host "    - live-region-controller"

# Auto-update setup (global install only)
if ($Choice -eq "2") {
    Write-Host ""
    Write-Host "  Would you like to enable auto-updates?"
    Write-Host "  This checks GitHub daily for new agents and improvements."
    Write-Host ""
    $AutoUpdate = Read-Host "  Enable auto-updates? [y/N]"

    if ($AutoUpdate -eq "y" -or $AutoUpdate -eq "Y") {
        # Copy the update script
        $UpdateSrc = Join-Path $ScriptDir "update.ps1"
        $UpdateDst = Join-Path $TargetDir ".a11y-agent-team-update.ps1"
        if (Test-Path $UpdateSrc) {
            Copy-Item -Path $UpdateSrc -Destination $UpdateDst -Force
        }

        # Create a scheduled task that runs daily at 9:00 AM
        $TaskName = "A11yAgentTeamUpdate"
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$UpdateDst`" -Silent"
        $Trigger = New-ScheduledTaskTrigger -Daily -At "9:00AM"
        $Settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd

        # Remove existing task if present
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

        Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Description "Auto-update A11y Agent Team for Claude Code" -ErrorAction SilentlyContinue | Out-Null

        if ($?) {
            Write-Host "  Auto-updates enabled (daily at 9:00 AM via Task Scheduler)."
            Write-Host "  Update log: ~\.claude\.a11y-agent-team-update.log"
        } else {
            Write-Host "  Could not create scheduled task. You can run update.ps1 manually."
        }
    } else {
        Write-Host "  Auto-updates skipped. You can run update.ps1 manually anytime."
    }
}

Write-Host ""
Write-Host "  If agents stop loading, increase the character budget:"
Write-Host "    `$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = '30000'"
Write-Host ""
Write-Host "  Start Claude Code and try: `"Build a login form`""
Write-Host "  The accessibility-lead should activate automatically."
Write-Host ""
