# WeatherApp для macOS - Указатель файлов

Быстрая навигация по документации и исходному коду.

## 📖 Документация

| Файл | Описание | Для кого |
|------|---------|----------|
| [**QUICKSTART.md**](QUICKSTART.md) | ⚡ Быстрый старт за 2 минуты | Новичков |
| [**README.md**](README.md) | 📚 Полная документация | Разработчиков |
| [**XCODE_SETUP.md**](XCODE_SETUP.md) | 🍎 Пошаговое создание в Xcode | Пользователей Xcode |
| [**DEVELOPMENT.md**](DEVELOPMENT.md) | 🔧 Руководство разработчика | Контрибьюторов |
| [**INDEX.md**](INDEX.md) | 📑 Этот файл - навигация | Всех |

## 🔧 Исходный код

### Основные файлы

| Файл | Строк | Назначение |
|------|--------|----------|
| [**WeatherApp.swift**](WeatherApp.swift) | 15 | Entry point приложения |
| [**ContentView.swift**](ContentView.swift) | 280 | Основной UI (SwiftUI) |
| [**Models.swift**](Models.swift) | 120 | Структуры данных |
| [**LocationManager.swift**](LocationManager.swift) | 45 | Работа с GPS (CoreLocation) |
| [**WeatherService.swift**](WeatherService.swift) | 80 | API и рекомендации |

### Конфигурация

| Файл | Описание |
|------|---------|
| [**Info.plist**](Info.plist) | Параметры приложения |
| [**build.sh**](build.sh) | Скрипт компиляции |

## 🚀 Быстрые команды

### Способ 1: Скрипт (рекомендуется)
```bash
chmod +x build.sh && ./build.sh && open build/WeatherApp.app
```

### Способ 2: Xcode
```bash
open .
# Нажмите Run (⌘R)
```

### Способ 3: Прямая компиляция
```bash
swiftc -o WeatherApp *.swift -framework SwiftUI -framework CoreLocation -O
./WeatherApp
```

## 📊 Размер и производительность

| Метрика | Значение |
|---------|----------|
| **Размер приложения** | ~5 MB |
| **Использование памяти** | 25-35 MB |
| **CPU (фоне)** | ~0.1% |
| **Время запуска** | <1 сек |
| **Трафик на запрос** | ~1-2 KB |

## 🎯 Типичные задачи

### "Мне нужно быстро запустить"
👉 Читайте [QUICKSTART.md](QUICKSTART.md)

### "Я хочу изменить цвета"
👉 Смотрите [ContentView.swift:40-50](ContentView.swift#L40)

### "Как добавить новый параметр (давление, UV)"
👉 Следуйте [DEVELOPMENT.md - Добавить новый параметр](DEVELOPMENT.md#1️⃣-добавить-новый-параметр)

### "Я хочу компилировать в Xcode"
👉 Прочитайте [XCODE_SETUP.md](XCODE_SETUP.md)

### "Геопозиция не работает"
👉 Выполните [README.md - Разрешения](README.md#разрешения)

### "Я хочу улучшить приложение"
👉 Начните с [DEVELOPMENT.md](DEVELOPMENT.md)

## 🔄 Flow диаграмма

```
┌─────────────────────────────┐
│  Запуск WeatherApp.swift    │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  ContentView загружает UI   │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  LocationManager запрашивает│
│  GPS координаты            │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  WeatherService запрашивает │
│  данные погоды из API       │
└────────────┬────────────────┘
             │
             ▼
┌─────────────────────────────┐
│  ContentView показывает     │
│  погоду + рекомендацию      │
└─────────────────────────────┘
```

## 📱 Поддерживаемые платформы

| Платформа | Поддержка |
|-----------|-----------|
| Intel Mac (x86_64) | ✅ |
| Apple Silicon (ARM64) | ✅ |
| macOS 12+ | ✅ |
| macOS 11 (Big Sur) | ❌ |

## 🌐 Внешние API

**Open-Meteo API**
- URL: `https://api.open-meteo.com/v1/forecast`
- Доступ: Бесплатно, без ключа
- Обновление: Каждые 30 минут

**CoreLocation**
- API: macOS встроенное
- Точность: ±10 метров
- Требует: Разрешение пользователя

## 📊 Статистика проекта

```
Язык программирования: Swift 5.7+
Framework UI:          SwiftUI
Количество файлов:     6 Swift + конфиг
Строк кода:            ~540
Документация:          ~1500 строк
Зависимости:           Встроенные (нет внешних)
Лицензия:             MIT
```

## 🎓 Структура обучения

Для новичков рекомендуется читать в таком порядке:

1. **QUICKSTART.md** - запустите приложение (5 мин)
2. **README.md** - поймите, что оно делает (10 мин)
3. **ContentView.swift** - посмотрите UI код (15 мин)
4. **Models.swift** - структуры данных (10 мин)
5. **WeatherService.swift** - логика (10 мин)
6. **DEVELOPMENT.md** - как улучшить (30 мин)

**Всего**: ~90 минут для полного понимания.

## 🐛 Поиск неполадок

### Ошибка при компиляции?
→ Проверьте [XCODE_SETUP.md - Troubleshooting](XCODE_SETUP.md#troubleshooting)

### Приложение не запускается?
→ Смотрите [README.md - Устранение неполадок](README.md#устранение-неполадок)

### Вопрос о разработке?
→ Прочитайте [DEVELOPMENT.md](DEVELOPMENT.md)

## 🔗 Полезные ссылки

- **Xcode Download**: https://apps.apple.com/us/app/xcode/id497799835
- **Open-Meteo API**: https://open-meteo.com
- **Swift Documentation**: https://docs.swift.org
- **SwiftUI Tutorial**: https://developer.apple.com/tutorials/swiftui

## ✨ Что дальше

После запуска приложения попробуйте:

- [ ] Изменить цвета (найдите `backgroundGradient`)
- [ ] Добавить новый параметр (давление)
- [ ] Кэшировать результаты (30 сек)
- [ ] Добавить темный режим
- [ ] Создать Widget версию

---

**Быстрый старт**: 👉 [QUICKSTART.md](QUICKSTART.md)

**Полная документация**: 👉 [README.md](README.md)

**Для разработчиков**: 👉 [DEVELOPMENT.md](DEVELOPMENT.md)
