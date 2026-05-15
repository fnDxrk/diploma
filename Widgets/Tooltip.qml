import QtQuick
import qs.Commons

// Themed tooltip bubble.
//
// Width is capped (default 320). Long text wraps. Position is centered above
// parent and shifted toward the closer side of the screen if it would
// overflow `screenWidth` (caller-provided to avoid mapToItem-to-window
// quirks under multi-monitor wlroots).
//
// Usage:
//   Tooltip {
//       text: "Power saver"
//       visible: hoverArea.containsMouse
//       screenWidth: rootBarWindow.width   // pass the actual window width
//       triggerScreenX: triggerItem.x      // X of trigger in window coords
//       triggerWidth: triggerItem.width
//   }
//
// If screenWidth not given, falls back to no clamp (centered locally).
Rectangle {
    id: root

    property string text: ""
    property int delay: 700
    property int gap: 6
    property int maxWidth: 320

    // Optional clamp inputs from caller (in window-local coordinates)
    property real screenWidth: 0
    property real triggerScreenX: 0
    property real triggerWidth: parent ? parent.width : 0

    implicitHeight: label.implicitHeight + 10
    implicitWidth: Math.min(maxWidth, label.implicitWidth + 16)

    // Compute x in parent-local coordinates.
    x: {
        if (!parent) return 0;
        const center = (parent.width - width) / 2;        // default: centered above parent
        if (screenWidth <= 0) return center;                // no clamp info → just center

        // Clamp inside [margin, screenWidth - margin]
        const margin = 8;
        const triggerCenterInScreen = triggerScreenX + triggerWidth / 2;
        const desiredScreenLeft = triggerCenterInScreen - width / 2;
        const clampedScreenLeft = Math.max(margin, Math.min(screenWidth - width - margin, desiredScreenLeft));
        return clampedScreenLeft - triggerScreenX;
    }
    y: -height - gap
    z: 1000

    color: Theme.background
    border.color: Theme.foregroundDim
    border.width: 1
    radius: 6

    opacity: shown ? 1 : 0
    property bool shown: false
    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root.shown = true
    }
    onVisibleChanged: {
        if (visible) showTimer.restart();
        else { showTimer.stop(); shown = false; }
    }
    Behavior on opacity { NumberAnimation { duration: 80 } }

    Text {
        id: label
        anchors.fill: parent
        anchors.margins: 8
        text: root.text
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeMenu
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
