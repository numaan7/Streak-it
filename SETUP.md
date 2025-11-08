# Streak it - Setup Guide

## 🎯 Complete Setup Instructions

### Step 1: Install Flutter

#### For macOS:
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add Flutter to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$HOME/flutter/bin:$PATH"

# Run flutter doctor
flutter doctor
```

#### For Linux:
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable ~/flutter

# Add Flutter to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/flutter/bin:$PATH"

# Run flutter doctor
flutter doctor
```

#### For Windows:
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to C:\src\flutter
3. Add C:\src\flutter\bin to system PATH
4. Run `flutter doctor` in PowerShell/CMD

### Step 2: Install Dependencies

After Flutter is installed, run:

```bash
cd /workspaces/Streak-it
flutter pub get
```

### Step 3: Setup Android Development (Optional)

1. Install Android Studio from https://developer.android.com/studio
2. Open Android Studio > Settings > Plugins
3. Install Flutter and Dart plugins
4. Set up an Android Virtual Device (AVD)

Run `flutter doctor --android-licenses` to accept licenses.

### Step 4: Setup iOS Development (macOS only)

```bash
# Install Xcode from Mac App Store
# Then install command line tools:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Install CocoaPods
sudo gem install cocoapods

# Setup iOS simulator
open -a Simulator
```

### Step 5: Run the App

#### List available devices:
```bash
flutter devices
```

#### Run on connected device/emulator:
```bash
flutter run
```

#### Run in debug mode with hot reload:
```bash
flutter run
# Press 'r' for hot reload
# Press 'R' for hot restart
```

#### Run on specific device:
```bash
flutter run -d <device-id>
```

#### Run on Chrome (web):
```bash
flutter run -d chrome
```

### Step 6: Build for Production

#### Android APK:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Google Play):
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only):
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

## 🔧 Troubleshooting

### Flutter Doctor Issues

```bash
flutter doctor -v
```

Common fixes:
- Accept Android licenses: `flutter doctor --android-licenses`
- Update Flutter: `flutter upgrade`
- Clear cache: `flutter clean`

### Dependency Issues

```bash
# Clear pub cache
flutter pub cache repair

# Get dependencies again
flutter pub get
```

### Build Issues

```bash
# Clean build
flutter clean

# Rebuild
flutter pub get
flutter run
```

### Hot Reload Not Working

1. Press `R` for full restart
2. Stop and rerun the app
3. Check for syntax errors

## 📱 Testing on Real Devices

### Android:
1. Enable Developer Options on phone (tap Build Number 7 times)
2. Enable USB Debugging
3. Connect via USB
4. Run `flutter devices` to verify
5. Run `flutter run`

### iOS (macOS only):
1. Connect iPhone via USB
2. Trust the computer on iPhone
3. Open Xcode, add Apple ID to account
4. Run `flutter run`

## 🌐 Running on Web

```bash
flutter run -d chrome
```

For better performance:
```bash
flutter run -d chrome --web-renderer html
```

## 🎨 IDE Setup

### VS Code:
1. Install Flutter extension
2. Install Dart extension
3. Press F5 to run with debugging

### Android Studio:
1. Open project folder
2. Click Run > Run 'main.dart'

## 📦 Project Structure Verification

Make sure all these files exist:
```
Streak-it/
├── lib/
│   ├── main.dart ✓
│   ├── models/
│   │   └── habit.dart ✓
│   ├── providers/
│   │   └── habit_provider.dart ✓
│   ├── screens/
│   │   ├── home_screen.dart ✓
│   │   ├── add_habit_screen.dart ✓
│   │   └── habit_detail_screen.dart ✓
│   ├── widgets/
│   │   ├── habit_card.dart ✓
│   │   └── streak_stats_card.dart ✓
│   ├── services/
│   │   └── storage_service.dart ✓
│   └── utils/
│       └── app_theme.dart ✓
├── assets/
│   └── animations/
├── pubspec.yaml ✓
├── analysis_options.yaml ✓
└── README.md ✓
```

## 🚀 Quick Start (If Flutter Already Installed)

```bash
# Navigate to project
cd /workspaces/Streak-it

# Get dependencies
flutter pub get

# Run app
flutter run
```

## 💡 Useful Flutter Commands

```bash
# Check Flutter installation
flutter doctor

# List devices
flutter devices

# Run app
flutter run

# Hot reload (while running)
r

# Hot restart (while running)
R

# Clear build cache
flutter clean

# Analyze code
flutter analyze

# Run tests
flutter test

# Build APK
flutter build apk

# Update Flutter
flutter upgrade

# Check outdated packages
flutter pub outdated

# Update packages
flutter pub upgrade
```

## 🎯 Next Steps

1. Run the app on an emulator or device
2. Create your first habit
3. Start building streaks!
4. Customize colors and icons
5. Track your progress

## 📧 Need Help?

If you encounter issues:
1. Check Flutter documentation: https://docs.flutter.dev/
2. Run `flutter doctor -v` for detailed diagnostics
3. Check the project's GitHub issues

---

**Happy coding! Build those habits! 🔥**
