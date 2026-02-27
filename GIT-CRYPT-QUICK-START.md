# Git-Crypt Quick Start - Case Repository Security

## 🔒 What We Set Up

Your repository now has encryption configuration ready for:
- **Automatic encryption** of sensitive files (zips, CSVs, logs, cases)
- **Decryption-on-demand** with GPG key authentication
- **GitHub storage** of encrypted files (safely inaccessible without key)

## ⚡ Quick Setup (5 minutes)

### Step 1: Install git-crypt

**Using Scoop (Recommended - easiest):**
```powershell
# Install Scoop first (if not already installed)
iwr -useb get.scoop.sh | iex

# Install git-crypt
scoop install git-crypt

# Verify
git-crypt --version
```

**Using Windows Package Manager:**
```powershell
winget install AGWA.git-crypt
git-crypt --version
```

### Step 2: Generate or Check GPG Key

```powershell
# Check for existing GPG keys
gpg --list-keys

# If none exist, generate one (takes ~1 min):
gpg --gen-key
# When prompted:
#   Key type: RSA
#   Key size: 4096
#   Real name: Your Name
#   Email: your.email@example.com
#   Passphrase: (create a strong password)
```

### Step 3: Initialize git-crypt

```powershell
cd C:\Users\Kylie.Dare\case-repository

# Run automated setup
.\setup-git-crypt.ps1

# Or manual setup:
git-crypt init
git add .gitattributes .git-crypt
git commit -m "Initialize git-crypt"
```

### Step 4: Encrypt and Push

```powershell
# Force re-encryption of existing files
git add --renormalize -A
git commit -m "Encrypt sensitive case files"
git push origin main
```

## 📋 Files Configured for Encryption

From `.gitattributes`:
- ✓ All `.zip` archives
- ✓ All `.csv` data exports
- ✓ All files in `cases/` folder
- ✓ All `.xlsx` / `.xls` spreadsheets
- ✓ All `.json` config files
- ✓ `logs/` directory
- ✓ `LOAD_REPORT.md`

NOT encrypted (for accessibility):
- README files
- Setup scripts
- Documentation

## 🔑 Key Management

### Check What's Encrypted
```powershell
git-crypt status
```

### Lock Files (Make Unreadable)
```powershell
git-crypt lock
# Files now encrypted in working directory
```

### Unlock Files (Make Readable)
```powershell
git-crypt unlock
# Requires your GPG passphrase
```

### Share Access with Collaborators
```powershell
# Get collaborator's GPG key ID
git-crypt add-gpg-user collaborator@email.com

# Commit the change
git commit -am "Grant access to collaborator"
git push
```

## ✅ Verification

### See encryption status:
```powershell
git status
git-crypt status

# Sample output:
# encrypted   cases/case-CE00064372/archives/...
# encrypted   cases/case-CE00064539/...
# not encrypted  README.md
```

### Test access:
```powershell
# When encrypted/locked - appear as binary
Get-Content cases/case-CE00064372/notes/some-file.txt

# When decrypted/unlocked - normal text
```

## 🔐 Security Features

✓ **At-rest encryption**: Files are encrypted on GitHub  
✓ **Transparent encryption**: Automatically encrypt on commit  
✓ **GPG-based access**: Only users with matching GPG keys can decrypt  
✓ **Shared security**: Add collaborators without sharing passwords  
✓ **Clone protection**: Clones keep files encrypted by default  

## 💡 Common Workflows

### Daily Development
```powershell
# When you start work - unlock (or auto-unlock)
git-crypt unlock

# Do normal work - files auto-encrypt on commit
git commit -am "Updated case notes"
git push

# When leaving - lock files
git-crypt lock
```

### New Collaborator Access
```powershell
# 1. They clone the repo (files stay encrypted)
git clone https://github.com/KylieDare/case-repository.git
cd case-repository

# 2. They generate their GPG key (if needed)
gpg --gen-key

# 3. You grant access
git-crypt add-gpg-user their-email@example.com
git commit -am "Grant access to user"
git push

# 4. They unlock with their key
git-crypt unlock
```

### Fresh Clone (First Time)
```powershell
git clone https://github.com/KylieDare/case-repository.git
cd case-repository
git-crypt unlock  # Enter GPG passphrase when prompted
```

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| `git-crypt: command not found` | Restart PowerShell after installing, check PATH |
| `permission denied` | Ensure you own the GPG key, try `gpg --list-keys` |
| Files not encrypting | Check `.gitattributes` syntax, run `git-crypt status` |
| Forgot GPG password | Can't recover - but you retain access with your key |
| Collaborator can't decrypt | Add their GPG key: `git-crypt add-gpg-user email@` |

## 📚 Full Documentation

For complete details, see **GIT-CRYPT-SETUP.md** in the repository

---

**Your repository is now secure! Only you (and authorized collaborators with GPG keys) can decrypt the sensitive files.**

🎯 **Next Steps:**
1. Install git-crypt
2. Generate or verify GPG key
3. Run `.\setup-git-crypt.ps1`
4. Push to GitHub: `git push origin main`
5. Files are now encrypted in GitHub