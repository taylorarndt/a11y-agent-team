# A11y Agent Team - Update Script (Windows PowerShell)
# Built by Taylor Arndt - https://github.com/taylorarndt
#
# Checks for updates from GitHub and installs them.
# Can be run manually or automatically via Scheduled Task.
#
# Usage:
#   powershell -File update.ps1              Update global install
#   powershell -File update.ps1 -Project     Update project install
#   powershell -File update.ps1 -Silent      Suppress output (for scheduled runs)

param(
    [switch]$Project,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/taylorarndt/a11y-agent-team.git"
$CacheDir = Join-Path $env:USERPROFILE ".claude\.a11y-agent-team-repo"
$VersionFile = Join-Path $env:USERPROFILE ".claude\.a11y-agent-team-version"
$LogFile = Join-Path $env:USERPROFILE ".claude\.a11y-agent-team-update.log"

# Agents are auto-detected from the cached repo after clone/pull

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Entry = "[$Timestamp] $Message"
    Add-Content -Path $LogFile -Value $Entry
    if (-not $Silent) {
        Write-Host "  $Message"
    }
}

if ($Project) {
    $InstallDir = Join-Path (Get-Location) ".claude"
} else {
    $InstallDir = Join-Path $env:USERPROFILE ".claude"
}

# Check for git
try {
    git --version | Out-Null
} catch {
    Write-Log "Error: git is not installed. Cannot check for updates."
    exit 1
}

# Clone or pull the repo
$GitDir = Join-Path $CacheDir ".git"
if (Test-Path $GitDir) {
    Set-Location $CacheDir
    git fetch origin main --quiet 2>$null
    $LocalHash = git rev-parse HEAD 2>$null
    $RemoteHash = git rev-parse origin/main 2>$null

    if ($LocalHash -eq $RemoteHash) {
        Write-Log "Already up to date."
        exit 0
    }

    git reset --hard origin/main --quiet 2>$null
    Write-Log "Pulled latest changes."
} else {
    Write-Log "Downloading a11y-agent-team..."
    $ParentDir = Split-Path $CacheDir -Parent
    New-Item -ItemType Directory -Force -Path $ParentDir | Out-Null
    git clone --quiet $RepoUrl $CacheDir 2>$null
    Write-Log "Repository cloned."
}

Set-Location $CacheDir
$NewHash = git rev-parse --short HEAD 2>$null

# Check if install directory exists
$AgentsDir = Join-Path $InstallDir "agents"
if (-not (Test-Path $AgentsDir)) {
    Write-Log "Install directory not found at $AgentsDir. Run install.ps1 first."
    exit 1
}

# Auto-detect and copy updated agents
$Updated = 0
$AgentsSrcDir = Join-Path $CacheDir ".claude\agents"
if (Test-Path $AgentsSrcDir) {
    foreach ($File in Get-ChildItem -Path $AgentsSrcDir -Filter "*.md") {
        $Dst = Join-Path $InstallDir "agents\$($File.Name)"
        $SrcContent = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
        $DstContent = Get-Content $Dst -Raw -ErrorAction SilentlyContinue
        if ($SrcContent -ne $DstContent) {
            Copy-Item -Path $File.FullName -Destination $Dst -Force
            $Name = $File.BaseName
            Write-Log "Updated: $Name"
            $Updated++
        }
    }
}

# Remove agents that no longer exist in the repo
$InstalledAgentsDir = Join-Path $InstallDir "agents"
if (Test-Path $InstalledAgentsDir) {
    foreach ($File in Get-ChildItem -Path $InstalledAgentsDir -Filter "*.md") {
        $Src = Join-Path $AgentsSrcDir $File.Name
        if (-not (Test-Path $Src)) {
            Remove-Item -Path $File.FullName -Force
            Write-Log "Removed (no longer in repo): $($File.BaseName)"
            $Updated++
        }
    }
}

# Copy updated hook
$HookSrc = Join-Path $CacheDir ".claude\hooks\a11y-team-eval.ps1"
$HookDst = Join-Path $InstallDir "hooks\a11y-team-eval.ps1"
if ((Test-Path $HookSrc) -and (Test-Path $HookDst)) {
    $SrcContent = Get-Content $HookSrc -Raw -ErrorAction SilentlyContinue
    $DstContent = Get-Content $HookDst -Raw -ErrorAction SilentlyContinue
    if ($SrcContent -ne $DstContent) {
        Copy-Item -Path $HookSrc -Destination $HookDst -Force
        Write-Log "Updated: hook script"
        $Updated++
    }
}

# Update Copilot agents if previously installed
$CopilotDirs = @()
if ($Project) {
    $ProjectCopilot = Join-Path (Get-Location) ".github\agents"
    if (Test-Path $ProjectCopilot) { $CopilotDirs += $ProjectCopilot }
} else {
    # Central store
    $Central = Join-Path $env:USERPROFILE ".a11y-agent-team\copilot-agents"
    if (Test-Path $Central) { $CopilotDirs += $Central }

    # VS Code profile folders (only if agents were previously installed there)
    $VSCodeProfile = Join-Path $env:APPDATA "Code\User"
    $VSCodeInsidersProfile = Join-Path $env:APPDATA "Code - Insiders\User"
    if ((Get-ChildItem -Path $VSCodeProfile -Filter "*.agent.md" -ErrorAction SilentlyContinue).Count -gt 0) {
        $CopilotDirs += $VSCodeProfile
    }
    if ((Get-ChildItem -Path $VSCodeInsidersProfile -Filter "*.agent.md" -ErrorAction SilentlyContinue).Count -gt 0) {
        $CopilotDirs += $VSCodeInsidersProfile
    }
}

$CopilotSrcDir = Join-Path $CacheDir ".github\agents"
foreach ($CopilotDir in $CopilotDirs) {
    if (Test-Path $CopilotSrcDir) {
        foreach ($File in Get-ChildItem -Path $CopilotSrcDir -Filter "*.agent.md") {
            $Dst = Join-Path $CopilotDir $File.Name
            $SrcContent = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
            $DstContent = Get-Content $Dst -Raw -ErrorAction SilentlyContinue
            if ($SrcContent -ne $DstContent) {
                Copy-Item -Path $File.FullName -Destination $Dst -Force
                Write-Log "Updated Copilot agent: $($File.BaseName)"
                $Updated++
            }
        }
    }

    # Update Copilot config files (only for central store and project)
    if ($CopilotDir -eq $Central) {
        $ConfigDir = Join-Path $env:USERPROFILE ".a11y-agent-team"
    } elseif ($CopilotDir -match "\.github\\agents$") {
        $ConfigDir = Split-Path $CopilotDir -Parent
    } else {
        continue
    }
    foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
        $Src = Join-Path $CacheDir ".github\$Config"
        $Dst = Join-Path $ConfigDir $Config
        if ((Test-Path $Src) -and (Test-Path $Dst)) {
            $SrcContent = Get-Content $Src -Raw -ErrorAction SilentlyContinue
            $DstContent = Get-Content $Dst -Raw -ErrorAction SilentlyContinue
            if ($SrcContent -ne $DstContent) {
                Copy-Item -Path $Src -Destination $Dst -Force
                Write-Log "Updated Copilot config: $Config"
                $Updated++
            }
        }
    }
}

# Save version
$NewHash | Out-File -FilePath $VersionFile -Encoding utf8 -NoNewline

if ($Updated -gt 0) {
    Write-Log "Update complete ($Updated files updated, version $NewHash)."
} else {
    Write-Log "Files already match latest version ($NewHash)."
}
