import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var locationName: String = ""
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    @Published var useIPLocation = false
    @Published var ipLocation: LocationData?
    @Published var isWaitingForLocation = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest

        loadPreferences()
        checkAuthorization()
        if isAuthorized {
            requestLocation()
        }
    }

    func checkAuthorization() {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    func requestLocation() {
        if isAuthorized {
            manager.requestLocation()
        }
    }

    func waitForLocation(timeout: TimeInterval = 10) async throws -> CLLocationCoordinate2D {
        if let currentLocation = location {
            return currentLocation
        }

        isWaitingForLocation = true
        defer { isWaitingForLocation = false }

        manager.requestLocation()

        let startTime = Date()
        while Date().timeIntervalSince(startTime) < timeout {
            if let currentLocation = location {
                return currentLocation
            }
            try await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
        }

        throw LocationError.timeout
    }

    func fetchIPLocation() async {
        do {
            guard let url = URL(string: "http://ip-api.com/json") else {
                await MainActor.run {
                    self.errorMessage = "Invalid URL"
                }
                return
            }

            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode < 200 || httpResponse.statusCode >= 300 {
                    await MainActor.run {
                        self.errorMessage = "IP API error: \(httpResponse.statusCode)"
                    }
                    return
                }
            }

            let decoder = JSONDecoder()
            let ipResponse = try decoder.decode(IPApiResponse.self, from: data)

            guard ipResponse.status == "success" else {
                await MainActor.run {
                    self.errorMessage = "Failed to get location from IP"
                }
                return
            }

            // Validate coordinates from IP API
            guard (-90...90).contains(ipResponse.lat),
                  (-180...180).contains(ipResponse.lon) else {
                await MainActor.run {
                    self.errorMessage = "Invalid coordinates from IP API"
                }
                return
            }

            let newLocation = LocationData(
                latitude: ipResponse.lat,
                longitude: ipResponse.lon,
                city: ipResponse.city,
                country: ipResponse.country
            )

            await MainActor.run {
                self.ipLocation = newLocation
                self.locationName = "\(ipResponse.city), \(ipResponse.country)"
                self.useIPLocation = true
                self.savePreferences()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "IP error: \(error.localizedDescription)"
            }
        }
    }

    func toggleLocationSource() {
        useIPLocation.toggle()
        savePreferences()
    }

    private func savePreferences() {
        UserDefaults.standard.set(useIPLocation, forKey: UserDefaultsKeys.useIPLocation)
    }

    private func loadPreferences() {
        useIPLocation = UserDefaults.standard.bool(forKey: UserDefaultsKeys.useIPLocation)
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            if let placemark = placemarks?.first {
                let city = placemark.locality ?? placemark.name ?? "Unknown"
                let country = placemark.country ?? "Unknown"
                DispatchQueue.main.async {
                    self.locationName = "\(city), \(country)"
                }
            } else if error == nil {
                DispatchQueue.main.async {
                    self.locationName = String(format: "%.2f, %.2f", coordinate.latitude, coordinate.longitude)
                }
            }
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !useIPLocation, let coordinate = locations.last?.coordinate {
            location = coordinate
            reverseGeocode(coordinate: coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Ошибка геопозиции: \(error.localizedDescription)"
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorization()
        if isAuthorized {
            requestLocation()
        }
    }
}

struct IPApiResponse: Codable {
    let status: String
    let city: String
    let country: String
    let lat: Double
    let lon: Double
}

enum LocationError: LocalizedError {
    case timeout
    case invalidCoordinates
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .timeout:
            return "GPS timeout: location acquisition took too long"
        case .invalidCoordinates:
            return "Invalid location coordinates"
        case .permissionDenied:
            return "Location permission denied"
        }
    }
}
