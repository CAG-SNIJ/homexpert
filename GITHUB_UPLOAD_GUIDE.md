# GitHub Upload Guide - HomeXpert Project

This guide will help you upload your entire HomeXpert project to GitHub.

## 📋 Prerequisites

- **Git installed** on your computer
  - Check: Open PowerShell and type `git --version`
  - If not installed: Download from https://git-scm.com/downloads
- **GitHub account** (create at https://github.com if needed)

## 🚀 Step-by-Step Instructions

### Step 1: Open PowerShell in Project Directory

1. **Open PowerShell**
2. **Navigate to your project**:
   ```powershell
   cd D:\TARUMT\FYP\Code\homexpert
   ```

### Step 2: Initialize Git Repository

```powershell
git init
```

This creates a new Git repository in your project folder.

### Step 3: Check What Will Be Uploaded

```powershell
git status
```

This shows which files will be added. **Make sure `.env` files are NOT listed** (they should be ignored).

### Step 4: Add All Files to Git

```powershell
git add .
```

This stages all files for commit (respecting .gitignore rules).

### Step 5: Create Initial Commit

```powershell
git commit -m "Initial commit: HomeXpert project"
```

### Step 6: Create GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Sign in** (or create account if needed)
3. **Click the "+" icon** (top right) → **"New repository"**
4. **Repository settings**:
   - **Name**: `homexpert` (or your preferred name)
   - **Description**: "HomeXpert - AI-powered real estate listing platform"
   - **Visibility**: 
     - Choose **Public** (if you want to showcase/share)
     - Or **Private** (if you want to keep it private)
   - **⚠️ IMPORTANT**: 
     - **DO NOT** check "Add a README file"
     - **DO NOT** check "Add .gitignore"
     - **DO NOT** check "Choose a license"
     - (We already have these files)
5. **Click "Create repository"**

### Step 7: Connect Local Repository to GitHub

After creating the repository, GitHub will show you setup instructions. Use these commands:

```powershell
# Add GitHub repository as remote (replace YOUR_USERNAME with your actual GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/homexpert.git

# Rename default branch to main (if needed)
git branch -M main

# Push your code to GitHub
git push -u origin main
```

**Note**: When pushing, GitHub will ask for credentials:
- **Username**: Your GitHub username
- **Password**: Use a **Personal Access Token** (not your GitHub password)
  - Get token: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
  - Generate with `repo` permissions

### Step 8: Verify Upload

1. **Refresh your GitHub repository page**
2. **You should see all your files** uploaded
3. **Double-check**: `.env` files should **NOT** be visible (they're in .gitignore)

## 🔒 Security Checklist

Before pushing, verify these files are **NOT** in your repository:

✅ **Should be ignored** (check with `git status`):
- `backend/.env` ❌ Should NOT appear
- `backend/node_modules/` ❌ Should NOT appear
- Any file with passwords/API keys ❌ Should NOT appear

✅ **Should be included**:
- Source code files ✅
- Configuration files (without secrets) ✅
- Documentation files ✅

## 📝 Quick Command Reference

```powershell
# Check if git is installed
git --version

# Initialize repository
git init

# Check what will be committed
git status

# Add all files
git add .

# Create commit
git commit -m "Your message here"

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/homexpert.git

# Push to GitHub
git push -u origin main

# Future updates (after making changes)
git add .
git commit -m "Description of changes"
git push
```

## 🐛 Troubleshooting

### Issue: "git: command not found"

**Solution**: Install Git from https://git-scm.com/downloads

### Issue: "Permission denied" when pushing

**Solution**: 
1. GitHub requires Personal Access Tokens (not passwords)
2. Go to: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
3. Generate new token with `repo` scope
4. Use this token as your password when pushing

### Issue: ".env file is showing in git status"

**Solution**: 
1. Make sure `backend/.env` is in `.gitignore`
2. If already committed:
   ```powershell
   git rm --cached backend/.env
   git commit -m "Remove .env from repository"
   git push
   ```
3. **Change all passwords immediately** if .env was already pushed!

### Issue: "Large files" error

**Solution**: 
- Some image files might be too large for GitHub
- Consider using Git LFS for large assets
- Or exclude very large files from git

## ✅ Final Checklist

- [ ] Git installed (`git --version` works)
- [ ] GitHub account created
- [ ] `.gitignore` includes `.env` files
- [ ] Git repository initialized
- [ ] Files added (`git add .`)
- [ ] Initial commit created
- [ ] GitHub repository created (empty, no README)
- [ ] Remote added (`git remote add origin`)
- [ ] Code pushed to GitHub
- [ ] Verified `.env` is NOT on GitHub
- [ ] All files visible on GitHub

## 🎯 Next Steps After Upload

1. **Add logo URL to .env** (for email templates):
   ```env
   LOGO_URL=https://raw.githubusercontent.com/YOUR_USERNAME/homexpert/main/assets/images/homexpert_logo.png
   ```

2. **Update README.md** with project information

3. **Share your repository** with team members (if needed)

---

**Ready?** Start with Step 1 and work through each step. If you get stuck, let me know which step and I'll help!
