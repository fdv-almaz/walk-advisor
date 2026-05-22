# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Quick Start

### System Requirements for Building

Before building, ensure you have:
- **macOS 12.0+** (Monterey or later)
- **Swift 5.5+** with async/await support (use Xcode Command Line Tools)
- **Internet connection** for weather API calls

Verify Swift installation:
```bash
swift --version  # Should show 5.5 or later
```

### Building the App

**Standard build (current architecture):**
```bash
cd WeatherApp
./build.sh
open build/Walk\ Advisor.app
```

**Universal build (both Intel and Apple Silicon separately):**
```bash
cd WeatherApp
./build_universal.sh
open build
```

The `build.sh` script:
- Detects system architecture (Intel/Apple Silicon) automatically via `uname -m`
- Compiles Swift files with swiftc (targets macOS 12+)
- Creates proper macOS .app bundle structure with Contents/MacOS, Contents/Resources
- Copies Info.plist and app icon from Icons/AppIcon_512.icns
- Uses `-O` optimization flag for release build
- Outputs to `build/Walk Advisor.app`

The `build_universal.sh` script:
- Builds both arm64 (Apple Silicon) and x86_64 (Intel) versions
- Outputs to `build/Walk Advisor.arm64.app` and `build/Walk Advisor.x86_64.app`
- Useful for testing cross-architecture compatibility

### Project Structure

```
walk-advisor/
├── WeatherApp/              ← Main macOS Swift app (production)
│   ├── *.swift             ← 6 Swift source files
│   ├── build.sh            ← Compilation script
│   ├── Info.plist          ← App metadata
│   ├── Icons/              ← App icon files (.icns)
│   └── build/              ← Compiled .app bundle
│
├── walk_advisor.py         ← Python CLI version (legacy)
├── activate.sh             ← Python venv setup (legacy)
└── [documentation files]   ← Multiple guides and README files
```

## Architecture Overview

### Core Components

**WeatherApp.swift** (entry point)
- SwiftUI @main app definition
- Sets up WindowGroup with ContentView
- Configures window frame (400x700px) and styling

**ContentView.swift** (UI layer)
- Main UI layout using SwiftUI
- Displays current weather, activity score, and 5-day forecast
- ScrollView for responsive content handling
- Handles GPS/IP toggle button and About button
- Color-coded activity recommendations (green/blue/orange/red)

**AboutView.swift** (information dialog)
- About application dialog
- Displays app version, build number, and developer info
- Shows API server information (Open-Meteo, ipapi.co)
- Lists application features
- License information (MIT)

**Models.swift** (data layer)
- `WeatherData`, `CurrentWeather`, `DailyForecast` - Codable structs for Open-Meteo API JSON
- `WeatherCondition` enum - Maps WMO weather codes (0-99) to readable conditions
- `ActivityScore` class - Calculates activity recommendation (0-100%) based on:
  - Temperature (40% weight): ideal 15-25°C
  - Weather condition (40% weight): clear > cloudy > rain > thunderstorm
  - Wind speed (20% weight): max ~15 km/h optimal
- `DayForecast`, `LocationData` - Supporting data structures

**LocationManager.swift** (geolocation)
- CLLocationManagerDelegate for GPS handling
- GPS + IP fallback architecture:
  - Tries GPS first (if authorized)
  - Falls back to ipapi.co if GPS denied or unavailable
  - Remembers user's preference in UserDefaults
- CLGeocoder for reverse geocoding (coordinates → city name)
- `IPResponse` struct for ipapi.co JSON parsing

**WeatherService.swift** (API integration)
- Fetches weather from Open-Meteo API (free, no key needed)
- URL parameters: latitude, longitude, current conditions, daily forecast
- Handles JSON decoding and error cases

**Localization.swift** (i18n)
- LocalizationManager singleton
- Supports 4 languages: English (en), Russian (ru), Polish (pl), Belarusian (be)
- Language preference stored in UserDefaults with key "selectedLanguage"
- Keys for all UI strings (weather conditions, button labels, descriptions)

### Data Flow

1. **App Launch** → LocationManager requests GPS → If denied, user can switch to IP mode
2. **Location Obtained** → WeatherService fetches Open-Meteo API
3. **Data Arrives** → Models decode JSON → ActivityScore calculates recommendation
4. **Render** → ContentView displays using SwiftUI bindings

### Weather Code Mapping

WMO codes (Open-Meteo) map to emoji and color:
- 0 = Clear (☀️) → 100% activity score
- 1-3 = Cloudy (☁️) → 90%
- 45, 48 = Fog (🌫️) → 60%
- 61, 63 = Rain (🌧️) → 30%
- 65 = Heavy Rain (⛈️) → 10%
- 95-99 = Thunderstorm (⚡) → 5%

## Development Guidelines

### Modifying the UI
- Edit `ContentView.swift` for layout/colors/fonts
- All strings should use `localization.localize("key")` not hardcoded text
- Colors: green (≥80%), blue (60-79%), orange (40-59%), red (<40%)
- Window size in `WeatherApp.swift`: 400x700 default

### Adding Localization
1. Add new key to all 4 language dicts in `Localization.swift` (en, ru, pl, be)
2. Use `LocalizationManager.shared.localize("key")` in code
3. User's language preference is remembered in UserDefaults, defaulting to "ru"

### Testing Location Changes
```swift
// In LocationManager, can simulate coordinates:
self.location = CLLocationCoordinate2D(latitude: 55.75, longitude: 37.62)  // Moscow
```

