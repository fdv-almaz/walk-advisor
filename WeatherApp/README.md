# WeatherApp для macOS

Нативное приложение для macOS, написанное на **Swift** с использованием **SwiftUI**.

## Особенности

✨ **Минималистичный дизайн** - красивый и интуитивный интерфейс
🌍 **GPS геопозиция** - использует встроенную CoreLocation
📊 **Рекомендации** - подсказывает, идти ли гулять или бегать
⚡ **Оптимизировано** - минимальное потребление ресурсов
🍎 **Native** - полная поддержка Intel и Apple Silicon

## Требования

- macOS 12.0 или выше
- Xcode 14.0+ (для компиляции)
- Swift 5.7+

## Компиляция и запуск

### Способ 1: Через Xcode (рекомендуется)

1. Откройте Xcode
2. Выберите **File → New → Project**
3. Выберите **macOS → App**
4. Скопируйте файлы из этой папки в проект:
   - `WeatherApp.swift` → AppDelegate место
   - `ContentView.swift`
   - `Models.swift`
   - `LocationManager.swift`
   - `WeatherService.swift`
   - `Info.plist` → Info section в проекте

5. В **Target Settings**:
   - Установите **Signing & Capabilities** → добавьте **Location** permission
   - Для Widget поддержки добавьте **WidgetKit capability**

6. Нажмите **Run** (⌘R)

### Способ 2: Через командную строку

```bash
# Скомпилировать
swiftc -o WeatherApp \
    WeatherApp.swift \
    ContentView.swift \
    Models.swift \
    LocationManager.swift \
    WeatherService.swift \
    -framework SwiftUI \
    -framework CoreLocation \
    -framework AppKit

# Запустить
./WeatherApp
```

### Способ 3: Создать .app пакет

```bash
# Создать структуру .app
mkdir -p WeatherApp.app/Contents/MacOS
mkdir -p WeatherApp.app/Contents/Resources

# Скомпилировать
swiftc -o WeatherApp.app/Contents/MacOS/WeatherApp \
    WeatherApp.swift \
    ContentView.swift \
    Models.swift \
    LocationManager.swift \
    WeatherService.swift \
    -framework SwiftUI \
    -framework CoreLocation \
    -framework AppKit

# Скопировать Info.plist
cp Info.plist WeatherApp.app/Contents/Info.plist

# Запустить
open WeatherApp.app
```

## Разрешения

Первый запуск попросит разрешение на доступ к геопозиции:

1. Откройте **Параметры системы**
2. Перейдите в **Приватность и безопасность → Службы геопозиции**
3. Включите переключатель **Службы геопозиции**
4. Найдите **Xcode** или **WeatherApp** в списке и установите **Разрешить**

Или через командную строку:
```bash
tccutil grant location /Applications/Xcode.app
```

## Использование

1. **Запустите приложение** - оно автоматически определит вашу геопозицию
2. **Смотрите погоду** - текущие условия, температура, влажность, ветер
3. **Следуйте рекомендации** - приложение подскажет, идеально ли идти гулять или бегать

## Рекомендации работают по схеме:

- **Идеально для прогулки и бега** ✨: 15-30°C, ясно/облачно, ветер <20 км/ч
- **Хорошо для прогулки** 👍: 10-35°C, ясно/облачно, ветер <25 км/ч
- **Легкая прогулка** 🤔: умеренные условия
- **Лучше остаться дома** ☕: дождь, гроза, сильный снег

## Архитектура

```
WeatherApp.swift       → Entry point приложения
ContentView.swift      → Основной UI с использованием SwiftUI
Models.swift          → Структуры данных (WeatherData, Recommendations)
LocationManager.swift → Работа с CoreLocation и геопозицией
WeatherService.swift  → API запросы и логика рекомендаций
Info.plist           → Конфигурация приложения
```

## API

Приложение использует бесплатный API **Open-Meteo**:
- Не требует регистрации
- Не требует API ключа
- Поддерживает множество параметров погоды
- Эко-дружелюбен

## Потребление ресурсов

- **Процессор**: ~0.1% в фоне
- **Память**: ~25-35 MB
- **Сеть**: ~1-2 KB на запрос (автообновление каждые 30 минут)

## Разработка

Для добавления новых функций:

1. Добавьте новые поля в `Models.swift`
2. Обновите `WeatherService.swift` для парсинга
3. Добавьте UI элементы в `ContentView.swift`

## Лицензия

MIT - свободно используйте в своих проектах
