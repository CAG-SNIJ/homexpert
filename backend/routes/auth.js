const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { query } = require('../config/database');

/**
 * @route   POST /api/auth/staff/login
 * @desc    Staff/Admin login
 * @access  Public
 */
router.post('/staff/login', async (req, res) => {
  try {
    const { staffId, password } = req.body;

    // Validate input
    if (!staffId || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide staff ID and password'
      });
    }

    // Query database for staff/admin user
    // Use JSON_EXTRACT or CAST to ensure admin_privileges is returned as JSON
    const loginQuery = `
      SELECT 
        u.id,
        u.user_id,
        u.email,
        u.password,
        u.first_name,
        u.last_name,
        u.account_status,
        u.role,
        ps.id AS platform_staff_id,
        ps.staff_id,
        ps.staff_role,
        ps.is_active,
        a.id AS admin_id,
        CAST(a.admin_privileges AS CHAR) AS admin_privileges
      FROM users u
      JOIN platform_staff ps ON u.id = ps.user_id
      LEFT JOIN admin a ON ps.id = a.platform_staff_id
      WHERE ps.staff_id = ?
      AND u.account_status = 'active'
      LIMIT 1
    `;

    const results = await query(loginQuery, [staffId]);

    // Check if user exists
    if (results.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid staff ID'
      });
    }

    const user = results[0];

    // Check if staff account is active
    if (!user.is_active) {
      return res.status(403).json({
        success: false,
        message: 'Staff account is inactive. Please contact administrator.'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid password'
      });
    }

    // Generate JWT token
    const tokenPayload = {
      userId: user.id,
      userUserId: user.user_id,
      email: user.email,
      staffId: user.staff_id,
      role: user.staff_role,
      isAdmin: user.admin_id ? true : false,
      adminPrivileges: user.admin_privileges ? JSON.parse(user.admin_privileges) : null
    };

    const token = jwt.sign(
      tokenPayload,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Update last login timestamp
    await query(
      'UPDATE users SET last_login = NOW() WHERE id = ?',
      [user.id]
    );

    // Return success response
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user.id,
          userId: user.user_id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          staffId: user.staff_id,
          role: user.staff_role,
          isAdmin: user.admin_id ? true : false,
          adminPrivileges: user.admin_privileges ? JSON.parse(user.admin_privileges) : null
        }
      }
    });

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again later.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   POST /api/auth/user/login
 * @desc    User/Agent login
 * @access  Public
 */
