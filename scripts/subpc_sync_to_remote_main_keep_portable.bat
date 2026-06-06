@echo off
setlocal EnableExtensions

rem Safety-first sync helper for sub PC.
rem Keeps local kensin portable script edits as an optional patch.
rem ASCII-only messages to avoid mojibake in cmd.exe.

set "ROOT_A=C:\data\GitHub"
set "ROOT_B=C:\path\to\repos"
set "PATCH_DIR=%USERPROFILE%\Desktop\subpc_git_backup"

set "REPO_KENSIN="
set "REPO_AHK="
set "REPO_HCOS="

if exist "%ROOT_A%\kensin\.git" set "REPO_KENSIN=%ROOT_A%\kensin"
if exist "%ROOT_B%\kensin\.git" if not defined REPO_KENSIN set "REPO_KENSIN=%ROOT_B%\kensin"

if exist "%ROOT_A%\ahk\.git" set "REPO_AHK=%ROOT_A%\ahk"
if exist "%ROOT_B%\AHK_setting\.git" if not defined REPO_AHK set "REPO_AHK=%ROOT_B%\AHK_setting"

if exist "%ROOT_A%\HealthCheck-OS\.git" set "REPO_HCOS=%ROOT_A%\HealthCheck-OS"
if exist "%ROOT_B%\HealthCheck-OS\.git" if not defined REPO_HCOS set "REPO_HCOS=%ROOT_B%\HealthCheck-OS"

if not exist "%PATCH_DIR%" mkdir "%PATCH_DIR%" >nul 2>nul

set "STAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "STAMP=%STAMP: =0%"
set "KENSIN_PATCH=%PATCH_DIR%\kensin_portable_local_%STAMP%.patch"

echo.
echo [STEP] 1/4 Backup local kensin portable script diffs (if any)
if defined REPO_KENSIN (
  pushd "%REPO_KENSIN%" >nul || goto :path_error
  git diff -- run.bat setup.bat build_portable.bat > "%KENSIN_PATCH%"
  for %%I in ("%KENSIN_PATCH%") do set "PATCH_SIZE=%%~zI"
  if "%PATCH_SIZE%"=="0" (
    del "%KENSIN_PATCH%" >nul 2>nul
    echo [INFO] No local diff found in run/setup/build_portable.
  ) else (
    echo [INFO] Saved patch: %KENSIN_PATCH%
  )
  popd >nul
) else (
  echo [WARN] kensin repo not found. Skip patch backup.
)

echo.
echo [STEP] 2/4 Sync main to origin/main for each repo
call :sync_main "kensin" "%REPO_KENSIN%"
if errorlevel 1 exit /b 1
call :sync_main "ahk" "%REPO_AHK%"
if errorlevel 1 exit /b 1
call :sync_main "HealthCheck-OS" "%REPO_HCOS%"
if errorlevel 1 exit /b 1

echo.
echo [STEP] 3/4 Re-apply kensin portable patch (if saved)
if exist "%KENSIN_PATCH%" (
  pushd "%REPO_KENSIN%" >nul || goto :path_error
  git apply --3way "%KENSIN_PATCH%"
  if errorlevel 1 (
    echo [ERROR] Patch apply failed. Please resolve manually.
    popd >nul
    exit /b 1
  )
  echo [OK] Re-applied kensin portable patch.
  popd >nul
) else (
  echo [INFO] No saved kensin portable patch to apply.
)

echo.
echo [STEP] 4/4 Show final status
call :show_status "kensin" "%REPO_KENSIN%"
call :show_status "ahk" "%REPO_AHK%"
call :show_status "HealthCheck-OS" "%REPO_HCOS%"

echo.
echo [DONE] Sync completed.
echo [NEXT] If kensin changed, run run.bat for startup check.
exit /b 0

:sync_main
set "NAME=%~1"
set "PATH_REPO=%~2"
if not defined PATH_REPO (
  echo [WARN] %NAME% repo not found. Skip.
  exit /b 0
)
echo ------------------------------------------------------------
echo [SYNC] %NAME%
echo [PATH] %PATH_REPO%
pushd "%PATH_REPO%" >nul || goto :path_error
git fetch --all --prune || goto :git_error
git switch main || goto :git_error
git reset --hard origin/main || goto :git_error
popd >nul
echo [OK] %NAME% main is now aligned to origin/main.
exit /b 0

:show_status
set "NAME=%~1"
set "PATH_REPO=%~2"
if not defined PATH_REPO exit /b 0
echo ------------------------------------------------------------
echo [STATUS] %NAME%
pushd "%PATH_REPO%" >nul || goto :path_error
git status -sb
popd >nul
exit /b 0

:path_error
echo [ERROR] Cannot access repo path.
exit /b 1

:git_error
echo [ERROR] Git command failed.
popd >nul
exit /b 1
