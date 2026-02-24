# A11y Agent Team Installer (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# One-liner:
#   irm https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/install.ps1 | iex

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

    git clone --quiet https://github.com/Community-Access/accessibility-agents.git $TmpDir 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  Error: git clone failed. Check your network connection and try again."
        exit 1
    }
    $ScriptDir = $TmpDir
    Write-Host "  Downloaded."
}

$AgentsSrc = Join-Path $ScriptDir ".claude\agents"
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
        Write-Host ""
        Write-Host "  Installing to project: $(Get-Location)"
    }
    "2" {
        $TargetDir = Join-Path $env:USERPROFILE ".claude"
        Write-Host ""
        Write-Host "  Installing globally to: $TargetDir"
    }
    default {
        Write-Host "  Invalid choice. Exiting."
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Merge-ConfigFile: append/update our section in a config markdown file.
# Never overwrites existing user content. Uses <!-- a11y-agent-team --> markers
# so the user's own content above/below our section is always preserved.
# ---------------------------------------------------------------------------
function Merge-ConfigFile {
    param([string]$SrcFile, [string]$DstFile, [string]$Label)
    $start  = "<!-- a11y-agent-team: start -->"
    $end    = "<!-- a11y-agent-team: end -->"
    $body   = ([IO.File]::ReadAllText($SrcFile, [Text.Encoding]::UTF8)).TrimEnd()
    $block  = "$start`n$body`n$end"
    if (-not (Test-Path $DstFile)) {
        [IO.File]::WriteAllText($DstFile, "$block`n", [Text.Encoding]::UTF8)
        Write-Host "    + $Label (created)"
        return
    }
    $existing = [IO.File]::ReadAllText($DstFile, [Text.Encoding]::UTF8)
    if ($existing -match [regex]::Escape($start)) {
        $pattern = "(?s)" + [regex]::Escape($start) + ".*?" + [regex]::Escape($end)
        $updated = [regex]::Replace($existing, $pattern, $block)
        [IO.File]::WriteAllText($DstFile, $updated, [Text.Encoding]::UTF8)
        Write-Host "    ~ $Label (updated our existing section)"
    } else {
        [IO.File]::WriteAllText($DstFile, $existing.TrimEnd() + "`n`n$block`n", [Text.Encoding]::UTF8)
        Write-Host "    + $Label (merged into your existing file)"
    }
}

# Create directories
New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "agents") | Out-Null

# Track which files we install so updates never touch user-created files
$ManifestPath = Join-Path $TargetDir ".a11y-agent-manifest"
$Manifest = [System.Collections.Generic.List[string]]::new()
if (Test-Path $ManifestPath) {
    [IO.File]::ReadAllLines($ManifestPath, [Text.Encoding]::UTF8) | ForEach-Object { $Manifest.Add($_) }
}

# Copy agents — skip any file that already exists (preserves user customisations)
Write-Host ""
Write-Host "  Copying agents..."
$SkippedAgents = 0
foreach ($Agent in $Agents) {
    $Src = Join-Path $AgentsSrc $Agent
    $Dst = Join-Path $TargetDir "agents\$Agent"
    $Name = $Agent -replace '\.md$', ''
    if (Test-Path $Dst) {
        Write-Host "    ~ $Name (skipped - already exists)"
        $SkippedAgents++
    } else {
        Copy-Item -Path $Src -Destination $Dst
        if (-not $Manifest.Contains("agents/$Agent")) { $Manifest.Add("agents/$Agent") }
        Write-Host "    + $Name"
    }
}
if ($SkippedAgents -gt 0) {
    Write-Host "      $SkippedAgents agent(s) skipped. Use -Force flag or delete them first to reinstall."
}

