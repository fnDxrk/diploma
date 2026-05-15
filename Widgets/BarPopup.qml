import QtQuick
import Quickshell
import qs.Commons

// A bar popup as an Item — used inside MainScreen, NOT as a separate window.
// Positions itself relative to BarPopupController.anchorX/anchorWidth/barHeight.
// Caller fills in content as default children.
Item {
    id: root

    default property alias contentChildren: surface.contentChildren

    // Center horizontally under the trigger, clamped to the bounds of the
    // window we live in (one MainScreen per monitor → width = that monitor).
    x: {
        const winW = root.Window?.window?.width
                  ?? (BarPopupController.activeScreen?.width ?? 1920);
        const desired = BarPopupController.anchorX + BarPopupController.anchorWidth / 2 - implicitWidth / 2;
        return Math.max(8, Math.min(winW - implicitWidth - 8, desired));
    }
    // Bar reserves its own exclusion zone, so MainScreen y=0 is already
    // below the bar. We just add a tiny gap (5px) so popup doesn't touch it.
    y: 10

    implicitWidth: surface.implicitWidth
    implicitHeight: surface.implicitHeight

    // Block click propagation so clicks inside popup don't reach
    // MainScreen's outside-click catcher.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: { /* swallow */ }
        onWheel: { /* swallow */ }
    }

    PopupSurface {
        id: surface
        anchors.fill: parent
    }

    // Helper for Tooltip / nested popups: returns the window-local X coord of
    // the given Item. Walks up `parent` chain to accumulate offset.
    // Workaround for mapToItem(null) returning unexpected coords on some
    // multi-monitor wlroots setups.
    function screenXOf(item) {
        let x = 0;
        let it = item;
        while (it && it !== root.parent) {
            x += it.x;
            it = it.parent;
        }
        return x;
    }

    // Width of the monitor this popup lives on — used by tooltips for clamping.
    readonly property real screenWidth: root.Window?.window?.width
                                        ?? (BarPopupController.activeScreen?.width ?? 1920)
}
