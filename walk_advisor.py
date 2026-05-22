#!/usr/bin/env python3
"""
Простая программа для проверки геопозиции и получения погоды
Использует GPS координаты из macOS CoreLocation
"""

import requests
import json
from datetime import datetime

try:
    from objc import nil
    from CoreLocation import CLLocationManager
    CORELOCATION_AVAILABLE = True
except ImportError:
    CORELOCATION_AVAILABLE = False


def get_gps_location():
    """Получить GPS координаты из macOS CoreLocation"""
    if not CORELOCATION_AVAILABLE:
        return None

    try:
        manager = CLLocationManager.new()

        # Проверить статус разрешений
        if manager.authorizationStatus() == 0:  # kCLAuthorizationStatusNotDetermined
            print("⚠️  Требуется разрешение на доступ к геопозиции")
            print("Откройте Параметры > Приватность и безопасность > Службы геопозиции")
            print("и разрешите доступ для терминала/Python")
            return None

        if manager.authorizationStatus() == 3:  # kCLAuthorizationStatusDenied
            print("❌ Доступ к геопозиции запрещен")
            return None

        # Получить последнее известное местоположение
        location = manager.location()
        if location is not nil:
            coord = location.coordinate()
            return {
                'latitude': float(coord.latitude),
                'longitude': float(coord.longitude),
                'source': 'GPS (macOS)'
            }
    except Exception as e:
        print(f"Ошибка при получении GPS координат: {e}")

    return None


def get_location_by_ip():
    """Получить геопозицию по IP-адресу (резервный вариант)"""
    try:
        response = requests.get('https://ipapi.co/json/', timeout=5)
        response.raise_for_status()
        data = response.json()
        return {
            'latitude': data.get('latitude'),
            'longitude': data.get('longitude'),
            'city': data.get('city'),
            'country': data.get('country_name'),
            'timezone': data.get('timezone'),
            'source': 'IP-адрес'
        }
    except requests.RequestException as e:
        print(f"Ошибка при получении геопозиции по IP: {e}")
        return None


def get_location():
    """Получить текущую геопозицию: сначала GPS, потом IP"""
    # Сначала пытаемся получить GPS координаты
    location = get_gps_location()
    if location:
        return location

    # Если GPS не доступен, используем IP-адрес
    print("📡 GPS не доступен, используем определение по IP-адресу...")
    return get_location_by_ip()


def get_weather(latitude, longitude):
    """Получить погоду по координатам"""
    try:
        url = 'https://api.open-meteo.com/v1/forecast'
        params = {
            'latitude': latitude,
            'longitude': longitude,
            'current': 'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
            'timezone': 'auto'
        }
        response = requests.get(url, params=params, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Ошибка при получении погоды: {e}")
        return None


def decode_weather_code(code):
    """Расшифровать код погоды"""
    weather_codes = {
        0: "Ясно",
        1: "Облачно",
        2: "Облачно",
        3: "Облачно",
        45: "Туман",
        48: "Туман",
        51: "Морось",
        53: "Морось",
        55: "Сильная морось",
        61: "Дождь",
        63: "Дождь",
        65: "Сильный дождь",
        71: "Снег",
        73: "Снег",
        75: "Сильный снег",
        80: "Ливень",
        81: "Сильный ливень",
        82: "Очень сильный ливень",
        95: "Гроза",
        96: "Гроза со снегом",
        99: "Гроза со снегом"
    }
    return weather_codes.get(code, "Неизвестно")


def main():
    print("=" * 50)
    print("Определение геопозиции и погоды")
    print("=" * 50)
    print()

    # Получить геопозицию
    print("📍 Получение геопозиции...")
    location = get_location()

    if not location:
        print("Не удалось определить геопозицию")
        return

    print(f"✓ Местоположение: {location['city']}, {location['country']}")
    print(f"  Координаты: {location['latitude']:.2f}°, {location['longitude']:.2f}°")
    print(f"  Временная зона: {location['timezone']}")
    print()

    # Получить погоду
    print("🌤️  Получение данных о погоде...")
    weather = get_weather(location['latitude'], location['longitude'])

    if not weather:
        print("Не удалось получить данные о погоде")
        return

    current = weather['current']
    time = current['time']
    temperature = current['temperature_2m']
    humidity = current['relative_humidity_2m']
    wind_speed = current['wind_speed_10m']
    weather_code = current['weather_code']
    weather_desc = decode_weather_code(weather_code)

    print(f"✓ Обновлено: {time}")
    print()
    print("ПОГОДА:")
    print(f"  Описание: {weather_desc}")
    print(f"  Температура: {temperature}°C")
    print(f"  Влажность: {humidity}%")
    print(f"  Скорость ветра: {wind_speed} км/ч")
    print()
    print("=" * 50)


if __name__ == "__main__":
    main()
