#!/bin/bash

# Скрипт для быстрой компиляции WeatherApp для macOS

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/build"
APP_NAME="Walk Advisor"
APP_EXECUTABLE="WalkAdvisor"
APP_PATH="$OUTPUT_DIR/$APP_NAME.app"

echo "🔨 Компиляция Walk Advisor для macOS..."

# Создать структуру .app пакета
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Определить архитектуру (Intel или Apple Silicon)
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    echo "🎯 Цель: Apple Silicon (M1/M2/M3...)"
    ARCH_FLAGS="-target arm64-apple-macos12"
else
    echo "🎯 Цель: Intel"
    ARCH_FLAGS="-target x86_64-apple-macos12"
fi

# Компилировать приложение
swiftc \
    $ARCH_FLAGS \
    -o "$APP_PATH/Contents/MacOS/$APP_EXECUTABLE" \
    "$PROJECT_DIR/WeatherApp.swift" \
    "$PROJECT_DIR/ContentView.swift" \
    "$PROJECT_DIR/AboutView.swift" \
    "$PROJECT_DIR/Models.swift" \
    "$PROJECT_DIR/LocationManager.swift" \
    "$PROJECT_DIR/WeatherService.swift" \
    "$PROJECT_DIR/Localization.swift" \
    -framework SwiftUI \
    -framework CoreLocation \
    -framework AppKit \
    -framework Foundation \
    -O

# Копировать Info.plist
cp "$PROJECT_DIR/Info.plist" "$APP_PATH/Contents/Info.plist"

# Копировать иконку если существует
if [ -f "$PROJECT_DIR/Icons/AppIcon_512.icns" ]; then
    cp "$PROJECT_DIR/Icons/AppIcon_512.icns" "$APP_PATH/Contents/Resources/AppIcon.icns"
fi

# Создать PkgInfo файл
echo -n "APPL????" > "$APP_PATH/Contents/PkgInfo"

echo "✅ Компиляция успешна!"
echo "📦 Приложение находится в: $APP_PATH"
echo ""
echo "Для запуска выполните:"
echo "  open \"$APP_PATH\""
echo ""
echo "Или просто откройте: open $OUTPUT_DIR"
