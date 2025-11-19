-- HomeXpert Complete Database Schema
-- MySQL 8.0+
-- Character Set: utf8mb4
-- Collation: utf8mb4_unicode_ci
-- Based on Complete Class Diagrams

-- Create database
CREATE DATABASE IF NOT EXISTS homexpert_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE homexpert_db;

-- ============================================
-- USERS TABLE (Based on User class)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20),
    region VARCHAR(100),
    area VARCHAR(100),
    gender BOOLEAN,
    birthday_month VARCHAR(20),
    birthday_year VARCHAR(4),
    account_status VARCHAR(50) DEFAULT 'active',
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    profile_picture VARCHAR(500),
    is_email_verified BOOLEAN DEFAULT FALSE,
    is_phone_verified BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_email (email),
    INDEX idx_phone_no (phone_no),
    INDEX idx_account_status (account_status),
    INDEX idx_role (role),
    INDEX idx_region_area (region, area)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PLATFORM_STAFF TABLE
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
-- ADMIN TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id VARCHAR(50) UNIQUE NOT NULL,
    platform_staff_id INT NOT NULL,
    admin_privileges JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (platform_staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    INDEX idx_admin_id (admin_id),
    INDEX idx_platform_staff_id (platform_staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADMIN_MANAGED_USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin_managed_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    user_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_admin_user (admin_id, user_id),
    INDEX idx_admin_id (admin_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADMIN_MANAGED_AGENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin_managed_agents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    agent_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_admin_agent (admin_id, agent_id),
    INDEX idx_admin_id (admin_id),
    INDEX idx_agent_id (agent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ADMIN_MANAGED_STAFF TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admin_managed_staff (
    id INT PRIMARY KEY AUTO_INCREMENT,
    admin_id INT NOT NULL,
    staff_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admin(id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    UNIQUE KEY unique_admin_staff (admin_id, staff_id),
    INDEX idx_admin_id (admin_id),
    INDEX idx_staff_id (staff_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ACTIVITY_LOG TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS activity_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    log_id VARCHAR(50) UNIQUE NOT NULL,
    staff_id INT NOT NULL,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    entity_type VARCHAR(50),
    entity_id VARCHAR(50),
    old_values JSON,
    new_values JSON,
    FOREIGN KEY (staff_id) REFERENCES platform_staff(id) ON DELETE CASCADE,
    INDEX idx_log_id (log_id),
    INDEX idx_staff_id (staff_id),
    INDEX idx_action (action),
    INDEX idx_timestamp (timestamp),
    INDEX idx_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- STAFF_METRICS TABLE
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
-- REPORTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS reports (
    id INT PRIMARY KEY AUTO_INCREMENT,
    report_id VARCHAR(50) UNIQUE NOT NULL,
    report_type VARCHAR(100) NOT NULL,
    generated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_content JSON,
    generated_by INT NOT NULL,
    format VARCHAR(20) DEFAULT 'PDF',
    parameters JSON,
    file_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (generated_by) REFERENCES admin(id) ON DELETE CASCADE,
    INDEX idx_report_id (report_id),
    INDEX idx_report_type (report_type),
    INDEX idx_generated_by (generated_by),
    INDEX idx_generated_date (generated_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- STORE_TYPE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS store_type (
    id INT PRIMARY KEY AUTO_INCREMENT,
    store_type_id VARCHAR(50) UNIQUE NOT NULL,
    store_type_name VARCHAR(100) NOT NULL,
    store_description TEXT,
    credit_per_listing INT DEFAULT 0,
    photos_per_ad INT DEFAULT 0,
    edit_credit_per_listing INT DEFAULT 0,
    monthly_fee DECIMAL(10, 2) DEFAULT 0.00,
    features JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_store_type_id (store_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY_AGENT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS property_agent (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agent_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    agent_name VARCHAR(255) NOT NULL,
    agency_name VARCHAR(255),
    firm_type VARCHAR(100),
    firm_number VARCHAR(100),
    agent_identity VARCHAR(100),
    agent_number VARCHAR(100),
    website VARCHAR(255),
    description TEXT,
    property_specialties JSON,
    focus_area VARCHAR(255),
    store_type_id INT,
    is_verified BOOLEAN DEFAULT FALSE,
    ai_assistant BOOLEAN DEFAULT FALSE,
    listing_credit INT DEFAULT 0,
    listing_edit_credit INT DEFAULT 0,
    commission_rate DECIMAL(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (store_type_id) REFERENCES store_type(id) ON DELETE SET NULL,
    INDEX idx_agent_id (agent_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_verified (is_verified),
    INDEX idx_store_type_id (store_type_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AGENT_PERFORMANCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS agent_performance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    performance_id VARCHAR(50) UNIQUE NOT NULL,
    agent_id INT NOT NULL,
    total_listings INT DEFAULT 0,
    active_listings INT DEFAULT 0,
    total_views INT DEFAULT 0,
    total_inquiries INT DEFAULT 0,
    total_bookings INT DEFAULT 0,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    response_rate DECIMAL(5, 2) DEFAULT 0.00,
    average_response_time INT DEFAULT 0,
    conversion_rate DECIMAL(5, 2) DEFAULT 0.00,
    total_revenue DECIMAL(12, 2) DEFAULT 0.00,
    last_calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_id) REFERENCES property_agent(id) ON DELETE CASCADE,
    UNIQUE KEY unique_agent_performance (agent_id),
    INDEX idx_performance_id (performance_id),
    INDEX idx_agent_id (agent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AI_ASSISTANT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS ai_assistant (
    id INT PRIMARY KEY AUTO_INCREMENT,
    assistant_id VARCHAR(50) UNIQUE NOT NULL,
    linked_agent_id INT NOT NULL,
    follow_up_settings JSON,
    ai_model VARCHAR(100),
    training_data JSON,
    response_templates JSON,
    learning_rate DECIMAL(5, 4) DEFAULT 0.0001,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (linked_agent_id) REFERENCES property_agent(id) ON DELETE CASCADE,
    INDEX idx_assistant_id (assistant_id),
    INDEX idx_linked_agent_id (linked_agent_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- LOCATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS location (
    id INT PRIMARY KEY AUTO_INCREMENT,
    location_id VARCHAR(50) UNIQUE NOT NULL,
    address VARCHAR(500) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    neighborhood VARCHAR(100),
    school_district VARCHAR(100),
    crime_rate DECIMAL(5, 2),
    walk_score INT,
    transit_score INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_location_id (location_id),
    INDEX idx_city_state (city, state),
    INDEX idx_postal_code (postal_code),
    INDEX idx_coordinates (latitude, longitude)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY_SPECS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS property_specs (
    id INT PRIMARY KEY AUTO_INCREMENT,
    specs_id VARCHAR(50) UNIQUE NOT NULL,
    bedrooms INT,
    bathrooms DECIMAL(3, 1),
    square_footage DECIMAL(10, 2),
    year_built INT,
    parking_spaces INT,
    floor_number INT,
    total_floors INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_specs_id (specs_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AMENITY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS amenity (
    id INT PRIMARY KEY AUTO_INCREMENT,
    amenity_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    category VARCHAR(50),
    icon VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_amenity_id (amenity_id),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- FACILITY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS facility (
    id INT PRIMARY KEY AUTO_INCREMENT,
    facility_id VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    category VARCHAR(50),
    icon VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_facility_id (facility_id),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS property (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id VARCHAR(50) UNIQUE NOT NULL,
    property_name VARCHAR(255),
    building_name VARCHAR(255),
    residential_type VARCHAR(100),
    property_description TEXT,
    property_image VARCHAR(500),
    sale_price_min INT,
    sale_price_max INT,
    rent_price_min INT,
    rent_price_max INT,
    tenure_type VARCHAR(50),
    completion_year VARCHAR(10),
    land_title VARCHAR(100),
    total_units INT,
    no_of_floors INT,
    property_facilities TEXT,
    location_id INT,
    developer_group VARCHAR(255),
    created_by INT,
    property_specs_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES location(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (property_specs_id) REFERENCES property_specs(id) ON DELETE SET NULL,
    INDEX idx_property_id (property_id),
    INDEX idx_location_id (location_id),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY_AMENITIES TABLE (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS property_amenities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    amenity_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES property(id) ON DELETE CASCADE,
    FOREIGN KEY (amenity_id) REFERENCES amenity(id) ON DELETE CASCADE,
    UNIQUE KEY unique_property_amenity (property_id, amenity_id),
    INDEX idx_property_id (property_id),
    INDEX idx_amenity_id (amenity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY_FACILITIES TABLE (Many-to-Many)
-- ============================================
CREATE TABLE IF NOT EXISTS property_facilities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    property_id INT NOT NULL,
    facility_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES property(id) ON DELETE CASCADE,
    FOREIGN KEY (facility_id) REFERENCES facility(id) ON DELETE CASCADE,
    UNIQUE KEY unique_property_facility (property_id, facility_id),
    INDEX idx_property_id (property_id),
    INDEX idx_facility_id (facility_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- PROPERTY_LISTING TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS property_listing (
    id INT PRIMARY KEY AUTO_INCREMENT,
    listing_id VARCHAR(50) UNIQUE NOT NULL,
    ad_title VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'draft',
    listing_type VARCHAR(50) NOT NULL,
    tenure_type VARCHAR(50),
    land_title VARCHAR(100),
    expiration_date TIMESTAMP NULL,
    listed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    view_count INT DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    property_id INT NOT NULL,
    is_bumped BOOLEAN DEFAULT FALSE,
    bump_count INT DEFAULT 0,
    last_bumped_at TIMESTAMP NULL,
    bedroom INT,
    bathroom INT,
    parking INT,
    property_size DECIMAL(10, 2),
    furnishing VARCHAR(50),
    floor_range VARCHAR(50),
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES property(id) ON DELETE CASCADE,
    INDEX idx_listing_id (listing_id),
    INDEX idx_status (status),
    INDEX idx_listing_type (listing_type),
    INDEX idx_created_by (created_by),
    INDEX idx_property_id (property_id),
    INDEX idx_listed_on (listed_on),
    FULLTEXT idx_search (ad_title, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- LISTING_PERFORMANCE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS listing_performance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    performance_id VARCHAR(50) UNIQUE NOT NULL,
    listing_id INT NOT NULL,
    view_count INT DEFAULT 0,
    favorite_count INT DEFAULT 0,
    inquiry_count INT DEFAULT 0,
    conversion_rate DECIMAL(5, 2) DEFAULT 0.00,
    roi DECIMAL(5, 2) DEFAULT 0.00,
    last_calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (listing_id) REFERENCES property_listing(id) ON DELETE CASCADE,
    UNIQUE KEY unique_listing_performance (listing_id),
    INDEX idx_performance_id (performance_id),
    INDEX idx_listing_id (listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- IMAGE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS image (
    id INT PRIMARY KEY AUTO_INCREMENT,
    image_id VARCHAR(50) UNIQUE NOT NULL,
    url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    caption VARCHAR(500),
    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    file_size BIGINT,
    dimensions VARCHAR(50),
    is_primary BOOLEAN DEFAULT FALSE,
    order_index INT DEFAULT 0,
    property_listing_id INT NOT NULL,
    FOREIGN KEY (property_listing_id) REFERENCES property_listing(id) ON DELETE CASCADE,
    INDEX idx_image_id (image_id),
    INDEX idx_property_listing_id (property_listing_id),
    INDEX idx_is_primary (is_primary),
    INDEX idx_order_index (order_index)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- KYC_VERIFICATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS kyc_verification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kyc_verification_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    document_type VARCHAR(100),
    document_url VARCHAR(500),
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(50) DEFAULT 'pending',
    verification_date TIMESTAMP NULL,
    verified_by INT,
    comments TEXT,
    expiry_date TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES platform_staff(id) ON DELETE SET NULL,
    INDEX idx_kyc_verification_id (kyc_verification_id),
    INDEX idx_user_id (user_id),
    INDEX idx_verification_status (verification_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- KYC_DOCUMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS kyc_documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    kyc_verification_id INT NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    document_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kyc_verification_id) REFERENCES kyc_verification(id) ON DELETE CASCADE,
    INDEX idx_kyc_verification_id (kyc_verification_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AGENT_IDENTITY_VERIFICATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS agent_identity_verification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agent_verification_id VARCHAR(50) UNIQUE NOT NULL,
    agent_id INT NOT NULL,
    license_number VARCHAR(100),
    license_doc_url VARCHAR(500),
    agency_certificate_url VARCHAR(500),
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(50) DEFAULT 'pending',
    verification_date TIMESTAMP NULL,
    verified_by INT,
    comments TEXT,
    expiry_date TIMESTAMP NULL,
    FOREIGN KEY (agent_id) REFERENCES property_agent(id) ON DELETE CASCADE,
    FOREIGN KEY (verified_by) REFERENCES platform_staff(id) ON DELETE SET NULL,
    INDEX idx_agent_verification_id (agent_verification_id),
    INDEX idx_agent_id (agent_id),
    INDEX idx_verification_status (verification_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AGENT_DOCUMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS agent_documents (
    id INT PRIMARY KEY AUTO_INCREMENT,
    agent_verification_id INT NOT NULL,
    document_url VARCHAR(500) NOT NULL,
    document_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (agent_verification_id) REFERENCES agent_identity_verification(id) ON DELETE CASCADE,
    INDEX idx_agent_verification_id (agent_verification_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- DOCUMENT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS document (
    id INT PRIMARY KEY AUTO_INCREMENT,
    document_id VARCHAR(50) UNIQUE NOT NULL,
    type VARCHAR(100) NOT NULL,
    content TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    created_by INT NOT NULL,
    version INT DEFAULT 1,
    template VARCHAR(255),
    expiry_date TIMESTAMP NULL,
    is_template BOOLEAN DEFAULT FALSE,
    file_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_document_id (document_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- BLOCKCHAIN_SIGNATURE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS blockchain_signature (
    id INT PRIMARY KEY AUTO_INCREMENT,
    signature_id VARCHAR(50) UNIQUE NOT NULL,
    signer_id INT NOT NULL,
    signed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    blockchain_hash VARCHAR(255) UNIQUE,
    document_id INT NOT NULL,
    signature_type VARCHAR(50),
    certificate TEXT,
    ip_address VARCHAR(45),
    FOREIGN KEY (signer_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (document_id) REFERENCES document(id) ON DELETE CASCADE,
    INDEX idx_signature_id (signature_id),
    INDEX idx_signer_id (signer_id),
    INDEX idx_document_id (document_id),
    INDEX idx_blockchain_hash (blockchain_hash)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- UNDERTAKING_LETTER TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS undertaking_letter (
    id INT PRIMARY KEY AUTO_INCREMENT,
    undertaking_letter_id VARCHAR(50) UNIQUE NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    terms JSON,
    client1_signature_id INT,
    client2_signature_id INT,
    client_witness_signature_id INT,
    FOREIGN KEY (client1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_undertaking_letter_id (undertaking_letter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AUTHORISATION_LETTER TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS authorisation_letter (
    id INT PRIMARY KEY AUTO_INCREMENT,
    authorisation_letter_id VARCHAR(50) UNIQUE NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    content TEXT,
    authorised_actions JSON,
    landlord1_signature_id INT,
    landlord2_signature_id INT,
    landlord_witness_signature_id INT,
    FOREIGN KEY (landlord1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_authorisation_letter_id (authorisation_letter_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- AMLA_FORM TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS amla_form (
    id INT PRIMARY KEY AUTO_INCREMENT,
    amla_form_id VARCHAR(50) UNIQUE NOT NULL,
    agent_id INT NOT NULL,
    client_type VARCHAR(50),
    full_name VARCHAR(255),
    occupation VARCHAR(100),
    property_address VARCHAR(500),
    contact_no VARCHAR(20),
    mode_of_payment VARCHAR(50),
    mode_of_purchase VARCHAR(50),
    source_of_income VARCHAR(255),
    politically_exposed_person BOOLEAN DEFAULT FALSE,
    risk_type BOOLEAN DEFAULT FALSE,
    red_flag_on_client BOOLEAN DEFAULT FALSE,
    moha_screening BOOLEAN DEFAULT FALSE,
    unscr_screening BOOLEAN DEFAULT FALSE,
    nationality VARCHAR(100),
    suspicious_transaction_report BOOLEAN DEFAULT FALSE,
    agent_signature_id INT,
    admin_signature_id INT,
    submission_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(50) DEFAULT 'pending',
    FOREIGN KEY (agent_id) REFERENCES property_agent(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (admin_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_amla_form_id (amla_form_id),
    INDEX idx_agent_id (agent_id),
    INDEX idx_verification_status (verification_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- BOOKING_FORM TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS booking_form (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_form_id VARCHAR(50) UNIQUE NOT NULL,
    form_type VARCHAR(50) NOT NULL,
    property_address VARCHAR(500),
    client1_id INT,
    client2_id INT,
    landlord1_id INT,
    landlord2_id INT,
    client_witness_id INT,
    landlord_witness_id INT,
    price DECIMAL(12, 2),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    advance_rental_month INT,
    advance_rental_amount DECIMAL(12, 2),
    earnest_deposit_months INT,
    earnest_deposit_amount DECIMAL(12, 2),
    security_deposit_months INT,
    security_deposit_amount DECIMAL(12, 2),
    utility_deposit_months INT,
    utility_deposit_amount DECIMAL(12, 2),
    other_fees DECIMAL(12, 2),
    stamping_fee DECIMAL(12, 2),
    commission_months INT,
    commission_amount DECIMAL(12, 2),
    tax DECIMAL(12, 2),
    tenancy_period_from DATE,
    tenancy_period_to DATE,
    renew_years INT,
    other_terms TEXT,
    furnish VARCHAR(100),
    renovation_from DATE,
    renovation_to DATE,
    borne_by VARCHAR(100),
    execution_days INT,
    payment_date DATE,
    status VARCHAR(50) DEFAULT 'draft',
    authorisation_letter_id INT,
    undertaking_letter_id INT,
    amla_form_id INT,
    client1_signature_id INT,
    client2_signature_id INT,
    landlord1_signature_id INT,
    landlord2_signature_id INT,
    client_witness_signature_id INT,
    landlord_witness_signature_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (client1_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (client2_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord1_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord2_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (client_witness_id) REFERENCES property_agent(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_witness_id) REFERENCES property_agent(id) ON DELETE SET NULL,
    FOREIGN KEY (authorisation_letter_id) REFERENCES authorisation_letter(id) ON DELETE SET NULL,
    FOREIGN KEY (undertaking_letter_id) REFERENCES undertaking_letter(id) ON DELETE SET NULL,
    FOREIGN KEY (amla_form_id) REFERENCES amla_form(id) ON DELETE SET NULL,
    FOREIGN KEY (client1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_booking_form_id (booking_form_id),
    INDEX idx_form_type (form_type),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SALES_BOOKING_FORM TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS sales_booking_form (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sales_booking_form_id VARCHAR(50) UNIQUE NOT NULL,
    booking_form_id INT NOT NULL,
    selling_price DECIMAL(12, 2),
    upon_spa_percentage DECIMAL(5, 2),
    upon_spa_remittance DECIMAL(12, 2),
    remaining_balance_percentage DECIMAL(5, 2),
    remaining_balance_amount DECIMAL(12, 2),
    remaining_balance_due_days INT,
    earnest_deposit_percentage DECIMAL(5, 2),
    earnest_deposit_amount DECIMAL(12, 2),
    commission_percentage DECIMAL(5, 2),
    commission_amount DECIMAL(12, 2),
    tax_amount DECIMAL(12, 2),
    interest_rate_percentage DECIMAL(5, 2),
    term_conditions TEXT,
    other_terms_and_conditions TEXT,
    possession_date DATE,
    payment_before_days INT,
    sign_before_date DATE,
    payment_date DATE,
    FOREIGN KEY (booking_form_id) REFERENCES booking_form(id) ON DELETE CASCADE,
    INDEX idx_sales_booking_form_id (sales_booking_form_id),
    INDEX idx_booking_form_id (booking_form_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SALES_PURCHASE_AGREEMENT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS sales_purchase_agreement (
    id INT PRIMARY KEY AUTO_INCREMENT,
    spa_id VARCHAR(50) UNIQUE NOT NULL,
    buyer_id INT,
    seller_id INT,
    purchase_price DECIMAL(12, 2),
    balance DECIMAL(12, 2),
    deposit DECIMAL(12, 2),
    client1_signature_id INT,
    client2_signature_id INT,
    landlord1_signature_id INT,
    landlord2_signature_id INT,
    client_witness_signature_id INT,
    landlord_witness_signature_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (client1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_spa_id (spa_id),
    INDEX idx_buyer_id (buyer_id),
    INDEX idx_seller_id (seller_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TENANCY_AGREEMENT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS tenancy_agreement (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tenancy_agreement_id VARCHAR(50) UNIQUE NOT NULL,
    booking_form_id INT NOT NULL,
    lease_terms TEXT,
    tenant_id INT,
    landlord_id INT,
    witness_tenant_id INT,
    witness_landlord_id INT,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    landlord_address VARCHAR(500),
    tenant_address VARCHAR(500),
    term_of_tenancy INT,
    special_condition JSON,
    client1_signature_id INT,
    client2_signature_id INT,
    landlord1_signature_id INT,
    landlord2_signature_id INT,
    client_witness_signature_id INT,
    landlord_witness_signature_id INT,
    status VARCHAR(50) DEFAULT 'draft',
    generated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    effective_date TIMESTAMP NULL,
    FOREIGN KEY (booking_form_id) REFERENCES booking_form(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (witness_tenant_id) REFERENCES property_agent(id) ON DELETE SET NULL,
    FOREIGN KEY (witness_landlord_id) REFERENCES property_agent(id) ON DELETE SET NULL,
    FOREIGN KEY (client1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord1_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord2_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (client_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    FOREIGN KEY (landlord_witness_signature_id) REFERENCES blockchain_signature(id) ON DELETE SET NULL,
    INDEX idx_tenancy_agreement_id (tenancy_agreement_id),
    INDEX idx_booking_form_id (booking_form_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INVOICE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS invoice (
    id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    due_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_invoice_number (invoice_number),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- INVOICE_ITEM TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS invoice_item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_id VARCHAR(50) UNIQUE NOT NULL,
    invoice_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    category VARCHAR(100),
    service_type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoice(id) ON DELETE CASCADE,
    INDEX idx_item_id (item_id),
    INDEX idx_invoice_id (invoice_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- RECEIPT TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS receipt (
    id INT PRIMARY KEY AUTO_INCREMENT,
    receipt_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_id INT,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id) REFERENCES invoice(id) ON DELETE SET NULL,
    INDEX idx_receipt_number (receipt_number),
    INDEX idx_invoice_id (invoice_id),
    INDEX idx_transaction_date (transaction_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- RECEIPT_ITEM TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS receipt_item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_id VARCHAR(50) UNIQUE NOT NULL,
    receipt_id INT NOT NULL,
    description VARCHAR(500) NOT NULL,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(12, 2) NOT NULL,
    total_price DECIMAL(12, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    category VARCHAR(100),
    service_type VARCHAR(100),
    payment_method VARCHAR(50),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (receipt_id) REFERENCES receipt(id) ON DELETE CASCADE,
    INDEX idx_item_id (item_id),
    INDEX idx_receipt_id (receipt_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- TRANSACTION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS transaction (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending',
    description TEXT,
    fee DECIMAL(12, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'MYR',
    gateway_response TEXT,
    property_listing_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_listing_id) REFERENCES property_listing(id) ON DELETE SET NULL,
    INDEX idx_transaction_id (transaction_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_transaction_date (transaction_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SEARCH_CRITERIA TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS search_criteria (
    id INT PRIMARY KEY AUTO_INCREMENT,
    criteria_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT,
    location_id INT,
    price_range VARCHAR(100),
    property_types JSON,
    bedrooms VARCHAR(50),
    bathrooms VARCHAR(50),
    amenities JSON,
    sort_by VARCHAR(50),
    furnishing VARCHAR(50),
    listing_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES location(id) ON DELETE SET NULL,
    INDEX idx_criteria_id (criteria_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- NOTIFICATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS notification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    notification_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_url VARCHAR(500),
    priority VARCHAR(20) DEFAULT 'normal',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_notification_id (notification_id),
    INDEX idx_user_id (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_created_at (created_at),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- EMAIL_NOTIFICATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS email_notification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email_notification_id VARCHAR(50) UNIQUE NOT NULL,
    notification_id INT NOT NULL,
    subject VARCHAR(255) NOT NULL,
    sender VARCHAR(255),
    is_html BOOLEAN DEFAULT FALSE,
    attachments JSON,
    recipients JSON,
    delivery_status VARCHAR(50) DEFAULT 'pending',
    sent_at TIMESTAMP NULL,
    FOREIGN KEY (notification_id) REFERENCES notification(id) ON DELETE CASCADE,
    INDEX idx_email_notification_id (email_notification_id),
    INDEX idx_notification_id (notification_id),
    INDEX idx_delivery_status (delivery_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- SMS_NOTIFICATION TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS sms_notification (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sms_notification_id VARCHAR(50) UNIQUE NOT NULL,
    notification_id INT NOT NULL,
    sender_phone_number VARCHAR(20),
    carrier VARCHAR(50),
    recipients JSON,
    message TEXT NOT NULL,
    delivery_status VARCHAR(50) DEFAULT 'pending',
    sent_at TIMESTAMP NULL,
    FOREIGN KEY (notification_id) REFERENCES notification(id) ON DELETE CASCADE,
    INDEX idx_sms_notification_id (sms_notification_id),
    INDEX idx_notification_id (notification_id),
    INDEX idx_delivery_status (delivery_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- HOME_AI_CHATBOT_SERVICE TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS home_ai_chatbot_service (
    id INT PRIMARY KEY AUTO_INCREMENT,
    chatbot_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT,
    daily_usage_count INT DEFAULT 0,
    max_daily_usage INT DEFAULT 100,
    session_id VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    conversation_history JSON,
    response_templates JSON,
    usage_reset_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_chatbot_id (chatbot_id),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- CONVERSATION TABLE (for chatbot)
-- ============================================
CREATE TABLE IF NOT EXISTS conversation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    conversation_id VARCHAR(50) UNIQUE NOT NULL,
    chatbot_id INT NOT NULL,
    user_message TEXT NOT NULL,
    bot_response TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chatbot_id) REFERENCES home_ai_chatbot_service(id) ON DELETE CASCADE,
    INDEX idx_conversation_id (conversation_id),
    INDEX idx_chatbot_id (chatbot_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- MESSAGES TABLE (for chat between users)
-- ============================================
CREATE TABLE IF NOT EXISTS messages (
    id INT PRIMARY KEY AUTO_INCREMENT,
    message_id VARCHAR(50) UNIQUE NOT NULL,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    property_listing_id INT,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_listing_id) REFERENCES property_listing(id) ON DELETE SET NULL,
    INDEX idx_message_id (message_id),
    INDEX idx_sender_receiver (sender_id, receiver_id),
    INDEX idx_property_listing_id (property_listing_id),
    INDEX idx_created_at (created_at),
    INDEX idx_is_read (is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- BOOKINGS TABLE (Appointments/Viewings)
-- ============================================
CREATE TABLE IF NOT EXISTS bookings (
    id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id VARCHAR(50) UNIQUE NOT NULL,
    property_listing_id INT NOT NULL,
    user_id INT NOT NULL,
    agent_id INT NOT NULL,
    booking_type VARCHAR(50) NOT NULL,
    scheduled_at TIMESTAMP NOT NULL,
    duration_minutes INT DEFAULT 60,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    google_calendar_event_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_listing_id) REFERENCES property_listing(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (agent_id) REFERENCES property_agent(id) ON DELETE CASCADE,
    INDEX idx_booking_id (booking_id),
    INDEX idx_property_listing_id (property_listing_id),
    INDEX idx_user_id (user_id),
    INDEX idx_agent_id (agent_id),
    INDEX idx_scheduled_at (scheduled_at),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- FAVORITES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS favorites (
    id INT PRIMARY KEY AUTO_INCREMENT,
    favorite_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    property_listing_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (property_listing_id) REFERENCES property_listing(id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_property (user_id, property_listing_id),
    INDEX idx_favorite_id (favorite_id),
    INDEX idx_user_id (user_id),
    INDEX idx_property_listing_id (property_listing_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- RENTAL_RECORD TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS rental_record (
    id INT PRIMARY KEY AUTO_INCREMENT,
    record_id VARCHAR(50) UNIQUE NOT NULL,
    property_id INT NOT NULL,
    tenant_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    rent_amount DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES property(id) ON DELETE CASCADE,
    FOREIGN KEY (tenant_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_record_id (record_id),
    INDEX idx_property_id (property_id),
    INDEX idx_tenant_id (tenant_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- OWNERSHIP_RECORD TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS ownership_record (
    id INT PRIMARY KEY AUTO_INCREMENT,
    record_id VARCHAR(50) UNIQUE NOT NULL,
    property_id INT NOT NULL,
    owner_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    purchase_price DECIMAL(12, 2) NOT NULL,
    ownership_type VARCHAR(50),
    current_value DECIMAL(12, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (property_id) REFERENCES property(id) ON DELETE CASCADE,
    FOREIGN KEY (owner_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_record_id (record_id),
    INDEX idx_property_id (property_id),
    INDEX idx_owner_id (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- ACCOUNT_DELETION_REQUESTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS account_deletion_requests (
    id INT PRIMARY KEY AUTO_INCREMENT,
    request_id VARCHAR(50) UNIQUE NOT NULL,
    user_id INT NOT NULL,
    approved_by INT,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES admin(id) ON DELETE SET NULL,
    INDEX idx_request_id (request_id),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Verify tables created
-- ============================================
SHOW TABLES;

-- ============================================
-- Show table count
-- ============================================
SELECT COUNT(*) AS total_tables 
FROM information_schema.tables 
WHERE table_schema = 'homexpert_db';

