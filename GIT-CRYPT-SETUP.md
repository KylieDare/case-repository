# Git-Crypt Security Setup for Case Repository

This guide enables transparent encryption for sensitive files in your git repository.

## Installation

### Option 1: Using Scoop (Recommended)
```powershell
# Install Scoop if not already installed
iwr -useb get.scoop.sh | iex

# Install git-crypt
scoop install git-crypt
```

### Option 2: Using Windows Package Manager (winget)
```powershell
winget install AGWA.git-crypt
```

### Option 3: Manual Download
1. Download from: https://github.com/AGWA/git-crypt/releases
2. Extract to C:\Program Files\git-crypt or add to PATH
3. Verify: `git-crypt --version`

### Option 4: Build from Source (requires Git Bash & compiler)
```bash
git clone https://github.com/AGWA/git-crypt.git
cd git-crypt
make
make install
```

## Setup (After Installation)

### Step 1: Initialize git-crypt in Repository
```powershell
cd C:\Users\Kylie.Dare\case-repository
git-crypt init
```

This creates `.git/config` encryption configuration.

### Step 2: View Encryption Status
```powershell
git-crypt status
```

### Step 3: Add Files to Encrypt

Edit `.gitattributes` to match what's already configured, or run:

```powershell
# Add to .gitattributes (already created)
git add .gitattributes
git commit -m "Configure git-crypt encryption for sensitive files"
```

### Step 4: Stage and Commit Files
```powershell
# Files matching patterns in .gitattributes will be automatically encrypted
git add .
git commit -m "Encrypt sensitive case files"
git push origin main
```

## What Gets Encrypted

Files automatically encrypted by pattern:
- All `.zip` files (archives)
- All files in `cases/` directory
- `.csv` files (data exports)
- `.txt` files in notes/ (documentation)

## Usage

### Lock Repository (Decrypt Files)
Files become unreadable without key:
```powershell
git-crypt lock
```

### Unlock Repository (Decrypt Files)
Requires authorized GPG key:
```powershell
git-crypt unlock
```

## Key Management

### Generate GPG Key (First Time Only)
```powershell
# Check for existing keys
gpg --list-keys

# If none exist, generate:
gpg --full-generate-key
# Or use: gpg --gen-key (simpler)
```

### Share Key with Other Authorized Users
```powershell
# Export your public key
gpg --armor --export your-email > my-public-key.gpg

# Add collaborator's GPG key
gpg --import collaborator-public-key.gpg

# Add their key to git-crypt
git-crypt add-gpg-user their-user-id
```

### Remove Access
```powershell
git-crypt unlock
# Remove and re-encrypt
git-crypt lock
```

## Verification

### Check Encryption Status
```powershell
git-crypt status

# Shows:
# encrypted  cases/case-CE00064372/archives/...
# encrypted  cases/case-CE00064539/...
# not encrypted  cases/case-001/README.md
```

### View Encrypted vs Unencrypted
```powershell
# Encrypted files appear as binary
Get-Content cases/case-CE00064372/archives/file.zip | head -c 50

# Unencrypted files are readable
Get-Content cases/case-001/README.md
```

## Troubleshooting

### "git-crypt: command not found"
- Verify installation: `git-crypt --version`
- Check PATH: `$env:Path`
- Restart PowerShell after installation

### "no GPG key available"
- Generate key: `gpg --gen-key`
- Provide key ID: `gpg --list-keys` → copy key ID

### "permission denied"
- Ensure you own the GPG key
- Try: `git-crypt unlock`

### Files Not Encrypting
- Check `.gitattributes` syntax
- Run: `git-crypt status` to verify patterns
- Add new patterns and re-commit

## Security Notes

✓ Files are encrypted both at rest (in repo) and in transit (GitHub)  
✓ Only users with matching GPG keys can decrypt  
✓ Committed encrypted files cannot be modified without key  
✓ Each clone/pull keeps files encrypted unless unlocked  
✓ GitHub still stores encrypted files safely (can't read content)  

## Common Workflows

### First-Time Clone
```powershell
git clone https://github.com/KylieDare/case-repository.git
cd case-repository
git-crypt unlock  # Decrypt files (requires your GPG key)
```

### Regular Development
```powershell
# Files auto-decrypt when accessing
cd cases/case-CE00064372/notes
Get-Content Check\ Acct\ CAcct\ Sub.txt  # Automatic decryption

# Editing automatically re-encrypts on commit
notepad Check\ Acct\ CAcct\ Sub.txt
git add .
git commit -m "Update notes"
git push
```

### Before Leaving Computer
```powershell
git-crypt lock  # Lock all encrypted files
# Files become unreadable without decryption
```

---

For more info: https://github.com/AGWA/git-crypt