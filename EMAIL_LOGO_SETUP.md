# Email Logo Setup Guide

## 📧 Adding Logo to Email Templates

Email templates require images to be hosted on a publicly accessible URL. Here's how to set it up:

## Option 1: Host Logo on Your Server (Recommended)

1. **Upload your logo** to a publicly accessible location:
   - Your production server
   - A CDN (Cloudflare, AWS S3, etc.)
   - GitHub (using raw.githubusercontent.com)
   - Any image hosting service

2. **Add to `.env` file**:
   ```env
   LOGO_URL=https://your-domain.com/images/homexpert_logo.png
   ```

3. **Restart backend server**

## Option 2: Use GitHub (Quick Setup)

1. **Upload logo to your GitHub repository**:
   - Go to your repo
   - Navigate to `assets/images/`
   - Upload `homexpert_logo.png`

2. **Get the raw URL**:
   - Click on the image file
   - Click "Raw" button
   - Copy the URL (e.g., `https://raw.githubusercontent.com/yourusername/repo/main/assets/images/homexpert_logo.png`)

3. **Add to `.env` file**:
   ```env
   LOGO_URL=https://raw.githubusercontent.com/yourusername/repo/main/assets/images/homexpert_logo.png
   ```

## Option 3: Use Base64 Embedding (For Development)

If you want to embed the logo directly in the email (larger email size but no external hosting needed):

1. **Convert image to base64**:
   ```bash
   # On Windows PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("assets/images/homexpert_logo.png"))
   ```

2. **Update email_service.js** to use base64:
   ```javascript
   const logoBase64 = 'YOUR_BASE64_STRING_HERE';
   <img src="data:image/png;base64,${logoBase64}" ... />
   ```

## ✅ Verification

After setting up, test the email:
1. Create a test user
2. Check the email - logo should appear between "to" and "HomeXpert"
3. Check the footer - copyright notice should appear at bottom

## 📝 Current Status

- ✅ Logo placeholder added to email template
- ✅ Copyright footer added
- ⚠️  Logo URL needs to be configured in `.env` (LOGO_URL)

---

**Note:** For production, always use Option 1 (hosted on your server) for better reliability and performance.

