# Overnight Load Task Scheduler for Case Repository
# This script sets up a scheduled task to run the overnight load
# Run this script with Administrator privileges

param(
    [string]$RepositoryPath = ".",
    [string]$ScheduleTime = "02:00AM"  # Default: 2:00 AM
)

# Settings
$PythonScript = Join-Path $RepositoryPath "overnight-load.py"
$LogPath = Join-Path $RepositoryPath "logs"
$TaskName = "CaseRepository-OvernightLoad"
$TaskDescription = "Overnight load of files from MYOB OneDrive ticket work directory"

function Main {
    write-Host "Case Repository - Overnight Load Scheduler" -ForegroundColor Cyan
    write-Host "=========================================" -ForegroundColor Cyan
    write-Host ""
    
    # Check if running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $isAdmin) {
        Write-Host "ERROR: This script must be run as Administrator" -ForegroundColor Red
        Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
        exit 1
    }
    
    # Verify Python script exists
    if (-not (Test-Path $PythonScript)) {
        Write-Host "ERROR: Python script not found at $PythonScript" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Configuration:" -ForegroundColor Green
    Write-Host "  Repository: $RepositoryPath"
    Write-Host "  Python Script: $PythonScript"
    Write-Host "  Schedule Time: $ScheduleTime"
    Write-Host "  Task Name: $TaskName"
    Write-Host ""
    
    # Create logs directory
    if (-not (Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
        Write-Host "Created logs directory: $LogPath" -ForegroundColor Green
    }
    
    # Check if task already exists
    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    
    if ($existingTask) {
        Write-Host "Scheduled task already exists. Unregistering old task..." -ForegroundColor Yellow
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }
    
    # Get Python executable path
    $pythonExe = (Get-Command python -ErrorAction SilentlyContinue).Source
    if (-not $pythonExe) {
        $pythonExe = "python"
    }
    
    Write-Host "Python executable: $pythonExe" -ForegroundColor Cyan
    
    # Create task action
    $action = New-ScheduledTaskAction `
        -Execute $pythonExe `
        -Argument "`\"$PythonScript`\"" `
        -WorkingDirectory $RepositoryPath
    
    # Create task trigger (daily at specified time)
    $trigger = New-ScheduledTaskTrigger `
        -Daily `
        -At $ScheduleTime
    
    # Create task settings
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable `
        -MultipleInstancePolicy IgnoreNew
    
    # Register the task
    try {
        Register-ScheduledTask `
            -TaskName $TaskName `
            -Action $action `
            -Trigger $trigger `
            -Settings $settings `
            -Description $TaskDescription `
            -Force | Out-Null
        
        Write-Host ""
        Write-Host "✓ Scheduled task created successfully!" -ForegroundColor Green
        Write-Host "  Task Name: $TaskName"
        Write-Host "  Schedule: Daily at $ScheduleTime"
        Write-Host "  Script: $PythonScript"
        Write-Host ""
        Write-Host "The overnight load will run automatically at the scheduled time." -ForegroundColor Cyan
        Write-Host "Check the logs folder for execution reports." -ForegroundColor Cyan
    }
    catch {
        Write-Host "ERROR: Failed to create scheduled task: $_" -ForegroundColor Red
        exit 1
    }
}

Main