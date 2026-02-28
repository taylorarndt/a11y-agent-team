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

if (-not $ScriptDir -or (-not (Test-Path (Join-Path $ScriptDir "claude-code-plugin\agents")) -and -not (Test-Path (Join-Path $ScriptDir ".claude\agents")))) {
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

# Prefer claude-code-plugin/ as distribution source, fall back to .claude/agents/
$PluginAgentsDir = Join-Path $ScriptDir "claude-code-plugin\agents"
if (Test-Path $PluginAgentsDir) {
    $AgentsSrc = $PluginAgentsDir
} else {
    $AgentsSrc = Join-Path $ScriptDir ".claude\agents"
}

$CommandsSrc = $null
$PluginCommandsDir = Join-Path $ScriptDir "claude-code-plugin\commands"
if (Test-Path $PluginCommandsDir) {
    $CommandsSrc = $PluginCommandsDir
}

$PluginClaudeMd = $null
$PluginClaudeMdPath = Join-Path $ScriptDir "claude-code-plugin\CLAUDE.md"
if (Test-Path $PluginClaudeMdPath) {
    $PluginClaudeMd = $PluginClaudeMdPath
}

# Plugin source for global installs
$PluginSrc = $null
$PluginVersion = "1.0.0"
$PluginSrcDir = Join-Path $ScriptDir "claude-code-plugin\.claude-plugin"
if (Test-Path $PluginSrcDir) {
    $PluginSrc = Join-Path $ScriptDir "claude-code-plugin"
    $PluginJsonPath = Join-Path $PluginSrcDir "plugin.json"
    if (Test-Path $PluginJsonPath) {
        try { $PluginVersion = (Get-Content $PluginJsonPath | ConvertFrom-Json).version } catch {}
    }
}

$CopilotAgentsSrc = Join-Path $ScriptDir ".github\agents"
$CopilotConfigSrc = Join-Path $ScriptDir ".github"

# Auto-detect agents from source directory
$Agents = @()
if (Test-Path $AgentsSrc) {
    $Agents = Get-ChildItem -Path $AgentsSrc -Filter "*.md" | Select-Object -ExpandProperty Name
}

# Auto-detect commands from source directory
$Commands = @()
if ($CommandsSrc -and (Test-Path $CommandsSrc)) {
    $Commands = Get-ChildItem -Path $CommandsSrc -Filter "*.md" | Select-Object -ExpandProperty Name
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

# ---------------------------------------------------------------------------
# Register-A11yPlugin: Registers a11y-agent-team as a Claude Code plugin.
# ---------------------------------------------------------------------------
function Register-A11yPlugin {
    param([string]$SrcDir)
    $Namespace = "community-access"
    $PluginName = "a11y-agent-team"
    $DefaultKey = "$PluginName@$Namespace"
    $PluginsJson = Join-Path $env:USERPROFILE ".claude\plugins\installed_plugins.json"
    $SettingsJson = Join-Path $env:USERPROFILE ".claude\settings.json"

    Write-Host ""
    Write-Host "  Registering Claude Code plugin..."

    # Ensure plugins directory exists
    New-Item -ItemType Directory -Force -Path (Join-Path $env:USERPROFILE ".claude\plugins") | Out-Null

    # Detect existing registration
    $ActualKey = $DefaultKey
    if (Test-Path $PluginsJson) {
        try {
            $data = Get-Content $PluginsJson | ConvertFrom-Json
            foreach ($prop in $data.plugins.PSObject.Properties) {
                if ($prop.Name -match "^a11y-agent-team@") {
                    $ActualKey = $prop.Name
                    $Namespace = $ActualKey -replace '^a11y-agent-team@', ''
                    break
                }
            }
        } catch {}
    }

    $CacheDir = Join-Path $env:USERPROFILE ".claude\plugins\cache\$Namespace\$PluginName\$PluginVersion"

    # Copy plugin to cache
    New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
    Copy-Item -Path "$SrcDir\*" -Destination $CacheDir -Recurse -Force
    Write-Host "    + Plugin cached"

    # Update installed_plugins.json
    if (-not (Test-Path $PluginsJson)) {
        @{ version = 2; plugins = @{} } | ConvertTo-Json -Depth 10 | Out-File -FilePath $PluginsJson -Encoding utf8
    }
    $data = Get-Content $PluginsJson | ConvertFrom-Json
    $now = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.000Z")
    $entry = @{ scope = "user"; installPath = $CacheDir; version = $PluginVersion; installedAt = $now; lastUpdated = $now }
    if (-not $data.plugins) { $data | Add-Member -NotePropertyName plugins -NotePropertyValue @{} }
    $data.plugins | Add-Member -NotePropertyName $ActualKey -NotePropertyValue @($entry) -Force
    $data | ConvertTo-Json -Depth 10 | Out-File -FilePath $PluginsJson -Encoding utf8
    Write-Host "    + Registered in installed_plugins.json ($ActualKey)"

    # Update settings.json enabledPlugins
    if (-not (Test-Path $SettingsJson)) {
        @{} | ConvertTo-Json | Out-File -FilePath $SettingsJson -Encoding utf8
    }
    $settings = Get-Content $SettingsJson | ConvertFrom-Json
    if (-not $settings.enabledPlugins) { $settings | Add-Member -NotePropertyName enabledPlugins -NotePropertyValue @{} }
    $settings.enabledPlugins | Add-Member -NotePropertyName $ActualKey -NotePropertyValue $true -Force
    $settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $SettingsJson -Encoding utf8
    Write-Host "    + Enabled in settings.json"

    $agentCount = (Get-ChildItem -Path "$CacheDir\agents" -Filter "*.md" -ErrorAction SilentlyContinue).Count
    $cmdCount = (Get-ChildItem -Path "$CacheDir\commands" -Filter "*.md" -ErrorAction SilentlyContinue).Count
    Write-Host ""
    Write-Host "  Plugin registered: $ActualKey (v$PluginVersion)"
    Write-Host "    $agentCount agents"
    Write-Host "    $cmdCount slash commands"
    Write-Host "    3 enforcement hooks (UserPromptSubmit, PreToolUse, PostToolUse)"
    return $CacheDir
}

# ---------------------------------------------------------------------------
# Install-GlobalHooks: Installs the three-hook enforcement gate.
# Hook 1 (UserPromptSubmit): Proactive web project detection
# Hook 2 (PreToolUse): Blocks Edit/Write to UI files until a11y review
# Hook 3 (PostToolUse): Creates session marker when accessibility-lead completes
# ---------------------------------------------------------------------------
function Install-GlobalHooks {
    $HooksDir = Join-Path $env:USERPROFILE ".claude\hooks"
    New-Item -ItemType Directory -Force -Path $HooksDir | Out-Null

    $ScriptsSrc = Join-Path $ScriptDir "claude-code-plugin\scripts"

    Write-Host ""
    Write-Host "  Installing enforcement hooks..."

    # Copy hook scripts
    foreach ($Hook in @("a11y-team-eval.sh", "a11y-enforce-edit.sh", "a11y-mark-reviewed.sh")) {
        $Src = Join-Path $ScriptsSrc $Hook
        $Dst = Join-Path $HooksDir $Hook
        if (Test-Path $Src) {
            Copy-Item -Path $Src -Destination $Dst -Force
            Write-Host "    + $Hook"
        } else {
            Write-Host "    ! $Hook (source not found)"
        }
    }

    # Register hooks in settings.json
    $SettingsJson = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (-not (Test-Path $SettingsJson)) {
        @{} | ConvertTo-Json | Out-File -FilePath $SettingsJson -Encoding utf8
    }

    $EvalPath = (Join-Path $HooksDir "a11y-team-eval.sh") -replace '\\', '/'
    $EnforcePath = (Join-Path $HooksDir "a11y-enforce-edit.sh") -replace '\\', '/'
    $MarkerPath = (Join-Path $HooksDir "a11y-mark-reviewed.sh") -replace '\\', '/'

    $settings = Get-Content $SettingsJson -Raw | ConvertFrom-Json
    if (-not $settings.hooks) {
        $settings | Add-Member -NotePropertyName hooks -NotePropertyValue @{} -Force
    }

    # Build hook entries
    $UserPromptHook = @{ hooks = @(@{ type = "command"; command = "bash `"$EvalPath`"" }) }
    $PreToolHook = @{ matcher = "Edit|Write"; hooks = @(@{ type = "command"; command = "bash `"$EnforcePath`"" }) }
    $PostToolHook = @{ matcher = "Agent"; hooks = @(@{ type = "command"; command = "bash `"$MarkerPath`"" }) }

    # Helper: upsert a hook entry into an event array
    function Set-HookEntry {
        param([string]$Event, [object]$Entry, [string]$Match)
        $existing = @()
        if ($settings.hooks.PSObject.Properties[$Event]) {
            $existing = @($settings.hooks.$Event)
        }
        # Remove any existing a11y hook for this event
        $filtered = @($existing | Where-Object {
            $dominated = $false
            foreach ($h in $_.hooks) {
                if ($h.command -and $h.command -match "a11y-") { $dominated = $true }
            }
            -not $dominated
        })
        $filtered += $Entry
        $settings.hooks | Add-Member -NotePropertyName $Event -NotePropertyValue $filtered -Force
    }

    Set-HookEntry -Event "UserPromptSubmit" -Entry $UserPromptHook
    Set-HookEntry -Event "PreToolUse" -Entry $PreToolHook
    Set-HookEntry -Event "PostToolUse" -Entry $PostToolHook

    $settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $SettingsJson -Encoding utf8
    Write-Host "    + Hooks registered in settings.json"
}

# ---------------------------------------------------------------------------
# Installation: plugin (global) vs file-copy (project)
# ---------------------------------------------------------------------------
$PluginInstall = $false

if ($Choice -eq "2" -and $PluginSrc) {
    # Global install: register as Claude Code plugin
    $PluginCacheDir = Register-A11yPlugin -SrcDir $PluginSrc
    $PluginInstall = $true

    # Install the three-hook enforcement gate
    Install-GlobalHooks

    # Clean up previous non-plugin install
    $OldManifest = Join-Path $TargetDir ".a11y-agent-manifest"
    if (Test-Path $OldManifest) {
        Write-Host ""
        Write-Host "  Cleaning up previous non-plugin install..."
        $removed = 0
        Get-Content $OldManifest | ForEach-Object {
            $file = Join-Path $TargetDir $_
            if (Test-Path $file) { Remove-Item $file; $removed++ }
        }
        Remove-Item $OldManifest -ErrorAction SilentlyContinue
        if ($removed -gt 0) { Write-Host "    Removed $removed files" }
    }
} else {
    # Project install (or global without plugin support): copy agents/commands directly

# Create directories
New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "agents") | Out-Null
if ($Commands.Count -gt 0) {
    New-Item -ItemType Directory -Force -Path (Join-Path $TargetDir "commands") | Out-Null
}

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

# Copy commands — skip any file that already exists (preserves user customisations)
if ($Commands.Count -gt 0) {
    Write-Host ""
    Write-Host "  Copying commands..."
    $SkippedCommands = 0
    foreach ($Cmd in $Commands) {
        $Src = Join-Path $CommandsSrc $Cmd
        $Dst = Join-Path $TargetDir "commands\$Cmd"
        $Name = $Cmd -replace '\.md$', ''
        if (Test-Path $Dst) {
            Write-Host "    ~ /$Name (skipped - already exists)"
            $SkippedCommands++
        } else {
            Copy-Item -Path $Src -Destination $Dst
            if (-not $Manifest.Contains("commands/$Cmd")) { $Manifest.Add("commands/$Cmd") }
            Write-Host "    + /$Name"
        }
    }
    if ($SkippedCommands -gt 0) {
        Write-Host "      $SkippedCommands command(s) skipped. Delete them first to reinstall."
    }
}

}  # end of project/fallback install path

# Merge CLAUDE.md snippet (optional)
if ($PluginClaudeMd) {
    Write-Host ""
    Write-Host "  Would you like to merge accessibility rules into your project CLAUDE.md?"
    Write-Host "  This adds the decision matrix and non-negotiable standards."
    Write-Host ""
    $ClaudeChoice = Read-Host "  Merge CLAUDE.md rules? [y/N]"
    if ($ClaudeChoice -eq "y" -or $ClaudeChoice -eq "Y") {
        if ($Choice -eq "1") {
            $ClaudeDst = Join-Path (Get-Location) "CLAUDE.md"
        } else {
            $ClaudeDst = Join-Path $env:USERPROFILE "CLAUDE.md"
        }
        Merge-ConfigFile -SrcFile $PluginClaudeMd -DstFile $ClaudeDst -Label "CLAUDE.md (accessibility rules)"
    }
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

# Verify installation
Write-Host ""
Write-Host "  ========================="
Write-Host "  Installation complete!"

if ($PluginInstall) {
    Write-Host ""
    Write-Host "  Claude Code plugin installed:"
    Write-Host ""
    Write-Host "  Agents:"
    foreach ($f in Get-ChildItem -Path "$PluginCacheDir\agents" -Filter "*.md" -ErrorAction SilentlyContinue) {
        Write-Host "    [x] $($f.BaseName)"
    }
    Write-Host ""
    Write-Host "  Slash commands:"
    foreach ($f in Get-ChildItem -Path "$PluginCacheDir\commands" -Filter "*.md" -ErrorAction SilentlyContinue) {
        Write-Host "    [x] /$($f.BaseName)"
    }
    Write-Host ""
    Write-Host "  Enforcement hooks (three-hook gate):"
    $HooksDir = Join-Path $env:USERPROFILE ".claude\hooks"
    $HookChecks = @(
        @{ File = "a11y-team-eval.sh";    Label = "UserPromptSubmit  - Proactive web project detection" },
        @{ File = "a11y-enforce-edit.sh";  Label = "PreToolUse        - Blocks UI file edits until accessibility-lead reviewed" },
        @{ File = "a11y-mark-reviewed.sh"; Label = "PostToolUse       - Unlocks edit gate after accessibility-lead completes" }
    )
    foreach ($Check in $HookChecks) {
        $HookPath = Join-Path $HooksDir $Check.File
        if (Test-Path $HookPath) {
            Write-Host "    [x] $($Check.Label)"
        } else {
            Write-Host "    [ ] $($Check.Label) (not installed)"
        }
    }
} else {
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
    if ($Commands.Count -gt 0) {
        Write-Host ""
        Write-Host "  Slash commands installed:"
        foreach ($Cmd in $Commands) {
            $Name = $Cmd -replace '\.md$', ''
            $CmdPath = Join-Path $TargetDir "commands\$Cmd"
            if (Test-Path $CmdPath) {
                Write-Host "    [x] /$Name"
            } else {
                Write-Host "    [ ] /$Name (missing)"
            }
        }
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
if ($PluginInstall) {
    Write-Host "  Restart Claude Code for the plugin to take effect."
    Write-Host ""
    Write-Host "  The three-hook enforcement gate will:"
    Write-Host "    - Detect web projects and inject accessibility instructions on every prompt"
    Write-Host "    - Block Edit/Write to UI files until accessibility-lead has reviewed"
    Write-Host "    - Unlock the edit gate after accessibility-lead completes"
} else {
    Write-Host "  If agents stop loading, increase the character budget:"
    Write-Host "    `$env:SLASH_COMMAND_TOOL_CHAR_BUDGET = '30000'"
}
Write-Host ""
Write-Host "  Start Claude Code and try: `"Build a login form`""
Write-Host "  The accessibility-lead should activate automatically."
Write-Host ""
