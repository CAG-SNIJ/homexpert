# Cursor Git Integration Guide

This guide will help you use Git directly in Cursor editor for version control.

## ✅ Current Git Configuration

Your Git is already set up:
- **Username**: CAG-SNIJ
- **Email**: snijders143@gmail.com
- **Remote**: https://github.com/CAG-SNIJ/homexpert.git
- **Branch**: main

## 🎯 Using Git in Cursor

### 1. Access Source Control Panel

**Method 1: Keyboard Shortcut**
- Press `Ctrl + Shift + G` (Windows/Linux)
- Or `Cmd + Shift + G` (Mac)

**Method 2: Sidebar Icon**
- Click the **Source Control icon** (looks like a branch/fork) in the left sidebar
- It shows a number badge if you have uncommitted changes

### 2. View Changes

In the Source Control panel, you'll see:
- **CHANGES**: Files you've modified
- **STAGED CHANGES**: Files ready to commit
- **MERGE CHANGES**: If you're merging branches

### 3. Stage Files for Commit

**To stage a single file:**
- Click the **"+"** icon next to the file name
- Or right-click the file → **"Stage Changes"**

**To stage all files:**
- Click the **"+"** icon next to "CHANGES" heading
- Or use `Ctrl + K, Ctrl + S` (stages all changes)

### 4. Commit Changes

1. **Type your commit message** in the text box at the top
   - Example: "Fix user deletion loading issue"
   - Example: "Add logo to email template"

2. **Click the checkmark icon** (✓) or press `Ctrl + Enter`
   - This commits your staged changes

3. **Or use the command palette**:
   - Press `Ctrl + Shift + P`
   - Type "Git: Commit"
   - Press Enter

### 5. Push to GitHub

After committing, you'll see a **"Publish Branch"** or **"Sync Changes"** button:

**Method 1: Sync Button**
- Click the **"Sync Changes"** button (circular arrows icon)
- This pushes and pulls in one action

**Method 2: Push Button**
- Click the **"Push"** button (cloud upload icon)
- This only pushes your commits

**Method 3: Command Palette**
- Press `Ctrl + Shift + P`
- Type "Git: Push"
- Press Enter

### 6. Pull Latest Changes

**To pull from GitHub:**
- Press `Ctrl + Shift + P`
- Type "Git: Pull"
- Press Enter

**Or use the sync button** (pulls and pushes)

## 📋 Common Git Workflows in Cursor

### Daily Workflow

1. **Start working**: Make changes to files
2. **See changes**: Open Source Control panel (`Ctrl + Shift + G`)
3. **Stage files**: Click "+" next to files you want to commit
4. **Commit**: Type message and click checkmark
5. **Push**: Click "Sync Changes" or "Push"

### Working with Branches

**Create a new branch:**
- Click the branch name (bottom left, shows "main")
- Type new branch name
- Press Enter

**Switch branches:**
- Click branch name (bottom left)
- Select branch from list

**Merge branches:**
- Switch to target branch (e.g., "main")
- Press `Ctrl + Shift + P`
- Type "Git: Merge Branch"
- Select branch to merge

## 🔍 Viewing Git Status

**Status Bar (Bottom of Cursor):**
- Shows current branch name
- Shows number of changes (if any)
- Click to see quick Git actions

**Source Control Panel:**
- Shows all modified files
- Shows file diffs (what changed)
- Click any file to see changes

## 🎨 Viewing File Differences

**To see what changed in a file:**
1. Open Source Control panel
2. Click on any modified file
3. Cursor will show:
   - **Left side**: Original file
   - **Right side**: Modified file
   - **Green**: Added lines
   - **Red**: Removed lines

## ⚙️ Git Settings in Cursor

**Access Git Settings:**
1. Press `Ctrl + ,` (opens Settings)
2. Search for "git"
3. Configure:
   - Auto fetch interval
   - Confirm sync
   - Enable/disable Git

## 🔐 Authentication with GitHub

**First time pushing:**
- Cursor will prompt for GitHub credentials
- Use your **Personal Access Token** (not password)
- Get token: GitHub → Settings → Developer settings → Personal access tokens

**Save credentials:**
- Windows: Credentials are saved in Windows Credential Manager
- Cursor will remember your token

## 📝 Commit Message Best Practices

**Good commit messages:**
- ✅ "Fix user deletion loading issue"
- ✅ "Add logo to email template"
- ✅ "Update .gitignore to exclude .env files"
- ✅ "Refactor user table component"

**Bad commit messages:**
- ❌ "fix"
- ❌ "update"
- ❌ "changes"
- ❌ "asdf"

**Format:**
- Start with a verb (Add, Fix, Update, Remove)
- Be specific about what changed
- Keep it concise (50-72 characters ideal)

## 🐛 Troubleshooting

### Issue: "Authentication failed"

**Solution:**
1. Use Personal Access Token instead of password
2. Generate new token: GitHub → Settings → Developer settings → Personal access tokens
3. Use token when prompted

### Issue: "Changes not showing"

**Solution:**
1. Refresh Source Control panel (click refresh icon)
2. Or close and reopen Cursor
3. Check if file is in .gitignore

### Issue: "Can't push - branch is behind"

**Solution:**
1. Pull first: `Ctrl + Shift + P` → "Git: Pull"
2. Resolve any conflicts
3. Then push again

### Issue: "Merge conflicts"

**Solution:**
1. Cursor will highlight conflicts
2. Choose: "Accept Current Change", "Accept Incoming Change", or "Accept Both"
3. Stage the resolved file
4. Commit the merge

## 🎯 Quick Reference

| Action | Shortcut | Location |
|--------|----------|----------|
| Open Source Control | `Ctrl + Shift + G` | Sidebar |
| Stage All | `Ctrl + K, Ctrl + S` | Source Control |
| Commit | `Ctrl + Enter` | After typing message |
| Push | `Ctrl + Shift + P` → "Git: Push" | Command Palette |
| Pull | `Ctrl + Shift + P` → "Git: Pull" | Command Palette |
| View Diff | Click file in Source Control | File diff view |
| Create Branch | Click branch name → Type name | Status bar |

## ✅ Checklist

- [ ] Source Control panel accessible (`Ctrl + Shift + G`)
- [ ] Can see modified files
- [ ] Can stage files (click "+")
- [ ] Can commit changes (type message + checkmark)
- [ ] Can push to GitHub (Sync Changes button)
- [ ] Branch name visible in status bar

---

**You're all set!** Cursor has built-in Git support, so you can manage your code directly from the editor without using the terminal.

