# A11y Agent Team Installer (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# One-liner:
#   irm https://raw.githubusercontent.com/taylorarndt/a11y-agent-team/main/install.ps1 | iex

$ErrorActionPreference = "Stop"

# Determine source: running from repo clone or downloaded?
$Downloaded = $false
$ScriptDir = if ($MyInvocation.MyCommand.Path) {
    Split-Path -Parent $MyInvocation.MyCommand.Path
} else {
    $null
}

if (-not $ScriptDir -or -not (Test-Path (Join-Path $ScriptDir ".claude\agents"))) {
    # Running from irm pipe or without repo — download first
    $Downloaded = $true
    $TmpDir = Join-Path $env:TEMP "a11y-agent-team-install-$(Get-Random)"
    Write-Host ""
    Write-Host "  Downloading A11y Agent Team..."

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  Error: git is required. Install git and try again."
        exit 1
    }

    git clone --quiet https://github.com/taylorarndt/a11y-agent-team.git $TmpDir 2>$null
    $ScriptDir = $TmpDir
    Write-Host "  Downloaded."
}

$AgentsSrc = Join-Path $ScriptDir ".claude\agents"
$HookSrc = Join-Path $ScriptDir ".claude\hooks\a11y-team-eval.ps1"
$CopilotAgentsSrc = Join-Path $ScriptDir ".github\agents"
$CopilotConfigSrc = Join-Path $ScriptDir ".github"

# Auto-detect agents from source directory
$Agents = @()
if (Test-Path $AgentsSrc) {
    $Agents = Get-ChildItem -Path $AgentsSrc -Filter "*.md" | Select-Object -ExpandProperty Name
}

if ($Agents.Count -eq 0) {
    Write-Host "  Error: No agents found in $AgentsSrc"
    Write-Host "  Make sure you are running this script from the a11y-agent-team directory."
    if ($Downloaded) { Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue }
    exit 1
}

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

# Copilot agents
$CopilotInstalled = $false
$CopilotDestinations = @()

Write-Host ""
Write-Host "  Would you also like to install GitHub Copilot agents?"
Write-Host "  This adds accessibility agents for Copilot Chat in VS Code/GitHub."
Write-Host ""
$CopilotChoice = Read-Host "  Install Copilot agents? [y/N]"

if ($CopilotChoice -eq "y" -or $CopilotChoice -eq "Y") {

    if ($Choice -eq "1") {
        # Project install: put agents in .github\agents\
        $ProjectDir = Get-Location
        $CopilotDst = Join-Path $ProjectDir ".github\agents"
        New-Item -ItemType Directory -Force -Path $CopilotDst | Out-Null
        $CopilotDestinations += $CopilotDst

        # Copy Copilot config files to project
        Write-Host ""
        Write-Host "  Copying Copilot config..."
        foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
            $Src = Join-Path $CopilotConfigSrc $Config
            $Dst = Join-Path $ProjectDir ".github\$Config"
            if (Test-Path $Src) {
                Copy-Item -Path $Src -Destination $Dst -Force
                Write-Host "    + $Config"
            }
        }
    } else {
        # Global install: store Copilot agents centrally and configure VS Code
        # to discover them via chat.agentFilesLocations setting.
        $CopilotCentral = Join-Path $env:USERPROFILE ".a11y-agent-team\copilot-agents"
        New-Item -ItemType Directory -Force -Path $CopilotCentral | Out-Null

        Write-Host ""
        Write-Host "  Storing Copilot agents centrally..."
        if (Test-Path $CopilotAgentsSrc) {
            foreach ($File in Get-ChildItem -Path $CopilotAgentsSrc -Filter "*.agent.md") {
                Copy-Item -Path $File.FullName -Destination (Join-Path $CopilotCentral $File.Name) -Force
                $Name = $File.BaseName -replace '\.agent$', ''
                Write-Host "    + $Name"
            }
        }

        # Copy config files to central store
        $CentralRoot = Join-Path $env:USERPROFILE ".a11y-agent-team"
        foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
            $Src = Join-Path $CopilotConfigSrc $Config
            if (Test-Path $Src) {
                Copy-Item -Path $Src -Destination (Join-Path $CentralRoot $Config) -Force
            }
        }

        # Copy .agent.md files directly into VS Code user profile folders
        # so they appear globally in the Copilot Chat agent picker.
        function Copy-ToVSCodeProfile {
            param([string]$ProfileDir, [string]$Label)

            if (-not (Test-Path $ProfileDir)) { return }

            Write-Host "  [found] $Label"
            $AgentFiles = Get-ChildItem -Path $CopilotCentral -Filter "*.agent.md" -ErrorAction SilentlyContinue
            foreach ($File in $AgentFiles) {
                Copy-Item -Path $File.FullName -Destination (Join-Path $ProfileDir $File.Name) -Force
            }
            Write-Host "    Copied $($AgentFiles.Count) agents to profile"
            $script:CopilotDestinations += $ProfileDir
        }

        Write-Host ""
        $VSCodeProfile = Join-Path $env:APPDATA "Code\User"
        $VSCodeInsidersProfile = Join-Path $env:APPDATA "Code - Insiders\User"
        Copy-ToVSCodeProfile -ProfileDir $VSCodeProfile -Label "VS Code"
        Copy-ToVSCodeProfile -ProfileDir $VSCodeInsidersProfile -Label "VS Code Insiders"

        # Also create a11y-copilot-init for per-project use (repos to check into git)
        $InitScript = Join-Path $CentralRoot "a11y-copilot-init.ps1"
        @'
