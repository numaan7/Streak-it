#!/bin/bash

# Streak it - Android Build Script
# This script sets up Android SDK and builds the APK

set -e

echo "📱 Streak it - Android Build Setup"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please run ./run_web.sh first to install Flutter.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"

# Set up Android SDK path
export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

# Check if Android SDK is installed
if [ ! -d "$ANDROID_HOME" ]; then
    echo -e "${YELLOW}⚠ Android SDK not found. Installing...${NC}"
    
    # Create directory
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME"
    
    # Download command line tools
    echo "📥 Downloading Android SDK Command Line Tools..."
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip
    
    echo "📦 Extracting..."
    unzip -q cmdline-tools.zip
    mkdir -p cmdline-tools/latest
    mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
    rm cmdline-tools.zip
    
    echo -e "${GREEN}✓ Android SDK Command Line Tools installed${NC}"
    
    # Accept licenses
    echo "📜 Accepting Android SDK licenses..."
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses || true
    
    # Install required packages
    echo "📦 Installing Android SDK components..."
    "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" "platforms;android-34" "build-tools;34.0.0"
    
    echo -e "${GREEN}✓ Android SDK installed${NC}"
else
    echo -e "${GREEN}✓ Android SDK found${NC}"
fi

# Navigate to project
cd "$(dirname "$0")"

# Get dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build APK
echo ""
echo "🚀 Building Android APK..."
echo ""

flutter build apk --release

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Build successful!${NC}"
    echo ""
    echo "📁 APK location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "📱 To install on device:"
    echo "   adb install build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "Or copy the APK to your Android device and install manually."
    echo ""
    
    # Show APK size
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
        echo "📦 APK size: $APK_SIZE"
    fi
else
    echo ""
    echo -e "${RED}❌ Build failed. Check the errors above.${NC}"
    exit 1
fi
