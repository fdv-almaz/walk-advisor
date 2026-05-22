# Создание проекта в Xcode пошагово

## 📋 Предварительные требования

- macOS 12.0+
- Xcode 14.0+ (скачайте из App Store)
- 20 GB свободного места для Xcode

## 🚀 Пошаговая инструкция

### Шаг 1: Создать новый проект в Xcode

1. Откройте **Xcode** → **File → New → Project**
2. Выберите **macOS** (в верхней части окна)
3. Выберите **App** и нажмите **Next**

![Xcode Create Project](https://img.shields.io/badge/Xcode-Create%20Project-blue)

### Шаг 2: Заполнить параметры проекта

Заполните следующие поля:

| Поле | Значение |
|------|----------|
| **Product Name** | `WeatherApp` |
| **Team** | None (или ваша команда) |
| **Organization Identifier** | `com.weatherapp` |
| **Bundle Identifier** | `com.weatherapp.macos` |
| **Interface** | `SwiftUI` |
| **Language** | `Swift` |

Нажмите **Next** → выберите место для сохранения → **Create**

### Шаг 3: Скопировать файлы

В левой панели Xcode нажмите на папку **WeatherApp** (не проекта, а папки в нём).

Теперь **замените содержимое** файла `ContentView.swift`:
- Откройте файл
- Выделите всё (⌘A)
- Скопируйте содержимое из [ContentView.swift](ContentView.swift)
- Вставьте (⌘V)

Повторите для остальных файлов. Или создайте новые файлы:

#### Создать новый файл SwiftUI:

1. **File → New → File** (⌘N)
2. Выберите **Swift File**
3. Назовите `Models.swift`
4. Вставьте содержимое из [Models.swift](Models.swift)

Повторите для:
- `LocationManager.swift`
- `WeatherService.swift`

### Шаг 4: Добавить разрешения (Signing & Capabilities)

1. Выберите проект в левой панели
2. Выберите **Targets → WeatherApp**
3. Перейдите на вкладку **Signing & Capabilities**
4. Нажмите **+ Capability** и добавьте:

#### Location (Геопозиция)
- Нажмите **+ Capability**
- Найдите **Location**
- Выберите **When In Use**

#### Network (если нужен интернет)
- Нажмите **+ Capability**
- Найдите **Network**

### Шаг 5: Обновить Info.plist

1. Выберите **Info.plist** в файлах проекта
2. Добавьте новые ключи:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Приложение использует ваше местоположение для получения точной информации о погоде</string>

<key>NSLocationUsageDescription</key>
<string>Приложение использует ваше местоположение для получения точной информации о погоде</string>

<key>NSBonjourServiceTypes</key>
<array>
    <string>_weatherapp._tcp</string>
</array>
```

Или сделайте это через Xcode Property List Editor:
1. Правый клик на Info.plist → Open As → Property List
2. Нажмите **+** и добавьте ключ `Privacy - Location When In Use Usage Description`
3. Значение: `Приложение использует ваше местоположение...`

### Шаг 6: Проверить Target Settings

1. **Targets → WeatherApp → General**
2. Проверьте:
   - **Minimum Deployments**: macOS 12.0
   - **Supports**: Intel + Apple Silicon

```
Architectures: Any Mac
```

### Шаг 7: Собрать и запустить

1. Выберите в меню: **Product → Scheme → WeatherApp**
2. Нажмите **Run** (⌘R) или кнопку ▶️ в левом верхнем углу

### Шаг 8: Разрешить геопозицию

При первом запуске приложение спросит разрешение:
- Нажмите **Allow** (Разрешить)

Если по ошибке нажали **Don't Allow**, разрешите вручную:

```bash
# Дать разрешение Xcode
tccutil grant location /Applications/Xcode.app

# Или вручную:
# Параметры → Приватность и безопасность → Геопозиция → включить
```

---

## ✅ Проверка работоспособности

После запуска приложение должно:

1. ✅ Открыться в отдельном окне
2. ✅ Запросить разрешение на геопозицию
3. ✅ Показать текущую температуру
4. ✅ Показать рекомендацию идти ли гулять

Если этого не происходит, смотрите раздел **Troubleshooting** ниже.

---

## 🐛 Troubleshooting

### Ошибка: "Could not find any iOS App"

```
Product → Destination → Any Mac
```

### Ошибка: "Import of module 'SwiftUI' failed"

```bash
# Обновить Command Line Tools
xcode-select --install

# Или выбрать версию Xcode
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### Ошибка: "Cannot find 'LocationManager' in scope"

Убедитесь, что:
1. Файл `LocationManager.swift` находится в целевой папке проекта
2. В Xcode показан в левой панели
3. В **Targets → Build Phases → Compile Sources** добавлен файл

Если файл не показан:
1. **File → Add Files to "WeatherApp"**
2. Выберите `LocationManager.swift`
3. Убедитесь, что отмечено `WeatherApp` в Target Membership

### Приложение загружает долго

Это нормально при первой компиляции. Последующие будут быстрее.

### Геопозиция не работает

1. Проверьте разрешение:
```bash
tccutil dump | grep location
```

2. Выдайте разрешение:
```bash
tccutil grant location /Applications/Xcode.app
```

3. В Xcode: **Run → Devices and Simulators → Your Mac → Location → Custom**

---

## 📦 Создать готовое приложение

После успешного тестирования:

### Вариант 1: Через Xcode

1. **Product → Build For → Running** (⌘B)
2. **Product → Archive**
3. **Distribute App**
4. Выберите **Direct Distribution**

Приложение будет в папке **DerivedData**

### Вариант 2: Через скрипт

```bash
cd /path/to/project

# Создать .app пакет
xcodebuild -scheme WeatherApp \
           -configuration Release \
           -derivedDataPath ./build \
           build

# Найти готовое приложение
find build -name "WeatherApp.app" -type d
```

### Вариант 3: Раздать друзьям

```bash
# Сжать приложение
cd /path/to/WeatherApp.app/..
ditto -c -k --sequesterRsrc WeatherApp.app WeatherApp.zip

# Отправить WeatherApp.zip
# Получатель просто распакует и запустит
```

---

## 🎓 Полезные горячие клавиши

| Сочетание | Действие |
|-----------|----------|
| ⌘R | Запустить (Run) |
| ⌘B | Собрать (Build) |
| ⌘⇧K | Очистить (Clean) |
| ⌘, | Параметры |
| ⌘⇧O | Открыть файл |
| ⌘⇧J | Перейти в файл в навигаторе |
| ⌘⌃I | Re-Indent Code |

---

## 📚 Дополнительно

- [Apple Documentation](https://developer.apple.com/documentation/)
- [Swift Playgrounds](https://www.apple.com/swift/playgrounds/) - для обучения
- [Xcode Help](https://help.apple.com/xcode/)

---

**Готово!** 🎉 Вы успешно создали WeatherApp в Xcode.
