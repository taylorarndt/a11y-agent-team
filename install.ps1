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

        # Copy Copilot agents (.agent.md + non-agent support files: AGENTS.md, shared-instructions.md, etc.)
        Write-Host ""
        Write-Host "  Copying Copilot agents..."
        if (Test-Path $CopilotAgentsSrc) {
            foreach ($File in Get-ChildItem -Path $CopilotAgentsSrc -File) {
                Copy-Item -Path $File.FullName -Destination (Join-Path $CopilotDst $File.Name) -Force
                $DisplayName = $File.BaseName -replace '\.agent$', ''
                Write-Host "    + $DisplayName"
            }
        }

        # Auto-sync all Copilot asset directories from .github/.
        # New subdirs (skills, prompts, instructions, hooks) are discovered automatically —
        # no hardcoded list to maintain. Adding any new asset to the repo makes it installable.
        Write-Host ""
        Write-Host "  Copying Copilot assets..."
        foreach ($SubDir in @("skills", "instructions", "prompts", "hooks")) {
            $SrcSubDir = Join-Path $CopilotConfigSrc $SubDir
            $DstSubDir = Join-Path $ProjectDir ".github\$SubDir"
            if (Test-Path $SrcSubDir) {
                New-Item -ItemType Directory -Force -Path $DstSubDir | Out-Null
                Copy-Item -Path "$SrcSubDir\*" -Destination $DstSubDir -Recurse -Force
                $FileCount = (Get-ChildItem -Recurse -File $SrcSubDir).Count
                Write-Host "    + .github\$SubDir\ ($FileCount files)"
            }
        }
        $CopilotInstalled = $true
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

        # Copy config files, prompts, instructions, and skills to central store.
        # VS Code 1.110+ discovers *.agent.md, *.prompt.md, *.instructions.md from User/prompts/.
        $CentralRoot = Join-Path $env:USERPROFILE ".a11y-agent-team"
        $CopilotCentralPrompts      = Join-Path $CentralRoot "copilot-prompts"
        $CopilotCentralInstructions = Join-Path $CentralRoot "copilot-instructions-files"
        $CopilotCentralSkills       = Join-Path $CentralRoot "copilot-skills"

        foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
            $Src = Join-Path $CopilotConfigSrc $Config
            if (Test-Path $Src) {
                Copy-Item -Path $Src -Destination (Join-Path $CentralRoot $Config) -Force
            }
        }
        foreach ($Pair in @(
            @{ Src = Join-Path $CopilotConfigSrc "prompts";      Dst = $CopilotCentralPrompts },
            @{ Src = Join-Path $CopilotConfigSrc "instructions"; Dst = $CopilotCentralInstructions },
            @{ Src = Join-Path $CopilotConfigSrc "skills";       Dst = $CopilotCentralSkills }
        )) {
            if (Test-Path $Pair.Src) {
                New-Item -ItemType Directory -Force -Path $Pair.Dst | Out-Null
                Copy-Item -Path "$($Pair.Src)\*" -Destination $Pair.Dst -Recurse -Force
            }
        }

        # Copy .agent.md, *.prompt.md, *.instructions.md into VS Code User profile folders.
        # VS Code 1.110+ discovers from User/prompts/; older versions from User/ root.
        # Both locations are populated for full compatibility.
        function Copy-ToVSCodeProfile {
            param([string]$ProfileDir, [string]$Label)

            if (-not (Test-Path $ProfileDir)) { return }

            $PromptsDir = Join-Path $ProfileDir "prompts"
            New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
            Write-Host "  [found] $Label"

            $AgentFiles       = Get-ChildItem -Path $CopilotCentral            -Filter "*.agent.md"       -ErrorAction SilentlyContinue
            $PromptFiles      = Get-ChildItem -Path $CopilotCentralPrompts     -Filter "*.prompt.md"      -ErrorAction SilentlyContinue
            $InstructionFiles = Get-ChildItem -Path $CopilotCentralInstructions -Filter "*.instructions.md" -ErrorAction SilentlyContinue

            foreach ($File in @($AgentFiles) + @($PromptFiles) + @($InstructionFiles)) {
                if ($File) {
                    Copy-Item -Path $File.FullName -Destination (Join-Path $ProfileDir  $File.Name) -Force
                    Copy-Item -Path $File.FullName -Destination (Join-Path $PromptsDir  $File.Name) -Force
                }
            }

            Write-Host "    Copied $($AgentFiles.Count) agents, $($PromptFiles.Count) prompts, $($InstructionFiles.Count) instructions"
            $script:CopilotDestinations += $PromptsDir
        }

        Write-Host ""
        $VSCodeProfile = Join-Path $env:APPDATA "Code\User"
        $VSCodeInsidersProfile = Join-Path $env:APPDATA "Code - Insiders\User"
        Copy-ToVSCodeProfile -ProfileDir $VSCodeProfile -Label "VS Code"
        Copy-ToVSCodeProfile -ProfileDir $VSCodeInsidersProfile -Label "VS Code Insiders"

        # Also create a11y-copilot-init for per-project use (repos to check into git)
        $InitScript = Join-Path $CentralRoot "a11y-copilot-init.ps1"
        @'
