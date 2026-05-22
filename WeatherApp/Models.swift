import Foundation
import CoreLocation
import SwiftUI

struct WeatherData: Codable {
    let current: CurrentWeather
    let currentUnits: CurrentUnits
    let daily: DailyForecast?

    enum CodingKeys: String, CodingKey {
        case current
        case currentUnits = "current_units"
        case daily
    }
}

struct CurrentWeather: Codable {
    let time: String
    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temperature_2m"
        case humidity = "relative_humidity_2m"
        case windSpeed = "wind_speed_10m"
        case weatherCode = "weather_code"
    }
}

struct CurrentUnits: Codable {
    let temperature: String
    let windSpeed: String

    enum CodingKeys: String, CodingKey {
        case temperature = "temperature_2m"
        case windSpeed = "wind_speed_10m"
    }
}

struct DailyForecast: Codable {
    let time: [String]
    let weatherCode: [Int]
    let temperatureMax: [Double]
    let temperatureMin: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperatureMax = "temperature_2m_max"
        case temperatureMin = "temperature_2m_min"
    }
}

struct DayForecast {
    let date: String
    let maxTemp: Double
    let minTemp: Double
    let weatherCode: Int

    var condition: WeatherCondition {
        WeatherCondition.from(code: weatherCode)
    }
}

struct LocationData {
    let latitude: Double
    let longitude: Double
    let city: String?
    let country: String?
}

class ActivityScore {
    let score: Double
    let localization = LocalizationManager.shared

    init(temperature: Double, humidity: Int, windSpeed: Double, weatherCode: Int) {
        let condition = WeatherCondition.from(code: weatherCode)

        var tempScore = 0.0
        if temperature >= 15 && temperature <= 25 {
            tempScore = 100
        } else if temperature >= 10 && temperature <= 30 {
            tempScore = 80
        } else if temperature >= 5 && temperature <= 35 {
            tempScore = 50
        } else {
            tempScore = 20
        }

        var conditionScore = 0.0
        switch condition {
        case .clear:
            conditionScore = 100
        case .cloudy:
            conditionScore = 90
        case .fog, .drizzle:
            conditionScore = 60
        case .rain:
            conditionScore = 30
        case .heavyRain:
            conditionScore = 10
        case .snow, .heavySnow:
            conditionScore = 40
        case .thunderstorm:
            conditionScore = 5
        case .unknown:
            conditionScore = 50
        }

        var windScore = 100.0
        if windSpeed > 30 {
            windScore = 20
        } else if windSpeed > 20 {
            windScore = 50
        } else if windSpeed > 15 {
            windScore = 80
        }

        self.score = (tempScore * 0.4 + conditionScore * 0.4 + windScore * 0.2)
    }

    var color: Color {
        if score >= 80 {
            return Color.green
        } else if score >= 60 {
            return Color.blue
        } else if score >= 40 {
            return Color.orange
        } else {
            return Color.red
        }
    }

    var description: String {
        let localization = LocalizationManager.shared
        if score >= 80 {
            return localization.localize("ideal")
        } else if score >= 60 {
            return localization.localize("good")
        } else if score >= 40 {
            return localization.localize("moderate")
        } else {
            return localization.localize("poor")
        }
    }
}

enum WeatherCondition {
    case clear
    case cloudy
    case fog
    case drizzle
    case rain
    case heavyRain
    case snow
    case heavySnow
    case thunderstorm
    case unknown

    var rawValue: String {
        let localization = LocalizationManager.shared
        switch self {
        case .clear: return localization.localize("clear")
        case .cloudy: return localization.localize("cloudy")
        case .fog: return localization.localize("fog")
        case .drizzle: return localization.localize("drizzle")
        case .rain: return localization.localize("rain")
        case .heavyRain: return localization.localize("heavy_rain")
        case .snow: return localization.localize("snow")
        case .heavySnow: return localization.localize("heavy_snow")
        case .thunderstorm: return localization.localize("thunderstorm")
        case .unknown: return localization.localize("unknown")
        }
    }

    static func from(code: Int) -> WeatherCondition {
        switch code {
        case 0: return .clear
        case 1, 2, 3: return .cloudy
        case 45, 48: return .fog
        case 51, 53: return .drizzle
        case 55: return .drizzle
        case 61, 63: return .rain
        case 65: return .heavyRain
        case 71, 73: return .snow
        case 75: return .heavySnow
        case 80, 81, 82: return .rain
        case 95, 96, 99: return .thunderstorm
        default: return .unknown
        }
    }

    var emoji: String {
        switch self {
        case .clear: return "☀️"
        case .cloudy: return "☁️"
        case .fog: return "🌫️"
        case .drizzle: return "🌦️"
        case .rain: return "🌧️"
        case .heavyRain: return "⛈️"
        case .snow: return "❄️"
        case .heavySnow: return "❄️❄️"
        case .thunderstorm: return "⚡"
        case .unknown: return "🤔"
        }
    }
}
