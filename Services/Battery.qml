pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Battery data source. Finds the laptop battery once; other widgets
// read level/charging without each doing their own UPower scan.
Singleton {
    id: root

    readonly property var device: UPower.devices.values.find(d => d.isLaptopBattery) ?? null

    readonly property bool available: device !== null
    readonly property real percentage: device?.percentage ?? 0   // 0..1
    readonly property int level: Math.round(percentage * 100)    // 0..100
    readonly property bool charging: !UPower.onBattery

    readonly property string icon: {
        if (charging) return "󰂄";
        if (level > 90) return "󰁹";
        if (level > 80) return "󰂂";
        if (level > 70) return "󰂁";
        if (level > 60) return "󰂀";
        if (level > 50) return "󰁿";
        if (level > 40) return "󰁾";
        if (level > 30) return "󰁽";
        if (level > 20) return "󰁼";
        if (level > 10) return "󰁻";
        return "󰁺";
    }
}
