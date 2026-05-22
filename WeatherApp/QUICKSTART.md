# Quick Start - WeatherApp для macOS

## ⚡ Самый быстрый способ запустить

### 1️⃣ Через скрипт (1 команда)

```bash
cd WeatherApp
chmod +x build.sh
./build.sh
open build/WeatherApp.app
```

**Готово!** Приложение откроется и попросит разрешение на геопозицию.

### 2️⃣ Через Xcode (рекомендуется для разработки)

```bash
# Создать новый проект Xcode
open -n /Applications/Xcode.app

# В Xcode: File → New → Project → macOS → App
# Имя: WeatherApp
# Тип: Swift + SwiftUI

# Скопировать файлы в группу WeatherApp (в левой панели):
# ├─ WeatherApp.swift
# ├─ ContentView.swift
# ├─ Models.swift
# ├─ LocationManager.swift
# └─ WeatherService.swift

# Нажать Run (⌘R)
```

### 3️⃣ Прямая компиляция (если нет Xcode)

```bash
swiftc -o WeatherApp \
    WeatherApp.swift \
    ContentView.swift \
    Models.swift \
    LocationManager.swift \
    WeatherService.swift \
    -framework SwiftUI \
    -framework CoreLocation \
    -framework AppKit \
    -O
```

## 🔐 Разрешить геопозицию

При первом запуске приложение попросит разрешение. Выберите **"Разрешить"**.

Если пропустили:
```bash
# Найти приложение
tccutil dump | grep location

# Выдать разрешение
tccutil grant location /Applications/Xcode.app

# Или вручную: Параметры → Приватность и безопасность → Геопозиция
```

## 🎨 Особенности UI

- **Красивый градиент** - голубой фон с переливом
- **Крупная температура** - сразу видно
- **Эмодзи погоды** - интуитивно понятно
- **Рекомендации** - цветная шкала: зелёный (идеально) → красный (дождь)
- **Лёгкая** - 35 MB RAM, минимальный CPU

## 📊 Что показывает

```
☀️ Погода          ← Тип погоды
28°                ← Температура в градусах Цельсия
💧 65%             ← Влажность
💨 12 км/ч         ← Скорость ветра

Рекомендация: Идеально для прогулки и бега ✨
```

## 🔄 Обновление

Нажмите кнопку **"Обновить"** для немедленной переполучки данных.

Автоматическое обновление каждые 30 минут (в версии 2.0).

## 🛠 Устранение неполадок

### "Геопозиция не получена"
```bash
# Проверить разрешения
sudo dscl . read /Library/Preferences/com.apple.location.services
```

### Приложение не открывается
```bash
# Проверить код
swift build -v

# Или запустить с логами
xcrun simctl diagnose
```

### Слишком много ошибок при компиляции
```bash
# Обновить Swift
xcode-select --install

# Или в Xcode: Preferences → Locations → Command Line Tools (выберите последнюю)
```

## 📱 Системные требования

| Требование | Версия |
|-----------|--------|
| macOS | 12.0+ |
| Архитектура | Intel x86_64 или Apple Silicon ARM64 |
| RAM | 25-35 MB |
| Диск | ~5 MB |
| Сеть | Для первого запуска и обновлений |

## 🚀 Что дальше

1. **Запустить** - `open build/WeatherApp.app`
2. **Разрешить геопозицию** - кнопка "Разрешить" при первом запуске
3. **Смотреть погоду** - информация обновляется автоматически

## 💡 Советы

- Приложение экономно - можно оставить в фоне
- GPS обновляется при изменении местоположения
- API запросы бесплатные (Open-Meteo)
- Нет трекинга и аналитики

---

**Вопросы?** Читайте [README.md](README.md) для полной документации.
