pragma Singleton

import QtQuick
import Quickshell

// Coordinates which bar popup is open, on which screen, and where to anchor it.
//
// Bar popups are plain Items inside MainScreen. With multiple monitors we have
// one MainScreen per screen — only the one matching `activeScreen` actually
// shows the popup, so we don't render duplicates everywhere.
Singleton {
    id: root

    property string current: ""
    property real anchorX: 0
    property real anchorWidth: 0
    // Screen (ShellScreen) where the trigger lives. MainScreens compare their
    // own modelData against this to decide whether to render the popup.
    property var activeScreen: null
    // Bar PanelWindow ref — TrayMenu (a PopupWindow) needs it as anchor.window.
    property var barWindow: null

    function open(id, x, width, screen, window) {
        if (current === id) return;
        anchorX = x !== undefined ? x : 0;
        anchorWidth = width !== undefined ? width : 0;
        activeScreen = screen ?? null;
        if (window) barWindow = window;
        current = id;
    }

    function close(id) {
        if (current === id) {
            current = "";
            activeScreen = null;
        }
    }

    function toggle(id, x, width, screen, window) {
        if (current === id) close(id);
        else open(id, x, width, screen, window);
    }
}
