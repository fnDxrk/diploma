import QtQuick
import qs.Commons

// Toggle switch — pill-shaped on/off control.
// Bind `checked` and listen to `toggled` (or set checked from outside).
Item {
    id: root

    property bool checked: false
    signal toggled(bool value)

    implicitWidth: 40
    implicitHeight: 22

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.foreground : Theme.trackInactive
        border.color: root.checked ? Theme.foreground : Theme.foregroundDim
        border.width: 1

        Behavior on color { ColorAnimation { duration: 120 } }
    }

    Rectangle {
        id: knob
        width: parent.height - 6
        height: parent.height - 6
        radius: width / 2
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        color: root.checked ? Theme.background : Theme.foreground

        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 120 } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