# Save manifest
[IO.File]::WriteAllLines($ManifestPath, $Manifest.ToArray(), [Text.Encoding]::UTF8)

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

        # Merge Copilot config files — appends our section rather than overwriting
        Write-Host ""
        Write-Host "  Merging Copilot config..."
        foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
            $Src = Join-Path $CopilotConfigSrc $Config
            $Dst = Join-Path $ProjectDir ".github\$Config"
            if (Test-Path $Src) {
                Merge-ConfigFile -SrcFile $Src -DstFile $Dst -Label $Config
            }
        }

        # Copy Copilot agents — skip files that already exist (preserves user agents)
        Write-Host ""
        Write-Host "  Copying Copilot agents..."
        if (Test-Path $CopilotAgentsSrc) {
            foreach ($File in Get-ChildItem -Path $CopilotAgentsSrc -File) {
                $DstPath = Join-Path $CopilotDst $File.Name
                $DisplayName = $File.BaseName -replace '\.agent$', ''
                if (Test-Path $DstPath) {
                    Write-Host "    ~ $DisplayName (skipped - already exists)"
                } else {
                    Copy-Item -Path $File.FullName -Destination $DstPath
                    Write-Host "    + $DisplayName"
                }
            }
        }

        # Copy Copilot asset subdirs — file-by-file, skipping files that already exist
        Write-Host ""
        Write-Host "  Copying Copilot assets..."
        foreach ($SubDir in @("skills", "instructions", "prompts")) {
            $SrcSubDir = Join-Path $CopilotConfigSrc $SubDir
            $DstSubDir = Join-Path $ProjectDir ".github\$SubDir"
            if (Test-Path $SrcSubDir) {
                New-Item -ItemType Directory -Force -Path $DstSubDir | Out-Null
                $Added = 0; $Skipped = 0
                foreach ($File in Get-ChildItem -Recurse -File $SrcSubDir) {
                    $Rel  = $File.FullName.Substring($SrcSubDir.Length).TrimStart('\')
                    $Dst  = Join-Path $DstSubDir $Rel
                    New-Item -ItemType Directory -Force -Path (Split-Path $Dst) | Out-Null
                    if (Test-Path $Dst) { $Skipped++ } else { Copy-Item $File.FullName $Dst; $Added++ }
                }
                $msg = "    + .github\$SubDir\ ($Added new"
                if ($Skipped -gt 0) { $msg += ", $Skipped skipped" }
                Write-Host "$msg)"
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
# Copies agents, prompts, instructions, and skills into .github/ for this project.
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

# Merge helper — appends/updates our section in config files; never overwrites user content
function Merge-ConfigFile {
    param([string]$SrcFile, [string]$DstFile, [string]$Label)
    $start  = "<!-- a11y-agent-team: start -->"
    $end    = "<!-- a11y-agent-team: end -->"
    $body   = ([IO.File]::ReadAllText($SrcFile, [Text.Encoding]::UTF8)).TrimEnd()
    $block  = "$start`n$body`n$end"
    if (-not (Test-Path $DstFile)) {
        [IO.File]::WriteAllText($DstFile, "$block`n", [Text.Encoding]::UTF8)
        Write-Host "  + $Label (created)"
        return
    }
    $existing = [IO.File]::ReadAllText($DstFile, [Text.Encoding]::UTF8)
    if ($existing -match [regex]::Escape($start)) {
        $pattern = "(?s)" + [regex]::Escape($start) + ".*?" + [regex]::Escape($end)
        $updated = [regex]::Replace($existing, $pattern, $block)
        [IO.File]::WriteAllText($DstFile, $updated, [Text.Encoding]::UTF8)
        Write-Host "  ~ $Label (updated our existing section)"
    } else {
        [IO.File]::WriteAllText($DstFile, $existing.TrimEnd() + "`n`n$block`n", [Text.Encoding]::UTF8)
        Write-Host "  + $Label (merged into your existing file)"
    }
}

# Agents — skip files that already exist (preserves user customisations)
$AgentDst = Join-Path $GithubDir "agents"
New-Item -ItemType Directory -Force -Path $AgentDst | Out-Null
$AgentAdded = 0; $AgentSkipped = 0
Get-ChildItem -Path $Central | ForEach-Object {
    $dst = Join-Path $AgentDst $_.Name
    if (Test-Path $dst) { $AgentSkipped++ } else { Copy-Item $_.FullName $dst; $AgentAdded++ }
}
Write-Host "  Copied agents to .github\agents\ ($AgentAdded new, $AgentSkipped skipped)"

# Copilot config files — always merged, never overwritten
foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
    $Src = Join-Path $CentralRoot $Config
    if (Test-Path $Src) {
        Merge-ConfigFile -SrcFile $Src -DstFile (Join-Path $GithubDir $Config) -Label $Config
    }
}

# Asset stores: prompts, instructions, skills — file-by-file, skip existing
foreach ($Pair in @(
    @{ Src = $CentralPrompts;      Sub = "prompts" },
    @{ Src = $CentralInstructions; Sub = "instructions" },
    @{ Src = $CentralSkills;       Sub = "skills" }
)) {
    if (Test-Path $Pair.Src) {
        $Dst = Join-Path $GithubDir $Pair.Sub
        New-Item -ItemType Directory -Force -Path $Dst | Out-Null
        $Added = 0; $Skipped = 0
        Get-ChildItem -Recurse -File $Pair.Src | ForEach-Object {
            $Rel  = $_.FullName.Substring($Pair.Src.Length).TrimStart('\')
            $DstF = Join-Path $Dst $Rel
            New-Item -ItemType Directory -Force -Path (Split-Path $DstF) | Out-Null
            if (Test-Path $DstF) { $Skipped++ } else { Copy-Item $_.FullName $DstF; $Added++ }
        }
        Write-Host "  Copied .github\$($Pair.Sub)\ ($Added new, $Skipped skipped)"
    }
}

Write-Host ""
Write-Host "  All Copilot assets are now in .github/ for version control."
Write-Host "  Your existing files were preserved. Only new content was added."
'@ | Out-File -FilePath $InitScript -Encoding utf8

        Write-Host ""
        Write-Host "  To copy Copilot agents into a specific project:"
        Write-Host "    powershell -File `"$InitScript`""
        Write-Host ""

        $CopilotInstalled = $true
        $CopilotDestinations += $CopilotCentral
    }
}

# Done\nWrite-Host \"\"\nWrite-Host \"  =========================\"\nWrite-Host \"  Installation complete!\"
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
        $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy RemoteSigned -WindowStyle Hidden -File `"$UpdateDst`" -Silent"
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
