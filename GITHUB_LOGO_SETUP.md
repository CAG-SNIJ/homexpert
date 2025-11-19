# GitHub Logo Setup Guide

This guide will help you set up GitHub to host your logo image for email templates.

## 📋 Prerequisites

- A GitHub account (create one at https://github.com if you don't have one)
- Your `homexpert_logo.png` file ready

## 🚀 Step-by-Step Setup

### Step 1: Create a GitHub Repository

1. **Go to GitHub**: https://github.com
2. **Sign in** to your account (or create one if needed)
3. **Click the "+" icon** in the top right corner
4. **Select "New repository"**

### Step 2: Configure Repository

1. **Repository name**: Enter `homexpert-assets` (or any name you prefer)
2. **Description** (optional): "HomeXpert project assets and images"
3. **Visibility**: 
   - Choose **Public** (so the image URL is accessible)
   - Or **Private** (if you want to keep it private, but you'll need to use a different hosting method)
4. **DO NOT** check "Initialize with README" (we'll add files manually)
5. **Click "Create repository"**

### Step 3: Upload Logo File

1. **On the repository page**, you'll see "uploading an existing file"
2. **Click "uploading an existing file"** link
3. **Drag and drop** your `homexpert_logo.png` file, OR
4. **Click "choose your files"** and select `homexpert_logo.png` from:
   - `homexpert/assets/images/homexpert_logo.png`
5. **Scroll down** and enter a commit message: "Add HomeXpert logo"
6. **Click "Commit changes"**

### Step 4: Create Images Folder (Optional but Recommended)

If you want to organize better:

1. **Click "Create new file"**
2. **Type**: `images/` (this creates a folder)
3. **Type a filename**: `README.md` (or any name)
4. **Click "Commit new file"**
5. **Go back** and upload your logo to the `images/` folder

### Step 5: Get the Raw URL

1. **Click on** `homexpert_logo.png` in your repository
2. **Click the "Raw" button** (top right of the image)
3. **Copy the URL** from your browser's address bar
   - It will look like: `https://raw.githubusercontent.com/YOUR_USERNAME/homexpert-assets/main/homexpert_logo.png`
   - Or if in images folder: `https://raw.githubusercontent.com/YOUR_USERNAME/homexpert-assets/main/images/homexpert_logo.png`

### Step 6: Add to .env File

1. **Open** `homexpert/backend/.env`
2. **Add this line**:
   ```env
   LOGO_URL=https://raw.githubusercontent.com/YOUR_USERNAME/homexpert-assets/main/homexpert_logo.png
   ```
   (Replace `YOUR_USERNAME` and path with your actual GitHub username and file path)

3. **Save** the file

### Step 7: Restart Backend Server

```bash
cd backend
npm run dev
```

## ✅ Verification

1. **Create a test user** through the admin panel
2. **Check the email** - the logo should now appear between "Welcome to" and "HomeXpert"
3. **Check backend console** for email sending logs

## 🔒 Security Note

- **Public repositories** are visible to everyone
- If you want to keep it private, consider:
  - Using your own server
  - Using a CDN service
  - Using GitHub with a personal access token (more complex)

## 📝 Example .env Entry

```env
# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=homexpert714@gmail.com
SMTP_PASSWORD=dughiabrazdtgzge
APP_URL=http://localhost:8080

# Logo URL for Email Templates
LOGO_URL=https://raw.githubusercontent.com/yourusername/homexpert-assets/main/homexpert_logo.png
```

## 🐛 Troubleshooting

### Logo not showing in email?

1. **Check the URL** - Make sure it's the "Raw" URL, not the regular GitHub page URL
2. **Check if repository is public** - Private repos won't work with raw URLs
3. **Check file path** - Make sure the path in URL matches where you uploaded the file
4. **Test the URL** - Open the raw URL in a browser - you should see the image directly

### URL format examples:

✅ **Correct (Raw URL)**:
```
https://raw.githubusercontent.com/username/repo/main/homexpert_logo.png
```

❌ **Wrong (Regular GitHub page)**:
```
https://github.com/username/repo/blob/main/homexpert_logo.png
```

## 🎯 Quick Checklist

- [ ] GitHub account created/signed in
- [ ] Repository created (public)
- [ ] Logo file uploaded to repository
- [ ] Raw URL copied
- [ ] LOGO_URL added to `.env` file
- [ ] Backend server restarted
- [ ] Test email sent and logo appears

---

**Need help?** If you get stuck at any step, let me know which step and I'll help you through it!

