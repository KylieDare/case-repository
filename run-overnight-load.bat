@echo off
REM Quick runner script for overnight load
REM This batch file makes it easy to run the load process

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Case Repository - Overnight Load Runner
echo ========================================
echo.

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6+ or add it to your PATH
    pause
    exit /b 1
)

echo Running overnight load process...
echo.

REM Run the Python script
python overnight-load.py

if errorlevel 1 (
    echo.
    echo ERROR: Load process failed
    echo Check logs folder for details
    pause
    exit /b 1
)

echo.
echo Load process completed successfully!
echo.
echo Next steps:
echo  - Check LOAD_REPORT.md for summary
echo  - Review cases/ folder for created cases
echo  - Check logs/ folder for detailed execution log
echo.
pause