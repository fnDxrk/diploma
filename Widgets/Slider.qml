import QtQuick
import qs.Commons

// Horizontal slider, value 0..1.
// - Click anywhere on the track to set value
// - Drag the handle to change value
// - Emits valueRequested(real) when user is interacting (so caller writes to system)
//
// `value` is a one-way visual binding from the caller. The slider does NOT
// auto-write back into `value`. Caller listens to valueRequested and decides
// what to do (e.g. Brightness.setLevel).
Item {
    id: root

    property real value: 0           // 0..1, set externally
    property real handleSize: 16
    property real trackHeight: 6

    signal valueRequested(real v)

    implicitHeight: handleSize
    implicitWidth: 200

    // Track background
    Rectangle {
        id: track

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.trackHeight
        radius: height / 2
        color: Theme.trackInactive

        // Filled portion
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0, Math.min(1, root.value))
            radius: parent.radius
            color: Theme.foreground
        }
    }

    // Handle
    Rectangle {
        id: handle

        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: Theme.foreground

        x: (root.width - width) * Math.max(0, Math.min(1, root.value))
        anchors.verticalCenter: parent.verticalCenter
    }

    // One MouseArea covers the whole row — click and drag both work
    MouseArea {
        anchors.fill: parent
        preventStealing: true   // keep ownership during drag

        function setFromX(x) {
            const w = root.width;
            if (w <= 0) return;
            const v = Math.max(0, Math.min(1, x / w));
            root.valueRequested(v);
        }

        onPressed: e => setFromX(e.x)
        onPositionChanged: e => { if (pressed) setFromX(e.x); }
    }
}
