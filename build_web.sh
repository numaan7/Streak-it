#!/bin/bash

# Quick build script for Streak it web app

echo "🔨 Building Streak it for Web"
echo "=============================="
echo ""

# Add Flutter to PATH
export PATH="$HOME/flutter/bin:$PATH"

# Navigate to project
cd "$(dirname "$0")"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please run ./run_web.sh first to install Flutter."
    exit 1
fi

echo "✓ Flutter found"
flutter --version | head -1

# Enable web
echo ""
echo "🌐 Enabling web support..."
flutter config --enable-web

# Get dependencies
echo ""
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo ""
echo "🚀 Building web app..."
flutter build web --release

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📁 Output location: build/web/"
    echo ""
    echo "🌐 To test locally, run:"
    echo "   cd build/web && python3 -m http.server 8080"
    echo ""
    echo "Then open: http://localhost:8080"
else
    echo ""
    echo "❌ Build failed. Check the errors above."
    exit 1
fi