router.post('/user/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    // Query database for user/agent
    const loginQuery = `
      SELECT 
        u.id,
        u.user_id,
        u.email,
        u.password,
        u.first_name,
        u.last_name,
        u.account_status,
        u.role
      FROM users u
      WHERE u.email = ?
      AND u.role IN ('user', 'agent')
      LIMIT 1
    `;

    const results = await query(loginQuery, [email.trim()]);

    // Check if user exists
    if (results.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const user = results[0];

    // Check if account is active
    if (user.account_status !== 'active') {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive. Please contact support.'
      });
    }

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    // Generate JWT token
    const tokenPayload = {
      userId: user.id,
      userUserId: user.user_id,
      email: user.email,
      role: user.role,
    };

    const token = jwt.sign(
      tokenPayload,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key',
      { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
    );

    // Update last login timestamp
    await query(
      'UPDATE users SET last_login = NOW() WHERE id = ?',
      [user.id]
    );

    // Return success response
    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user.id,
          userId: user.user_id,
          email: user.email,
          firstName: user.first_name,
          lastName: user.last_name,
          role: user.role,
        }
      }
    });

  } catch (error) {
    console.error('User login error:', error);
    res.status(500).json({
      success: false,
      message: 'Server error. Please try again later.',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/auth/user/profile
 * @desc    Get current user profile
 * @access  Private
 */
router.get('/user/profile', async (req, res) => {
  try {
    // Get user ID from token (set by auth middleware if you have one)
    // For now, we'll extract from Authorization header
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key'
    );

    const userId = decoded.userId;

    // Get user from database
    const users = await query(
      `SELECT 
        u.id,
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.phone_no,
        u.region,
        u.area,
        u.gender,
        u.birthday_month,
        u.birthday_year,
        u.account_status,
        u.role,
        u.created_at,
        u.profile_picture
      FROM users u
      WHERE u.id = ?
      AND u.role IN ('user', 'agent')
      LIMIT 1`,
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const user = users[0];

    // Convert gender boolean/0/1 to string
    let gender = null;
    if (user.gender === true || user.gender === 1) {
      gender = 'Male';
    } else if (user.gender === false || user.gender === 0) {
      gender = 'Female';
    }

    // Parse phone number to extract country code and number
    let phoneNo = user.phone_no || '';
    let countryCode = '+60'; // Default to Malaysia
    let phoneNumber = phoneNo;

    // Try to extract country code from phone number
    for (const code of ['+971', '+966', '+886', '+852', '+91', '+44', '+1', '+86', '+82', '+81', '+61', '+63', '+62', '+66', '+65', '+60']) {
      if (phoneNo.startsWith(code)) {
        countryCode = code;
        phoneNumber = phoneNo.substring(code.length);
        break;
      }
    }

    res.json({
      success: true,
      data: {
        id: user.id,
        user_id: user.user_id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        phone_no: user.phone_no,
        country_code: countryCode,
        phone_number: phoneNumber,
        region: user.region || '',
        area: user.area || '',
        gender: gender,
        birthday_month: user.birthday_month || '',
        birthday_year: user.birthday_year || '',
        account_status: user.account_status || 'active',
        role: user.role,
        created_at: user.created_at,
        profile_picture: user.profile_picture || null,
      },
    });
  } catch (error) {
    console.error('Get user profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user profile',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   PUT /api/auth/user/profile
 * @desc    Update current user profile
 * @access  Private
 */
router.put('/user/profile', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key'
    );

    const userId = decoded.userId;
    const {
      firstName,
      lastName,
      mobilePhone,
      region,
      area,
      gender,
      birthdayMonth,
      birthdayYear,
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !mobilePhone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: firstName, lastName, mobilePhone',
      });
    }

    // Check if phone already exists for another user
    const phoneCheck = await query(
      'SELECT id FROM users WHERE phone_no = ? AND id != ?',
      [mobilePhone, userId]
    );

    if (phoneCheck.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Mobile phone already exists',
      });
    }

    // Convert gender to boolean
    let genderValue = null;
    if (gender === 'Male') {
      genderValue = true;
    } else if (gender === 'Female') {
      genderValue = false;
    }

    // Update user in database (email is not updated)
    await query(
      `UPDATE users SET
        first_name = ?,
        last_name = ?,
        phone_no = ?,
        region = ?,
        area = ?,
        gender = ?,
        birthday_month = ?,
        birthday_year = ?
      WHERE id = ?
      AND role IN ('user', 'agent')`,
      [
        firstName,
        lastName,
        mobilePhone,
        region || null,
        area || null,
        genderValue,
        birthdayMonth || null,
        birthdayYear || null,
        userId,
      ]
    );

    res.json({
      success: true,
      message: 'Profile updated successfully',
    });
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update profile',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   PUT /api/auth/user/password
 * @desc    Change user password
 * @access  Private
 */
router.put('/user/password', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key'
    );

    const userId = decoded.userId;
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: 'Please provide current password and new password',
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: 'New password must be at least 6 characters long',
      });
    }

    // Get user from database
    const users = await query(
      'SELECT id, password FROM users WHERE id = ? AND role IN (\'user\', \'agent\')',
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const user = users[0];

    // Verify current password
    const isPasswordValid = await bcrypt.compare(currentPassword, user.password);
    
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Current password is incorrect',
      });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password
    await query(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, userId]
    );

    res.json({
      success: true,
      message: 'Password changed successfully',
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to change password',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   POST /api/auth/verify-token
 * @desc    Verify JWT token
 * @access  Private
 */
router.post('/verify-token', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1]; // Bearer token

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'No token provided'
      });
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'your_super_secret_jwt_key'
    );

    res.json({
      success: true,
      data: decoded
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid or expired token'
    });
  }
});

module.exports = router;

