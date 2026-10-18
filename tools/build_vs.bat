@echo off
rem ============================================================================
rem  build_vs.bat -- one-click build with Visual Studio 2022 (MSBuild)
rem ----------------------------------------------------------------------------
rem  Builds the real mixed C/C++ project in VS\visual_simu.sln:
rem      code\*.c / env\simu_env.c  ->  compiled as C   (/TC)
rem      main.cpp / env\*.cpp       ->  compiled as C++ (/TP)
rem
rem  Output: VS\x64\Debug\visual_simu.exe
rem  Usage : tools\build_vs.bat [Release] [norun]
rem ============================================================================
setlocal
cd /d "%~dp0.."
set "ROOT=%CD%"

set "CFG=Debug"
if /i "%~1"=="Release" set "CFG=Release"

rem ---------------------------- 1. locate MSBuild -----------------------------
set "MSB="
for %%P in (
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe"
) do (
    if not defined MSB if exist %%P set "MSB=%%~P"
)

if not defined MSB (
    for /f "usebackq tokens=*" %%I in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.Component.MSBuild -property installationPath 2^>nul`) do (
        if exist "%%I\MSBuild\Current\Bin\MSBuild.exe" set "MSB=%%I\MSBuild\Current\Bin\MSBuild.exe"
    )
)

if not defined MSB (
    echo [ERROR] MSBuild not found. Install Visual Studio 2022 with "Desktop
    echo         development with C++", or just use tools\build_dev.bat instead.
    exit /b 1
)

echo [build_vs] MSBuild  : %MSB%
echo [build_vs] Config   : %CFG% ^| x64

rem ---------------------------- 2. regenerate file list -----------------------
echo [build_vs] scanning code\ ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\tools\gen_filelist.ps1"
if errorlevel 1 ( echo [ERROR] gen_filelist.ps1 failed & exit /b 1 )

rem ---------------------------- 3. build --------------------------------------
"%MSB%" "%ROOT%\VS\visual_simu.sln" /p:Configuration=%CFG% /p:Platform=x64 /v:minimal /nologo
if errorlevel 1 ( echo. & echo [ERROR] build failed & exit /b 1 )

set "EXE=%ROOT%\VS\x64\%CFG%\visual_simu.exe"
echo.
echo [build_vs] OK  -^>  %EXE%
echo.

rem ---------------------------- 4. run ----------------------------------------
rem  No need to copy pic\ next to the exe: the program chdir's to the project
rem  root at startup and reads images by relative path.
if /i "%~2"=="norun" goto :done
if /i "%~1"=="norun" goto :done
echo [build_vs] launching ...
start "" "%EXE%"
goto :done

:done
endlocal
exit /b 0
