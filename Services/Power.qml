pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// Thin wrapper around Quickshell's UPower.PowerProfiles singleton.
// Exposes the same shape we used before (profile name strings, profiles list,
// icons, supportsFullCharge) so popup code doesn't need to know about enums.
//
// Why a wrapper:
//   - PowerProfiles uses an enum (Performance / Balanced / PowerSaver).
//     Our UI lists profiles as strings; converting in one place is cleaner.
//   - Bridges to D-Bus property updates — when an external tool (Fn key,
//     tlpctl in terminal) switches profile, this updates reactively.
//   - Holds extra bits like supportsFullCharge (TLP-only feature).
Singleton {
    id: root

    // ----- Detection -----
    //
    // PowerProfiles exists on any PPD-compatible backend. TLP exports a PPD
    // D-Bus interface too, so this catches both. supportsFullCharge is true
    // only for the TLP path (we check for `tlp` binary).

    readonly property bool available: true
    property bool supportsFullCharge: false

    Process {
        running: true
        command: ["sh", "-c", "command -v tlp >/dev/null && echo yes || echo no"]
        stdout: StdioCollector {
            onStreamFinished: root.supportsFullCharge = text.trim() === "yes"
        }
    }

    // ----- Profile state -----

    readonly property var profiles: ["power-saver", "balanced", "performance"]

    function _enumToString(e) {
        if (e === PowerProfile.Performance) return "performance";
        if (e === PowerProfile.PowerSaver)  return "power-saver";
        return "balanced";
    }

    function _stringToEnum(s) {
        if (s === "performance") return PowerProfile.Performance;
        if (s === "power-saver") return PowerProfile.PowerSaver;
        return PowerProfile.Balanced;
    }

    readonly property string profile: _enumToString(PowerProfiles.profile)

    function iconFor(p) {
        if (p === "performance") return "󰓅";
        if (p === "power-saver") return "󰌪";
        return "󰾅";
    }

    readonly property string icon: iconFor(profile)

    function setProfile(p) {
        // D-Bus property write — Quickshell handles it, UI updates reactively
        // via the readonly `profile` binding above.
        PowerProfiles.profile = _stringToEnum(p);
    }

    // ----- TLP fullcharge — root via pkexec -----

    function fullCharge() {
        Quickshell.execDetached(["pkexec", "tlp", "fullcharge"]);
    }
}
