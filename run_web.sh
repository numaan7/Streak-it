#!/bin/bash

# Streak it - Flutter Installation & Web Runner Script
# This script installs Flutter and runs the app on web

set -e

echo "🚀 Streak it - Flutter Web Setup & Runner"
echo "=========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓ Flutter is already installed${NC}"
    flutter --version
else
    echo -e "${YELLOW}⚠ Flutter not found. Installing...${NC}"
    
    # Install Flutter
    if [ ! -d "$HOME/flutter" ]; then
        echo "📥 Downloading Flutter SDK..."
        git clone https://github.com/flutter/flutter.git -b stable $HOME/flutter
    fi
    
    # Add to PATH for this session
    export PATH="$HOME/flutter/bin:$PATH"
    
    # Add to .bashrc for future sessions
    if ! grep -q "flutter/bin" "$HOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.bashrc"
        echo -e "${GREEN}✓ Added Flutter to PATH in .bashrc${NC}"
    fi
    
    # Run flutter doctor
    echo "🔍 Running Flutter doctor..."
    flutter doctor
fi

# Enable web support
echo ""
echo "🌐 Enabling Flutter web support..."
flutter config --enable-web

# Check if Chrome is available
if command -v google-chrome &> /dev/null; then
    CHROME_CMD="google-chrome"
elif command -v chromium &> /dev/null; then
    CHROME_CMD="chromium"
elif command -v chromium-browser &> /dev/null; then
    CHROME_CMD="chromium-browser"
else
    echo -e "${YELLOW}⚠ Chrome/Chromium not found. Will use web-server mode.${NC}"
    CHROME_CMD=""
fi

# Navigate to project directory
cd "$(dirname "$0")"

# Get dependencies
echo ""
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Check available devices
echo ""
echo "📱 Available Flutter devices:"
flutter devices

# Run the app
echo ""
echo "🎯 Starting Streak it on web..."
echo ""

if [ -n "$CHROME_CMD" ]; then
    echo "Starting in Chrome browser..."
    echo -e "${GREEN}Press 'r' for hot reload, 'R' for hot restart, 'q' to quit${NC}"
    flutter run -d chrome
else
    echo "Starting web server on port 8080..."
    echo -e "${GREEN}Open http://localhost:8080 in your browser${NC}"
    echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
    flutter run -d web-server --web-port=8080
fi
