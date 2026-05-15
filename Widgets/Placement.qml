pragma Singleton

import QtQuick
import QtQuick.Window
import Quickshell

Singleton {
    id: root

    readonly property real defaultScreenWidth: 1920

    function centerHorizontally(triggerCenterX, popupWidth, screenWidth, margin) {
        margin = margin === undefined ? 8 : margin;
        screenWidth = screenWidth || (Quickshell.screens[0]?.width ?? defaultScreenWidth);
        const desired = triggerCenterX - popupWidth / 2;
        return Math.max(margin, Math.min(screenWidth - popupWidth - margin, desired));
    }

    function localCenteredX(trigger, popupWidth, margin) {
        margin = margin === undefined ? 8 : margin;
        if (!trigger) return -popupWidth / 2;

        // Get window width — that's the real bound, not the screen
        // (multi-monitor / negative coords make Screen unreliable here).
        const winW = trigger.Window?.window?.width
                  ?? (trigger.Screen ? trigger.Screen.width : defaultScreenWidth);

        const triggerCenterInWin = trigger.mapToItem(null, trigger.width / 2, 0).x;
        const triggerLeftInWin = triggerCenterInWin - trigger.width / 2;

        const desiredInWin = triggerCenterInWin - popupWidth / 2;
        const clampedInWin = Math.max(margin, Math.min(winW - popupWidth - margin, desiredInWin));

        const result = clampedInWin - triggerLeftInWin;
        const win = trigger.Window?.window;
        console.log("[Placement] center=", triggerCenterInWin,
                    "popupW=", popupWidth, "winW=", winW,
                    "winObj=", win, "win.width=", win?.width,
                    "screenW=", trigger.Screen?.width,
                    "trigger.x=", trigger.x, "trigger.w=", trigger.width,
                    "desired=", desiredInWin, "clamped=", clampedInWin,
                    "localX=", result);
        return result;
    }
}