# A11y Agent Team - Copy Copilot assets into the current project
# Usage: powershell -File a11y-copilot-init.ps1
#
# Copies agents, prompts, instructions, skills, and hooks into .github/ for this project.
# Use this when you want to check all Copilot assets into version control.

$CentralRoot   = Join-Path $env:USERPROFILE ".a11y-agent-team"
$Central       = Join-Path $CentralRoot "copilot-agents"
$CentralPrompts      = Join-Path $CentralRoot "copilot-prompts"
$CentralInstructions = Join-Path $CentralRoot "copilot-instructions-files"
$CentralSkills       = Join-Path $CentralRoot "copilot-skills"
$GithubDir     = Join-Path (Get-Location) ".github"

if (-not (Test-Path $Central)) {
    Write-Host "  Error: No Copilot agents found. Run the installer first."
    exit 1
}

# Agents
$AgentDst = Join-Path $GithubDir "agents"
New-Item -ItemType Directory -Force -Path $AgentDst | Out-Null
Get-ChildItem -Path $Central | Copy-Item -Destination $AgentDst -Force
Write-Host "  Copied agents to .github\agents\"

# Copilot config files
foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
    $Src = Join-Path $CentralRoot $Config
    if (Test-Path $Src) {
        Copy-Item -Path $Src -Destination (Join-Path $GithubDir $Config) -Force
        Write-Host "  Copied .github\$Config"
    }
}

# Auto-sync central asset stores: prompts, instructions, skills
foreach ($Pair in @(
    @{ Src = $CentralPrompts;      Sub = "prompts" },
    @{ Src = $CentralInstructions; Sub = "instructions" },
    @{ Src = $CentralSkills;       Sub = "skills" }
)) {
    if (Test-Path $Pair.Src) {
        $Dst = Join-Path $GithubDir $Pair.Sub
        New-Item -ItemType Directory -Force -Path $Dst | Out-Null
        Copy-Item -Path "$($Pair.Src)\*" -Destination $Dst -Recurse -Force
        $Count = (Get-ChildItem -Recurse -File $Pair.Src).Count
        Write-Host "  Copied .github\$($Pair.Sub)\ ($Count files)"
    }
}

Write-Host ""
Write-Host "  All Copilot assets are now in .github/ for version control."
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
    $AgentSummaryDir = if ($Choice -eq "1") { Join-Path (Get-Location) ".github\agents" } else { $CopilotDestinations[0] }
    foreach ($File in Get-ChildItem -Path $AgentSummaryDir -Filter "*.agent.md" -ErrorAction SilentlyContinue) {
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
