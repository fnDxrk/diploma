pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// Network data source. Wired connection takes precedence over Wi-Fi:
// when an Ethernet cable is plugged in, NetworkManager assigns it a lower
// route metric → it becomes the system default. Bar should reflect that.
Singleton {
    id: root

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null

    readonly property var activeWifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null

    readonly property bool hasWifi: activeWifiNetwork !== null
    readonly property bool hasWired: wiredDevice?.connected ?? false
    readonly property bool wifiEnabled: Networking.wifiEnabled

    readonly property string ssid: activeWifiNetwork?.name ?? ""
    readonly property real signalStrength: activeWifiNetwork?.signalStrength ?? 0

    readonly property string icon: {
        if (hasWired) return "󰈀";
        if (hasWifi) {
            const s = signalStrength;
            if (s >= 0.8) return "󰤨";
            if (s >= 0.6) return "󰤥";
            if (s >= 0.4) return "󰤢";
            if (s >= 0.2) return "󰤟";
            return "󰤯";
        }
        if (wifiEnabled) return "󰤮";
        return "󰪎";
    }
}
