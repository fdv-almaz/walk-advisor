# Разработка WeatherApp

Руководство для разработчиков, которые хотят улучшить приложение.

## 🏗 Архитектура

```
┌─────────────────────────────────────┐
│        ContentView (SwiftUI)        │  ← Пользовательский интерфейс
└────────────┬────────────────────────┘
             │
    ┌────────┴────────┐
    │                 │
┌───▼────────┐    ┌──▼──────────────┐
│ Location   │    │ Weather Service │  ← Бизнес-логика
│ Manager    │    │                 │
└───┬────────┘    └──┬──────────────┘
    │                │
    └────────┬───────┘
             │
        ┌────▼─────────────────┐
        │  External APIs       │  ← Интеграция
        │ • CoreLocation       │
        │ • Open-Meteo API     │
        └──────────────────────┘
```

## 📝 Структура файлов

### WeatherApp.swift
Entry point приложения. Здесь определяется главное окно и сцена.

```swift
@main struct WeatherApp: App
```

**Когда редактировать**:
- Изменение размеров окна
- Скрытие/показ строки заголовка
- Конфигурация вкладок

### ContentView.swift
Основной UI - всё, что видит пользователь.

**Компоненты**:
- `backgroundGradient` - фон с градиентом
- `headerView` - название и время обновления
- `weatherContentView` - температура, влажность, ветер
- `recommendationView` - совет идти ли гулять

**Когда редактировать**:
- Изменение цветов
- Добавление новых данных (давление, UV индекс)
- Переделка макета

### Models.swift
Структуры данных для типизации.

```swift
struct WeatherData {
    let current: CurrentWeather
    let currentUnits: CurrentUnits
}

enum ActivityRecommendation {
    case excellent, good, moderate, poor
}
```

**Когда редактировать**:
- Добавление новых параметров погоды
- Изменение рекомендаций
- Поддержка новых API

### LocationManager.swift
Работа с CoreLocation для получения GPS координат.

**Ключевые методы**:
```swift
func checkAuthorization()    // Проверить разрешение
func requestLocation()       // Запросить координаты
```

**Когда редактировать**:
- Изменение точности GPS
- Добавление обратного геокодирования (город/адрес)
- Улучшение обработки ошибок

### WeatherService.swift
Работа с API и логика рекомендаций.

```swift
func fetchWeather(latitude: Double, longitude: Double) async -> WeatherData
func getActivityRecommendation(...) -> ActivityRecommendation
```

**Когда редактировать**:
- Добавление новых параметров API
- Изменение алгоритма рекомендаций
- Кэширование результатов

## 🔄 Типичные улучшения

### 1️⃣ Добавить новый параметр (напр. давление)

**Шаг 1**: Обновить Models.swift
```swift
struct CurrentWeather: Codable {
    // ... существующие поля
    let pressure: Int  // ← НОВОЕ
    
    enum CodingKeys: String, CodingKey {
        // ...
        case pressure = "pressure_2m"  // ← НОВОЕ
    }
}
```

**Шаг 2**: Обновить API запрос в WeatherService.swift
```swift
let params = [
    // ...
    URLQueryItem(name: "current", value: "...pressure_2m"),  // ← ДОБАВИТЬ
]
```

**Шаг 3**: Показать в UI (ContentView.swift)
```swift
HStack(spacing: 4) {
    Image(systemName: "gauge")
    Text("\(weather.current.pressure) hPa")
}
```

### 2️⃣ Изменить цвета приложения

В `ContentView.swift` найти `backgroundGradient`:

```swift
var backgroundGradient: some View {
    LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.135, green: 0.506, blue: 0.969),  // ← ЦВЕТ 1
            Color(red: 0.198, green: 0.631, blue: 0.973)   // ← ЦВЕТ 2
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
```

### 3️⃣ Добавить кэширование результатов

В `WeatherService.swift`:

```swift
private var cachedWeather: WeatherData?
private var cacheTimestamp: Date?
private let cacheExpiration: TimeInterval = 300  // 5 минут

func fetchWeather(...) async throws -> WeatherData {
    if let cached = cachedWeather,
       let timestamp = cacheTimestamp,
       Date().timeIntervalSince(timestamp) < cacheExpiration {
        return cached
    }
    
    let data = try await /* API запрос */
    cachedWeather = data
    cacheTimestamp = Date()
    return data
}
```

### 4️⃣ Добавить обратное геокодирование (город/адрес)

В `LocationManager.swift`:

```swift
import CoreLocation

func getPlaceName(for coordinate: CLLocationCoordinate2D) async {
    let geocoder = CLGeocoder()
    let location = CLLocation(latitude: coordinate.latitude, 
                              longitude: coordinate.longitude)
    
    do {
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        if let placemark = placemarks.first {
            print("Город: \(placemark.locality ?? "Unknown")")
            print("Адрес: \(placemark.name ?? "Unknown")")
        }
    } catch {
        print("Ошибка геокодирования: \(error)")
    }
}
```

## 🧪 Тестирование

### Симуляция разных GPS координат

В Xcode при разработке:
```
Simulator → Features → Location → Custom Location
Latitude: 55.7558
Longitude: 37.6173
```

Или через код:
```swift
// Для тестирования используйте hardcoded координаты
#if DEBUG
let testLatitude = 55.7558
let testLongitude = 37.6173
#else
let testLatitude = location.latitude
#endif
```

### Симуляция ошибок

```swift
// В LocationManager.swift для отладки
func simulateError() {
    errorMessage = "Тестовая ошибка геопозиции"
    isAuthorized = false
}
```

## 📱 Widget (будущее)

Для добавления Widget поддержки (в версии 2.0):

```swift
import WidgetKit

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("Погода")
        .description("Показывает текущую погоду и рекомендации")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
```

## 🚀 Performance Tips

### 1. Используйте async/await
```swift
// ✅ Правильно
func fetchWeather() async throws -> WeatherData {
    let (data, _) = try await session.data(from: url)
    return try decoder.decode(WeatherData.self, from: data)
}

// ❌ Неправильно
func fetchWeatherSync() throws -> WeatherData {
    // Блокирует UI!
}
```

### 2. Кэшируйте запросы
```swift
// ✅ Кэш предотвращает лишние запросы
if let cached = cachedData, isFresh() {
    return cached
}
```

### 3. Минимизируйте UI обновления
```swift
// ✅ Правильно - обновляется только одно свойство
@State private var weather: WeatherData?

// ❌ Неправильно - пересчитывается весь view
var weather: WeatherData { ... }
```

## 🔍 Отладка

### Включить логирование

```swift
// В WeatherService.swift
private let logger = Logger(subsystem: "com.weatherapp.macos", category: "Weather")

func fetchWeather(...) async throws -> WeatherData {
    logger.debug("Запрос погоды: \(latitude), \(longitude)")
    // ...
    logger.debug("Получена погода: \(temperature)°C")
}
```

### Просмотреть логи

```bash
log stream --predicate 'subsystem == "com.weatherapp.macos"'
```

## 📚 Полезные ресурки

- [Apple SwiftUI Docs](https://developer.apple.com/documentation/swiftui)
- [CoreLocation Guide](https://developer.apple.com/documentation/corelocation)
- [Open-Meteo API](https://open-meteo.com/en/docs)
- [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency)

## 🤝 Contributing

1. Создайте ветку: `git checkout -b feature/my-feature`
2. Внесите изменения
3. Протестируйте: `./build.sh && open build/WeatherApp.app`
4. Закоммитьте: `git commit -am 'Add my feature'`
5. Push: `git push origin feature/my-feature`
6. Создайте Pull Request

---

**Happy coding!** 🎉
