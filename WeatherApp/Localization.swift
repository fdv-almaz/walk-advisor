import Foundation

enum UserDefaultsKeys {
    static let useIPLocation = "useIPLocation"
    static let selectedLanguage = "selectedLanguage"
}

enum Language: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case polish = "pl"
    case belarusian = "be"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        case .polish: return "Polski"
        case .belarusian: return "Беларуский"
        }
    }
}

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: Language {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: UserDefaultsKeys.selectedLanguage)
        }
    }

    static let shared = LocalizationManager()

    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedLanguage) ?? "ru"
        self.currentLanguage = Language(rawValue: savedLanguage) ?? .russian
    }

    func localize(_ key: String) -> String {
        let translations = translationDictionary()
        return translations[key] ?? key
    }

    private func translationDictionary() -> [String: String] {
        switch currentLanguage {
        case .english:
            return englishTranslations()
        case .russian:
            return russianTranslations()
        case .polish:
            return polishTranslations()
        case .belarusian:
            return belarusianTranslations()
        }
    }

    private func englishTranslations() -> [String: String] {
        [
            "app_title": "Walk Advisor",
            "updated": "Updated",
            "clear": "Clear",
            "cloudy": "Cloudy",
            "fog": "Fog",
            "drizzle": "Drizzle",
            "rain": "Rain",
            "heavy_rain": "Heavy Rain",
            "snow": "Snow",
            "heavy_snow": "Heavy Snow",
            "thunderstorm": "Thunderstorm",
            "unknown": "Unknown",
            "activity_level": "Activity Level",
            "perfect": "Perfect",
            "good": "Good",
            "moderate": "Moderate",
            "poor": "Poor",
            "forecast_5_days": "5-Day Forecast",
            "humidity": "Humidity",
            "wind": "Wind",
            "gps_location": "GPS",
            "ip_location": "IP",
            "refresh": "Refresh",
            "exit": "Exit",
            "loading": "Loading...",
            "location_not_found": "Location Not Found",
            "enable_gps_or_use_ip": "Enable GPS or use IP detection",
            "use_ip_detection": "Use IP detection?",
            "gps_unavailable": "GPS unavailable. Determine location by IP address?",
            "location_denied": "Location access denied",
            "no_location": "No location available",
            "error_loading": "Error loading",
            "loading_error_prefix": "Loading error",
            "ideal_for_walking": "Ideal for walking 🚶",
            "ideal_for_walking_running": "Perfect for walking 🚶 & running 🏃",
            "good_for_walking": "Good for walking 🚶",
            "light_walk": "Light walk 🚶",
            "stay_home": "Better stay home ☕",
            "ideal": "Ideal",
            "allow": "Allow",
            "deny": "Deny",
            "location_error": "Location error",
        ]
    }

    private func russianTranslations() -> [String: String] {
        [
            "app_title": "Walk Advisor",
            "updated": "Обновлено",
            "clear": "Ясно",
            "cloudy": "Облачно",
            "fog": "Туман",
            "drizzle": "Морось",
            "rain": "Дождь",
            "heavy_rain": "Сильный дождь",
            "snow": "Снег",
            "heavy_snow": "Сильный снег",
            "thunderstorm": "Гроза",
            "unknown": "Неизвестно",
            "activity_level": "Уровень активности",
            "perfect": "Идеально",
            "good": "Хорошо",
            "moderate": "Допустимо",
            "poor": "Плохо",
            "forecast_5_days": "Прогноз на 5 дней",
            "humidity": "Влажность",
            "wind": "Ветер",
            "gps_location": "GPS",
            "ip_location": "IP",
            "refresh": "Обновить",
            "exit": "Выход",
            "loading": "Загрузка...",
            "location_not_found": "Местоположение не определено",
            "enable_gps_or_use_ip": "Включите GPS или используйте IP определение",
            "use_ip_detection": "Использовать IP определение?",
            "gps_unavailable": "GPS недоступна. Определить местоположение по IP адресу?",
            "location_denied": "Доступ к геопозиции запрещен",
            "no_location": "Местоположение недоступно",
            "error_loading": "Ошибка загрузки",
            "loading_error_prefix": "Ошибка загрузки",
            "ideal_for_walking": "Идеально для прогулки 🚶",
            "ideal_for_walking_running": "Идеально для прогулки 🚶‍♂️ и бега 🏃‍♀️",
            "good_for_walking": "Хорошо для прогулки 🚶‍♂️",
            "light_walk": "Легкая прогулка 🚶‍♂️",
            "stay_home": "Лучше остаться дома ☕",
            "ideal": "Идеально",
            "allow": "Разрешить",
            "deny": "Отклонить",
            "location_error": "Ошибка геопозиции",
        ]
    }

    private func polishTranslations() -> [String: String] {
        [
            "app_title": "Walk Advisor",
            "updated": "Zaktualizowano",
            "clear": "Jasno",
            "cloudy": "Pochmurno",
            "fog": "Mgła",
            "drizzle": "Mżawka",
            "rain": "Deszcz",
            "heavy_rain": "Intensywny deszcz",
            "snow": "Śnieg",
            "heavy_snow": "Intensywny śnieg",
            "thunderstorm": "Burza",
            "unknown": "Nieznane",
            "activity_level": "Poziom aktywności",
            "perfect": "Idealnie",
            "good": "Dobrze",
            "moderate": "Umiarkowanie",
            "poor": "Słabo",
            "forecast_5_days": "Prognoza na 5 dni",
            "humidity": "Wilgotność",
            "wind": "Wiatr",
            "gps_location": "GPS",
            "ip_location": "IP",
            "refresh": "Odśwież",
            "exit": "Wyjście",
            "loading": "Ładowanie...",
            "location_not_found": "Lokalizacja nie znaleziona",
            "enable_gps_or_use_ip": "Włącz GPS lub użyj detekcji IP",
            "use_ip_detection": "Użyć detekcji IP?",
            "gps_unavailable": "GPS niedostępny. Określić lokalizację na podstawie adresu IP?",
            "location_denied": "Dostęp do lokalizacji odmówiony",
            "no_location": "Lokalizacja niedostępna",
            "error_loading": "Błąd ładowania",
            "loading_error_prefix": "Błąd ładowania",
            "ideal_for_walking": "Idealnie do spaceru 🚶",
            "ideal_for_walking_running": "Idealnie do spaceru 🚶‍♂️ i biegu 🏃‍♀️",
            "good_for_walking": "Dobrze do spaceru 🚶‍♂️",
            "light_walk": "Lekki spacer 🚶‍♂️",
            "stay_home": "Lepiej zostać w domu ☕",
            "ideal": "Idealnie",
            "allow": "Zezwól",
            "deny": "Odmów",
            "location_error": "Błąd lokalizacji",
        ]
    }

    private func belarusianTranslations() -> [String: String] {
        [
            "app_title": "Walk Advisor",
            "updated": "Абноўлена",
            "clear": "Ясна",
            "cloudy": "Хмарна",
            "fog": "Туман",
            "drizzle": "Дрібны дождь",
            "rain": "Дождь",
            "heavy_rain": "Сільны дождь",
            "snow": "Снег",
            "heavy_snow": "Сільны снег",
            "thunderstorm": "Гроза",
            "unknown": "Невядома",
            "activity_level": "Уровень актыўнасці",
            "perfect": "Ідэально",
            "good": "Добра",
            "moderate": "Умеранна",
            "poor": "Плоха",
            "forecast_5_days": "Прагноз на 5 дзён",
            "humidity": "Вільготнасць",
            "wind": "Ветар",
            "gps_location": "GPS",
            "ip_location": "IP",
            "refresh": "Абнавіць",
            "exit": "Выход",
            "loading": "Загрузка...",
            "location_not_found": "Месцазнаходжанне не знойдзена",
            "enable_gps_or_use_ip": "Ўключыце GPS або выкарыстоўвайце вызначэнне IP",
            "use_ip_detection": "Выкарыстоўваць вызначэнне IP?",
            "gps_unavailable": "GPS недаступна. Вызначыць месцазнаходжанне па IP адрасе?",
            "location_denied": "Доступ да месцазнаходжання запрешчаны",
            "no_location": "Месцазнаходжанне недаступна",
            "error_loading": "Памылка загрузкі",
            "loading_error_prefix": "Памылка загрузкі",
            "ideal_for_walking": "Ідэально для прагулкі 🚶",
            "ideal_for_walking_running": "Ідэально для прагулкі 🚶‍♂️ і біега 🏃‍♀️",
            "good_for_walking": "Добра для прагулкі 🚶‍♂️",
            "light_walk": "Лёгкая прагулка 🚶‍♂️",
            "stay_home": "Лепей быць дома ☕",
            "ideal": "Ідэально",
            "allow": "Дазволіць",
            "deny": "Адмовіць",
            "location_error": "Памылка месцазнаходжання",
        ]
    }
}
