# A11y Agent Team Uninstaller (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Usage:
#   irm https://raw.githubusercontent.com/Community-Access/accessibility-agents/main/uninstall.ps1 | iex
#   powershell -File uninstall.ps1                Interactive mode
#   powershell -File uninstall.ps1 --project      Uninstall from .claude\ in the current directory
#   powershell -File uninstall.ps1 --global       Uninstall from ~\.claude\

$ErrorActionPreference = "Stop"

# Parse CLI flags
$Choice = ""
foreach ($arg in $args) {
    if ($arg -eq "--global")  { $Choice = "2" }
    if ($arg -eq "--project") { $Choice = "1" }
}

if (-not $Choice) {
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
}

switch ($Choice) {
    "1" {
        $TargetDir = Join-Path (Get-Location) ".claude"
        $ProjectDir = (Get-Location).Path
        Write-Host ""
        Write-Host "  Uninstalling from project: $(Get-Location)"
    }
    "2" {
        $TargetDir = Join-Path $env:USERPROFILE ".claude"
        $ProjectDir = $null
        Write-Host ""
        Write-Host "  Uninstalling from: $TargetDir"
    }
    default {
        Write-Host "  Invalid choice. Exiting."
        exit 1
    }
}

# ---------------------------------------------------------------------------
# Load manifest — if missing, build a fallback list from the repo
# ---------------------------------------------------------------------------
$ManifestFile = Join-Path $TargetDir ".a11y-agent-manifest"
$ManifestEntries = @()
$FallbackUsed = $false

if (Test-Path $ManifestFile) {
    $ManifestEntries = @(Get-Content $ManifestFile | Where-Object { $_.Trim() -ne "" })
    Write-Host "  Loaded manifest with $($ManifestEntries.Count) entries."
} else {
    Write-Host "  No manifest found — building fallback list from repo..."
    $FallbackUsed = $true
    $TmpRepo = Join-Path ([IO.Path]::GetTempPath()) "a11y-agent-uninstall-$(Get-Random)"
    try {
        & git clone --quiet --depth 1 https://github.com/Community-Access/accessibility-agents.git $TmpRepo 2>$null
        if (Test-Path $TmpRepo) {
            $RepoAgents = Get-ChildItem -Path (Join-Path $TmpRepo ".claude\agents") -Filter "*.md" -ErrorAction SilentlyContinue
            foreach ($f in $RepoAgents) { $ManifestEntries += "agents/$($f.Name)" }

            $RepoCopilotAgents = Get-ChildItem -Path (Join-Path $TmpRepo ".github\agents") -ErrorAction SilentlyContinue
            foreach ($f in $RepoCopilotAgents) { $ManifestEntries += "copilot-agents/$($f.Name)" }

            foreach ($SubDir in @("skills", "instructions", "prompts")) {
                $SrcDir = Join-Path $TmpRepo ".github\$SubDir"
                if (Test-Path $SrcDir) {
                    Get-ChildItem -Path $SrcDir -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                        $Rel = $_.FullName.Substring($SrcDir.Length + 1).Replace('\', '/')
                        $ManifestEntries += "copilot-$SubDir/$Rel"
                    }
                }
            }

            foreach ($Cfg in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
                if (Test-Path (Join-Path $TmpRepo ".github\$Cfg")) { $ManifestEntries += "copilot-config/$Cfg" }
            }

            if (Test-Path (Join-Path $TmpRepo ".codex\AGENTS.md")) {
                $ManifestEntries += "codex/project"
                $ManifestEntries += "codex/global"
            }

            if (Test-Path (Join-Path $TmpRepo ".gemini\extensions\a11y-agents")) {
                $ManifestEntries += "gemini/project"
                $ManifestEntries += "gemini/global"
            }

            Remove-Item -Recurse -Force $TmpRepo -ErrorAction SilentlyContinue
            Write-Host "  Built fallback manifest with $($ManifestEntries.Count) entries."
        }
    } catch {
        Write-Host "  Warning: Could not download repo for fallback. Will use file-pattern matching."
    }
}

