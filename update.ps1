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

# Helper: recursively sync a source directory to a destination directory.
# Updates changed files, adds new files, and removes files that no longer exist in source.
# Auto-discovered — no hardcoded file list to maintain.
function Sync-GitHubDir {
    param([string]$SrcDir, [string]$DstDir, [string]$Label)
    if (-not (Test-Path $SrcDir)) { return }
    if (-not (Test-Path $DstDir)) { return }  # only sync if previously installed
    # Update/add
    foreach ($File in Get-ChildItem -Recurse -File $SrcDir) {
        $Rel = $File.FullName.Substring($SrcDir.Length).TrimStart('\')
        $Dst = Join-Path $DstDir $Rel
        New-Item -ItemType Directory -Force -Path (Split-Path $Dst) | Out-Null
        $SrcContent = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
        $DstContent = Get-Content $Dst -Raw -ErrorAction SilentlyContinue
        if ($SrcContent -ne $DstContent) {
            Copy-Item -Path $File.FullName -Destination $Dst -Force
            Write-Log "Updated $Label\$Rel"
            $script:Updated++
        }
    }
    # Remove obsolete
    foreach ($File in Get-ChildItem -Recurse -File $DstDir) {
        $Rel = $File.FullName.Substring($DstDir.Length).TrimStart('\')
        if (-not (Test-Path (Join-Path $SrcDir $Rel))) {
            Remove-Item -Path $File.FullName -Force
            Write-Log "Removed $Label\$Rel"
            $script:Updated++
        }
    }
}

$GitHubSrc = Join-Path $CacheDir ".github"

# Update Copilot assets for project install
if ($Project) {
    $ProjectRoot = (Get-Location).Path
    $ProjectGitHub = Join-Path $ProjectRoot ".github"
    if (Test-Path $ProjectGitHub) {
        # Agents (all files: *.agent.md + AGENTS.md, shared-instructions.md, etc.)
        Sync-GitHubDir -SrcDir (Join-Path $GitHubSrc "agents") -DstDir (Join-Path $ProjectGitHub "agents") -Label "agents"
        # Config files
        foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
            $Src = Join-Path $GitHubSrc $Config
            $Dst = Join-Path $ProjectGitHub $Config
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
        # Asset subdirs: skills, instructions, prompts, hooks
        foreach ($SubDir in @("skills", "instructions", "prompts", "hooks")) {
            Sync-GitHubDir -SrcDir (Join-Path $GitHubSrc $SubDir) -DstDir (Join-Path $ProjectGitHub $SubDir) -Label $SubDir
        }
    }
}

# Update Copilot assets for global install
if (-not $Project) {
    $CentralRoot   = Join-Path $env:USERPROFILE ".a11y-agent-team"
    $Central       = Join-Path $CentralRoot "copilot-agents"
    $CentralPrompts      = Join-Path $CentralRoot "copilot-prompts"
    $CentralInstructions = Join-Path $CentralRoot "copilot-instructions-files"
    $CentralSkills       = Join-Path $CentralRoot "copilot-skills"

    # Update central stores (agents, prompts, instructions, skills)
    if (Test-Path $Central) {
        foreach ($File in Get-ChildItem -Path (Join-Path $GitHubSrc "agents") -Filter "*.agent.md" -ErrorAction SilentlyContinue) {
            $Dst = Join-Path $Central $File.Name
            $SrcContent = Get-Content $File.FullName -Raw -ErrorAction SilentlyContinue
            $DstContent = Get-Content $Dst -Raw -ErrorAction SilentlyContinue
            if ($SrcContent -ne $DstContent) {
                Copy-Item -Path $File.FullName -Destination $Dst -Force
                Write-Log "Updated central agent: $($File.BaseName)"
                $Updated++
            }
        }
        # Remove central agents no longer in repo
        foreach ($File in Get-ChildItem -Path $Central -Filter "*.agent.md" -ErrorAction SilentlyContinue) {
            if (-not (Test-Path (Join-Path $GitHubSrc "agents\$($File.Name)"))) {
                Remove-Item -Path $File.FullName -Force
                Write-Log "Removed central agent: $($File.BaseName)"
                $Updated++
            }
        }
    }
    if (Test-Path $CentralPrompts)      { Sync-GitHubDir -SrcDir (Join-Path $GitHubSrc "prompts")      -DstDir $CentralPrompts      -Label "central-prompts" }
    if (Test-Path $CentralInstructions) { Sync-GitHubDir -SrcDir (Join-Path $GitHubSrc "instructions") -DstDir $CentralInstructions -Label "central-instructions" }
    if (Test-Path $CentralSkills)       { Sync-GitHubDir -SrcDir (Join-Path $GitHubSrc "skills")       -DstDir $CentralSkills       -Label "central-skills" }
    # Update config files in central store
    foreach ($Config in @("copilot-instructions.md", "copilot-review-instructions.md", "copilot-commit-message-instructions.md")) {
        $Src = Join-Path $GitHubSrc $Config
        $Dst = Join-Path $CentralRoot $Config
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

    # Push agents, prompts, and instructions to VS Code User profile folders.
    # VS Code 1.110+ discovers from User/prompts/; older from User/ root. Both are updated.
    $VSCodeProfiles = @(
        (Join-Path $env:APPDATA "Code\User"),
        (Join-Path $env:APPDATA "Code - Insiders\User")
    )
    foreach ($ProfileDir in $VSCodeProfiles) {
        $PromptsDir = Join-Path $ProfileDir "prompts"
        # Only update if agents were previously installed
        $HasAgents = (Get-ChildItem -Path $ProfileDir -Filter "*.agent.md" -ErrorAction SilentlyContinue).Count -gt 0
        $HasPrompts = (Test-Path $PromptsDir) -and ((Get-ChildItem -Path $PromptsDir -Filter "*.agent.md" -ErrorAction SilentlyContinue).Count -gt 0)
        if (-not ($HasAgents -or $HasPrompts)) { continue }
        New-Item -ItemType Directory -Force -Path $PromptsDir | Out-Null
        foreach ($File in Get-ChildItem -Path $Central -Filter "*.agent.md" -ErrorAction SilentlyContinue) {
            Copy-Item -Path $File.FullName -Destination (Join-Path $ProfileDir $File.Name) -Force
            Copy-Item -Path $File.FullName -Destination (Join-Path $PromptsDir $File.Name) -Force
        }
        foreach ($File in Get-ChildItem -Path $CentralPrompts -Filter "*.prompt.md" -ErrorAction SilentlyContinue) {
            Copy-Item -Path $File.FullName -Destination (Join-Path $ProfileDir $File.Name) -Force
            Copy-Item -Path $File.FullName -Destination (Join-Path $PromptsDir $File.Name) -Force
        }
        foreach ($File in Get-ChildItem -Path $CentralInstructions -Filter "*.instructions.md" -ErrorAction SilentlyContinue) {
            Copy-Item -Path $File.FullName -Destination (Join-Path $ProfileDir $File.Name) -Force
            Copy-Item -Path $File.FullName -Destination (Join-Path $PromptsDir $File.Name) -Force
        }
        Write-Log "Updated VS Code profile: $ProfileDir"
    }
}

# Save version
$NewHash | Out-File -FilePath $VersionFile -Encoding utf8 -NoNewline

if ($Updated -gt 0) {
    Write-Log "Update complete ($Updated files updated, version $NewHash)."
} else {
    Write-Log "Files already match latest version ($NewHash)."
}
