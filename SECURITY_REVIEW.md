# Security & Bug Review Report

**Date:** 2026-05-22  
**Files Reviewed:** WeatherApp.swift, ContentView.swift, WeatherService.swift, LocationManager.swift, Models.swift, Localization.swift  
**Severity Levels:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## 🔴 Critical Issues

### 1. Force-Unwrapped URLs (URL Injection Risk)

**Location:** `WeatherService.swift:9`, `WeatherService.swift:20`, `LocationManager.swift:48`

```swift
// DANGEROUS - crashes if URL is malformed
let url = URL(string: "https://api.open-meteo.com/v1/forecast")!
var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
let (data, _) = try await session.data(from: components.url!)
```

**Risk:** While current URLs are hardcoded, force-unwrapping can crash the app unexpectedly.

**Fix:**
```swift
guard let url = URL(string: "https://api.open-meteo.com/v1/forecast") else {
    throw URLError(.badURL)
}
guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
    throw URLError(.badURL)
}
guard let finalURL = components.url else {
    throw URLError(.badURL)
}
let (data, _) = try await session.data(from: finalURL)
```

**Severity:** 🔴 Critical

---

### 2. GPS Location Race Condition (Blocking Loop)

**Location:** `ContentView.swift:440-446`

```swift
for _ in 0..<20 {
    if let location = locationManager.location {
        gpsLocation = location
        break
    }
    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 sec
}
```

**Risk:** 
- Inefficient polling loop blocks UI thread
- Arbitrary 2-second timeout may be insufficient for GPS lock
- Tight polling consumes battery unnecessarily
- No guarantee location is actually fresh

**Fix:** Use async/await with proper location delegate callbacks
```swift
// Better approach: have LocationManager emit location updates via publishers
// or async streams instead of polling
```

**Severity:** 🔴 Critical (Performance & Reliability)

---

### 3. No HTTP Status Code Validation

**Location:** `WeatherService.swift:20`

```swift
let (data, _) = try await session.data(from: url)  // Ignores response!
```

**Risk:** HTTP 404, 500, 429 (rate limit) responses are accepted and passed to JSON decoder, causing misleading error messages.

**Fix:**
```swift
let (data, response) = try await session.data(from: url)
guard let httpResponse = response as? HTTPURLResponse else {
    throw URLError(.badServerResponse)
}
guard (200...299).contains(httpResponse.statusCode) else {
    throw URLError(.badServerResponse)
}
```

**Severity:** 🔴 Critical (Error Handling)

---

## 🟠 High Issues

### 4. Missing Coordinate Validation

**Location:** `ContentView.swift:462-465`, `LocationManager.swift:53-62`

```swift
let data = try await WeatherService.shared.fetchWeather(
    latitude: latitude,      // No bounds check
    longitude: longitude     // No bounds check
)
```

**Risk:** Invalid coordinates (>±90° lat, >±180° lon) sent to API. API might accept malformed requests.

**Fix:**
```swift
func validateCoordinates(latitude: Double, longitude: Double) throws {
    guard (-90...90).contains(latitude) else { throw LocationError.invalidLatitude }
    guard (-180...180).contains(longitude) else { throw LocationError.invalidLongitude }
}
```

**Severity:** 🟠 High

---

### 5. No API Rate Limiting

**Location:** `ContentView.swift:378-395` (Refresh button)

**Risk:** Rapid clicking of "Refresh" button can overwhelm Open-Meteo API (public APIs usually have rate limits like 10,000 requests/day).

**Fix:**
```swift
private var lastRefreshTime: Date?
private let refreshCooldown: TimeInterval = 5  // seconds

func loadWeather() async {
    guard let lastTime = lastRefreshTime, 
          Date().timeIntervalSince(lastTime) < refreshCooldown else {
        // Proceed with refresh
        lastRefreshTime = Date()
        return
    }
    // Show "Please wait X seconds" error
}
```

**Severity:** 🟠 High

---

### 6. Hardcoded Strings Outside Localization

**Location:** `ContentView.swift:102`

```swift
Text("Walk Advisor")  // Should use localization
```

**Risk:** User sees English title even in non-English mode. Minor but breaks consistency.

**Fix:**
```swift
Text(localization.localize("app_title"))
```

**Severity:** 🟠 High (UX/i18n)

---

## 🟡 Medium Issues

### 7. Inefficient Async Handling with onReceive

**Location:** `ContentView.swift:56-69`

```swift
.onReceive(locationManager.$useIPLocation) { useIP in
    Task {
        // Complex async work here
    }
}
```

**Risk:** `onReceive` with manual `Task` is less reliable than `.onChange` or `.task`. Can miss updates or cause race conditions.

**Fix:**
```swift
.onChange(of: locationManager.useIPLocation) { oldValue, newValue in
    Task {
        await handleLocationSourceChange(newValue)
    }
}
```

Note: `onChange` is preferred in iOS 17+, but this targets macOS 12+ so may need `onReceive`. Consider using `.task` modifier instead.

