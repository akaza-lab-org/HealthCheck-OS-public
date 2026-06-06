# Fix Git ACL Permissions for HealthCheck-OS Repositories
#
# このスクリプトは、Windows ACL で .git ディレクトリへの書き込み権限が
# 制限されている場合に、権限をリセット・修復します。
#
# 用途: git add / git commit が .git/index.lock 権限エラーで失敗する場合
# 実行: powershell -ExecutionPolicy Bypass -File .\fix_git_acl_permissions.ps1

param(
    [string]$RepoPath = $PWD,
    [switch]$Verify = $false
)

Write-Host "=== Git ACL Permission Fixer ===" -ForegroundColor Cyan
Write-Host "Target: $RepoPath" -ForegroundColor Cyan

# .git ディレクトリの確認
if (-not (Test-Path "$RepoPath\.git")) {
    Write-Host "✗ Error: .git directory not found at $RepoPath" -ForegroundColor Red
    exit 1
}

# 現在のユーザーを取得
$CurrentUser = $env:USERNAME
$ComputerName = $env:COMPUTERNAME
$FullUsername = "$ComputerName\$CurrentUser"

Write-Host "User: $FullUsername" -ForegroundColor Green

# ACL リセット
Write-Host "`n[Step 1] Resetting .git ACL..." -ForegroundColor Yellow
icacls "$RepoPath\.git" /reset /T /C | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ ACL reset successful" -ForegroundColor Green
} else {
    Write-Host "✗ ACL reset failed (may require admin rights)" -ForegroundColor Red
    exit 1
}

# ユーザーにフル権限を付与
Write-Host "`n[Step 2] Granting full permissions to $FullUsername..." -ForegroundColor Yellow
icacls "$RepoPath\.git" /grant:r "$FullUsername`:(F)" /T /C | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Permissions granted successfully" -ForegroundColor Green
} else {
    Write-Host "✗ Permission grant failed" -ForegroundColor Red
    exit 1
}

# 検証
Write-Host "`n[Step 3] Verifying permissions..." -ForegroundColor Yellow
$AclOutput = icacls "$RepoPath\.git" | Select-Object -First 2
Write-Host $AclOutput -ForegroundColor Green

# オプション: git add テスト
if ($Verify) {
    Write-Host "`n[Step 4] Testing git add..." -ForegroundColor Yellow

    Push-Location $RepoPath

    # テストファイル作成
    $TestFile = ".acl_verify_test"
    "ACL verification test" | Out-File -FilePath $TestFile -Encoding UTF8

    # git add テスト
    git add $TestFile 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ git add works correctly" -ForegroundColor Green

        # テストファイル削除
        git restore --staged $TestFile
        Remove-Item $TestFile -ErrorAction SilentlyContinue

    } else {
        Write-Host "✗ git add still fails - may require further investigation" -ForegroundColor Red
        Remove-Item $TestFile -ErrorAction SilentlyContinue
        Pop-Location
        exit 1
    }

    Pop-Location
}

Write-Host "`n=== Complete ===" -ForegroundColor Green
Write-Host "✓ Git ACL permissions fixed" -ForegroundColor Green
Write-Host "`nYou can now use: git add, git commit, git push" -ForegroundColor Cyan
