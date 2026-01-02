# GitHub Repository Setup Guide

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com  
**Document Version:** 1.0 | Last Updated: 2025-12-31

---

## Overview

This guide walks through creating the private `NextLevelDebloat` repository and securely pushing your Windows optimization solution to GitHub.

## Prerequisites

- **GitHub Account:** bmundy1996@gmail.com
- **Git Installed:** v2.52.0 (or later)
- **Repository Type:** Private
- **Local Repo:** Already initialized in C:\temp\

---

## Step 1: Create Private GitHub Repository

### Via GitHub Web Interface (Recommended)

1. Go to: https://github.com/new
2. **Repository Name:** `NextLevelDebloat`
3. **Visibility:** Select **Private** 🔒
4. **Initialize:** Leave all options unchecked (we already have code)
5. Click **Create repository**
6. Copy the repository URL: `https://github.com/bmundy1996/NextLevelDebloat.git`

### Via GitHub CLI (Alternative)

```bash
gh repo create NextLevelDebloat --private
```

---

## Step 2: Authenticate with GitHub

### Option A: GitHub CLI (Recommended)

```powershell
# Install GitHub CLI if not installed
winget install --id GitHub.cli

# Authenticate
gh auth login
```

When prompted:
- Enter GitHub.com for GitHub.com server
- Choose **HTTPS** for protocol
- Choose **Login with a web browser** (recommended)
- Follow browser prompts to authorize
- Enter device code if prompted

### Option B: Personal Access Token (Secure)

1. Go to: https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. **Note:** Enter "NextLevelDebloat Deployment"
4. **Expiration:** Select expiration period (e.g., 90 days or No expiration)
5. **Scopes:** Select **repo** (Full control of private repositories)
6. Click **Generate token**
7. **IMPORTANT:** Copy the token immediately (you won't see it again!)

**⚠️ SECURITY WARNING:** Never store tokens in scripts, commit them to git, or share them publicly.

### Option C: SSH Key (Advanced)

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "bmundy1996@gmail.com"

# Add to GitHub
# Copy contents of ~/.ssh/id_ed25519.pub
# Go to: https://github.com/settings/keys
# Click "New SSH key"
# Paste key contents and save

# Test SSH connection
ssh -T git@github.com
```

---

## Step 3: Connect Local Repository to GitHub

### Using HTTPS (with GitHub CLI or Token)

```bash
# Navigate to repository
cd C:\temp

# Add remote (replace URL if needed)
git remote add origin https://github.com/bmundy1996/NextLevelDebloat.git

# Verify remote
git remote -v

# Push main branch
git branch -M main
git push -u origin main
```

### Using SSH (if SSH key configured)

```bash
git remote add origin git@github.com:bmundy1996/NextLevelDebloat.git
git push -u origin main
```

---

## Step 4: Verify Deployment

After successful push, verify:

```bash
# Check remote
git remote -v

# Check branch
git branch -a

# View commit history
git log --oneline -5
```

Visit your repository at: https://github.com/bmundy1996/NextLevelDebloat

---

## Common Issues & Solutions

### Issue: "Permission denied (publickey)"

**Cause:** SSH key not added to GitHub account

**Solution:**
1. Copy SSH public key: `cat ~/.ssh/id_ed25519.pub`
2. Add at: https://github.com/settings/keys
3. Test: `ssh -T git@github.com`

### Issue: "Authentication failed"

**Cause:** Invalid or expired credentials

**Solution:**
- Re-authenticate: `gh auth login`
- Or regenerate personal access token and update git credential helper

### Issue: "remote already exists"

**Cause:** Remote "origin" already configured

**Solution:**
```bash
# Remove existing remote
git remote remove origin

# Add new remote
git remote add origin https://github.com/bmundy1996/NextLevelDebloat.git
```

### Issue: "LF will be replaced by CRLF"

**Cause:** Line ending mismatch (Windows to Unix)

**Solution:**
```bash
# Configure git to handle line endings
git config --global core.autocrlf true

# Re-commit if needed
git add .
git commit --amend
```

---

## Post-Deployment Checklist

- [ ] Private repository created on GitHub
- [ ] Repository name: NextLevelDebloat
- [ ] Authentication successful (gh auth login or token configured)
- [ ] Remote origin added and verified
- [ ] Initial push completed
- [ ] All files visible in repository
- [ ] README.md displays correctly
- [ ] Documentation accessible in docs/ folder
- [ ] Snapshots excluded (via .gitignore)

---

## GitHub Best Practices

### Branching
- Use `main` as primary branch (not `master`)
- Create feature branches for major updates
- Pull requests for code review (if collaborating)

### Commit Messages
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:** feat, fix, docs, chore, refactor, test  
**Examples:**
- `feat(deployment): Add automated deployment script`
- `fix(restore): Correct registry import path`
- `docs(readme): Update deployment instructions`

### .gitignore Configuration

Already configured in repository:
```gitignore
# Flag files (runtime files)
*.flag

# Log files
*.log
debloat-log.txt
restore-log.txt

# Snapshot files (large)
snapshot-*.tar.gz

# Windows specific
Thumbs.db
desktop.ini

# Backup files
registry-backup-*.reg
```

---

## Security Considerations

### What NOT to Commit
- Personal access tokens ❌
- API keys ❌
- Passwords ❌
- Sensitive configuration files with secrets ❌

### What to Commit
- Public documentation ✅
- Scripts and configuration ✅
- README files ✅
- Git configuration ✅

### Repository Settings
- **Visibility:** Private (for internal use)
- **Branch Protection:** Enable on main branch (recommended)
- **Status Checks:** Enable for pull requests (if collaborating)
- **Security Alerts:** Enable Dependabot alerts

---

## Next Steps

After successful GitHub setup:

1. **Clone to new machine:**
   ```bash
   git clone https://github.com/bmundy1996/NextLevelDebloat.git
   cd NextLevelDebloat
   ```

2. **Run deployment:**
   ```powershell
   .\Deploy-NextLevelDebloat.ps1
   ```

3. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

4. **Push updates:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

---

## Support

For GitHub or repository issues:

**Email:** bryan@mundytuned.com  
**Business:** #MundyTuned

---

**Document Status:** ✅ Complete  
**Deployment Ready:** Yes  
**Last Updated:** 2025-12-31

---

**#MundyTuned** - Windows Optimization Solutions  
**Business Email:** bryan@mundytuned.com