#!/bin/bash

echo "🧪 Testing Walk Advisor builds..."
echo ""

BUILD_DIR="$(pwd)/WeatherApp/build"
ARCH=$(uname -m)

if [ "$ARCH" = "arm64" ]; then
    APP_PATH="$BUILD_DIR/Walk Advisor.arm64.app"
    echo "🍎 Current system: Apple Silicon (arm64)"
    echo "   Launching optimized version..."
else
    APP_PATH="$BUILD_DIR/Walk Advisor.x86_64.app"
    echo "💻 Current system: Intel (x86_64)"
    echo "   Launching optimized version..."
fi

if [ -d "$APP_PATH" ]; then
    echo "✅ App bundle found: $APP_PATH"
    echo ""
    echo "Launching application..."
    echo "(Close the app when done testing)"
    open "$APP_PATH"
else
    echo "❌ App bundle not found at: $APP_PATH"
    echo ""
    echo "Available builds:"
    ls -d "$BUILD_DIR"/Walk*.app 2>/dev/null || echo "   No builds found"
fi
