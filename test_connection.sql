-- Test MySQL Connection Script
-- Run this in MySQL Workbench to verify your connection

-- Test 1: Check if you can connect
SELECT 'Connection successful!' AS status;

-- Test 2: Show current database
SELECT DATABASE() AS current_database;

-- Test 3: Show MySQL version
SELECT VERSION() AS mysql_version;

-- Test 4: Show current user
SELECT USER() AS current_user;

-- Test 5: Check if homexpert_db exists
SELECT SCHEMA_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'homexpert_db';

-- Test 6: Show all databases (if you have permission)
SHOW DATABASES;

-- Test 7: Test basic query
SELECT NOW() AS current_timestamp;

-- If all queries execute successfully, your connection is working!

