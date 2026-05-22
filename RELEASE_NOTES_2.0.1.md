# 🏃 Walk Advisor v2.0.1 — Release Notes

**Release Date:** May 22, 2026

## ✨ What's New

### 🎨 New App Icon
- Beautiful new icon featuring a jogger silhouette on green background
- Professional appearance matching modern macOS design standards

### 📦 Distribution Packages

#### DMG Installer (Universal)
- **File:** `WalkAdvisor_2.0.1.dmg` (2.6 MB)
- **Contents:** Both Apple Silicon and Intel versions
- **Best for:** General users, includes both architectures
- **Installation:** Drag and drop to Applications folder

#### PKG Installers (Architecture-specific)
- **arm64 Version:** `WalkAdvisor_2.0.1_arm64.pkg` (1.2 MB)
  - For: Apple Silicon Mac (M1, M2, M3+)
  - Installation method: Double-click to install via macOS Installer
  
- **x86_64 Version:** `WalkAdvisor_2.0.1_x86_64.pkg` (1.2 MB)
  - For: Intel Mac
  - Installation method: Double-click to install via macOS Installer

#### Direct App Bundles
- Located in: `build/Walk Advisor.arm64.app` and `build/Walk Advisor.x86_64.app`
- Direct execution without installation

## 🔧 System Requirements

- **macOS:** 12.0 (Monterey) or later
- **Architecture:** Apple Silicon or Intel
- **RAM:** Minimal (typical usage ~50 MB)
- **Internet:** Required for weather data and IP geolocation

## 🌍 Supported Languages

- 🇬🇧 English
- 🇷🇺 Русский (Russian)
- 🇵🇱 Polski (Polish)
- 🇧🇾 Беларускі (Belarusian)

## ✅ Installation Methods

### Method 1: DMG (Recommended for most users)
```bash
# Double-click WalkAdvisor_2.0.1.dmg in Finder
# Drag app to Applications folder
# Done!
```

### Method 2: PKG (Automatic installation)
```bash
# Double-click WalkAdvisor_2.0.1_arm64.pkg (or x86_64)
# Follow the installer wizard
# App will be installed to /Applications
```

### Method 3: Direct App Bundle
```bash
# Copy Walk Advisor.app to Applications folder
# Or run directly from any location
open "Walk Advisor.arm64.app"
```

## 📋 Features

- ☀️ Real-time weather data from Open-Meteo API
- 🎯 Activity score (0-100%) based on:
  - Temperature (40% weight)
  - Weather conditions (40% weight)
  - Wind speed (20% weight)
- 🗺️ Dual location: GPS + IP geolocation fallback
- 📊 5-day weather forecast
- 🎨 Color-coded activity recommendations (Green/Blue/Orange/Red)
- 🌐 Multi-language support (4 languages)
- 🚀 Zero external dependencies
- ⚡ Lightweight (< 5 MB)

## 🐛 Known Issues

None at this time.

## 📖 Documentation

- **CLAUDE.md** — Developer guide for contributors
- **README.md** — User-facing documentation
- **CHANGELOG.md** — Full version history
- **DEVELOPMENT.md** — Development setup guide

## 📞 Support

For issues, questions, or feature requests, please check the project repository.

---

**Built with:** Swift 5.5+, SwiftUI, CoreLocation
**Distribution:** macOS 12.0+
**Version Control:** Git
**License:** See LICENSE file (if included)
