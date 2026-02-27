# Git-Crypt Automated Setup Script
# Initializes encryption for the case repository
# Run after git-crypt is installed

param(
    [switch]$GenerateGPGKey,
    [string]$Email = ""
)

function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Git-Crypt Repository Setup" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if git-crypt is installed
    $gitCryptPath = (Get-Command git-crypt -ErrorAction SilentlyContinue).Source
    if (-not $gitCryptPath) {
        Write-Host "ERROR: git-crypt is not installed" -ForegroundColor Red
        Write-Host "Please install it first:" -ForegroundColor Yellow
        Write-Host "  Option 1: scoop install git-crypt" -ForegroundColor Yellow
        Write-Host "  Option 2: winget install AGWA.git-crypt" -ForegroundColor Yellow
        Write-Host "  Option 3: Download from https://github.com/AGWA/git-crypt/releases" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✓ git-crypt found: $gitCryptPath" -ForegroundColor Green
    Write-Host ""
    
    # Check for GPG
    $gpgPath = (Get-Command gpg -ErrorAction SilentlyContinue).Source
    if (-not $gpgPath) {
        Write-Host "WARNING: GPG is not installed" -ForegroundColor Yellow
        Write-Host "You can continue, but key management will be limited" -ForegroundColor Yellow
        Write-Host ""
    } else {
        Write-Host "✓ GPG found: $gpgPath" -ForegroundColor Green
    }
    
    # Check for existing GPG keys
    $gpgKeys = gpg --list-keys 2>$null | Where-Object { $_ -match 'uid' }
    if ($gpgKeys) {
        Write-Host "✓ Found existing GPG keys:" -ForegroundColor Green
        gpg --list-keys | Select-String "^\[" | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "No GPG keys found" -ForegroundColor Yellow
        if ($GenerateGPGKey) {
            Write-Host "Generating new GPG key..." -ForegroundColor Cyan
            if ($Email) {
                gpg --batch --generate-key <@"
Key-Type: RSA
Key-Length: 4096
Name-Real: Case Repository Owner
Name-Email: $Email
Expire-Date: 0
%no-protection
"@
                Write-Host "✓ GPG key generated" -ForegroundColor Green
            } else {
                Write-Host "Run 'gpg --gen-key' to create a key interactively" -ForegroundColor Yellow
                Write-Host "Then run this script again" -ForegroundColor Yellow
                exit 1
            }
        }
    }
    
    Write-Host ""
    Write-Host "Initializing git-crypt in repository..." -ForegroundColor Cyan
    
    # Get git repository root
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if (-not $gitRoot) {
        Write-Host "ERROR: Not in a git repository" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Repository: $gitRoot" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if git-crypt is already initialized
    if (Test-Path "$gitRoot\.git\config" -PathType Leaf) {
        $gitCryptInit = git config --local hooks.git-crypt 2>$null
        if ($gitCryptInit) {
            Write-Host "⚠ git-crypt appears to already be initialized" -ForegroundColor Yellow
            $continue = Read-Host "Continue and reinitialize? (y/n)"
            if ($continue -ne 'y') {
                exit
            }
        }
    }
    
    # Initialize git-crypt
    try {
        git-crypt init
        Write-Host "✓ git-crypt initialized" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to initialize git-crypt: $_" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "Setting up encryption patterns..." -ForegroundColor Cyan
    
    # Check .gitattributes exists
    if (-not (Test-Path "$gitRoot\.gitattributes")) {
        Write-Host "ERROR: .gitattributes not found" -ForegroundColor Red
        Write-Host "This should have been created" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✓ .gitattributes configured" -ForegroundColor Green
    
    # Stage and commit git-crypt config
    Write-Host ""
    Write-Host "Committing git-crypt configuration..." -ForegroundColor Cyan
    git add .gitattributes .git-crypt
    git commit -m "Configure git-crypt encryption for sensitive files" -ErrorAction SilentlyContinue
    
    # Encrypt existing files
    Write-Host ""
    Write-Host "Encrypting repository files..." -ForegroundColor Cyan
    git-crypt status
    
    Write-Host ""
    Write-Host "Re-encrypting files..." -ForegroundColor Cyan
    # Force re-encrypt by resetting index
    git add --renormalize -A
    git commit -m "Encrypt sensitive case files" -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "✓ Git-Crypt Setup Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Review .gitattributes to see what will be encrypted" -ForegroundColor White
    Write-Host "2. Push to GitHub: git push origin main" -ForegroundColor White
    Write-Host "3. Lock files: git-crypt lock" -ForegroundColor White
    Write-Host "4. Unlock files: git-crypt unlock" -ForegroundColor White
    Write-Host ""
    Write-Host "Key management:" -ForegroundColor Cyan
    Write-Host "• List keys: gpg --list-keys" -ForegroundColor White
    Write-Host "• Add GPG user: git-crypt add-gpg-user [email]" -ForegroundColor White
    Write-Host "• Check status: git-crypt status" -ForegroundColor White
    Write-Host ""
    Write-Host "See GIT-CRYPT-SETUP.md for detailed documentation" -ForegroundColor Cyan
    Write-Host ""
}

Main