@echo off
setlocal EnableExtensions

rem ASCII-only output to reduce mojibake risk on mixed code pages.

set "ROOT_A=C:\data\GitHub"
set "ROOT_B=C:\path\to\repos"

set "REPO_KENSIN="
set "REPO_AHK="
set "REPO_HCOS="

if exist "%ROOT_A%\kensin\.git" set "REPO_KENSIN=%ROOT_A%\kensin"
if exist "%ROOT_B%\kensin\.git" if not defined REPO_KENSIN set "REPO_KENSIN=%ROOT_B%\kensin"

if exist "%ROOT_A%\ahk\.git" set "REPO_AHK=%ROOT_A%\ahk"
if exist "%ROOT_B%\AHK_setting\.git" if not defined REPO_AHK set "REPO_AHK=%ROOT_B%\AHK_setting"

if exist "%ROOT_A%\HealthCheck-OS\.git" set "REPO_HCOS=%ROOT_A%\HealthCheck-OS"
if exist "%ROOT_B%\HealthCheck-OS\.git" if not defined REPO_HCOS set "REPO_HCOS=%ROOT_B%\HealthCheck-OS"

call :check_repo "kensin" "%REPO_KENSIN%"
call :check_repo "ahk" "%REPO_AHK%"
call :check_repo "HealthCheck-OS" "%REPO_HCOS%"

echo.
echo [DONE] Startup check finished.
echo [NOTE] If any repo shows "behind", update before running app/build.
exit /b 0

:check_repo
set "NAME=%~1"
set "PATH_REPO=%~2"
if not defined PATH_REPO (
  echo.
  echo [SKIP] %NAME% repo not found.
  exit /b 0
)

echo.
echo ============================================================
echo [CHECK] %NAME%
echo [PATH ] %PATH_REPO%
echo ============================================================

pushd "%PATH_REPO%" >nul || (
  echo [ERROR] Cannot enter repo path.
  exit /b 1
)

git fetch --all --prune
if errorlevel 1 (
  echo [ERROR] git fetch failed in %NAME%.
  popd >nul
  exit /b 1
)

git status -sb
git branch -vv
git rev-parse --abbrev-ref HEAD

popd >nul
exit /b 0
