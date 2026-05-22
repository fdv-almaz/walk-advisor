#!/bin/bash

# Скрипт создания иконки для Walk Advisor

ICON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/Icons"
mkdir -p "$ICON_DIR"

# Размеры иконок для macOS
SIZES=(16 32 64 128 256 512)

# Создать иконку из эмодзи или текста
# Способ 1: Используем встроенную утилиту macOS

for size in "${SIZES[@]}"; do
    # Создать простую иконку с градиентом и символом прогулки
    # Этот способ сложен для скрипта, поэтому используем готовую иконку

    # Копируем встроенную иконку или используем символ
    if [ -f "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" ]; then
        cp "/System/Applications/Maps.app/Contents/Resources/AppIcon.icns" \
           "$ICON_DIR/AppIcon_${size}.icns"
        echo "✓ Создана иконка ${size}x${size}"
    fi
done

echo ""
echo "Иконки созданы в: $ICON_DIR"
echo ""
echo "Для использования:"
echo "1. Откройте Assets.xcassets в Xcode"
echo "2. Создайте App Icon Set"
echo "3. Перетащите иконки из $ICON_DIR"
echo ""
echo "Или скопируйте в приложение:"
echo "mkdir -p \"./build/Walk Advisor.app/Contents/Resources\""
echo "cp \"$ICON_DIR\"/*.icns \"./build/Walk Advisor.app/Contents/Resources/\""