# ---------------------------------------------------------------------------
# Helper: remove our section markers from a config file.
# If no user content remains, delete the file. Otherwise keep user content.
# ---------------------------------------------------------------------------
function Remove-OurSection {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return "absent" }
    $Content = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
    if ($Content -match '<!-- a11y-agent-team: start -->') {
        $Cleaned = [regex]::Replace($Content, '(?s)<!-- a11y-agent-team: start -->.*?<!-- a11y-agent-team: end -->', '')
        $Cleaned = $Cleaned.Trim()
        if ($Cleaned -eq "") {
            Remove-Item -Path $Path -Force
            return "deleted"
        } else {
            [IO.File]::WriteAllText($Path, $Cleaned, [Text.Encoding]::UTF8)
            return "cleaned"
        }
    }
    return "skipped"
}

# =============================================
# 1. Remove Claude Code agents
# =============================================
Write-Host ""
Write-Host "  Removing Claude Code agents..."
$AgentsDir = Join-Path $TargetDir "agents"
$RemovedAgents = 0
if (Test-Path $AgentsDir) {
    $AgentEntries = @($ManifestEntries | Where-Object { $_ -like "agents/*" })
    if ($AgentEntries.Count -gt 0) {
        foreach ($Entry in $AgentEntries) {
            $FileName = $Entry -replace '^agents/', ''
            $FilePath = Join-Path $AgentsDir $FileName
            if (Test-Path $FilePath) {
                Remove-Item -Path $FilePath -Force
                Write-Host "    - $([IO.Path]::GetFileNameWithoutExtension($FileName))"
                $RemovedAgents++
            }
        }
    } elseif ($FallbackUsed) {
        Get-ChildItem -Path $AgentsDir -Filter "*.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-Item $_.FullName -Force
            Write-Host "    - $($_.BaseName)"
            $RemovedAgents++
        }
    } else {
        Write-Host "    (no agent entries in manifest — skipping)"
    }
}
if ($RemovedAgents -eq 0) {
    Write-Host "    (no agents found to remove)"
}

