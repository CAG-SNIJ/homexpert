const nodemailer = require('nodemailer');

// Create reusable transporter object using SMTP transport
const createTransporter = () => {
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true', // true for 465, false for other ports
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD,
    },
  });
};

/**
 * Send welcome email to newly created user
 * @param {string} email - User's email address
 * @param {string} firstName - User's first name
 * @param {string} lastName - User's last name
 * @param {string} tempPassword - Temporary password
 * @returns {Promise<Object>} - Email send result
 */
async function sendWelcomeEmail(email, firstName, lastName, tempPassword) {
  try {
    // Validate email configuration
    if (!process.env.SMTP_USER || !process.env.SMTP_PASSWORD) {
      console.warn('⚠️  Email service not configured. Skipping email send.');
      console.warn('   SMTP_USER:', process.env.SMTP_USER ? '✅ Set' : '❌ Missing');
      console.warn('   SMTP_PASSWORD:', process.env.SMTP_PASSWORD ? '✅ Set' : '❌ Missing');
      return { success: false, message: 'Email service not configured' };
    }

    console.log(`📧 Configuring email transporter...`);
    console.log(`   SMTP Host: ${process.env.SMTP_HOST || 'smtp.gmail.com'}`);
    console.log(`   SMTP Port: ${process.env.SMTP_PORT || '587'}`);
    console.log(`   SMTP User: ${process.env.SMTP_USER}`);

    const transporter = createTransporter();
    
    // Verify transporter configuration
    console.log(`🔍 Verifying email configuration...`);
    await transporter.verify();
    console.log(`✅ Email configuration verified successfully`);

    // Email content
    const mailOptions = {
      from: `"HomeXpert" <${process.env.SMTP_USER}>`,
      to: email,
      subject: 'Welcome to HomeXpert - Your Account Has Been Created',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Welcome to HomeXpert</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
          <div style="background-color: #387366; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0;">
            <div style="display: flex; align-items: center; justify-content: center; gap: 10px; flex-wrap: wrap;">
              <span style="font-size: 28px; font-weight: bold; line-height: 1.2;">Welcome to</span>
              <img src="${process.env.LOGO_URL || 'https://via.placeholder.com/60x60/387366/ffffff?text=HX'}" alt="HomeXpert Logo" style="height: 50px; width: auto; display: inline-block; vertical-align: middle;" />
              <span style="font-size: 28px; font-weight: bold; line-height: 1.2;">HomeXpert</span>
            </div>
          </div>
          
          <div style="background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
            <p>Dear ${firstName} ${lastName},</p>
            
            <p>Your account has been successfully created on HomeXpert platform!</p>
            
            <div style="background-color: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #387366;">
              <p style="margin: 0 0 10px 0;"><strong>Your Login Credentials:</strong></p>
              <p style="margin: 5px 0;"><strong>Email:</strong> ${email}</p>
              <p style="margin: 5px 0;"><strong>Temporary Password:</strong> ${tempPassword}</p>
            </div>
            
            <p><strong>Important:</strong> Please change your password after your first login for security purposes.</p>
            
            <p>You can now log in to your account and start exploring our platform.</p>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${process.env.APP_URL || 'http://localhost:8080'}/login" 
                 style="background-color: #387366; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;">
                Login to Your Account
              </a>
            </div>
            
            <p style="margin-top: 30px; font-size: 12px; color: #666;">
              If you have any questions or need assistance, please don't hesitate to contact our support team.
            </p>
            
            <p style="margin-top: 20px;">
              Best regards,<br>
              <strong>The HomeXpert Team</strong>
            </p>
          </div>
          
          <div style="text-align: center; margin-top: 40px; padding-top: 20px; border-top: 1px solid #e5e5e5;">
            <p style="font-size: 12px; color: #666; margin: 0;">
              © Copyright 2025 HomeXpert. All rights reserved.
            </p>
          </div>
        </body>
        </html>
      `,
      text: `
        Welcome to HomeXpert
        
        Dear ${firstName} ${lastName},
        
        Your account has been successfully created on HomeXpert platform!
        
        Your Login Credentials:
        Email: ${email}
        Temporary Password: ${tempPassword}
        
        Important: Please change your password after your first login for security purposes.
        
        You can now log in to your account and start exploring our platform.
        
        Login URL: ${process.env.APP_URL || 'http://localhost:8080'}/login
        
        If you have any questions or need assistance, please don't hesitate to contact our support team.
        
        Best regards,
        The HomeXpert Team
      `,
    };

    // Send email
    console.log(`📤 Sending email to ${email}...`);
    const info = await transporter.sendMail(mailOptions);
    console.log('✅ Email sent successfully!');
    console.log(`   Message ID: ${info.messageId}`);
    console.log(`   To: ${email}`);
    console.log(`   Subject: Welcome to HomeXpert - Your Account Has Been Created`);
    return { success: true, messageId: info.messageId };
  } catch (error) {
    console.error('❌ Error sending email:', error.message);
    console.error('   Error details:', error);
    if (error.code) {
      console.error(`   Error code: ${error.code}`);
    }
    return { success: false, error: error.message };
  }
}

/**
 * Test email configuration
 * @returns {Promise<boolean>} - True if email service is properly configured
 */
async function testEmailConfig() {
  try {
    if (!process.env.SMTP_USER || !process.env.SMTP_PASSWORD) {
      return false;
    }

    const transporter = createTransporter();
    await transporter.verify();
    return true;
  } catch (error) {
    console.error('Email configuration test failed:', error.message);
    return false;
  }
}

module.exports = {
  sendWelcomeEmail,
  testEmailConfig,
};

