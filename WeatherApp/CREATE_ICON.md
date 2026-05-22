# Создание иконки для Walk Advisor

## Быстрый способ через Xcode

1. Откройте проект в Xcode
2. Выберите **Assets.xcassets** в левой панели
3. Нажмите **+** → **App Icon Set**
4. Назовите **AppIcon**
5. Перетащите изображения в нужные слоты

## Создание иконки вручную

### Способ 1: Использовать готовую иконку

Скачайте иконку "Walk Advisor" или создайте свою:

```bash
# Пример: создать простую иконку из эмодзи
# Используйте любой онлайн редактор иконок и экспортируйте PNG

# Размеры для macOS:
# 512x512 - основной размер
# 256x256 - второй размер
# 128x128 - третий размер
```

### Способ 2: Использовать встроенное изображение в коде

В Info.plist добавьте ссылку на иконку:

```xml
<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

### Способ 3: Встроить иконку в приложение (Swift код)

Добавьте в ContentView.swift:

```swift
Image(systemName: "figure.walk")
    .font(.system(size: 64))
    .foregroundColor(.white)
```

## Онлайн инструменты для создания иконок

1. **Figma** (figma.com) - бесплатный редактор
2. **Canva** (canva.com) - шаблоны иконок
3. **App Icon Generator** - автоматическое создание всех размеров
4. **Sketch** - профессиональный инструмент

## Рекомендуемый дизайн для Walk Advisor

- **Цвет**: Голубой (0x1F82F5) или зеленый (0x34C759)
- **Иконка**: Силуэт человека идущего/бегущего
- **Фон**: Прозрачный или градиент голубой
- **Стиль**: Современный, минималистичный

### Варианты:
1. 🚶 Силуэт прогулки
2. 🏃 Силуэт бега
3. 🧭 Компас с человеком
4. 🌍 Земля + человек
5. ☀️ Солнце + человек

## Быстрый способ: используйте систему иконок macOS

Скопируйте существующую иконку из Applications:

```bash
# Пример: использовать встроенную иконку macOS
cp /System/Applications/Maps.app/Contents/Resources/AppIcon.icns \
   /Users/fdv/projects/weather.python/WeatherApp/AppIcon.icns
```

## Интеграция в приложение через build.sh

Обновите build.sh для копирования иконки:

```bash
# Добавьте в build.sh:
mkdir -p "$APP_PATH/Contents/Resources"
cp AppIcon.icns "$APP_PATH/Contents/Resources/"

# И обновите Info.plist:
# <key>CFBundleIconFile</key>
# <string>AppIcon</string>
```

---

**После создания иконки**, скомпилируйте приложение заново:

```bash
./build.sh
```

Иконка появится в Finder, на Dock и в меню Applications.
