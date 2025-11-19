# Email Setup Guide for HomeXpert

This guide will help you configure email sending functionality for user notifications.

## 📋 Prerequisites

- Node.js backend is set up and running
- An email account (Gmail, Outlook, or any SMTP-compatible email service)

## 🔧 Setup Instructions

### Option 1: Gmail (Recommended for Development)

#### Step 1: Enable App Password for Gmail

**Important:** You must have 2-Step Verification enabled first. If you see the 2-Step Verification page, make sure it's turned ON.

1. Go to your Google Account settings: https://myaccount.google.com/
2. Navigate to **Security** → **2-Step Verification** (make sure it's enabled)
3. **Scroll down** on the 2-Step Verification page, or look for **"App passwords"** link
4. **Alternative method:** Go directly to: https://myaccount.google.com/apppasswords
   - If you see "App passwords aren't available for your account", make sure 2-Step Verification is enabled
5. If prompted, sign in again
6. Select **Mail** from the dropdown
7. Select **Other (Custom name)** from the device dropdown
8. Enter "HomeXpert Backend" as the name
9. Click **Generate**
10. **Copy the 16-character password** (it will look like: `abcd efgh ijkl mnop` - remove spaces when using it)

#### Step 2: Update `.env` File

Open `backend/.env` and add the following configuration:

```env
# Email Configuration (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-character-app-password

# Application URL (for email links)
APP_URL=http://localhost:8080
```

**Important:** 
- Use your Gmail address for `SMTP_USER`
- Use the **App Password** (not your regular Gmail password) for `SMTP_PASSWORD`
- The App Password is 16 characters without spaces

### Option 2: Outlook/Hotmail

#### Step 1: Enable App Password

1. Go to https://account.microsoft.com/security
2. Enable **Two-step verification** if not already enabled
3. Go to **Security** → **Advanced security options**
4. Under **App passwords**, create a new app password
5. Name it "HomeXpert Backend" and copy the password

#### Step 2: Update `.env` File

```env
# Email Configuration (Outlook)
SMTP_HOST=smtp-mail.outlook.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@outlook.com
SMTP_PASSWORD=your-app-password

# Application URL
APP_URL=http://localhost:8080
```

### Option 3: Custom SMTP Server

If you have your own SMTP server (e.g., SendGrid, Mailgun, AWS SES):

```env
# Email Configuration (Custom SMTP)
SMTP_HOST=your-smtp-server.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-smtp-username
SMTP_PASSWORD=your-smtp-password

# Application URL
APP_URL=http://localhost:8080
```

## 🧪 Testing Email Configuration

### Method 1: Test via Backend Logs

1. Start your backend server:
   ```bash
   cd backend
   npm run dev
   ```

2. Create a new user through the admin panel

3. Check the backend console:
   - ✅ If email is sent: You'll see `✅ Email sent successfully: [message-id]`
   - ❌ If email fails: You'll see `❌ Error sending email: [error message]`
   - ⚠️ If not configured: You'll see `⚠️ Email service not configured. Skipping email send.`

### Method 2: Test Email Service Directly

You can test the email service by creating a test endpoint. Add this to `backend/routes/admin.js`:

```javascript
// Test email endpoint (add this temporarily for testing)
router.post('/test-email', async (req, res) => {
  const { sendWelcomeEmail } = require('../services/email_service');
  const result = await sendWelcomeEmail(
    'test@example.com',
    'Test',
    'User',
    'TempPassword123!'
  );
  res.json(result);
});
```

Then test with:
```bash
curl -X POST http://localhost:3000/api/admin/test-email
```

## 📧 Email Content

The welcome email includes:
- Welcome message with user's name
- Login credentials (email and temporary password)
- Login link to the application
- Security reminder to change password

## 🔒 Security Notes

1. **Never commit `.env` file** - It contains sensitive credentials
2. **Use App Passwords** - Don't use your regular email password
3. **Environment Variables** - Keep email credentials in `.env`, never hardcode
4. **Production** - For production, use a dedicated email service (SendGrid, AWS SES, etc.)

## 🐛 Troubleshooting

### Issue: "Invalid login" or "Authentication failed"

**Solution:**
- Make sure you're using an **App Password**, not your regular email password
- For Gmail: Verify 2-Step Verification is enabled
- Double-check `SMTP_USER` and `SMTP_PASSWORD` in `.env`

### Issue: "Connection timeout"

**Solution:**
- Check your firewall settings
- Verify `SMTP_HOST` and `SMTP_PORT` are correct
- Try using port 465 with `SMTP_SECURE=true`

### Issue: "Email not sending but no error"

**Solution:**
- Check backend console logs for email errors
- Verify `.env` file is in the `backend/` directory
- Restart the backend server after changing `.env`

### Issue: "Email goes to spam"

**Solution:**
- Use a professional email service (SendGrid, Mailgun) for production
- Set up SPF, DKIM, and DMARC records for your domain
- Avoid using free email services for production

## 📝 Example `.env` File

Here's a complete example of what your `backend/.env` should look like:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MySQL Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=homexpert_db

# JWT Secret
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRES_IN=7d

# CORS Configuration
CORS_ORIGIN=http://localhost:8080

# Email Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-16-character-app-password
APP_URL=http://localhost:8080
```

## ✅ Verification Checklist

- [ ] `.env` file exists in `backend/` directory
- [ ] `SMTP_USER` is set to your email address
- [ ] `SMTP_PASSWORD` is set to your App Password (not regular password)
- [ ] `SMTP_HOST` and `SMTP_PORT` are correct for your email provider
- [ ] Backend server has been restarted after updating `.env`
- [ ] Test email was sent successfully (check backend logs)

## 🚀 Next Steps

Once email is configured:
1. Create a test user through the admin panel
2. Check the user's email inbox (and spam folder)
3. Verify the email contains correct login credentials
4. Test the login link in the email

---

**Note:** For production environments, consider using a dedicated email service like:
- **SendGrid** (Free tier: 100 emails/day)
- **Mailgun** (Free tier: 5,000 emails/month)
- **AWS SES** (Pay-as-you-go, very affordable)
- **Postmark** (Great deliverability)

These services provide better deliverability and analytics compared to using personal email accounts.

