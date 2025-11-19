const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const { testConnection } = require('./config/database');
const authRoutes = require('./routes/auth');
const adminRoutes = require('./routes/admin');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware - CORS Configuration
// In development: Allow any localhost port (for Flutter web random ports)
// In production: Use specific CORS_ORIGIN from .env
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps, Postman, curl)
    if (!origin) return callback(null, true);
    
    const isDevelopment = process.env.NODE_ENV !== 'production';
    
    // In development: Allow any localhost port (handles Flutter web random ports)
    if (isDevelopment && origin.match(/^http:\/\/localhost:\d+$/)) {
      return callback(null, true);
    }
    
    // Allow specific CORS_ORIGIN from .env (for production or specific dev setup)
    const allowedOrigin = process.env.CORS_ORIGIN;
    if (allowedOrigin && origin === allowedOrigin) {
      return callback(null, true);
    }
    
    // Default: Allow localhost:8080 if no CORS_ORIGIN specified
    if (!allowedOrigin && origin === 'http://localhost:8080') {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true
};

app.use(cors(corsOptions));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'HomeXpert API is running',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// Start server
async function startServer() {
  // Test database connection
  const dbConnected = await testConnection();
  
  if (!dbConnected) {
    console.error('⚠️  Warning: Database connection failed. Server will start but API calls may fail.');
    console.log('💡 Make sure MySQL is running and .env file is configured correctly.');
  }

  app.listen(PORT, () => {
    console.log('========================================');
    console.log('🚀 HomeXpert Backend API');
    console.log('========================================');
    console.log(`📍 Server running on: http://localhost:${PORT}`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`💾 Database: ${dbConnected ? '✅ Connected' : '❌ Not Connected'}`);
    console.log('========================================');
    console.log('\n📋 Available Endpoints:');
    console.log(`   GET  /health`);
    console.log(`   POST /api/auth/staff/login`);
    console.log(`   POST /api/auth/verify-token`);
    console.log(`   GET  /api/admin/dashboard/stats`);
    console.log(`   GET  /api/admin/dashboard/activities`);
    console.log(`   GET  /api/admin/users`);
    console.log(`   POST /api/admin/users`);
    console.log('========================================\n');
  });
}

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Rejection:', err);
});

// Start the server
startServer();