# A11y Agent Team - Copy Copilot agents into the current project
# Usage: a11y-copilot-init
#
# Copies .agent.md files into .github/agents/ for this project.
# Use this when you want to check agents into version control.

$Central = Join-Path $env:USERPROFILE ".a11y-agent-team\copilot-agents"
$Target = Join-Path (Get-Location) ".github\agents"
$GithubDir = Join-Path (Get-Location) ".github"

if (-not (Test-Path $Central)) {
    Write-Host "  Error: No Copilot agents found. Run the installer first."
    exit 1
}

New-Item -ItemType Directory -Force -Path $Target | Out-Null
Copy-Item -Path (Join-Path $Central "*.agent.md") -Destination $Target -Force
Write-Host "  Copied Copilot agents to $Target"

# Copy config files
$CentralRoot = Join-Path $env:USERPROFILE ".a11y-agent-team"
foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
    $Src = Join-Path $CentralRoot $Config
    $Dst = Join-Path $GithubDir $Config
    if (Test-Path $Src) {
        Copy-Item -Path $Src -Destination $Dst -Force
        Write-Host "  Copied .github\$Config"
    }
}

Write-Host ""
Write-Host "  These are now in your project for version control."
'@ | Out-File -FilePath $InitScript -Encoding utf8

        Write-Host ""
        Write-Host "  To copy Copilot agents into a specific project:"
        Write-Host "    powershell -File `"$InitScript`""
        Write-Host ""

        $CopilotInstalled = $true
        $CopilotDestinations += $CopilotCentral
    }
}

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
Write-Host "  Claude Code agents installed:"
foreach ($Agent in $Agents) {
    $Name = $Agent -replace '\.md$', ''
    $AgentPath = Join-Path $TargetDir "agents\$Agent"
    if (Test-Path $AgentPath) {
        Write-Host "    [x] $Name"
    } else {
        Write-Host "    [ ] $Name (missing)"
    }
}
if ($CopilotInstalled) {
    Write-Host ""
    Write-Host "  Copilot agents installed to:"
    foreach ($Dest in $CopilotDestinations) {
        Write-Host "    -> $Dest"
    }
    Write-Host ""
    Write-Host "  Copilot agents:"
    foreach ($File in Get-ChildItem -Path $CopilotDestinations[0] -Filter "*.agent.md") {
        $Name = $File.BaseName -replace '\.agent$', ''
        Write-Host "    [x] $Name"
    }
}

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

# Clean up temp download
if ($Downloaded) { Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue }

Write-Host ""
Write-Host "  If agents stop loading, increase the character budget:"
Write-Host "    `$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = '30000'"
Write-Host ""
Write-Host "  Start Claude Code and try: `"Build a login form`""
Write-Host "  The accessibility-lead should activate automatically."
Write-Host ""
