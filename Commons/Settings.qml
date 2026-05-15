pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// User-facing settings persisted to ~/.config/quickshell/config.json.
//
// Edit on disk → shell auto-reloads (FileView watchChanges).
// Modify from QML (e.g. Settings.theme = "Light") → auto-saved (adapterUpdated).
//
// Settings UI app (Phase E4) writes here. Other modules just read Settings.foo.
Singleton {
    id: root

    // Direct read access. Other files do `Settings.theme` etc.
    property alias theme: data.theme
    property alias weather: data.weather

    // ----- Storage -----

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/config.json"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        // First launch: file doesn't exist yet — create it with defaults.
        onLoadFailed: error => {
            console.log("[Settings] file missing, creating with defaults:", error);
            writeAdapter();
        }

        JsonAdapter {
            id: data

            // Active theme name. Must match a file in Themes/ (case-sensitive).
            property string theme: "Dark"

            // Weather: `city` is the wttr.in query (empty → auto-IP).
            property JsonObject weather: JsonObject {
                property string city: ""
                property string units: "metric"   // "metric" | "imperial"
            }

            // Future settings go here:
            //   property bool barTopPosition: true
            //   property string wallpaperPath: ""
        }
    }
}
