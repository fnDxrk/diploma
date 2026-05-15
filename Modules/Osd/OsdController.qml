pragma Singleton

import QtQuick
import Quickshell
import qs.Widgets
import qs.Services

// Coordinates which OSD is shown, and on which screen.
//
// If a bar popup is open, OSDs are suppressed (user already sees the slider
// in the popup, no point doubling up).
//
// Active screen = focused output from niri. With multi-monitor we have one
// OSD-window per screen and only the matching one renders.
Singleton {
    id: root

    property string current: ""
    property var activeScreen: null
    readonly property int hideMs: 1000

    Timer {
        id: hideTimer
        interval: root.hideMs
        onTriggered: {
            root.current = "";
            root.activeScreen = null;
        }
    }

    function show(id) {
        if (BarPopupController.current !== "") return;
        activeScreen = Niri.focusedScreen;
        current = id;
        hideTimer.restart();
    }
}
