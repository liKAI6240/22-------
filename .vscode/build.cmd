@echo off
chcp 65001 >nul
cd /d "%~dp0..\Liumian-SimuEnv"
call tools\build_vs.bat %*
exit /b %errorlevel%