### Changing Weather API
- Currently uses Open-Meteo (free, no auth)
- To switch APIs: modify `WeatherService.swift` URL and JSON decoding
- Must maintain `WeatherData` struct or refactor all consumers

### Activity Score Algorithm
Located in `Models.swift` ActivityScore.init():
- Temperature score: 100% for 15-25°C, scales outside range
- Condition score: lookup from enum switch
- Wind score: 100% for <15 km/h, degrades above
- Final: 40% temp + 40% condition + 20% wind

Adjust weights or thresholds here if recommendation feels off.

## Common Tasks

### Run the App
```bash
cd WeatherApp && ./build.sh && open build/Walk\ Advisor.app
```

### Rebuild After Code Changes
```bash
cd WeatherApp && ./build.sh && open build/Walk\ Advisor.app
```

### Test on Both Architectures
```bash
cd WeatherApp && ./build_universal.sh
# Then test both: open build/Walk\ Advisor.arm64.app and open build/Walk\ Advisor.x86_64.app
```

### Check Permissions (if GPS not working)
```bash
tccutil grant location /Applications/Xcode.app
```

### Modify Info.plist
- App name: `CFBundleName` or `CFBundleDisplayName`
- Version: `CFBundleShortVersionString`
- Min macOS: `LSMinimumSystemVersion`

### Create New Build Architecture
The build.sh detects arm64 (Apple Silicon) vs x86_64 (Intel) automatically.
- For universal binary: compile separately with both ARCH_FLAGS and lipo together

## Icon Management

To update the app icon:
```bash
cd WeatherApp
./create_icon.sh /path/to/source/image.png
```

This script converts a PNG image to macOS `.icns` format and places it in `Icons/AppIcon_512.icns`. The build script automatically includes this icon in the app bundle. For best results, use a square image (512x512 or larger).

## Troubleshooting

### Build Issues

**"swift: command not found"**
```bash
xcode-select --install  # Install Command Line Tools
```

**"Cannot find Swift compiler"**
```bash
# Verify Swift is available
swift --version

# If not, reinstall Xcode Command Line Tools
xcode-select --install
rm -rf build/
./build.sh
```

### Runtime Issues

**"GPS permission denied" or geolocation not working**
```bash
# Grant location permission to terminal/app running the build
tccutil grant location /Applications/Xcode.app

# Or manually:
# System Settings → Privacy & Security → Location Services → enable Terminal/Xcode
```

**"Weather data not loading" / "API error"**
- Verify internet connection is active
- Check if https://api.open-meteo.com is accessible
- Try toggling between GPS and IP geolocation modes
- Restart the app

**"App crashes on launch"**
- Ensure macOS 12.0 or later is running
- Clean build: `rm -rf build/` then `./build.sh`
- Check Console.app for detailed error messages

**"Location shows wrong coordinates"**
- IP geolocation is approximate (city-level accuracy)
- Ensure GPS permission is granted (Settings → Privacy & Security → Location Services)
- Wait 5-10 seconds for GPS to acquire lock on first run

## Key Files Reference

| File | Purpose | Key Classes |
|------|---------|-------------|
| WeatherApp.swift | Entry point | `WeatherApp` (SwiftUI App) |
| ContentView.swift | Main UI | `ContentView` (SwiftUI View) |
| Models.swift | Data structures | `WeatherData`, `ActivityScore`, `WeatherCondition` |
| LocationManager.swift | Geolocation | `LocationManager` (ObservableObject) |
| WeatherService.swift | API calls | Weather data fetching |
| Localization.swift | i18n | `LocalizationManager` singleton |

## Important Notes

- **No external dependencies**: Uses only Swift stdlib + system frameworks
  - Framework dependencies: SwiftUI, CoreLocation, AppKit, Foundation
- **Architecture support**: Auto-detects Intel vs Apple Silicon via `uname -m`
- **API key needed**: None - Open-Meteo is free
- **macOS version**: Targets macOS 12+ (Monterey)
- **Location permission**: Prompts user on first run, remembers choice
- **Background updates**: Manual only - app doesn't run as daemon or widget
- **Languages supported**: English, Russian, Polish, Belarusian (4 total)
- **Swift version**: Swift 5.5+ required (uses async/await syntax)
- **Testing**: Manual testing only - no automated test suite
- **App version**: 2.0.2 (defined in Info.plist CFBundleShortVersionString)
- **Last verified**: 2026-05-22 - With About dialog, all tests passed

## Recent Fixes (v2.0.1)

- Fixed locale hardcoding in date formatting (now respects selected language)
- Fixed IP geolocation not loading when toggled from GPS
- Fixed incorrect localization label in activity score display
- Ensured macOS 12.0 compatibility with `onReceive` instead of newer `onChange` syntax

## Additional Documentation

For more detailed information, refer to these files in the project:

- **[WeatherApp/DEVELOPMENT.md](WeatherApp/DEVELOPMENT.md)** — Detailed development guide with component breakdown
- **[WeatherApp/LOCALIZATION_GUIDE.md](WeatherApp/LOCALIZATION_GUIDE.md)** — Instructions for adding new languages
- **[WeatherApp/CHANGELOG.md](WeatherApp/CHANGELOG.md)** — Complete version history
- **[WeatherApp/README.md](WeatherApp/README.md)** — Comprehensive project overview
- **[START_HERE.md](START_HERE.md)** — Quick start guide in Russian (for users)
- **[WeatherApp/QUICKSTART.md](WeatherApp/QUICKSTART.md)** — Fast setup instructions
