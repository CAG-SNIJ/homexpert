-- Create Test Admin User Script
-- Run this after creating the complete database schema
-- Make sure to update the password with a proper bcrypt hash

USE homexpert_db;

-- ============================================
-- STEP 1: Create User Account for Admin
-- ============================================
-- Note: Replace '$2b$10$YourBcryptHashHere' with actual bcrypt hash
-- Generate hash using: node hash_password.js
-- Or use online tool: https://bcrypt-generator.com/

INSERT INTO users (
    user_id,
    email,
    password,
    first_name,
    last_name,
    phone_no,
    account_status,
    role,
    is_email_verified,
    is_phone_verified
) VALUES (
    'USER_ADMIN001',
    'admin@homexpert.com',
    '$2a$10$qbFVjTJ6GwsefkCiSu79wuKXXJ9Ss7G7zoUakdD0JL1dipTLgnSsm', -- TODO: Replace with actual bcrypt hash (e.g., for password: Admin@123)
    'System',
    'Administrator',
    NULL,
    'active',
    'admin',
    TRUE,
    FALSE
) ON DUPLICATE KEY UPDATE email=email;

-- Get the user ID
SET @admin_user_id = LAST_INSERT_ID();
SELECT @admin_user_id AS admin_user_id;

-- If user already exists, get the ID
SELECT @admin_user_id := id FROM users WHERE email = 'admin@homexpert.com';

-- ============================================
-- STEP 2: Create Platform Staff Record
-- ============================================
INSERT INTO platform_staff (
    staff_id,
    staff_role,
    user_id,
    is_active
) VALUES (
    'ADMIN001',
    'admin',
    @admin_user_id,
    TRUE
) ON DUPLICATE KEY UPDATE staff_id=staff_id;

-- Get the platform staff ID
SET @platform_staff_id = LAST_INSERT_ID();
SELECT @platform_staff_id AS platform_staff_id;

-- If staff already exists, get the ID
SELECT @platform_staff_id := id FROM platform_staff WHERE staff_id = 'ADMIN001';

-- ============================================
-- STEP 3: Create Admin Record
-- ============================================
INSERT INTO admin (
    admin_id,
    platform_staff_id,
    admin_privileges
) VALUES (
    'ADMIN001',
    @platform_staff_id,
    JSON_ARRAY(
        'user_management',
        'agent_management',
        'staff_management',
        'property_management',
        'kyc_review',
        'agent_verification',
        'listing_approval',
        'account_deletion_approval',
        'user_suspension',
        'agent_suspension',
        'staff_deactivation',
        'report_generation'
    )
) ON DUPLICATE KEY UPDATE admin_id=admin_id;

-- Get the admin ID
SET @admin_id = LAST_INSERT_ID();
SELECT @admin_id AS admin_id;

-- ============================================
-- STEP 4: Create Staff Metrics for Admin
-- ============================================
INSERT INTO staff_metrics (
    metrics_id,
    staff_id,
    kyc_reviews_completed,
    agent_verifications_completed,
    listing_approvals_completed,
    properties_created,
    properties_updated
) VALUES (
    CONCAT('METRICS_', @platform_staff_id),
    @platform_staff_id,
    0,
    0,
    0,
    0,
    0
) ON DUPLICATE KEY UPDATE metrics_id=metrics_id;

-- ============================================
-- STEP 5: Verify Admin Creation
-- ============================================
SELECT 
    'Admin Created Successfully!' AS status,
    u.id AS user_id,
    u.user_id AS user_user_id,
    u.email,
    u.first_name,
    u.last_name,
    u.account_status,
    u.role,
    ps.staff_id,
    ps.staff_role,
    a.admin_id,
    JSON_PRETTY(a.admin_privileges) AS privileges,
    sm.metrics_id
FROM users u
JOIN platform_staff ps ON u.id = ps.user_id
JOIN admin a ON ps.id = a.platform_staff_id
LEFT JOIN staff_metrics sm ON ps.id = sm.staff_id
WHERE u.email = 'admin@homexpert.com';

-- ============================================
-- STEP 6: Test Login Query (for backend API)
-- ============================================
-- This query can be used in your Node.js backend for admin login
-- Parameters: email, staff_id
SELECT 
    'Login Query Result:' AS info,
    u.id,
    u.user_id,
    u.email,
    u.password,
    u.first_name,
    u.last_name,
    u.account_status,
    u.role,
    ps.staff_id,
    ps.staff_role,
    a.admin_id,
    a.admin_privileges
FROM users u
JOIN platform_staff ps ON u.id = ps.user_id
JOIN admin a ON ps.id = a.platform_staff_id
WHERE u.email = 'admin@homexpert.com'
AND ps.staff_id = 'ADMIN001'
AND u.account_status = 'active';

-- ============================================
-- STEP 7: Create Test Regular User (Optional)
-- ============================================
INSERT INTO users (
    user_id,
    email,
    password,
    first_name,
    last_name,
    phone_no,
    account_status,
    role,
    is_email_verified,
    is_phone_verified
) VALUES (
    'USER_TEST001',
    'testuser@homexpert.com',
    '$2a$10$qbFVjTJ6GwsefkCiSu79wuKXXJ9Ss7G7zoUakdD0JL1dipTLgnSsm', -- TODO: Replace with actual bcrypt hash
    'Test',
    'User',
    '+60123456789',
    'active',
    'user',
    TRUE,
    FALSE
) ON DUPLICATE KEY UPDATE email=email;

SELECT 'Test User Created!' AS status;

-- ============================================
-- SUCCESS MESSAGE
-- ============================================
SELECT 
    'Setup Complete!' AS status,
    'Admin Email: admin@homexpert.com' AS admin_email,
    'Admin Staff ID: ADMIN001' AS admin_staff_id,
    'User ID: USER_ADMIN001' AS admin_user_id,
    'IMPORTANT: Update password hash before testing login!' AS note;