**Severity:** 🟡 Medium

---

### 8. Missing Network Reachability Check

**Location:** `WeatherService.swift`, `LocationManager.swift`

**Risk:** App makes API calls without checking if device has internet connection. Users see misleading error messages instead of "No Internet".

**Fix:** Add Network framework check
```swift
import Network

let monitor = NWPathMonitor()
if monitor.currentPath.status == .unsatisfied {
    throw NetworkError.noConnection
}
```

**Severity:** 🟡 Medium

---

### 9. Potential Index Out of Bounds

**Location:** `Models.swift:40-47` (Minor)

```swift
for i in 0..<days {
    let forecast = DayForecast(
        date: daily.time[i],              // No bounds check
        maxTemp: daily.temperatureMax[i], // No bounds check
        minTemp: daily.temperatureMin[i]  // No bounds check
    )
}
```

**Risk:** If API response has mismatched array lengths, crashes with index error.

**Fix:**
```swift
guard daily.time.count >= i + 1,
      daily.temperatureMax.count >= i + 1,
      daily.temperatureMin.count >= i + 1 else {
    continue  // Skip incomplete forecast day
}
```

**Severity:** 🟡 Medium

---

### 10. GPS Permission Not Re-checked on App Resume

**Location:** `LocationManager.swift:27-37`

**Risk:** User could deny GPS in Settings after app is running. App doesn't detect this change until restart.

**Fix:**
```swift
override init() {
    super.init()
    // ... existing code ...
    
    NotificationCenter.default.addObserver(
        self,
        selector: #selector(checkAuthorization),
        name: UIApplication.willEnterForegroundNotification,
        object: nil
    )
}
```

**Severity:** 🟡 Medium

---

## 🟢 Low Issues

### 11. UserDefaults Keys Not Centralized

**Location:** `LocationManager.swift:77`, `Localization.swift:22, 29`

```swift
UserDefaults.standard.set(useIPLocation, forKey: "useIPLocation")
UserDefaults.standard.string(forKey: "selectedLanguage")
```

**Risk:** Magic strings can lead to typos. If key changes, old data is lost.

**Fix:**
```swift
enum UserDefaultsKeys {
    static let useIPLocation = "useIPLocation"
    static let selectedLanguage = "selectedLanguage"
}

// Usage:
UserDefaults.standard.set(useIPLocation, forKey: UserDefaultsKeys.useIPLocation)
```

**Severity:** 🟢 Low (Code Quality)

---

### 12. No Input Validation for JSON Decoder

**Location:** `WeatherService.swift:22`, `LocationManager.swift:51`

```swift
let decoder = JSONDecoder()
return try decoder.decode(WeatherData.self, from: data)
```

**Risk:** If API changes schema, cryptic JSONDecoder error. No helpful user message.

**Fix:**
```swift
do {
    return try decoder.decode(WeatherData.self, from: data)
} catch {
    if let decodingError = error as? DecodingError {
        throw APIError.invalidResponse("Failed to parse weather data: \(decodingError)")
    }
    throw error
}
```

**Severity:** 🟢 Low (Error Messages)

---

### 13. Weak Self Reference in Closure

**Location:** `LocationManager.swift:87`

```swift
geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
    guard let self = self else { return }  // ✅ Correct
    // ...
}
```

**Status:** ✅ Already correctly implemented with `[weak self]`

**Severity:** 🟢 (No Issue - Best Practice Already Used)

---

## Summary

| Severity | Count | Examples |
|----------|-------|----------|
| 🔴 Critical | 3 | Force-unwrapped URLs, GPS race condition, HTTP status codes |
| 🟠 High | 3 | Coordinate validation, rate limiting, hardcoded strings |
| 🟡 Medium | 4 | Async handling, network reachability, array bounds, permission re-check |
| 🟢 Low | 3 | UserDefaults keys, JSON validation, error messages |

---

## Recommended Action Plan

### Priority 1 (Fix Immediately)
1. Replace force-unwrapped URLs with proper error handling
2. Implement HTTP status code validation in `fetchWeather()`
3. Fix GPS location race condition with proper async/await

### Priority 2 (Fix in Next Release)
1. Add coordinate validation
2. Add rate limiting to refresh button
3. Fix hardcoded "Walk Advisor" string
4. Check network reachability before API calls

### Priority 3 (Nice to Have)
1. Centralize UserDefaults keys
2. Improve JSON decoder error messages
3. Re-check GPS permissions on app resume

---

## Security Posture Assessment

**Overall:** 🟡 **Medium Risk** - Functional but needs hardening

✅ **Strengths:**
- Uses HTTPS for all API calls
- Proper use of `[weak self]` in closures
- Good localization architecture
- No hardcoded secrets/API keys

❌ **Weaknesses:**
- Force-unwrapped optionals (crash vectors)
- No input validation on coordinates
- Race conditions in async handling
- Missing network error handling

**Recommendation:** Address the 3 critical issues before production use.

