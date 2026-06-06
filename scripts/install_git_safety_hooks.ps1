[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet("dev", "subpc", "clinic", "all")]
    [string]$Role = "dev",

    [string[]]$Repos = @(),

    [switch]$Force
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$hookSource = Join-Path $repoRoot "scripts\git-hooks\pre-push"

if (-not (Test-Path -LiteralPath $hookSource)) {
    throw "Hook source not found: $hookSource"
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

$repositories = @(
    @{ Alias = "hcos"; Name = "HealthCheck-OS"; Path = "C:\path\to\repos\HealthCheck-OS"; Roles = @("dev", "subpc", "all") },
    @{ Alias = "skills"; Name = "skills"; Path = "C:\path\to\repos\skills"; Roles = @("dev", "all") },
    @{ Alias = "summarymaker"; Name = "summarymaker"; Path = "C:\path\to\repos\summarymaker"; Roles = @("dev", "all") },
    @{ Alias = "kensin"; Name = "kensin"; Path = "C:\data\GitHub\kensin"; Roles = @("dev", "subpc", "all") },
    @{ Alias = "ahk"; Name = "AHK_setting"; Path = "C:\path\to\apps\ahk"; Roles = @("dev", "subpc", "clinic", "all") },
    @{ Alias = "pdf_digitizer"; Name = "pdf_digitizer"; Path = "C:\data\GitHub\pdf_digitizer"; Roles = @("dev", "all") },
    @{ Alias = "ikensho_git"; Name = "ikensho_git"; Path = "C:\path\to\repos\ikensho_git"; Roles = @("all") },
    @{ Alias = "keikakusho"; Name = "keikakusho"; Path = "C:\path\to\repos\keikakusho"; Roles = @("all") },
    @{ Alias = "DM-kousin"; Name = "DM-kousin"; Path = "C:\path\to\repos\DM-kousin"; Roles = @("all") },
    @{ Alias = "wakumy_apilot"; Name = "wakumy_apilot"; Path = "C:\path\to\repos\wakumy_apilot"; Roles = @("all") }
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
$hookContent = [System.IO.File]::ReadAllText($hookSource)
$hookContent = $hookContent -replace "`r`n", "`n"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$installed = 0
$skipped = 0
$missing = 0

foreach ($repo in $selected) {
    $repoPath = $repo.Path
    $gitDir = Join-Path $repoPath ".git"
    $hooksDir = Join-Path $gitDir "hooks"
    $target = Join-Path $hooksDir "pre-push"

    if (-not (Test-Path -LiteralPath $gitDir)) {
        Write-Warning "Missing git repository: $($repo.Name) ($repoPath)"
        $missing += 1
        continue
    }

    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        Write-Warning "Hook already exists, skipped: $($repo.Name) ($target). Use -Force to replace it."
        $skipped += 1
        continue
    }

    if ($PSCmdlet.ShouldProcess($target, "Install HCOS pre-push safety hook")) {
        if (-not (Test-Path -LiteralPath $hooksDir)) {
            New-Item -ItemType Directory -Path $hooksDir | Out-Null
        }

        [System.IO.File]::WriteAllText($target, $hookContent, $utf8NoBom)
        $installed += 1
        Write-Host "Installed: $($repo.Name) -> $target"
    }
}

Write-Host ""
Write-Host "HCOS git safety hook install summary"
Write-Host "Role: $Role"
Write-Host "Installed: $installed"
Write-Host "Skipped: $skipped"
Write-Host "Missing: $missing"
Write-Host ""
Write-Host "This hook blocks direct push to main/master. It does not block GitHub UI/API merge."
