-- HomeXpert Minimal Database Schema (Admin Testing Only)
-- MySQL 8.0+
-- Character Set: utf8mb4
-- Collation: utf8mb4_unicode_ci
-- 
-- This is a minimal schema for testing admin login functionality only.
-- Full schema will be created later based on complete class diagrams.

-- Create database
CREATE DATABASE IF NOT EXISTS homexpert_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE homexpert_db;

-- ============================================
-- USERS TABLE (Minimal - for admin only)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- bcrypt hashed password
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20),
    account_status VARCHAR(50) DEFAULT 'active',
    role VARCHAR(50) DEFAULT 'admin', -- user, agent, staff, admin
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    profile_picture VARCHAR(500),
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_account_status (account_status),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PLATFORM_STAFF TABLE (Minimal)
-- ============================================
CREATE TABLE IF NOT EXISTS platform_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    staff_id VARCHAR(50) UNIQUE NOT NULL,
    staff_role VARCHAR(50) NOT NULL,
    user_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_staff_id (staff_id),
    INDEX idx_staff_role (staff_role),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADMIN TABLE (Minimal)
-- ============================================
CREATE TABLE IF NOT EXISTS admin (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id VARCHAR(50) UNIQUE NOT NULL,
    platform_staff_id INT NOT NULL,
    admin_privileges JSON, -- List of privileges stored as JSON array
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (platform_staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    INDEX idx_admin_id (admin_id),
    INDEX idx_platform_staff_id (platform_staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ACTIVITY_LOG TABLE (Minimal - for testing)
-- ============================================
CREATE TABLE IF NOT EXISTS activity_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_id VARCHAR(50) UNIQUE NOT NULL,
    staff_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    ip_address VARCHAR(45),
    entity_type VARCHAR(50),
    entity_id VARCHAR(50),
    FOREIGN KEY (staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    INDEX idx_log_id (log_id),
    INDEX idx_staff_id (staff_id),
    INDEX idx_action (action),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- STAFF_METRICS TABLE (Minimal - for testing)
-- ============================================
CREATE TABLE IF NOT EXISTS staff_metrics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    metrics_id VARCHAR(50) UNIQUE NOT NULL,
    staff_id INT NOT NULL,
    kyc_reviews_completed INT DEFAULT 0,
    agent_verifications_completed INT DEFAULT 0,
    listing_approvals_completed INT DEFAULT 0,
    properties_created INT DEFAULT 0,
    properties_updated INT DEFAULT 0,
    last_calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    UNIQUE KEY unique_staff_metrics (staff_id),
    INDEX idx_metrics_id (metrics_id),
    INDEX idx_staff_id (staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Verify tables created
-- ============================================
SHOW TABLES;

-- ============================================
-- Show table structure
-- ============================================
SELECT 'Users table structure:' AS info;
DESCRIBE users;

SELECT 'Platform Staff table structure:' AS info;
DESCRIBE platform_staff;

SELECT 'Admin table structure:' AS info;
DESCRIBE admin;

