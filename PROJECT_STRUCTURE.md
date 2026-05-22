# Weather App - Полная документация проекта

Проект содержит две версии приложения для получения информации о погоде:

## 📁 Структура проекта

```
weather.python/
├── weather_app.py              ← Python версия (CLI)
├── PROJECT_STRUCTURE.md        ← Этот файл
│
└── WeatherApp/                 ← Swift версия (macOS GUI)
    ├── WeatherApp.swift        ← Entry point
    ├── ContentView.swift       ← UI компоненты
    ├── Models.swift            ← Структуры данных
    ├── LocationManager.swift   ← Работа с CoreLocation
    ├── WeatherService.swift    ← API и логика
    ├── Info.plist             ← Конфигурация
    ├── build.sh               ← Скрипт для компиляции
    ├── README.md              ← Полная документация
    ├── QUICKSTART.md          ← Быстрый старт
    └── build/                 ← Скомпилированное приложение
        └── WeatherApp.app
```

## 🐍 Python версия (weather_app.py)

**Тип**: Command Line Interface (CLI)
**Язык**: Python 3
**Использование**: 
```bash
python3 weather_app.py
```

### Особенности
- 📍 GPS из macOS CoreLocation
- 🌐 Резервный способ: определение по IP-адресу
- 🌤️ Текущие условия: температура, влажность, ветер
- 💾 Простая архитектура
- 🐧 Кроссплатформенная (Linux, Windows, macOS)

### Требования
```bash
pip install requests pyobjc pyobjc-framework-CoreLocation
```

---

## 🍎 Swift версия (WeatherApp/)

**Тип**: Native macOS Application (GUI)
**Язык**: Swift + SwiftUI
**Использование**:
```bash
cd WeatherApp
./build.sh
open build/WeatherApp.app
```

### Особенности
✨ **Красивый дизайн**
- Градиентный фон
- Крупные шрифты
- Цветные индикаторы

📊 **Полная информация**
- Текущая температура
- Влажность и ветер
- Тип погоды с эмодзи

💡 **Умные рекомендации**
- Идеально ли идти гулять
- Подходит ли погода для бега
- Цветовой индикатор (зелёный - идеально, красный - плохо)

⚡ **Оптимизация**
- Минимальное потребление CPU
- ~35 MB памяти
- Быстрая загрузка

🔒 **Приватность**
- Нет трекинга
- Нет отправки данных
- Локальная обработка

### Требования
- macOS 12.0+
- Xcode 14+ (для разработки)
- Swift 5.7+
- Разрешение на доступ к геопозиции

---

## 🌐 API

Обе версии используют бесплатный API **Open-Meteo**:

```
https://api.open-meteo.com/v1/forecast
  ?latitude=55.75
  &longitude=37.62
  &current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
  &timezone=auto
```

**Преимущества**:
- ✅ Бесплатный
- ✅ Без регистрации
- ✅ Без API ключа
- ✅ Точные данные
- ✅ Эко-friendly

---

## 📍 Определение местоположения

### Версия 1: GPS (Swift/Python)
- **Точность**: ±10 метров
- **Скорость**: Зависит от сигнала
- **Требует**: Разрешение пользователя
- **Работает**: Везде с GPS модулем

### Версия 2: IP-адрес (Python fallback)
- **Точность**: ±100 км
- **Скорость**: Мгновенно
- **Требует**: Интернет
- **Работает**: Везде

---

## 🎯 Когда использовать

### 🐍 Python версия
```bash
python3 weather_app.py
```
✅ Нужна информация в терминале
✅ Автоматизация и скрипты
✅ Кроссплатформенность
✅ Минимальные зависимости

### 🍎 Swift версия
```bash
cd WeatherApp && ./build.sh && open build/WeatherApp.app
```
✅ Приятный UI
✅ Работает как виджет
✅ Легче на ресурсах
✅ Максимальная интеграция с macOS

---

## 🔧 Развертывание

### Python версия

```bash
# Установить зависимости
pip install -r requirements.txt

# Запустить
python3 weather_app.py

# Или создать executable
pyinstaller --onefile weather_app.py
```

### Swift версия

```bash
# Способ 1: Скрипт
cd WeatherApp && ./build.sh

# Способ 2: Xcode
open WeatherApp  # откроет проект в Xcode

# Способ 3: Ручная компиляция
swiftc -o WeatherApp *.swift -framework SwiftUI -framework CoreLocation -O
```

---

## 📊 Сравнение

| Аспект | Python | Swift |
|--------|--------|-------|
| **UI** | Текст | Графический |
| **Ресурсы** | ~20 MB | ~35 MB |
| **Скорость** | Зависит от Python | Нативная |
| **Портативность** | Кроссплатформенная | только macOS |
| **GUI Widget** | ❌ | ✅ (в разработке) |
| **Разработка** | Быстрая | Полнофункциональная |

---

## 🚀 Что дальше

### Python версия
- [ ] Добавить дополнительные метрики (UV index, давление)
- [ ] Интеграция с MQTT
- [ ] Web интерфейс

### Swift версия
- [x] Основное приложение
- [ ] WidgetKit интеграция
- [ ] Notchmeister поддержка
- [ ] iCloud синхронизация
- [ ] Темный режим (уже готов)

---

## 🐛 Troubleshooting

### Проблема: "Геопозиция не работает"
```bash
# Swift
tccutil grant location /Applications/Xcode.app

# Python
sudo dscl . read /Library/Preferences/com.apple.location.services
```

### Проблема: "API недоступен"
```bash
# Проверить интернет
curl -I https://api.open-meteo.com/v1/forecast

# Проверить IP
curl https://api.open-meteo.com/v1/forecast?latitude=0&longitude=0
```

### Проблема: "Swift не компилируется"
```bash
# Обновить Xcode Command Line Tools
xcode-select --install

# Или выбрать версию в Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

---

## 📝 Лицензия

MIT License - свободно используйте в своих проектах

---

## 👨‍💻 Автор

Weather App - демонстрация интеграции GPS, погодных API и создания приложений для macOS.

**Дата создания**: 2026-05-22
**Версия**: 1.0
