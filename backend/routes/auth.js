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

