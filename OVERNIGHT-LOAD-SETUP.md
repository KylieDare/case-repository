# Overnight Load Setup Guide

## Overview

The overnight load process automatically copies files from your MYOB OneDrive Ticket Work directory into organized case folders in the repository.

## Requirements

- Python 3.6 or higher
- Windows PowerShell 5.0+ (for scheduling)
- Administrator privileges (for scheduling)
- Read access to OneDrive directory
- Write access to case repository

## Installation

### Step 1: Verify Python Installation

```powershell
python --version
```

Should return Python 3.x.x

### Step 2: Configure the Script

Edit `overnight-load.py` if you need to change:
- Source directory path
- Logging behavior
- File organization rules

Default source: `C:\Users\Kylie.Dare\OneDrive - MYOB\Documents\!!!_Ticket Work`

### Step 3: Test the Load Process

Run the script manually first to verify it works:

```powershell
python overnight-load.py
```

This will:
- Create case folders for each ticket
- Copy and organize files
- Generate a load report
- Create detailed logs

### Step 4: Schedule for Overnight Runs (Optional)

To automatically schedule daily loads at 2:00 AM:

```powershell
# Run as Administrator
.\setup-overnight-task.ps1
```

Or with custom time:

```powershell
.\setup-overnight-task.ps1 -ScheduleTime "03:00AM"
```

## File Organization

Files are automatically organized by type:

- **Scripts**: `.py`, `.ps1`, `.sh`, `.bat`, `.sql`
- **Notes**: `.txt`, `.md`, `.log`, `.doc`, `.docx`
- **Archives**: `.zip` files are extracted to `archives/` folder
- **Other**: Copied to `scripts/` by folder

## Output Structure

```
cases/
├── case-hubspot-ticket-work/
│   ├── scripts/
│   ├── notes/
│   ├── archives/
│   └── README.md
├── case-ce00064372/
│   ├── scripts/
│   ├── notes/
│   ├── archives/
│   └── README.md
└── case-ce00064539/
    ├── scripts/
    ├── notes/
    ├── archives/
    └── README.md
```

## Monitoring

### View Logs

Logs are created in the `logs/` directory with timestamp:

```powershell
Get-ChildItem ./logs
Get-Content ./logs/load_20260227_020000.log
```

### View Load Report

After each load, check `LOAD_REPORT.md` for a summary:

```powershell
Get-Content ./LOAD_REPORT.md
```

### Check Scheduled Task Status

```powershell
Get-ScheduledTask -TaskName "CaseRepository-OvernightLoad" | Select-Object Name, State, Triggers
Get-ScheduledTaskInfo -TaskName "CaseRepository-OvernightLoad"
```

## Troubleshooting

### Python Not Found

```powershell
# Find Python path
$pythonPath = (Get-Command python).Source
Write-Host $pythonPath
```

### Permission Denied on OneDrive

Ensure your user account has read access to the ticket work directory.

### Task Won't Run

1. Check Task Scheduler: `taskschd.msc`
2. Verify Python path is correct
3. Check firewall/antivirus blocking execution
4. Review event logs for errors

### Zip Extraction Fails

Some zip files may have special characters or encoding issues. Check logs for specific files and manually handle if needed.

## Manual Execution

To run anytime without scheduling:

```powershell
cd C:\path\to\repository
python overnight-load.py
```

## Stopping the Scheduled Task

```powershell
Unregister-ScheduledTask -TaskName "CaseRepository-OvernightLoad" -Confirm:$false
```

## Next Steps

1. Test the overnight load script
2. Review the generated cases and files
3. Set up scheduling for automatic runs
4. Monitor logs for first few runs
5. Adjust file organization rules if needed

---

For more information, see the main README.md