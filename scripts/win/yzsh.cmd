@echo off
rem Run a yazi config script under Git Bash, see yzsh next to this file.
setlocal
set "YZSH_BASH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%YZSH_BASH%" set "YZSH_BASH=%LOCALAPPDATA%\Programs\Git\bin\bash.exe"
"%YZSH_BASH%" "%~dp0yzsh" %*
