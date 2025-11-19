// Quick script to generate bcrypt hash for admin password
// Run: node hash_password.js

const bcrypt = require('bcrypt');

// Change this to your desired admin password
const password = 'Admin@123';

// Generate hash with 10 rounds (recommended)
const hash = bcrypt.hashSync(password, 10);

console.log('========================================');
console.log('Password Hash Generator');
console.log('========================================');
console.log('Password:', password);
console.log('Hash:', hash);
console.log('========================================');
console.log('\nCopy the hash above and use it in create_admin.sql');
console.log('Replace: $2b$10$YourBcryptHashHere');
console.log('With:   ', hash);
console.log('========================================\n');

// Optional: Verify the hash
const isValid = bcrypt.compareSync(password, hash);
console.log('Hash verification:', isValid ? '✅ Valid' : '❌ Invalid');

