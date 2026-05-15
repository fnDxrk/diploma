pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var names: []
    property int currentIdx: 0
    readonly property string currentName: names[currentIdx] ?? ""
    readonly property bool available: names.length > 0

    readonly property string shortName: {
        const n = currentName;
        if (!n) return "";
        const m = n.match(/\(([A-Za-z]{2,4})\)/);
        if (m) return m[1].toUpperCase();
        return n.slice(0, 2).toUpperCase();
    }

    // Cycle to the next layout via niri action.
    function cycle() {
        Quickshell.execDetached(["niri", "msg", "action", "switch-layout", "next"]);
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(text);
                    if (obj.names) root.names = obj.names;
                    if (typeof obj.current_idx === "number") root.currentIdx = obj.current_idx;
                } catch (e) {}
            }
        }
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const obj = JSON.parse(line);
                    if (obj.KeyboardLayoutsChanged) {
                        const k = obj.KeyboardLayoutsChanged.keyboard_layouts;
                        if (k.names) root.names = k.names;
                        if (typeof k.current_idx === "number") root.currentIdx = k.current_idx;
                    } else if (obj.KeyboardLayoutSwitched) {
                        const idx = obj.KeyboardLayoutSwitched.idx;
                        if (typeof idx === "number") root.currentIdx = idx;
                    }
                } catch (e) {}
            }
        }
    }
}
