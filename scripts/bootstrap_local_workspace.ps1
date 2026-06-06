[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet("dev", "subpc", "clinic", "all")]
    [string]$Role = "dev",

    [string[]]$Repos = @(),

    [switch]$InstallHooks,
    [switch]$SetupSkills,
    [switch]$Fetch
)

$ErrorActionPreference = "Stop"

function Normalize-RemoteUrl {
    param([string]$Url)
    if ([string]::IsNullOrWhiteSpace($Url)) {
        return ""
    }
    $value = $Url.Trim()
    $value = $value -replace "^git@github\.com:", "https://github.com/"
    $value = $value -replace "\.git$", ""
    return $value.ToLowerInvariant()
}

function Invoke-GitOutput {
    param(
        [string]$RepoPath,
        [string[]]$GitArgs
    )
    $output = & git -C $RepoPath @GitArgs 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $null
    }
    return $output
}

function Resolve-RepoAliases {
    param([string[]]$Values)
    $allowed = @("hcos", "skills", "summarymaker", "kensin", "ahk", "pdf_digitizer", "ikensho_git", "keikakusho", "DM-kousin", "wakumy_apilot")
    $allowedSet = @{}
    foreach ($alias in $allowed) {
        $allowedSet[$alias] = $true
    }

    $resolved = @()
    foreach ($value in $Values) {
        foreach ($item in ($value -split ",")) {
            $alias = $item.Trim()
            if ([string]::IsNullOrWhiteSpace($alias)) {
                continue
            }
            if (-not $allowedSet.ContainsKey($alias)) {
                throw "Unknown repository alias: $alias"
            }
            $resolved += $alias
        }
    }
    return @($resolved | Select-Object -Unique)
}

$scriptRoot = $PSScriptRoot
$repoRoot = (Resolve-Path (Join-Path $scriptRoot "..")).Path

$repositories = @(
    @{ Alias = "hcos"; Name = "HealthCheck-OS"; Roles = @("dev", "subpc", "all"); Path = "C:\data\GitHub_org\HealthCheck-OS"; Remote = "https://github.com/akaza-lab-org/HealthCheck-OS"; DefaultBranch = "main" },
    @{ Alias = "skills"; Name = "skills"; Roles = @("dev", "all"); Path = "C:\data\GitHub_org\skills"; Remote = "https://github.com/akaza-lab-org/skills"; DefaultBranch = "main" },
    @{ Alias = "summarymaker"; Name = "summarymaker"; Roles = @("dev", "all"); Path = "C:\data\GitHub_org\summarymaker"; Remote = "https://github.com/akaza-lab-org/summarymaker"; DefaultBranch = "main" },
    @{ Alias = "kensin"; Name = "kensin"; Roles = @("dev", "subpc", "all"); Path = "C:\data\GitHub\kensin"; Remote = "https://github.com/akaza-lab-org/clinic-app"; DefaultBranch = "main" },
    @{ Alias = "ahk"; Name = "AHK_setting"; Roles = @("dev", "subpc", "clinic", "all"); Path = "C:\data\GitHub\ahk"; Remote = "https://github.com/akaza-lab-org/AHK_setting"; DefaultBranch = "main" },
    @{ Alias = "pdf_digitizer"; Name = "pdf_digitizer"; Roles = @("dev", "all"); Path = "C:\data\GitHub\pdf_digitizer"; Remote = "https://github.com/akaza-lab-org/pdf_digitizer"; DefaultBranch = "master" },
    @{ Alias = "ikensho_git"; Name = "ikensho_git"; Roles = @("all"); Path = "C:\data\GitHub_org\ikensho_git"; Remote = "https://github.com/akaza-lab-org/ikensho_git"; DefaultBranch = "main" },
    @{ Alias = "keikakusho"; Name = "keikakusho"; Roles = @("all"); Path = "C:\data\GitHub_org\keikakusho"; Remote = "https://github.com/akaza-lab-org/keikakusho"; DefaultBranch = "main" },
    @{ Alias = "DM-kousin"; Name = "DM-kousin"; Roles = @("all"); Path = "C:\data\GitHub_org\DM-kousin"; Remote = "https://github.com/akaza-lab-org/DM-kousin"; DefaultBranch = "main" },
    @{ Alias = "wakumy_apilot"; Name = "wakumy_apilot"; Roles = @("all"); Path = "C:\data\GitHub_org\wakumy_apilot"; Remote = "https://github.com/akaza-lab-org/wakumy_apilot"; DefaultBranch = "main" }
)

