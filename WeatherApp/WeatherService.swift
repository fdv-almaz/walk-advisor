import Foundation

enum WeatherServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL"
        case .invalidResponse:
            return "Invalid response from weather server"
        case .httpError(let code):
            return "Weather server error (\(code))"
        case .decodingError(let details):
            return "Failed to parse weather data: \(details)"
        }
    }
}

class WeatherService {
    static let shared = WeatherService()

    private let session = URLSession.shared

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast") else {
            throw WeatherServiceError.invalidURL
        }

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw WeatherServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        guard let finalURL = components.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: finalURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherData.self, from: data)
        } catch let decodingError as DecodingError {
            throw WeatherServiceError.decodingError(decodingError.localizedDescription)
        }
    }

    func getActivityScore(
        temperature: Double,
        humidity: Int,
        windSpeed: Double,
        weatherCode: Int
    ) -> ActivityScore {
        ActivityScore(temperature: temperature, humidity: humidity, windSpeed: windSpeed, weatherCode: weatherCode)
    }

    func getForecastDays(from dailyForecast: DailyForecast?) -> [DayForecast] {
        guard let daily = dailyForecast else { return [] }

        let days = min(5, daily.time.count)
        var forecasts: [DayForecast] = []

        for i in 0..<days {
            guard i < daily.temperatureMax.count,
                  i < daily.temperatureMin.count,
                  i < daily.weatherCode.count else {
                continue
            }

            let forecast = DayForecast(
                date: daily.time[i],
                maxTemp: daily.temperatureMax[i],
                minTemp: daily.temperatureMin[i],
                weatherCode: daily.weatherCode[i]
            )
            forecasts.append(forecast)
        }

        return forecasts
    }
}
