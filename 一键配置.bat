@echo off
rem ============================================================================
rem  setup.bat  --  run this ONCE after copying the project to a new machine
rem ----------------------------------------------------------------------------
rem  It does four things:
rem    1. scans code\ and regenerates env\code_filelist.h
rem    2. finds a usable compiler (Dev-C++ / MinGW  or  Visual Studio 2022)
rem    3. checks that EasyX is installed for that compiler
rem    4. optionally builds and runs right away
rem ============================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ============================================================
echo    22nd Visual Simulation Environment  -  First-time Setup
echo ============================================================
echo.

echo [1/4] Scanning code\ and generating env\code_filelist.h ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\gen_filelist.ps1"
if errorlevel 1 (
    echo       [FAILED] could not generate code_filelist.h
    goto :end
)
echo.

echo [2/4] Looking for a compiler ...
set "MINGW="
if exist "D:\TOOLS\Dev-Cpp\MinGW64\bin\g++.exe" set "MINGW=D:\TOOLS\Dev-Cpp\MinGW64"
if not defined MINGW if exist "C:\Program Files (x86)\Dev-Cpp\MinGW64\bin\g++.exe" set "MINGW=C:\Program Files (x86)\Dev-Cpp\MinGW64"
if not defined MINGW if exist "C:\Program Files\Dev-Cpp\MinGW64\bin\g++.exe" set "MINGW=C:\Program Files\Dev-Cpp\MinGW64"
if defined MINGW_HOME if exist "%MINGW_HOME%\bin\g++.exe" set "MINGW=%MINGW_HOME%"

set "HASVS=0"
for %%P in (
    "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe"
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
) do if exist %%P set "HASVS=1"

if defined MINGW (
    echo       [OK] Dev-C++ / MinGW : !MINGW!
) else (
    echo       [--] Dev-C++ / MinGW not found
)
if "%HASVS%"=="1" (
    echo       [OK] Visual Studio 2022
) else (
    echo       [--] Visual Studio 2022 not found
)
if not defined MINGW if "%HASVS%"=="0" (
    echo.
    echo       [ERROR] No compiler found. Install Dev-C++ or VS2022 with C++ first.
    goto :end
)
echo.

echo [3/4] Checking EasyX ...
set "HASEX=0"
if defined MINGW if exist "!MINGW!\include\easyx.h" set "HASEX=1"
if defined MINGW if exist "!MINGW!\MinGW64\include\easyx.h" set "HASEX=1"
if "%HASEX%"=="1" (
    echo       [OK] EasyX installed for Dev-C++
) else (
    if defined MINGW echo       [!!] easyx.h not found for MinGW - see dev config guide
)
if "%HASVS%"=="1" (
    for /f "usebackq tokens=*" %%I in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -property installationPath 2^>nul`) do (
        if exist "%%I\VC\Auxiliary\VS\include\easyx.h" echo       [OK] EasyX installed for Visual Studio
    )
)
echo.

echo [4/4] Build now?
echo       1 = build and run with Dev-C++ / MinGW
echo       2 = build and run with Visual Studio
echo       0 = skip
set "CHOICE="
set /p "CHOICE=Enter 0/1/2 then press Enter [default 0]: "
if "%CHOICE%"=="1" call "%~dp0tools\build_dev.bat"
if "%CHOICE%"=="2" call "%~dp0tools\build_vs.bat"
echo.

echo ============================================================
echo   Setup complete. From now on:
echo     * command line : tools\build_dev.bat   or   tools\build_vs.bat
echo     * Dev-C++      : open the .dev file, press F11
echo     * VS 2022      : open VS\visual_simu.sln, press F5
echo.
echo   Your code goes in code\ - new .c/.h files are picked up automatically.
echo ============================================================

:end
echo.
pause
endlocal
exit /b 0