# =============================================
# 2. Remove Copilot agents — project
# =============================================
if ($Choice -eq "1" -and $ProjectDir) {
    $CopilotDir = Join-Path $ProjectDir ".github\agents"
    if (Test-Path $CopilotDir) {
        Write-Host ""
        Write-Host "  Removing Copilot agents..."
        $CopilotEntries = @($ManifestEntries | Where-Object { $_ -like "copilot-agents/*" })
        if ($CopilotEntries.Count -gt 0) {
            foreach ($Entry in $CopilotEntries) {
                $FileName = $Entry -replace '^copilot-agents/', ''
                $FilePath = Join-Path $CopilotDir $FileName
                if (Test-Path $FilePath) {
                    Remove-Item -Path $FilePath -Force
                    Write-Host "    - $([IO.Path]::GetFileNameWithoutExtension($FileName))"
                }
            }
        } elseif ($FallbackUsed) {
            Get-ChildItem -Path $CopilotDir -Filter "*.agent.md" -File -ErrorAction SilentlyContinue | ForEach-Object {
                Remove-Item $_.FullName -Force
                Write-Host "    - $($_.BaseName)"
            }
        } else {
            Write-Host "    (no copilot-agents in manifest — skipping)"
        }
        if ((Get-ChildItem -Path $CopilotDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
            Remove-Item -Path $CopilotDir -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove Copilot config files — removes our section markers, preserves user content
    $GithubDir = Join-Path $ProjectDir ".github"
    foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
        $ConfigPath = Join-Path $GithubDir $Config
        $Result = Remove-OurSection -Path $ConfigPath
        switch ($Result) {
            "deleted" { Write-Host "    - $Config" }
            "cleaned" { Write-Host "    ~ $Config (removed our section, kept your content)" }
        }
    }

    # Remove Copilot asset subdirs (skills, instructions, prompts)
    foreach ($SubDir in @("skills", "instructions", "prompts")) {
        $AssetDir = Join-Path $GithubDir $SubDir
        if (Test-Path $AssetDir) {
            $SubDirEntries = @($ManifestEntries | Where-Object { $_ -like "copilot-$SubDir/*" })
            $Removed = 0
            if ($SubDirEntries.Count -gt 0) {
                foreach ($Entry in $SubDirEntries) {
                    $RelPath = $Entry -replace "^copilot-$SubDir/", ''
                    $FilePath = Join-Path $AssetDir $RelPath
                    if (Test-Path $FilePath) {
                        Remove-Item -Path $FilePath -Force
                        $Removed++
                    }
                }
            }
            # Clean up empty directories
            Get-ChildItem -Path $AssetDir -Directory -Recurse -ErrorAction SilentlyContinue |
                Sort-Object { $_.FullName.Length } -Descending |
                Where-Object { (Get-ChildItem $_.FullName -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0 } |
                ForEach-Object { Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }
            if ((Get-ChildItem -Path $AssetDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
                Remove-Item -Path $AssetDir -Force -ErrorAction SilentlyContinue
            }
            if ($Removed -gt 0) { Write-Host "    - $SubDir/ ($Removed files)" }
        }
    }
}

# =============================================
# 3. Remove Copilot agents — global
# =============================================
if ($Choice -eq "2") {
    $VSCodeProfiles = @(
        (Join-Path $env:APPDATA "Code\User"),
        (Join-Path $env:APPDATA "Code - Insiders\User")
    )
    foreach ($ProfileDir in $VSCodeProfiles) {
        if (-not (Test-Path $ProfileDir)) { continue }
        $PromptsDir = Join-Path $ProfileDir "prompts"

        # Remove agent, prompt, and instruction files
        foreach ($Dir in @($ProfileDir, $PromptsDir)) {
            if (-not (Test-Path $Dir)) { continue }
            $AllFiles = @()
            $AllFiles += @(Get-ChildItem -Path $Dir -Filter "*.agent.md" -ErrorAction SilentlyContinue)
            $AllFiles += @(Get-ChildItem -Path $Dir -Filter "*.prompt.md" -ErrorAction SilentlyContinue)
            $AllFiles += @(Get-ChildItem -Path $Dir -Filter "*.instructions.md" -ErrorAction SilentlyContinue)

            if ($AllFiles.Count -gt 0) {
                Write-Host ""
                Write-Host "  Removing files from: $Dir"
                foreach ($File in $AllFiles) {
                    Remove-Item -Path $File.FullName -Force
                    Write-Host "    - $($File.Name)"
                }
            }
        }

        # Remove prompts/ subdirectories that match our asset folders
        foreach ($SubFolder in @("skills", "instructions")) {
            $SubPath = Join-Path $PromptsDir $SubFolder
            if (Test-Path $SubPath) {
                Remove-Item -Path $SubPath -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "    - prompts/$SubFolder/"
            }
        }

        # Restore settings.json — remove our chat.agentFilesLocations override
        $SettingsFile = Join-Path $ProfileDir "settings.json"
        if (Test-Path $SettingsFile) {
            try {
                $Settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
                if ($Settings.PSObject.Properties.Name -contains 'chat.agentFilesLocations') {
                    $Locations = $Settings.'chat.agentFilesLocations'
                    $Changed = $false
                    foreach ($Key in @('.claude/agents', '.github/agents')) {
                        if ($Locations.PSObject.Properties.Name -contains $Key) {
                            $Locations.PSObject.Properties.Remove($Key)
                            $Changed = $true
                        }
                    }
                    if (($Locations.PSObject.Properties | Measure-Object).Count -eq 0) {
                        $Settings.PSObject.Properties.Remove('chat.agentFilesLocations')
                    }
                    if ($Changed) {
                        $Settings | ConvertTo-Json -Depth 10 | Set-Content $SettingsFile -Encoding UTF8
                        Write-Host "    - Restored VS Code settings"
                    }
                }
            } catch {
                Write-Host "    ! Could not update settings.json (edit manually if needed)"
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

# =============================================
# 4. Remove Codex CLI support
# =============================================
if ($Choice -eq "1") {
    $CodexDir = Join-Path (Get-Location) ".codex"
} else {
    $CodexDir = Join-Path $env:USERPROFILE ".codex"
}
$CodexFile = Join-Path $CodexDir "AGENTS.md"
if (Test-Path $CodexFile) {
    $Result = Remove-OurSection -Path $CodexFile
    switch ($Result) {
        "deleted" {
            Write-Host ""
            Write-Host "  Removing Codex CLI support..."
            if ((Get-ChildItem $CodexDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
                Remove-Item -Path $CodexDir -Force -ErrorAction SilentlyContinue
            }
            Write-Host "    - AGENTS.md (Codex removed)"
        }
        "cleaned" {
            Write-Host ""
            Write-Host "  Codex CLI:"
            Write-Host "    ~ AGENTS.md (removed our section, kept your content)"
        }
    }
}

# =============================================
# 5. Remove Gemini CLI extension
# =============================================
$GeminiPaths = @()
$GeminiPathEntry = $ManifestEntries | Where-Object { $_ -like "gemini/path:*" } | Select-Object -First 1
if ($GeminiPathEntry) {
    $GeminiPaths += ($GeminiPathEntry -replace '^gemini/path:', '')
}
if ($Choice -eq "1") {
    $GeminiPaths += Join-Path (Get-Location) ".gemini\extensions\a11y-agents"
} else {
    $GeminiPaths += Join-Path $env:USERPROFILE ".gemini\extensions\a11y-agents"
}
$GeminiRemoved = $false
foreach ($GeminiDir in ($GeminiPaths | Select-Object -Unique)) {
    if (Test-Path $GeminiDir) {
        Write-Host ""
        Write-Host "  Removing Gemini CLI extension..."
        Remove-Item -Path $GeminiDir -Recurse -Force
        Write-Host "    - $GeminiDir"
        $GeminiRemoved = $true
        $Parent = Split-Path $GeminiDir
        while ($Parent -and (Test-Path $Parent) -and ((Get-ChildItem $Parent -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0)) {
            Remove-Item -Path $Parent -Force -ErrorAction SilentlyContinue
            $Parent = Split-Path $Parent
        }
    }
}

# =============================================
# 6. Remove auto-update (global only)
# =============================================
if ($Choice -eq "2") {
    Write-Host ""
    Write-Host "  Removing auto-update..."

    $TaskName = "A11yAgentTeamUpdate"
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($Task) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "    - Scheduled task removed"
    }

    foreach ($File in @(".a11y-agent-team-update.ps1", ".a11y-agent-team-version", ".a11y-agent-team-update.log")) {
        $FilePath = Join-Path $TargetDir $File
        if (Test-Path $FilePath) { Remove-Item -Path $FilePath -Force }
    }
    $CacheDir = Join-Path $TargetDir ".a11y-agent-team-repo"
    if (Test-Path $CacheDir) { Remove-Item -Path $CacheDir -Recurse -Force }
    Write-Host "    - Update files cleaned up"
}

# =============================================
# 7. Clean up manifest and empty directories
# =============================================
if (Test-Path $ManifestFile) { Remove-Item -Path $ManifestFile -Force }
$VersionFile = Join-Path $TargetDir ".a11y-agent-team-version"
if (Test-Path $VersionFile) { Remove-Item -Path $VersionFile -Force }

$AgentsDir = Join-Path $TargetDir "agents"
if ((Test-Path $AgentsDir) -and ((Get-ChildItem $AgentsDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0)) {
    Remove-Item -Path $AgentsDir -Force -ErrorAction SilentlyContinue
}

# =============================================
# Done
# =============================================
Write-Host ""
Write-Host "  ========================="
Write-Host "  Uninstall complete!"
Write-Host ""
Write-Host "  What was removed:"
Write-Host "    - Claude Code agents from $TargetDir"
if ($Choice -eq "1") {
    Write-Host "    - Copilot agents, config, skills, instructions, prompts from .github/"
} else {
    Write-Host "    - Copilot agents from VS Code profiles"
    Write-Host "    - Copilot central store (~\.a11y-agent-team\)"
}
if ($GeminiRemoved) { Write-Host "    - Gemini CLI extension" }
Write-Host ""
Write-Host "  Next steps:"
Write-Host "    1. Restart Claude Code, VS Code, and any open terminals"
Write-Host "    2. Verify agents are gone: type '@' in Copilot Chat or '/agents' in Claude"
Write-Host ""
Write-Host "  If something was missed, see the manual uninstall guide:"
Write-Host "    https://github.com/Community-Access/accessibility-agents/blob/main/UNINSTALL.md"
Write-Host ""
