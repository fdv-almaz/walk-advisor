#!/bin/bash

# Скрипт для создания инсталляционных пакетов
# Создаёт DMG, PKG для распространения приложения

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
DIST_DIR="$PROJECT_DIR/../dist"
APP_NAME="Walk Advisor"
VERSION="2.0.2"

echo "📦 Создание инсталляционных пакетов для версии $VERSION..."
echo ""

# Создать папку dist если её нет
mkdir -p "$DIST_DIR"

# Получить текущую архитектуру для сборки по умолчанию
CURRENT_ARCH=$(uname -m)

if [ "$CURRENT_ARCH" = "arm64" ]; then
    BUILD_APP="$BUILD_DIR/$APP_NAME.arm64.app"
    ARCH_SUFFIX="arm64"
    PKG_ARCH="Apple Silicon"
else
    BUILD_APP="$BUILD_DIR/$APP_NAME.x86_64.app"
    ARCH_SUFFIX="x86_64"
    PKG_ARCH="Intel"
fi

# Убедиться, что приложение собрано
if [ ! -d "$BUILD_APP" ]; then
    echo "❌ Ошибка: $BUILD_APP не найдено"
    echo "Сначала запустите ./build_universal.sh"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Создание PKG пакетов"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Функция для создания PKG файла
create_pkg() {
    local APP_SOURCE=$1
    local ARCH=$2
    local ARCH_NAME=$3

    PKG_NAME="${APP_NAME}_${VERSION}_${ARCH}.pkg"
    PKG_PATH="$DIST_DIR/$PKG_NAME"

    echo ""
    echo "🔧 Создание $ARCH_NAME пакета..."
    echo "  Источник: $APP_SOURCE"
    echo "  Выход: $PKG_PATH"

    # Создать временную папку для pkgbuild
    TEMP_PKG_DIR=$(mktemp -d)
    mkdir -p "$TEMP_PKG_DIR/Applications"

    # Скопировать приложение
    cp -r "$APP_SOURCE" "$TEMP_PKG_DIR/Applications/$APP_NAME.app"

    # Создать PKG
    /usr/bin/pkgbuild \
        --root "$TEMP_PKG_DIR" \
        --install-location "/" \
        --version "$VERSION" \
        --identifier "com.walkadvisor.macos.${ARCH}" \
        "$PKG_PATH"

    # Очистить временные файлы
    rm -rf "$TEMP_PKG_DIR"

    if [ -f "$PKG_PATH" ]; then
        PKG_SIZE=$(du -h "$PKG_PATH" | cut -f1)
        echo "✅ Создан $ARCH_NAME пакет ($PKG_SIZE)"
    else
        echo "❌ Ошибка создания $ARCH_NAME пакета"
        exit 1
    fi
}

# Создать PKG для всех доступных архитектур
if [ -d "$BUILD_DIR/$APP_NAME.arm64.app" ]; then
    create_pkg "$BUILD_DIR/$APP_NAME.arm64.app" "arm64" "Apple Silicon"
fi

if [ -d "$BUILD_DIR/$APP_NAME.x86_64.app" ]; then
    create_pkg "$BUILD_DIR/$APP_NAME.x86_64.app" "x86_64" "Intel"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💿 Создание DMG образа"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DMG_NAME="${APP_NAME}_${VERSION}.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"
TEMP_DMG_DIR=$(mktemp -d)
MOUNT_POINT="/tmp/wa_dmg_mount_$$"

echo ""
echo "🔧 Создание DMG образа..."

# Создать временную папку для DMG содержимого
mkdir -p "$TEMP_DMG_DIR/Applications"

# Использовать текущую архитектуру для DMG
if [ "$CURRENT_ARCH" = "arm64" ]; then
    cp -r "$BUILD_DIR/$APP_NAME.arm64.app" "$TEMP_DMG_DIR/$APP_NAME.app"
    ARCH_INFO="Apple Silicon (M1/M2/M3+)"
else
    cp -r "$BUILD_DIR/$APP_NAME.x86_64.app" "$TEMP_DMG_DIR/$APP_NAME.app"
    ARCH_INFO="Intel"
fi

# Создать символическую ссылку на Applications
ln -s /Applications "$TEMP_DMG_DIR/Applications" 2>/dev/null || true

# Создать DMG
echo "  Компонуя образ..."
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$TEMP_DMG_DIR" \
    -ov -format UDZO \
    "$DMG_PATH" > /dev/null 2>&1

# Очистить временные файлы
rm -rf "$TEMP_DMG_DIR"

if [ -f "$DMG_PATH" ]; then
    DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
    echo "✅ DMG образ создан ($DMG_SIZE)"
    echo "  Архитектура: $ARCH_INFO"
else
    echo "❌ Ошибка создания DMG образа"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ ИНСТАЛЛЯЦИОННЫЕ ПАКЕТЫ ГОТОВЫ!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 Файлы находятся в: $DIST_DIR"
echo ""

# Показать созданные файлы
ls -lh "$DIST_DIR" | grep -E "\.dmg$|\.pkg$" | while read -r line; do
    echo "  $line"
done

echo ""
echo "📥 Установка:"
echo ""
echo "  DMG (рекомендуется):"
echo "    open $DIST_DIR/$DMG_NAME"
echo ""
echo "  PKG (для автоматизации):"
if [ -f "$DIST_DIR/${APP_NAME}_${VERSION}_arm64.pkg" ]; then
    echo "    sudo installer -pkg $DIST_DIR/${APP_NAME}_${VERSION}_arm64.pkg -target /"
fi
if [ -f "$DIST_DIR/${APP_NAME}_${VERSION}_x86_64.pkg" ]; then
    echo "    sudo installer -pkg $DIST_DIR/${APP_NAME}_${VERSION}_x86_64.pkg -target /"
fi
echo ""
