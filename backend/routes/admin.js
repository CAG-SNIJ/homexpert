/**
 * @route   POST /api/admin/staff
 * @desc    Create a new staff member
 * @access  Private (Admin only)
 */
const express = require('express');
const router = express.Router();
const { query } = require('../config/database');

const getNextStaffId = async () => {
  const result = await query(
    'SELECT staff_id FROM platform_staff ORDER BY id DESC LIMIT 1'
  );
  if (!result.length || !result[0].staff_id) {
    return 'STF00001';
  }
  const lastId = result[0].staff_id;
  const numericPart = parseInt(lastId.replace(/\D/g, ''), 10) || 0;
  const nextNumber = numericPart + 1;
  return `STF${nextNumber.toString().padStart(5, '0')}`;
};

router.post('/staff', async (req, res) => {
  try {
    const {
      staffRole,
      firstName,
      lastName,
      email,
      mobilePhone,
      region,
      area,
      gender,
      birthdayMonth,
      birthdayYear,
    } = req.body;

    if (!staffRole || !firstName || !lastName || !email || !mobilePhone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide staffRole, firstName, lastName, email, and mobilePhone',
      });
    }

    const existingUser = await query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );
    if (existingUser.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    const existingPhone = await query(
      'SELECT id FROM users WHERE phone_no = ?',
      [mobilePhone]
    );
    if (existingPhone.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Mobile phone already exists',
      });
    }

    const bcrypt = require('bcrypt');
    const { sendWelcomeEmail } = require('../services/email_service');
    const generateRandomPassword = () => {
      const length = 12;
      const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
      let password = '';
      for (let i = 0; i < length; i++) {
        password += charset.charAt(Math.floor(Math.random() * charset.length));
      }
      return password;
    };

    const defaultPassword = generateRandomPassword();
    const hashedPassword = await bcrypt.hash(defaultPassword, 10);

    let genderValue = null;
    if (gender === 'Male') {
      genderValue = true;
    } else if (gender === 'Female') {
      genderValue = false;
    }

    const staffId = await getNextStaffId();

    const insertUserResult = await query(
      `INSERT INTO users (
        user_id, email, password, first_name, last_name, phone_no,
        region, area, gender, birthday_month, birthday_year,
        account_status, role, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 'staff', NOW())`,
      [
        staffId,
        email,
        hashedPassword,
        firstName,
        lastName,
        mobilePhone,
        region || null,
        area || null,
        genderValue,
        birthdayMonth || null,
        birthdayYear || null,
      ]
    );

    const userId = insertUserResult.insertId;

    await query(
      `INSERT INTO platform_staff (staff_id, staff_role, user_id, is_active)
       VALUES (?, ?, ?, true)`,
      [staffId, staffRole, userId]
    );

    sendWelcomeEmail(email, firstName, lastName, defaultPassword).catch((emailError) => {
      console.error(`❌ Failed to send staff welcome email to ${email}:`, emailError);
    });

    res.status(201).json({
      success: true,
      message: 'Staff created successfully',
      data: {
        staff_id: staffId,
        staff_role: staffRole,
        name: `${firstName} ${lastName}`.trim(),
        email,
        region: region || '',
        status: 'Active',
        date_joined: new Date(),
      },
    });
  } catch (error) {
    console.error('Create staff error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create staff member',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   GET /api/admin/dashboard/stats
 * @desc    Get admin dashboard statistics
 * @access  Private (Admin only)
 */
router.get('/dashboard/stats', async (req, res) => {
  try {
    // Get total users (excluding staff/admin)
    const totalUsers = await query(
      `SELECT COUNT(*) as count FROM users WHERE role = 'user' AND account_status = 'active'`
    );

    // Get total agents
    const totalAgents = await query(
      `SELECT COUNT(*) as count FROM users WHERE role = 'agent' AND account_status = 'active'`
    );

    // Get total listings
    const totalListings = await query(
      `SELECT COUNT(*) as count FROM property_listings WHERE status = 'active'`
    );

    // Get total properties
    const totalProperties = await query(
      `SELECT COUNT(*) as count FROM properties`
    );

    // Get total rent listings
    const totalRent = await query(
      `SELECT COUNT(*) as count FROM property_listings WHERE listing_type = 'rent' AND status = 'active'`
    );

    // Get total sale listings
    const totalSale = await query(
      `SELECT COUNT(*) as count FROM property_listings WHERE listing_type = 'sale' AND status = 'active'`
    );

    res.json({
      success: true,
      data: {
        totalUsers: totalUsers[0]?.count || 0,
        totalAgents: totalAgents[0]?.count || 0,
        totalListings: totalListings[0]?.count || 0,
        totalProperties: totalProperties[0]?.count || 0,
        totalRent: totalRent[0]?.count || 0,
        totalSale: totalSale[0]?.count || 0,
      }
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch dashboard statistics',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/admin/dashboard/activities
 * @desc    Get recent activities for admin dashboard
 * @access  Private (Admin only)
 */
router.get('/dashboard/activities', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    // Get recent activities from activity_log table
    const activities = await query(
      `SELECT 
        al.log_id,
        al.action,
        al.timestamp,
        al.details,
        al.entity_type,
        al.entity_id,
        ps.staff_id,
        u.first_name,
        u.last_name,
        u.email
      FROM activity_log al
      LEFT JOIN platform_staff ps ON al.staff_id = ps.id
      LEFT JOIN users u ON ps.user_id = u.id
      ORDER BY al.timestamp DESC
      LIMIT ?`,
      [limit]
    );

    // Format activities
    const formattedActivities = activities.map(activity => ({
      id: activity.log_id,
      staffName: activity.first_name && activity.last_name
        ? `${activity.first_name} ${activity.last_name}`
        : activity.staff_id || 'System',
      action: activity.action || 'Unknown action',
      timestamp: activity.timestamp,
      details: activity.details,
      entityType: activity.entity_type,
      entityId: activity.entity_id,
    }));

    res.json({
      success: true,
      data: formattedActivities
    });
  } catch (error) {
    console.error('Dashboard activities error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch recent activities',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * @route   GET /api/admin/users
 * @desc    Get list of users with pagination and search
 * @access  Private (Admin only)
 */
router.get('/users', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const offset = (page - 1) * limit;

    let sqlQuery = `
      SELECT 
        u.id,
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.phone_no,
        u.region,
        u.area,
        u.account_status,
        u.role,
        u.created_at
      FROM users u
      WHERE u.role = 'user'
    `;
    const queryParams = [];
    const countParams = [];

    // Add search filter if provided
    if (search) {
      sqlQuery += ` AND (
        u.user_id LIKE ? OR
        u.email LIKE ? OR
        u.first_name LIKE ? OR
        u.last_name LIKE ? OR
        u.phone_no LIKE ? OR
        u.region LIKE ?
      )`;
      const searchPattern = `%${search}%`;
      queryParams.push(searchPattern, searchPattern, searchPattern, searchPattern, searchPattern, searchPattern);
      // Copy search params for count query
      countParams.push(...queryParams);
    }

    // Get total count for pagination (before adding LIMIT/OFFSET)
    const countQuery = sqlQuery.replace(/SELECT[\s\S]*?FROM/, 'SELECT COUNT(*) as total FROM');
    const countResult = await query(countQuery, countParams);
    const total = countResult[0]?.total || 0;

    // Add pagination and ordering
    // Note: Using integers directly for LIMIT/OFFSET instead of placeholders
    // as MySQL prepared statements can have issues with LIMIT/OFFSET parameters
    sqlQuery += ` ORDER BY u.created_at DESC LIMIT ${limit} OFFSET ${offset}`;

    const users = await query(sqlQuery, queryParams);

    // Format response
    const formattedUsers = users.map(user => ({
      id: user.id,
      user_id: user.user_id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      phone_no: user.phone_no,
      region: user.region || '',
      area: user.area || '',
      account_status: user.account_status || 'active',
      role: user.role,
      created_at: user.created_at,
    }));

    res.json({
      success: true,
      data: formattedUsers,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Get users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch users',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   GET /api/admin/users/review
 * @desc    Get list of users pending review (KYC Pending, Suspended Pending)
 * @access  Private (Admin only)
 */
router.get('/users/review', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const offset = (page - 1) * limit;

    let sqlQuery = `
      SELECT 
        u.id,
        u.user_id,
        u.email,
        u.first_name,
        u.last_name,
        u.account_status,
        u.created_at
      FROM users u
      WHERE u.role = 'user' 
        AND (
          u.account_status = 'suspended' 
          OR u.account_status LIKE '%pending%' 
          OR u.account_status = 'kyc_pending' 
          OR u.account_status = 'suspended_pending'
          OR (u.account_status != 'active' AND u.account_status IS NOT NULL)
        )
    `;
    const queryParams = [];
    const countParams = [];

    // Add search filter if provided
    if (search) {
      sqlQuery += ` AND (
        u.user_id LIKE ? OR
        u.email LIKE ? OR
        u.first_name LIKE ? OR
        u.last_name LIKE ?
      )`;
      const searchPattern = `%${search}%`;
      queryParams.push(searchPattern, searchPattern, searchPattern, searchPattern);
      // Copy search params for count query
      countParams.push(...queryParams);
    }

    // Get total count for pagination (before adding LIMIT/OFFSET)
    const countQuery = sqlQuery.replace(/SELECT[\s\S]*?FROM/, 'SELECT COUNT(*) as total FROM');
    const countResult = await query(countQuery, countParams);
    const total = countResult[0]?.total || 0;

    // Add pagination and ordering
    sqlQuery += ` ORDER BY u.created_at DESC LIMIT ${limit} OFFSET ${offset}`;

    const users = await query(sqlQuery, queryParams);

    // Format response - convert status to readable format
    const formattedUsers = users.map(user => {
      let accountStatus = user.account_status || 'KYC Pending';
      const statusLower = accountStatus.toLowerCase();
      
      // Convert status to readable format
      if (statusLower === 'suspended') {
        accountStatus = 'Suspended Pending';
      } else if (statusLower.includes('kyc') || statusLower === 'pending' || statusLower === 'kyc_pending') {
        accountStatus = 'KYC Pending';
      } else if (statusLower.includes('suspended')) {
        accountStatus = 'Suspended Pending';
      } else if (statusLower !== 'active') {
        // Any other non-active status is treated as KYC Pending
        accountStatus = 'KYC Pending';
      }
      
      return {
        id: user.id,
        user_id: user.user_id,
        email: user.email,
        first_name: user.first_name,
        last_name: user.last_name,
        account_status: accountStatus,
        date_submitted: user.created_at,
      };
    });

    res.json({
      success: true,
      data: formattedUsers,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Get review users error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch review users',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   POST /api/admin/users
 * @desc    Create a new user
 * @access  Private (Admin only)
 */
router.post('/users', async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      mobilePhone,
      region,
      area,
      gender,
      birthdayMonth,
      birthdayYear,
    } = req.body;

    // Validate required fields
    if (!firstName || !lastName || !email || !mobilePhone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: firstName, lastName, email, mobilePhone',
      });
    }

    // Check if email already exists
    const existingUser = await query(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if (existingUser.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    const existingPhone = await query(
      'SELECT id FROM users WHERE phone_no = ?',
      [mobilePhone]
    );

    if (existingPhone.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Mobile phone already exists',
      });
    }

    // Generate unique user_id (format: USER + timestamp + random)
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000);
    const userId = `USER${timestamp}${random}`;

    // Convert gender string to boolean (Male = true, Female = false, Other = null)
    let genderValue = null;
    if (gender === 'Male') {
      genderValue = true;
    } else if (gender === 'Female') {
      genderValue = false;
    }

    // Insert user into database
    // Note: Password will be set to a default temporary password
    // In production, you might want to generate a random password and send it via email
    const bcrypt = require('bcrypt');
    const { sendWelcomeEmail } = require('../services/email_service');
    
    // Generate a secure random password
    const generateRandomPassword = () => {
      const length = 12;
      const charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
      let password = '';
      for (let i = 0; i < length; i++) {
        password += charset.charAt(Math.floor(Math.random() * charset.length));
      }
      return password;
    };
    
    const defaultPassword = generateRandomPassword();
    const hashedPassword = await bcrypt.hash(defaultPassword, 10);

    const insertResult = await query(
      `INSERT INTO users (
        user_id, email, password, first_name, last_name, phone_no,
        region, area, gender, birthday_month, birthday_year,
        account_status, role, created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 'user', NOW())`,
      [
        userId,
        email,
        hashedPassword,
        firstName,
        lastName,
        mobilePhone,
        region || null,
        area || null,
        genderValue,
        birthdayMonth || null,
        birthdayYear || null,
      ]
    );

    // Get the created user
    const newUser = await query(
      'SELECT * FROM users WHERE id = ?',
      [insertResult.insertId]
    );

    // Send welcome email to the user (non-blocking)
    console.log(`📧 Attempting to send welcome email to: ${email}`);
    sendWelcomeEmail(
      email,
      firstName,
      lastName,
      defaultPassword
    )
      .then((result) => {
        if (result.success) {
          console.log(`✅ Welcome email sent successfully to ${email}`);
        } else {
          console.warn(`⚠️  Email send result: ${result.message}`);
        }
      })
      .catch((emailError) => {
        // Log email error but don't fail the user creation
        console.error(`❌ Failed to send welcome email to ${email}:`, emailError);
      });

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      data: {
        id: newUser[0].id,
        user_id: newUser[0].user_id,
        email: newUser[0].email,
        first_name: newUser[0].first_name,
        last_name: newUser[0].last_name,
        phone_no: newUser[0].phone_no,
        region: newUser[0].region,
        area: newUser[0].area,
        account_status: newUser[0].account_status,
        role: newUser[0].role,
        created_at: newUser[0].created_at,
      },
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create user',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   GET /api/admin/staff
 * @desc    Get list of staff members with pagination and search
 * @access  Private (Admin only)
 */
router.get('/staff', async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const search = req.query.search || '';
    const offset = (page - 1) * limit;

    let sqlQuery = `
      SELECT 
        ps.id,
        ps.staff_id,
        ps.staff_role,
        ps.is_active,
        ps.created_at,
        u.first_name,
        u.last_name,
        u.email,
        u.region
      FROM platform_staff ps
      JOIN users u ON ps.user_id = u.id
      WHERE u.role = 'staff'
    `;
    const queryParams = [];
    const countParams = [];

    if (search) {
      sqlQuery += ` AND (
        ps.staff_id LIKE ? OR
        u.email LIKE ? OR
        u.first_name LIKE ? OR
        u.last_name LIKE ? OR
        u.region LIKE ?
      )`;
      const searchPattern = `%${search}%`;
      queryParams.push(
        searchPattern,
        searchPattern,
        searchPattern,
        searchPattern,
        searchPattern
      );
      countParams.push(...queryParams);
    }

    const countQuery = sqlQuery.replace(/SELECT[\s\S]*?FROM/, 'SELECT COUNT(*) as total FROM');
    const countResult = await query(countQuery, countParams);
    const total = countResult[0]?.total || 0;

    sqlQuery += ` ORDER BY ps.created_at DESC LIMIT ${limit} OFFSET ${offset}`;
    const staffMembers = await query(sqlQuery, queryParams);

    const formattedStaff = staffMembers.map((staff) => ({
      id: staff.id,
      staff_id: staff.staff_id,
      name: `${staff.first_name || ''} ${staff.last_name || ''}`.trim(),
      email: staff.email || '',
      region: staff.region || '',
      status: staff.is_active ? 'Active' : 'Inactive',
      role: staff.staff_role,
      date_joined: staff.created_at,
    }));

    res.json({
      success: true,
      data: formattedStaff,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Get staff error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch staff members',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   PUT /api/admin/staff/:staffId/status
 * @desc    Update staff active status
 * @access  Private (Admin only)
 */
router.put('/staff/:staffId/status', async (req, res) => {
  try {
    const { staffId } = req.params;
    const { status } = req.body;

    if (!staffId) {
      return res.status(400).json({
        success: false,
        message: 'Staff ID is required',
      });
    }

    if (!status || !['active', 'inactive'].includes(status.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: 'Status must be either "active" or "inactive"',
      });
    }

    const staffRecords = await query(
      `SELECT ps.id, ps.user_id
       FROM platform_staff ps
       WHERE ps.staff_id = ?`,
      [staffId]
    );

    if (staffRecords.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Staff member not found',
      });
    }

    const staffRecord = staffRecords[0];
    const isActive = status.toLowerCase() === 'active';

    await query(
      `UPDATE platform_staff
       SET is_active = ?, updated_at = NOW()
       WHERE id = ?`,
      [isActive, staffRecord.id]
    );

    await query(
      `UPDATE users
       SET account_status = ?, updated_at = NOW()
       WHERE id = ?`,
      [isActive ? 'active' : 'inactive', staffRecord.user_id]
    );

    res.json({
      success: true,
      message: `Staff ${isActive ? 'activated' : 'inactivated'} successfully`,
      data: {
        staff_id: staffId,
        status: isActive ? 'Active' : 'Inactive',
      },
    });
  } catch (error) {
    console.error('Update staff status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update staff status',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   GET /api/admin/users/:userId
 * @desc    Get user details by user_id
 * @access  Private (Admin only)
 */
router.get('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

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
        u.created_at
      FROM users u
      WHERE u.user_id = ?`,
      [userId]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const user = users[0];

    // Convert gender boolean/0/1 to string
    // MySQL stores boolean as TINYINT(1): 1 = true (Male), 0 = false (Female), NULL = null
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
      },
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch user',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   PUT /api/admin/users/:userId
 * @desc    Update a user by user_id
 * @access  Private (Admin only)
 */
router.put('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      firstName,
      lastName,
      email,
      mobilePhone,
      region,
      area,
      gender,
      birthdayMonth,
      birthdayYear,
    } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    // Check if user exists
    const existingUser = await query(
      'SELECT id, user_id, email, phone_no FROM users WHERE user_id = ?',
      [userId]
    );

    if (existingUser.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Validate required fields
    if (!firstName || !lastName || !email || !mobilePhone) {
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields: firstName, lastName, email, mobilePhone',
      });
    }

    // Check if email already exists for another user
    const emailCheck = await query(
      'SELECT id FROM users WHERE email = ? AND user_id != ?',
      [email, userId]
    );

    if (emailCheck.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email already exists',
      });
    }

    // Check if phone already exists for another user
    const phoneCheck = await query(
      'SELECT id FROM users WHERE phone_no = ? AND user_id != ?',
      [mobilePhone, userId]
    );

    if (phoneCheck.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Mobile phone already exists',
      });
    }

    // Convert gender string to boolean (Male = true, Female = false, Other = null)
    let genderValue = null;
    if (gender === 'Male') {
      genderValue = true;
    } else if (gender === 'Female') {
      genderValue = false;
    }

    // Update user in database
    await query(
      `UPDATE users SET
        email = ?,
        first_name = ?,
        last_name = ?,
        phone_no = ?,
        region = ?,
        area = ?,
        gender = ?,
        birthday_month = ?,
        birthday_year = ?
      WHERE user_id = ?`,
      [
        email,
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

    // Get the updated user
    const updatedUser = await query(
      'SELECT * FROM users WHERE user_id = ?',
      [userId]
    );

    res.json({
      success: true,
      message: 'User updated successfully',
      data: {
        id: updatedUser[0].id,
        user_id: updatedUser[0].user_id,
        email: updatedUser[0].email,
        first_name: updatedUser[0].first_name,
        last_name: updatedUser[0].last_name,
        phone_no: updatedUser[0].phone_no,
        region: updatedUser[0].region,
        area: updatedUser[0].area,
        account_status: updatedUser[0].account_status,
        role: updatedUser[0].role,
        created_at: updatedUser[0].created_at,
      },
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   DELETE /api/admin/users/:userId
 * @desc    Delete a user by user_id
 * @access  Private (Admin only)
 */
router.delete('/users/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    // Check if user exists
    const existingUser = await query(
      'SELECT id, user_id, first_name, last_name FROM users WHERE user_id = ?',
      [userId]
    );

    if (existingUser.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Delete user from database
    await query('DELETE FROM users WHERE user_id = ?', [userId]);

    res.json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete user',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   PUT /api/admin/users/:userId/status
 * @desc    Update user account status (suspend/activate)
 * @access  Private (Admin only)
 */
router.put('/users/:userId/status', async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    if (!status || !['active', 'suspended'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Status must be either "active" or "suspended"',
      });
    }

    // Check if user exists
    const existingUser = await query(
      'SELECT id, user_id, first_name, last_name, account_status FROM users WHERE user_id = ?',
      [userId]
    );

    if (existingUser.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Update user status
    await query(
      'UPDATE users SET account_status = ? WHERE user_id = ?',
      [status, userId]
    );

    // Get the updated user
    const updatedUser = await query(
      'SELECT * FROM users WHERE user_id = ?',
      [userId]
    );

    res.json({
      success: true,
      message: `User ${status === 'suspended' ? 'suspended' : 'activated'} successfully`,
      data: {
        id: updatedUser[0].id,
        user_id: updatedUser[0].user_id,
        email: updatedUser[0].email,
        first_name: updatedUser[0].first_name,
        last_name: updatedUser[0].last_name,
        account_status: updatedUser[0].account_status,
        role: updatedUser[0].role,
      },
    });
  } catch (error) {
    console.error('Update user status error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update user status',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

/**
 * @route   POST /api/admin/test-email
 * @desc    Test email configuration and send a test email
 * @access  Private (Admin only)
 */
router.post('/test-email', async (req, res) => {
  try {
    const { sendWelcomeEmail } = require('../services/email_service');
    const { email, firstName, lastName } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: 'Email address is required',
      });
    }

    console.log('🧪 Testing email service...');
    const result = await sendWelcomeEmail(
      email,
      firstName || 'Test',
      lastName || 'User',
      'TestPassword123!'
    );

    if (result.success) {
      res.json({
        success: true,
        message: 'Test email sent successfully',
        messageId: result.messageId,
      });
    } else {
      res.status(500).json({
        success: false,
        message: 'Failed to send test email',
        error: result.error || result.message,
      });
    }
  } catch (error) {
    console.error('Test email error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to send test email',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined,
    });
  }
});

module.exports = router;

