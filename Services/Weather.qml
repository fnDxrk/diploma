pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

// Weather via open-meteo.com — free, no API key, reliable JSON, no VPN issues.
//
// City name → lat/lon via open-meteo's geocoding API.
// Then current weather via the forecast API.
//
// Refresh every 30 minutes. Re-geocode only when city changes.
Singleton {
    id: root

    // ----- Public state -----

    property bool available: false
    property real temp: 0
    property real feelsLike: 0
    property int humidity: 0
    property real windSpeed: 0
    property string condition: ""
    property string city: ""
    property int weatherCode: 0

    readonly property string units: Settings.weather?.units ?? "metric"
    readonly property string unitSymbol: units === "imperial" ? "°F" : "°C"

    readonly property string icon: iconForCode(weatherCode)
    readonly property string display: available
                                       ? `${Math.round(temp)}${unitSymbol}`
                                       : "—"

    // WMO weather codes → Nerd Font glyphs.
    // https://open-meteo.com/en/docs (search "WMO Weather interpretation codes")
    function iconForCode(code) {
        if (code === 0)                              return "󰖙"; // clear
        if (code >= 1 && code <= 3)                  return "󰖕"; // mainly clear → overcast
        if (code === 45 || code === 48)              return "󰖑"; // fog
        if (code >= 51 && code <= 67)                return "󰖗"; // drizzle / rain
        if (code >= 71 && code <= 77)                return "󰖘"; // snow
        if (code >= 80 && code <= 82)                return "󰖗"; // rain showers
        if (code >= 85 && code <= 86)                return "󰖘"; // snow showers
        if (code >= 95 && code <= 99)                return "󰙾"; // thunder
        return "󰖐";
    }

    function descriptionForCode(code) {
        if (code === 0) return "Ясно";
        if (code === 1) return "В основном ясно";
        if (code === 2) return "Переменная облачность";
        if (code === 3) return "Пасмурно";
        if (code === 45 || code === 48) return "Туман";
        if (code >= 51 && code <= 57) return "Морось";
        if (code >= 61 && code <= 67) return "Дождь";
        if (code >= 71 && code <= 77) return "Снег";
        if (code >= 80 && code <= 82) return "Ливень";
        if (code >= 85 && code <= 86) return "Снегопад";
        if (code >= 95 && code <= 99) return "Гроза";
        return "—";
    }

    // ----- Resolved coordinates -----

    property real lat: 0
    property real lon: 0
    property bool hasCoords: false

    // ----- Geocoding: city → lat/lon -----

    Process {
        id: geocodeProc
        function lookup() {
            const c = Settings.weather?.city ?? "";
            if (!c) return;
            const url = "https://geocoding-api.open-meteo.com/v1/search?count=1&language=ru&name=" + encodeURIComponent(c);
            console.log("[Weather] geocoding", c);
            command = ["curl", "-fsSL", "--max-time", "10", url];
            running = false;
            running = true;
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text);
                    const r = obj?.results?.[0];
                    if (!r) {
                        console.log("[Weather] no geocoding result");
                        return;
                    }
                    root.lat = r.latitude;
                    root.lon = r.longitude;
                    root.city = r.name;
                    root.hasCoords = true;
                    weatherProc.refresh();
                } catch (e) {
                    console.log("[Weather] geocoding parse error:", e);
                }
            }
        }
    }

    // ----- Current weather -----

    Process {
        id: weatherProc
        function refresh() {
            if (!root.hasCoords) return;
            const tempUnit = root.units === "imperial" ? "fahrenheit" : "celsius";
            const windUnit = root.units === "imperial" ? "mph" : "kmh";
            const url = "https://api.open-meteo.com/v1/forecast"
                      + "?latitude=" + root.lat
                      + "&longitude=" + root.lon
                      + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code"
                      + "&temperature_unit=" + tempUnit
                      + "&wind_speed_unit=" + windUnit;
            console.log("[Weather] fetching forecast for", root.city);
            command = ["curl", "-fsSL", "--max-time", "10", url];
            running = false;
            running = true;
        }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text);
                    const c = obj?.current;
                    if (!c) return;
                    root.temp = c.temperature_2m ?? 0;
                    root.feelsLike = c.apparent_temperature ?? 0;
                    root.humidity = c.relative_humidity_2m ?? 0;
                    root.windSpeed = c.wind_speed_10m ?? 0;
                    root.weatherCode = c.weather_code ?? 0;
                    root.condition = root.descriptionForCode(root.weatherCode);
                    root.available = true;
                } catch (e) {
                    console.log("[Weather] forecast parse error:", e);
                }
            }
        }
    }

    function refresh() {
        // Re-geocode only when city changes; otherwise just hit forecast API.
        if (Settings.weather?.city && !hasCoords)
            geocodeProc.lookup();
        else
            weatherProc.refresh();
    }

    Component.onCompleted: {
        if (Settings.weather?.city)
            geocodeProc.lookup();
    }

    Connections {
        target: Settings.weather
        function onCityChanged() {
            root.hasCoords = false;
            root.available = false;
            geocodeProc.lookup();
        }
        function onUnitsChanged() {
            weatherProc.refresh();
        }
    }

    Timer {
        interval: 30 * 60 * 1000   // 30 min
        running: true
        repeat: true
        onTriggered: weatherProc.refresh()
    }
}
