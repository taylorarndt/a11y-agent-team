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

# Load manifest to only remove files we installed
$ManifestFile = Join-Path $TargetDir ".a11y-agent-manifest"
$ManifestEntries = @()
if (Test-Path $ManifestFile) {
    $ManifestEntries = Get-Content $ManifestFile | Where-Object { $_.Trim() -ne "" }
}

Write-Host ""
Write-Host "  Removing agents..."
$AgentsDir = Join-Path $TargetDir "agents"
if (Test-Path $AgentsDir) {
    if ($ManifestEntries.Count -gt 0) {
        foreach ($Entry in $ManifestEntries) {
            if ($Entry -like "agents/*") {
                $FileName = $Entry -replace '^agents/', ''
                $FilePath = Join-Path $AgentsDir $FileName
                if (Test-Path $FilePath) {
                    Remove-Item -Path $FilePath -Force
                    Write-Host "    - $([IO.Path]::GetFileNameWithoutExtension($FileName))"
                }
            }
        }
    } else {
        Write-Host "    (no manifest found — skipping to avoid removing user-created files)"
    }
}

# Remove Copilot agents if installed (project uninstall only)
if ($Choice -eq "1") {
    $CopilotDir = Join-Path (Get-Location) ".github\agents"
    if (Test-Path $CopilotDir) {
        Write-Host ""
        Write-Host "  Removing Copilot agents..."
        # Only remove agents listed in manifest to avoid deleting user-created files
        $CopilotManifestEntries = $ManifestEntries | Where-Object { $_ -like "copilot-agents/*" }
        if ($CopilotManifestEntries.Count -gt 0) {
            foreach ($Entry in $CopilotManifestEntries) {
                $FileName = $Entry -replace '^copilot-agents/', ''
                $FilePath = Join-Path $CopilotDir $FileName
                if (Test-Path $FilePath) {
                    Remove-Item -Path $FilePath -Force
                    Write-Host "    - $([IO.Path]::GetFileNameWithoutExtension($FileName))"
                }
            }
        } else {
            Write-Host "    (no manifest entries for copilot-agents — skipping)"
        }
        if ((Get-ChildItem -Path $CopilotDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
            Remove-Item -Path $CopilotDir -Force -ErrorAction SilentlyContinue
        }
    }

    # Remove Copilot config files — only those with our section markers
    $GithubDir = Join-Path (Get-Location) ".github"
    foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
        $ConfigPath = Join-Path $GithubDir $Config
        if (Test-Path $ConfigPath) {
            $content = [IO.File]::ReadAllText($ConfigPath, [Text.Encoding]::UTF8)
            if ($content -match '<!-- a11y-agent-team: start -->') {
                Remove-Item -Path $ConfigPath -Force
                Write-Host "    - $Config"
            } else {
                Write-Host "    ~ $Config (has user content — skipped)"
            }
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

# Remove enforcement hooks (global uninstall only)
if ($Choice -eq "2") {
    Write-Host ""
    Write-Host "  Removing enforcement hooks..."
    $HooksDir = Join-Path $env:USERPROFILE ".claude\hooks"
    foreach ($Hook in @("a11y-team-eval.sh", "a11y-enforce-edit.sh", "a11y-mark-reviewed.sh")) {
        $HookPath = Join-Path $HooksDir $Hook
        if (Test-Path $HookPath) {
            Remove-Item -Path $HookPath -Force
            Write-Host "    - $Hook"
        }
    }
    if ((Test-Path $HooksDir) -and (Get-ChildItem -Path $HooksDir -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
        Remove-Item -Path $HooksDir -Force -ErrorAction SilentlyContinue
    }

    # Remove hook registrations from settings.json
    $SettingsJson = Join-Path $env:USERPROFILE ".claude\settings.json"
    if (Test-Path $SettingsJson) {
        try {
            $settings = Get-Content $SettingsJson -Raw | ConvertFrom-Json
            if ($settings.hooks) {
                $changed = $false
                foreach ($event in @($settings.hooks.PSObject.Properties.Name)) {
                    $entries = @($settings.hooks.$event)
                    $filtered = @($entries | Where-Object {
                        $dominated = $false
                        foreach ($h in $_.hooks) {
                            if ($h.command -and $h.command -match "a11y-") { $dominated = $true }
                        }
                        -not $dominated
                    })
                    if ($filtered.Count -lt $entries.Count) { $changed = $true }
                    if ($filtered.Count -eq 0) {
                        $settings.hooks.PSObject.Properties.Remove($event)
                    } else {
                        $settings.hooks | Add-Member -NotePropertyName $event -NotePropertyValue $filtered -Force
                    }
                }
                if ($changed) {
                    if (($settings.hooks.PSObject.Properties | Measure-Object).Count -eq 0) {
                        $settings.PSObject.Properties.Remove("hooks")
                    }
                    $settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $SettingsJson -Encoding utf8
                    Write-Host "    - Hook registrations removed from settings.json"
                }
            }
        } catch {
            Write-Host "    ! Could not update settings.json (edit manually)"
        }
    }

    # Clean up session markers
    Get-ChildItem -Path $env:TEMP -Filter "a11y-reviewed-*" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
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
Write-Host "  Uninstall complete."
Write-Host ""
