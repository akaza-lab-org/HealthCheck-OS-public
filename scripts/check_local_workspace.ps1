param(
    [ValidateSet("dev", "subpc", "clinic", "all")]
    [string]$Role = "dev",
    [string[]]$Repos = @(),
    [switch]$Fetch
)

$ErrorActionPreference = "Continue"

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

function Invoke-Git {
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

$repoRegistry = @(
    @{
        Alias = "hcos"
        Name = "HealthCheck-OS"
        Roles = @("dev", "subpc", "all")
        Path = "C:\data\GitHub_org\HealthCheck-OS"
        Remote = "https://github.com/akaza-lab-org/HealthCheck-OS"
        DefaultBranch = "main"
    },
    @{
        Alias = "skills"
        Name = "skills"
        Roles = @("dev", "all")
        Path = "C:\data\GitHub_org\skills"
        Remote = "https://github.com/akaza-lab-org/skills"
        DefaultBranch = "main"
    },
    @{
        Alias = "summarymaker"
        Name = "summarymaker"
        Roles = @("dev", "all")
        Path = "C:\data\GitHub_org\summarymaker"
        Remote = "https://github.com/akaza-lab-org/summarymaker"
        DefaultBranch = "main"
    },
    @{
        Alias = "kensin"
        Name = "kensin"
        Roles = @("dev", "subpc", "all")
        Path = "C:\data\GitHub\kensin"
        Remote = "https://github.com/akaza-lab-org/clinic-app"
        DefaultBranch = "main"
    },
    @{
        Alias = "ahk"
        Name = "ahk"
        Roles = @("dev", "subpc", "clinic", "all")
        Path = "C:\data\GitHub\ahk"
        Remote = "https://github.com/akaza-lab-org/AHK_setting"
        DefaultBranch = "main"
    },
    @{
        Alias = "pdf_digitizer"
        Name = "pdf_digitizer"
        Roles = @("dev", "all")
        Path = "C:\data\GitHub\pdf_digitizer"
        Remote = "https://github.com/akaza-lab-org/pdf_digitizer"
        DefaultBranch = "master"
    },
    @{
        Alias = "ikensho_git"
        Name = "ikensho_git"
        Roles = @("all")
        Path = "C:\data\GitHub_org\ikensho_git"
        Remote = "https://github.com/akaza-lab-org/ikensho_git"
        DefaultBranch = "main"
    },
    @{
        Alias = "keikakusho"
        Name = "keikakusho"
        Roles = @("all")
        Path = "C:\data\GitHub_org\keikakusho"
        Remote = "https://github.com/akaza-lab-org/keikakusho"
        DefaultBranch = "main"
    },
    @{
        Alias = "DM-kousin"
        Name = "DM-kousin"
        Roles = @("all")
        Path = "C:\data\GitHub_org\DM-kousin"
        Remote = "https://github.com/akaza-lab-org/DM-kousin"
        DefaultBranch = "main"
    },
    @{
        Alias = "wakumy_apilot"
        Name = "wakumy_apilot"
        Roles = @("all")
        Path = "C:\data\GitHub_org\wakumy_apilot"
        Remote = "https://github.com/akaza-lab-org/wakumy_apilot"
        DefaultBranch = "main"
    }
)

$repoAliases = Resolve-RepoAliases -Values $Repos
if ($repoAliases.Count -gt 0) {
    $repoSet = @{}
    foreach ($repoAlias in $repoAliases) {
        $repoSet[$repoAlias] = $true
    }
    $selected = $repoRegistry | Where-Object { $repoSet.ContainsKey($_.Alias) }
} else {
    $selected = $repoRegistry | Where-Object { $_.Roles -contains $Role }
}
$errorCount = 0
$warningCount = 0
$results = @()

foreach ($repo in $selected) {
    $status = "OK"
    $details = @()
    $repoPath = $repo.Path

    if (!(Test-Path -LiteralPath $repoPath)) {
        $status = "ERROR"
        $details += "missing path"
        $errorCount++
        $results += [pscustomobject]@{
            Repo = $repo.Name
            Status = $status
            Path = $repoPath
            Branch = ""
            Details = ($details -join "; ")
        }
        continue
    }

    if (!(Test-Path -LiteralPath (Join-Path $repoPath ".git"))) {
        $status = "ERROR"
        $details += "not a git repo"
        $errorCount++
        $results += [pscustomobject]@{
            Repo = $repo.Name
            Status = $status
            Path = $repoPath
            Branch = ""
            Details = ($details -join "; ")
        }
        continue
    }

    if ($Fetch) {
        Invoke-Git -RepoPath $repoPath -GitArgs @("fetch", "--quiet", "origin") | Out-Null
    }

    $actualRemote = Invoke-Git -RepoPath $repoPath -GitArgs @("remote", "get-url", "origin")
    if ((Normalize-RemoteUrl $actualRemote) -ne (Normalize-RemoteUrl $repo.Remote)) {
        $status = "ERROR"
        $details += "remote mismatch: $actualRemote"
        $errorCount++
    }

    $branch = Invoke-Git -RepoPath $repoPath -GitArgs @("branch", "--show-current")
    if ([string]::IsNullOrWhiteSpace($branch)) {
        $branch = "(detached)"
        if ($status -eq "OK") { $status = "WARN" }
        $details += "detached HEAD"
        $warningCount++
    } elseif ($branch -ne $repo.DefaultBranch) {
        if ($status -eq "OK") { $status = "WARN" }
        $details += "branch=$branch"
        $warningCount++
    }

    $porcelain = Invoke-Git -RepoPath $repoPath -GitArgs @("status", "--porcelain")
    if ($porcelain) {
        if ($status -eq "OK") { $status = "WARN" }
        $details += "working tree has changes"
        $warningCount++
    }

    $upstream = Invoke-Git -RepoPath $repoPath -GitArgs @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")
    if ($upstream) {
        $counts = Invoke-Git -RepoPath $repoPath -GitArgs @("rev-list", "--left-right", "--count", "$upstream...HEAD")
        if ($counts) {
            $parts = ($counts -join " ").Trim() -split "\s+"
            if ($parts.Length -ge 2) {
                $behind = [int]$parts[0]
                $ahead = [int]$parts[1]
                if ($behind -gt 0 -or $ahead -gt 0) {
                    if ($status -eq "OK") { $status = "WARN" }
                    $details += "ahead=$ahead behind=$behind"
                    $warningCount++
                }
            }
        }
    } else {
        if ($status -eq "OK") { $status = "WARN" }
        $details += "no upstream"
        $warningCount++
    }

    $stagedFiles = Invoke-Git -RepoPath $repoPath -GitArgs @("diff", "--cached", "--name-only")
    $risky = @()
    foreach ($file in $stagedFiles) {
        if ($file -match "(^|/)(\.env|\.env\..*|config\.ini)$" -or
            $file -match "(secret|credential|token|password)" -or
            $file -match "(^|/)(log|logs|exports|dist)/") {
            $risky += $file
        }
    }
    if ($risky.Count -gt 0) {
        $status = "ERROR"
        $details += "staged risky files: $($risky -join ', ')"
        $errorCount++
    }

    if ($details.Count -eq 0) {
        $details += "standard path and remote"
    }

    $results += [pscustomobject]@{
        Repo = $repo.Name
        Status = $status
        Path = $repoPath
        Branch = $branch
        Details = ($details -join "; ")
    }
}

$results | Format-Table -AutoSize
Write-Host ""
Write-Host "Summary: ERROR=$errorCount WARN=$warningCount ROLE=$Role"

if ($errorCount -gt 0) {
    exit 1
}

exit 0
