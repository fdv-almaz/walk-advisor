#!/bin/bash

# Скрипт для компиляции Walk Advisor для обеих архитектур
# Создаёт отдельные сборки для Apple Silicon и Intel

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$PROJECT_DIR/build"
APP_NAME="Walk Advisor"

echo "🚀 Сборка Walk Advisor для обеих архитектур..."
echo ""

# Функция для сборки одной архитектуры
build_for_arch() {
    local ARCH=$1
    local ARCH_FLAG=$2
    local APP_EXECUTABLE=$3
    local HUMAN_NAME=$4

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 Компиляция для $HUMAN_NAME ($ARCH)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    APP_PATH="$OUTPUT_DIR/$APP_NAME.$ARCH.app"

    # Создать структуру .app пакета
    mkdir -p "$APP_PATH/Contents/MacOS"
    mkdir -p "$APP_PATH/Contents/Resources"

    echo "📦 Путь: $APP_PATH"

    # Компилировать приложение
    echo "⚙️  Компиляция кода..."
    swiftc \
        $ARCH_FLAG \
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

    echo "✅ Компиляция успешна для $HUMAN_NAME"
    echo "📦 Приложение: $APP_PATH"
    echo ""
}

# Очистить старые сборки
echo "🧹 Очистка старых сборок..."
rm -rf "$OUTPUT_DIR"/*arm64* "$OUTPUT_DIR"/*x86_64* 2>/dev/null || true
echo ""

# Сборка для Apple Silicon
build_for_arch "arm64" "-target arm64-apple-macos12" "WalkAdvisor" "Apple Silicon (M1/M2/M3+)"

# Сборка для Intel
build_for_arch "x86_64" "-target x86_64-apple-macos12" "WalkAdvisor" "Intel (x86_64)"

# Сводка
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ СБОРКА ЗАВЕРШЕНА!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Сборки находятся в: $OUTPUT_DIR"
echo ""
echo "🍎 Apple Silicon версия:"
echo "  open \"$OUTPUT_DIR/$APP_NAME.arm64.app\""
echo ""
echo "💻 Intel версия:"
echo "  open \"$OUTPUT_DIR/$APP_NAME.x86_64.app\""
echo ""
echo "📂 Или откройте папку:"
echo "  open $OUTPUT_DIR"
echo ""
