<#
.SYNOPSIS
    Sync HCOS standard labels from scripts/labels.json to a GitHub repository.

.DESCRIPTION
    Reads the label taxonomy source of truth (scripts/labels.json) and applies it
    to the target repository using `gh label create --force` (create-or-update).

    - Common labels are applied to every repository.
    - council:* and type:* (hcos_only_labels) are applied only to HealthCheck-OS.
    - The repository's own repo:* label is applied. HealthCheck-OS additionally
      receives the full repo: registry (it routes cross-repo issues).

    This script does NOT delete labels by default. Use -Prune to remove labels
    that are not in the manifest (off by default; destructive).

    Renames (e.g. repo:DM-kousin -> repo:dm-kousin) are listed in labels.json
    "migrations" and must be run explicitly with -ApplyRenames before normal
    sync, because rename preserves issue associations while a create+delete
    would lose them.

.PARAMETER Repo
    Target repository in owner/name form, e.g. akaza-lab-org/keikakusho.

.PARAMETER Prune
    Delete labels present on the repo but absent from the manifest. Destructive.

.PARAMETER ApplyRenames
    Apply only the rename migrations in labels.json that target this repo, then
    exit before create/update sync. Run normal sync as a second command after
    checking the rename result.

.EXAMPLE
    pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/keikakusho -WhatIf
    pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/DM-kousin -ApplyRenames
    pwsh -File scripts/sync_labels.ps1 -Repo akaza-lab-org/keikakusho
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true)]
    [string]$Repo,

    [switch]$Prune,

    [switch]$ApplyRenames
)

$ErrorActionPreference = "Stop"

$manifestPath = Join-Path $PSScriptRoot "labels.json"
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest not found: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Set-Label {
    param([string]$Name, [string]$Color, [string]$Description)
    if ($PSCmdlet.ShouldProcess("$Repo : $Name", "create/update label")) {
        & gh label create $Name --repo $Repo --color $Color --description $Description --force | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  set  $Name (#$Color)"
        } else {
            Write-Warning "  failed to set $Name"
        }
    }
}

function Get-ExistingLabelNames {
    $labels = & gh label list --repo $Repo --limit 200 --json name | ConvertFrom-Json
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to list labels for $Repo"
    }
    return @($labels | ForEach-Object { $_.name })
}

function Apply-LabelRenames {
    if (-not $manifest.migrations) {
        Write-Host "No migrations are defined."
        return
    }

    $existingNames = Get-ExistingLabelNames
    $applied = 0
    $skipped = 0

    foreach ($m in $manifest.migrations) {
        if ($m.action -ne "rename") { continue }
        if ($m.repos -and ($m.repos -notcontains $Repo)) { continue }

        $fromExists = $existingNames -contains $m.from
        $toExists = $existingNames -contains $m.to

        if (-not $fromExists) {
            Write-Host "  skip rename $($m.from) -> $($m.to) (source label not found)"
            $skipped++
            continue
        }
        if ($toExists) {
            Write-Warning "  cannot rename $($m.from) -> $($m.to): target label already exists. Resolve manually to avoid losing issue associations."
            $skipped++
            continue
        }

        if ($PSCmdlet.ShouldProcess("$Repo : $($m.from) -> $($m.to)", "rename label")) {
            & gh label edit $m.from --repo $Repo --name $m.to | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  renamed $($m.from) -> $($m.to)"
                $existingNames = @($existingNames | Where-Object { $_ -ne $m.from }) + $m.to
                $applied++
            } else {
                Write-Warning "  rename failed: $($m.from) -> $($m.to)"
                $skipped++
            }
        }
    }

    Write-Host ""
    Write-Host "Rename migrations complete. Applied: $applied; skipped: $skipped"
    Write-Host "Next step after review: pwsh -File scripts/sync_labels.ps1 -Repo $Repo"
}

# Rename migrations must run before create/update sync. Otherwise a target label
# can be created first and make GitHub's in-place rename fail.
if ($ApplyRenames) {
    Write-Host "Applying rename migrations only to $Repo ..."
    Apply-LabelRenames
    return
}

# 1. Build the desired label set for this repo.
$desired = [System.Collections.Generic.List[object]]::new()
foreach ($l in $manifest.common_labels) { $desired.Add($l) }

$isHcos = $Repo -ieq "akaza-lab-org/HealthCheck-OS"
if ($isHcos) {
    foreach ($l in $manifest.hcos_only_labels) { $desired.Add($l) }
    foreach ($l in $manifest.repo_registry)    { $desired.Add($l) }
} else {
    $selfName = $manifest.repo_self_label.$Repo
    if (-not $selfName) {
        Write-Warning "No repo_self_label entry for $Repo. Skipping repo: label. Add it to labels.json."
    } else {
        $selfLabel = $manifest.repo_registry | Where-Object { $_.name -eq $selfName }
        if ($selfLabel) { $desired.Add($selfLabel) }
    }
}

Write-Host "Applying $($desired.Count) labels to $Repo ..."
foreach ($l in $desired) {
    Set-Label -Name $l.name -Color $l.color -Description $l.description
}

# 2. Optional prune of unmanaged labels.
if ($Prune) {
    $managed = $desired.name
    # GitHub default labels are intentionally left alone unless explicitly listed.
    $githubDefaults = @("bug","documentation","duplicate","enhancement","good first issue","help wanted","invalid","question","wontfix")
    $existing = & gh label list --repo $Repo --limit 200 --json name | ConvertFrom-Json
    foreach ($e in $existing) {
        if ($managed -contains $e.name) { continue }
        if ($githubDefaults -contains $e.name) { continue }
        if ($PSCmdlet.ShouldProcess("$Repo : $($e.name)", "DELETE unmanaged label")) {
            & gh label delete $e.name --repo $Repo --yes | Out-Null
            Write-Host "  deleted $($e.name)"
        }
    }
}

Write-Host ""
Write-Host "Done. Review with: gh label list --repo $Repo --limit 100"
