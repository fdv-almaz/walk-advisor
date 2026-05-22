import Foundation

class WeatherService {
    static let shared = WeatherService()

    private let session = URLSession.shared

    func fetchWeather(latitude: Double, longitude: Double) async throws -> WeatherData {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]

        let (data, _) = try await session.data(from: components.url!)
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherData.self, from: data)
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
