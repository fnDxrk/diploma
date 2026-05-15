pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth service: thin wrapper around Quickshell.Bluetooth.
//
// Why an own service:
//   - Re-export the device-state enum as ints so popups don't need to
//     import Quickshell.Bluetooth (which shadows our singleton).
//   - Centralise the "scan ↔ connect" race fix (BlueZ can't do both at once).
//   - Run a NoInputNoOutput agent in the background so headphone pairing
//     and audio-profile authorization auto-accept.
//   - Sort devices for the popup (connected → paired → others, alphabetical).
//
// Manual disconnect blocks auto-reconnect by setting `device.blocked = true`.
// User must click Connect again to re-enable.
Singleton {
    id: root

    // ──────────────────────────────────────────────────────────────────────
    // State
    // ──────────────────────────────────────────────────────────────────────

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    // Device-state enum re-exported as plain ints.
    readonly property int stateDisconnected: BluetoothDeviceState.Disconnected
    readonly property int stateConnecting: BluetoothDeviceState.Connecting
    readonly property int stateConnected: BluetoothDeviceState.Connected
    readonly property int stateDisconnecting: BluetoothDeviceState.Disconnecting

    // ──────────────────────────────────────────────────────────────────────
    // Devices — raw + sorted view
    // ──────────────────────────────────────────────────────────────────────

    readonly property var devicesRaw: adapter?.devices?.values ?? []

    readonly property var devices: {
        const arr = devicesRaw.slice();
        arr.sort(function(a, b) {
            const rank = function(d) {
                if (d.connected) return 0;
                if (d.paired)    return 1;
                return 2;
            };
            const ra = rank(a), rb = rank(b);
            if (ra !== rb) return ra - rb;
            const an = (root.labelFor(a) || "").toLowerCase();
            const bn = (root.labelFor(b) || "").toLowerCase();
            return an.localeCompare(bn);
        });
        return arr;
    }

    // Friendly label for a device. nickname is often best, falls back gracefully.
    function labelFor(dev) {
        if (!dev) return "";
        return dev.name || dev.deviceName || dev.address || "Unknown";
    }

    // Icon for the bar widget depending on overall state.
    readonly property string icon: {
        if (!available || !enabled) return "󰂲";              // off
        if (devices.some(d => d.connected)) return "󰂱";       // connected
        return "󰂯";                                          // on
    }

    // ──────────────────────────────────────────────────────────────────────
    // Power / pairable
    // ──────────────────────────────────────────────────────────────────────

    function toggleEnabled() {
        if (!adapter) return;
        if (adapter.enabled) {
            adapter.enabled = false;
        } else {
            // BT may be soft-blocked by rfkill — unblock first (no-op if not).
            Quickshell.execDetached(["rfkill", "unblock", "bluetooth"]);
            adapter.enabled = true;
            adapter.pairable = true;
        }
    }

    // Keep pairable on whenever BT is enabled (headphones in pairing mode
    // need the adapter to accept inbound auth requests).
    onEnabledChanged: {
        if (enabled && adapter && !adapter.pairable)
            adapter.pairable = true;
    }

    function setDiscovering(on) {
        if (!adapter) return;
        // Guard against "Operation already in progress" / "No discovery started"
        // warnings when our property is out-of-sync with BlueZ.
        if (adapter.discovering === on) return;
        adapter.discovering = on;
    }

    // ──────────────────────────────────────────────────────────────────────
    // Connect / pair / disconnect / forget — with scan ↔ connect serialisation
    // ──────────────────────────────────────────────────────────────────────

    // Pending action deferred until scan stops (BlueZ can't connect while
    // scanning — the radio is busy).
    property var _pendingAction: null
    Timer {
        id: _afterScanStop
        interval: 150
        onTriggered: {
            if (root._pendingAction) {
                const fn = root._pendingAction;
                root._pendingAction = null;
                fn();
            }
        }
    }

    function _runWhenIdle(fn) {
        if (discovering) {
            adapter.discovering = false;
            _pendingAction = fn;
            _afterScanStop.restart();
        } else {
            fn();
        }
    }

    function safeConnect(device) {
        if (!device) return;
        _runWhenIdle(function() {
            // Pre-trust so our NoInputNoOutput agent auto-accepts the audio
            // profile authorizations once the base link is up.
            if (device.paired && !device.trusted) device.trusted = true;
            // User wants to connect — unblock if a previous disconnect blocked it.
            if (device.blocked) device.blocked = false;
            device.connect();
        });
    }

    function safePair(device) {
        if (!device) return;
        _runWhenIdle(function() {
            device.pair();
            device.trusted = true;
        });
    }

    // Manual disconnect blocks BlueZ from auto-reconnecting. The user has to
    // click Connect to re-enable.
    function disconnect(device) {
        if (!device) return;
        device.disconnect();
        device.blocked = true;
    }

    function forget(device) {
        if (!device) return;
        device.trusted = false;
        device.forget();
    }

    // Remove all discovered-but-not-paired devices from the BlueZ cache.
    // Paired devices are kept — only the noise from scans gets cleared.
    function clearDiscovered() {
        const arr = devicesRaw.slice();
        for (let i = 0; i < arr.length; i++) {
            const d = arr[i];
            if (d && !d.paired) d.forget();
        }
    }

    readonly property bool hasDiscovered: devicesRaw.some(d => d && !d.paired)

}
