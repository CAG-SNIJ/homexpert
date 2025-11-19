

INSERT INTO users (
    user_id,
    email,
    password,
    first_name,
    last_name,
    account_status,
    role,
    is_email_verified
) VALUES (
    'USER_ADMIN001',
    'admin@homexpert.com',
    '$2b$10$YourBcryptHashHere', -- TODO: Replace with actual bcrypt hash
    'System',
    'Administrator',
    'active',
    'admin',
    TRUE
) ON DUPLICATE KEY UPDATE email=email;

-- Get the user ID
SET @admin_user_id = LAST_INSERT_ID();
SELECT @admin_user_id AS admin_user_id;

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
SELECT 
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
-- SUCCESS MESSAGE
-- ============================================
SELECT 
    '✅ Admin created successfully!' AS status,
    'admin@homexpert.com' AS email,
    'USER_ADMIN001' AS user_id,
    'ADMIN001' AS staff_id,
    '⚠️ Remember to update the password with a proper bcrypt hash!' AS note;