$repoAliases = Resolve-RepoAliases -Values $Repos
if ($repoAliases.Count -gt 0) {
    $repoSet = @{}
    foreach ($repoAlias in $repoAliases) {
        $repoSet[$repoAlias] = $true
    }
    $selected = $repositories | Where-Object { $repoSet.ContainsKey($_.Alias) }
} else {
    $selected = $repositories | Where-Object { $_.Roles -contains $Role }
}

if ($selected.Count -eq 0) {
    throw "No repositories selected. Check -Role or -Repos."
}

$errors = 0
$cloned = 0
$existing = 0

foreach ($repo in $selected) {
    $repoPath = $repo.Path
    $parent = Split-Path -Parent $repoPath
    $gitDir = Join-Path $repoPath ".git"

    Write-Host ""
    Write-Host "== $($repo.Name) =="
    Write-Host "Path: $repoPath"

    if (-not (Test-Path -LiteralPath $repoPath)) {
        if ($PSCmdlet.ShouldProcess($repoPath, "Clone $($repo.Remote)")) {
            if (-not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            & git clone "$($repo.Remote).git" $repoPath
            if ($LASTEXITCODE -ne 0) {
                throw "git clone failed: $($repo.Name)"
            }
            $cloned += 1
        }
        continue
    }

    if (-not (Test-Path -LiteralPath $gitDir)) {
        Write-Error "Path exists but is not a git repository: $repoPath"
        $errors += 1
        continue
    }

    $actualRemote = Invoke-GitOutput -RepoPath $repoPath -GitArgs @("remote", "get-url", "origin")
    if ((Normalize-RemoteUrl $actualRemote) -ne (Normalize-RemoteUrl $repo.Remote)) {
        Write-Error "Remote mismatch for $($repo.Name): $actualRemote"
        $errors += 1
        continue
    }

    if ($Fetch) {
        if ($PSCmdlet.ShouldProcess($repoPath, "Fetch origin")) {
            & git -C $repoPath fetch --quiet origin
            if ($LASTEXITCODE -ne 0) {
                throw "git fetch failed: $($repo.Name)"
            }
        }
    }

    $existing += 1
    Write-Host "OK: existing standard repository"
}

if ($errors -gt 0) {
    throw "Bootstrap stopped because repository validation failed."
}

$selectedAliases = @($selected | ForEach-Object { $_.Alias })

if ($WhatIfPreference) {
    Write-Host ""
    Write-Host "WhatIf: workspace check and hook installation are skipped after clone preview."
} else {
    Write-Host ""
    Write-Host "Running workspace check..."
    $checkArgs = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", (Join-Path $scriptRoot "check_local_workspace.ps1"),
        "-Role", $Role,
        "-Repos"
    ) + $selectedAliases
    if ($Fetch) {
        $checkArgs += "-Fetch"
    }
    & powershell @checkArgs
    if ($LASTEXITCODE -ne 0) {
        throw "Workspace check failed."
    }

    if ($InstallHooks) {
        Write-Host ""
        Write-Host "Installing git safety hooks..."
        $hookArgs = @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", (Join-Path $scriptRoot "install_git_safety_hooks.ps1"),
            "-Role", $Role,
            "-Repos"
        ) + $selectedAliases
        & powershell @hookArgs
        if ($LASTEXITCODE -ne 0) {
            throw "Git safety hook installation failed."
        }
    }
}

if ($SetupSkills -and ($selectedAliases -contains "skills")) {
    $skillsSetup = "C:\data\GitHub_org\skills\setup-shared-skills.ps1"
    if (Test-Path -LiteralPath $skillsSetup) {
        if ($PSCmdlet.ShouldProcess($skillsSetup, "Run shared skills setup")) {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $skillsSetup
            if ($LASTEXITCODE -ne 0) {
                throw "Shared skills setup failed."
            }
        }
    } else {
        Write-Warning "Shared skills setup script not found: $skillsSetup"
    }
}

Write-Host ""
Write-Host "HCOS local workspace bootstrap summary"
Write-Host "Role: $Role"
Write-Host "Repositories: $($selectedAliases -join ', ')"
Write-Host "Cloned: $cloned"
Write-Host "Existing: $existing"
Write-Host "Hooks requested: $InstallHooks"
Write-Host "Skills setup requested: $SetupSkills"
