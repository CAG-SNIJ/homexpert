# HomeXpert - Real Estate Listing Platform

HomeXpert is an AI-powered real estate listing and transaction platform designed to address critical inefficiencies and security risks in Malaysia's property industry by automating workflows, enhancing communication, and securing transactions using blockchain technology.

## 🚀 Features

- **Multi-User Platform**: Separate modules for Users, Agents, Staff, and Admins
- **AI Chatbot**: Intelligent client engagement and automated follow-ups (Coming Soon)
- **Blockchain Integration**: Secure document handling and e-signatures (Coming Soon)
- **Real-time Communication**: WebSocket-based messaging system
- **Cross-Platform**: Flutter web, Android, and iOS support

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
  - Check installation: `flutter --version`
  - Install from: https://flutter.dev/docs/get-started/install
- **Dart SDK** (comes with Flutter)
- **Node.js** (for backend - separate project)
- **MySQL** (for database)
- **IDE**: VS Code or Android Studio with Flutter extensions

## 🛠️ Setup Instructions

### Step 1: Clone and Navigate

```bash
cd homexpert
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This will install all required packages defined in `pubspec.yaml`.

### Step 3: Configure Environment Variables

1. Create a `.env` file in the root directory:

```bash
# Copy the example file
cp .env.example .env
```

2. Update the `.env` file with your configuration:

```env
API_BASE_URL=http://localhost:3000/api
WS_URL=ws://localhost:3000
```

### Step 4: Start the Backend API

The Flutter app expects the Node.js API to be running on `http://localhost:3000`.

```bash
cd backend
npm install
Copy-Item .env.example .env   # PowerShell
# or: cp .env.example .env    # macOS/Linux
```

Edit `backend/.env` with your MySQL credentials and desired port, then start the server:

```bash
npm run dev
# Wait for "Server running on: http://localhost:3000"
```

> Tip: hit `http://localhost:3000/health` in a browser to confirm the API is up.

### Step 5: Run the Flutter Application

#### For Web Development:

```bash
# Run in Chrome
flutter run -d chrome

# Or run in a specific browser
flutter run -d edge
flutter run -d firefox
```

#### For Mobile Development:

```bash
# Check available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

#### For Development with Hot Reload:

```bash
# Run and keep terminal open for hot reload
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

### Step 6: Build for Production

#### Web Build:

```bash
flutter build web
```

The output will be in `build/web/` directory.

#### Android Build:

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS Build:

```bash
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── core/                    # Core functionality shared across the app
│   ├── config/             # Configuration files (router, etc.)
│   ├── constants/          # App constants and enums
│   ├── models/             # Data models
│   ├── services/           # API services, auth, etc.
│   ├── theme/              # App theme and styling
│   ├── utils/              # Utility functions
│   └── widgets/            # Reusable widgets
│
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   │   ├── screens/       # Login, Register screens
│   │   └── widgets/       # Auth-specific widgets
│   │
│   ├── user/              # User module
│   │   ├── screens/       # User dashboard, property listings
│   │   ├── widgets/       # User-specific widgets
│   │   └── services/      # User-specific services
│   │
│   ├── agent/             # Agent module
│   │   ├── screens/       # Agent dashboard, listings management
│   │   ├── widgets/       # Agent-specific widgets
│   │   └── services/      # Agent-specific services
│   │
│   ├── staff/             # Staff module
│   │   ├── screens/       # Staff dashboard, reporting
│   │   ├── widgets/       # Staff-specific widgets
│   │   └── services/      # Staff-specific services
│   │
│   └── admin/             # Admin module
│       ├── screens/       # Admin dashboard, user management
│       ├── widgets/       # Admin-specific widgets
│       └── services/      # Admin-specific services
│
└── main.dart              # App entry point
```

## 🔧 Key Technologies

- **Flutter**: Cross-platform UI framework
- **GoRouter**: Declarative routing
- **Provider**: State management
- **Dio**: HTTP client for API calls
- **WebSocket Channel**: Real-time communication
- **Shared Preferences**: Local storage

## 📝 Development Workflow

### Adding a New Feature

1. Create feature folder in `lib/features/`
2. Add screens in `screens/` subfolder
3. Add widgets in `widgets/` subfolder
4. Add services in `services/` subfolder if needed
5. Update router in `lib/core/config/router_config.dart`
6. Add routes to `app_constants.dart` if needed

### API Integration

1. Update `API_BASE_URL` in `.env` file
2. Add API endpoints in `lib/core/services/api_service.dart`
3. Create feature-specific service files in respective feature folders

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🐛 Troubleshooting

### Common Issues

1. **Dependencies not installing**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Web not running**
   ```bash
   flutter config --enable-web
   flutter create --platforms=web .
   ```

3. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 📚 Next Steps

1. **Backend Setup**: Set up Node.js backend with REST APIs
2. **Database**: Configure MySQL database
3. **AI Chatbot**: Integrate AI chatbot functionality
4. **Blockchain**: Set up Hyperledger Fabric for document security
5. **Firebase**: Configure Firebase Storage for media files

## 🤝 Contributing

This is a Final Year Project. For questions or issues, please contact the development team.

## 📄 License

This project is for educational purposes as part of a Final Year Project.

---

**Note**: This is the initial setup. AI Chatbot and Blockchain features will be integrated in subsequent phases.
