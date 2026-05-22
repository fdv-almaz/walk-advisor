import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocationCoordinate2D?
    @Published var locationName: String = ""
    @Published var isAuthorized = false
    @Published var errorMessage: String?
    @Published var useIPLocation = false
    @Published var ipLocation: LocationData?

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

    func fetchIPLocation() async {
        do {
            let url = URL(string: "https://ipapi.co/json/")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(IPResponse.self, from: data)

            await MainActor.run {
                self.ipLocation = LocationData(
                    latitude: response.latitude,
                    longitude: response.longitude,
                    city: response.city,
                    country: response.country_name
                )
                self.locationName = "\(response.city), \(response.country_name)"
                self.useIPLocation = true
                self.savePreferences()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Ошибка определения по IP: \(error.localizedDescription)"
            }
        }
    }

    func toggleLocationSource() {
        useIPLocation.toggle()
        savePreferences()
    }

    private func savePreferences() {
        UserDefaults.standard.set(useIPLocation, forKey: "useIPLocation")
    }

    private func loadPreferences() {
        useIPLocation = UserDefaults.standard.bool(forKey: "useIPLocation")
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

struct IPResponse: Codable {
    let latitude: Double
    let longitude: Double
    let city: String
    let country_name: String
}
