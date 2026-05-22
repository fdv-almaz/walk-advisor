import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var localization = LocalizationManager.shared
    @State private var weather: WeatherData?
    @State private var score: ActivityScore?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var lastUpdate: Date?
    @State private var showIPPrompt = false
    @State private var forecastDays: [DayForecast] = []
    @State private var showLanguageMenu = false
    @State private var lastRefreshTime: Date?
    @State private var showAbout = false

    private let refreshCooldown: TimeInterval = 3  // seconds
    private let appVersion = "2.0.2"
    private let appBuild = "1"

    var body: some View {
        ZStack {
            backgroundGradient

            VStack(spacing: 0) {
                // Шапка с названием и локацией
                headerView
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)

                // Основной контент
                ScrollView {
                    VStack(spacing: 20) {
                        if isLoading {
                            loadingView
                        } else if let weather = weather, let score = score {
                            currentWeatherView(weather: weather, score: score)
                            scoreView(score: score)
                            forecastView()

                            Spacer(minLength: 20)
                        } else {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }

                Spacer(minLength: 0)

                // Переключатель и кнопки
                controlsView
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
            }
        }
        .task {
            await loadWeather()
        }
        .onReceive(locationManager.$useIPLocation) { useIP in
            Task {
                if useIP {
                    // Только загружаем если еще не загружена
                    if locationManager.ipLocation == nil {
                        await locationManager.fetchIPLocation()
                    }
                } else if locationManager.isAuthorized {
                    locationManager.requestLocation()
                }
                await loadWeather()
            }
        }
        .alert(localization.localize("use_ip_detection"), isPresented: $showIPPrompt) {
            Button(localization.localize("allow")) {
                Task {
                    await locationManager.fetchIPLocation()
                    // Дайте MainActor время на обновление
                    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 сек
                    await loadWeather()
                }
            }
            Button(localization.localize("deny"), role: .cancel) {}
        } message: {
            Text(localization.localize("gps_unavailable"))
        }
        .sheet(isPresented: $showAbout) {
            AboutView(isPresented: $showAbout, appVersion: appVersion, appBuild: appBuild)
        }
    }

    // MARK: - Views

    var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.135, green: 0.506, blue: 0.969),
                Color(red: 0.198, green: 0.631, blue: 0.973)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(localization.localize("app_title"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        if !locationManager.locationName.isEmpty {
                            Text(locationManager.locationName)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    Button(action: { showLanguageMenu.toggle() }) {
                        Image(systemName: "globe")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(6)
                    }
                }

                if let lastUpdate = lastUpdate {
                    Text("\(localization.localize("updated")): \(formatTime(lastUpdate))")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if showLanguageMenu {
                Divider()
                    .padding(.vertical, 8)

                VStack(spacing: 6) {
                    ForEach(Language.allCases, id: \.rawValue) { lang in
                        Button(action: {
                            localization.currentLanguage = lang
                            showLanguageMenu = false
                        }) {
                            HStack {
                                Text(lang.displayName)
                                    .foregroundColor(.white)

                                if localization.currentLanguage == lang {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(localization.currentLanguage == lang ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(6)
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.5)

            Text(localization.localize("loading"))
                .foregroundColor(.white)
                .font(.subheadline)
        }
        .frame(height: 200)
    }

    func currentWeatherView(weather: WeatherData, score: ActivityScore) -> some View {
        VStack(spacing: 16) {
            let condition = WeatherCondition.from(code: weather.current.weatherCode)

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text(condition.emoji)
                        .font(.system(size: 48))

                    Text(condition.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 4) {
                        Text("\(Int(weather.current.temperature))°")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)

                        Text("C")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 4)
                    }

                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(weather.current.humidity)%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }

                        VStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(Int(weather.current.windSpeed))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
    }

    func scoreView(score: ActivityScore) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(localization.localize("activity_level"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()

                Text("\(Int(score.score))%")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))

                        RoundedRectangle(cornerRadius: 4)
                            .fill(score.color)
                            .frame(width: geometry.size.width * (score.score / 100))
                    }
                }
                .frame(height: 8)

                HStack {
                    Text(score.description)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Circle()
                        .fill(score.color)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }

    func forecastView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localize("forecast_5_days"))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            VStack(spacing: 8) {
                ForEach(Array(forecastDays.enumerated()), id: \.offset) { _, day in
                    HStack(spacing: 12) {
                        Text(formatDate(day.date))
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 50, alignment: .leading)

                        Text(day.condition.emoji)
                            .font(.system(size: 16))

                        Text(day.condition.rawValue)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: 8) {
                            Text("\(Int(day.maxTemp))°")
                                .font(.caption)
                                .foregroundColor(.white)

                            Text("\(Int(day.minTemp))°")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.15))
        .cornerRadius(12)
    }

    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.5))

            VStack(spacing: 8) {
                Text(localization.localize("location_not_found"))
                    .font(.headline)
                    .foregroundColor(.white)

                Text(localization.localize("enable_gps_or_use_ip"))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }

            if let error = errorMessage ?? locationManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
    }

    var controlsView: some View {
        VStack(spacing: 12) {
            // Переключатель GPS/IP
            HStack(spacing: 12) {
                Image(systemName: locationManager.useIPLocation ? "globe" : "location.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))

                Text(locationManager.useIPLocation ? localization.localize("ip_location") : localization.localize("gps_location"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { locationManager.useIPLocation },
                    set: { _ in locationManager.toggleLocationSource() }
                ))
                .tint(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.2))
            .cornerRadius(8)

            // Кнопки действия
            HStack(spacing: 10) {
                Button(action: {
                    if canRefresh() {
                        Task {
                            await loadWeather()
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLoading ? "arrow.clockwise.circle.fill" : "arrow.clockwise")
                            .rotationEffect(.degrees(isLoading ? 360 : 0))
                            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isLoading)
                        Text(localization.localize("refresh"))
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(isLoading || !canRefresh() ? 0.3 : 0.2))
                    .cornerRadius(6)
                }
                .disabled(isLoading || !canRefresh())
                .help(canRefresh() ? "" : "Please wait before refreshing again")

                Button(action: { showAbout = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(6)
                }

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                        Text(localization.localize("exit"))
                    }
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(6)
                }
            }
        }
    }

    // MARK: - Helpers

    private func loadWeather() async {
        isLoading = true
        defer { isLoading = false }

        var latitude: Double
        var longitude: Double

        if locationManager.useIPLocation {
            // IP режим - убедимся что координаты загружены
            let result = await ensureIPLocation()
            guard result else {
                errorMessage = locationManager.errorMessage ?? localization.localize("no_location")
                return
            }

            guard let ipLoc = locationManager.ipLocation else {
                errorMessage = localization.localize("no_location")
                return
            }
            latitude = ipLoc.latitude
            longitude = ipLoc.longitude
        } else {
            // GPS режим
            if locationManager.isAuthorized {
                do {
                    let location = try await locationManager.waitForLocation(timeout: 10)
                    latitude = location.latitude
                    longitude = location.longitude
                } catch {
                    errorMessage = "GPS Error: \(error.localizedDescription)"
                    return
                }
            } else {
                showIPPrompt = true
                return
            }
        }

        do {
            try validateCoordinates(latitude: latitude, longitude: longitude)

            let data = try await WeatherService.shared.fetchWeather(
                latitude: latitude,
                longitude: longitude
            )
            self.weather = data

            let score = WeatherService.shared.getActivityScore(
                temperature: data.current.temperature,
                humidity: data.current.humidity,
                windSpeed: data.current.windSpeed,
                weatherCode: data.current.weatherCode
            )
            self.score = score

            self.forecastDays = WeatherService.shared.getForecastDays(from: data.daily)
            self.lastUpdate = Date()
            self.errorMessage = nil

            // Обновляем время последнего успешного обновления только если успешно
            lastRefreshTime = Date()
        } catch {
            let errorDesc = truncateErrorMessage(error.localizedDescription)
            self.errorMessage = "\(localization.localize("error_loading")): \(errorDesc)"
        }
    }

    private func validateCoordinates(latitude: Double, longitude: Double) throws {
        guard (-90...90).contains(latitude) else {
            throw LocationError.invalidCoordinates
        }
        guard (-180...180).contains(longitude) else {
            throw LocationError.invalidCoordinates
        }
    }

    private func canRefresh() -> Bool {
        if let lastTime = lastRefreshTime {
            return Date().timeIntervalSince(lastTime) >= refreshCooldown
        }
        return true
    }

    private func truncateErrorMessage(_ message: String, maxLength: Int = 100) -> String {
        if message.count > maxLength {
            return String(message.prefix(maxLength)) + "..."
        }
        return message
    }

    private func ensureIPLocation() async -> Bool {
        // Если уже есть ipLocation, используем её
        if locationManager.ipLocation != nil {
            return true
        }

        // Иначе загружаем
        await locationManager.fetchIPLocation()

        // Даем время на обновление @Published свойства
        try? await Task.sleep(nanoseconds: 200_000_000)  // 0.2 сек

        // Проверяем что загрузилось
        return locationManager.ipLocation != nil
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "EEE, d MMM"
            let localeId = localization.currentLanguage == .english ? "en_US" :
                          localization.currentLanguage == .polish ? "pl_PL" :
                          localization.currentLanguage == .belarusian ? "be_BY" : "ru_RU"
            formatter.locale = Locale(identifier: localeId)
            return formatter.string(from: date)
        }

        return dateString
    }
}
