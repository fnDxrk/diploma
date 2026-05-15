pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Brightness service. Inspired by noctalia-shell's BrightnessService (simplified
// to single internal backlight — no DDC, no Apple displays, no multi-monitor).
//
// Read: FileView watches /sys/class/backlight/<dev>/brightness for changes.
// On change → refresh via `cat brightness && cat max_brightness` (one Process).
// Write: brightnessctl, debounced via Timer so holding a key doesn't spawn
// a process on every step.
Singleton {
    id: root

    // Auto-discovered on init by reading /sys/class/backlight/*
    property string backlightDevice: ""
    readonly property bool available: backlightDevice !== ""
    readonly property string brightnessPath: backlightDevice ? backlightDevice + "/brightness" : ""
    readonly property string maxBrightnessPath: backlightDevice ? backlightDevice + "/max_brightness" : ""

    // Brightness as a 0..1 ratio
    property real ratio: 0
    readonly property int percent: Math.round(ratio * 100)

    readonly property string icon: {
        if (ratio <= 0.33) return "󰃞";
        if (ratio <= 0.66) return "󰃟";
        return "󰃠";
    }

    // ----- Initial discovery + first read -----

    Process {
        id: initProc
        running: true
        // Find first backlight device, then print: <path>\n<current>\n<max>
        command: ["sh", "-c",
            "for dev in /sys/class/backlight/*; do " +
            "  if [ -f \"$dev/brightness\" ] && [ -f \"$dev/max_brightness\" ]; then " +
            "    echo \"$dev\"; cat \"$dev/brightness\"; cat \"$dev/max_brightness\"; break; " +
            "  fi; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 3) return;
                root.backlightDevice = lines[0];
                const cur = parseInt(lines[1]);
                const mx = parseInt(lines[2]);
                if (!isNaN(cur) && !isNaN(mx) && mx > 0)
                    root.ratio = cur / mx;
            }
        }
    }

    // ----- React to external changes (Fn keys, brightnessctl from CLI, etc.) -----

    FileView {
        path: root.brightnessPath
        watchChanges: path !== ""
        onFileChanged: Qt.callLater(refreshProc.refresh)
    }

    Process {
        id: refreshProc
        function refresh() {
            command = ["sh", "-c", "cat " + root.brightnessPath + " && cat " + root.maxBrightnessPath];
            running = true;
        }
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n");
                if (lines.length < 2) return;
                const cur = parseInt(lines[0]);
                const mx = parseInt(lines[1]);
                if (!isNaN(cur) && !isNaN(mx) && mx > 0) {
                    const next = cur / mx;
                    if (Math.abs(next - root.ratio) > 0.001)
                        root.ratio = next;
                }
            }
        }
    }

    // ----- Write (debounced) -----

    property real queuedRatio: NaN

    Timer {
        id: writeDebounce
        interval: 33
        onTriggered: {
            if (isNaN(root.queuedRatio)) return;
            const pct = Math.round(Math.max(0, Math.min(1, root.queuedRatio)) * 100);
            root.queuedRatio = NaN;
            Quickshell.execDetached(["brightnessctl", "set", pct + "%"]);
        }
    }

    function setLevel(value) {
        // Update UI immediately for responsiveness
        root.ratio = Math.max(0, Math.min(1, value));
        root.queuedRatio = root.ratio;
        writeDebounce.restart();
    }

    function bump(step) {
        const base = isNaN(queuedRatio) ? ratio : queuedRatio;
        setLevel(base + step);
    }
}
