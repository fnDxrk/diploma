import QtQuick
import qs.Commons

// One row in a list. Optional leading icon, label, trailing checkmark for "active" state.
// Hover background, clickable.
Item {
    id: root

    property string text: ""
    property string leadingIcon: ""    // Nerd Font glyph or empty
    property bool active: false        // shows trailing checkmark
    property bool enabled: true

    signal clicked()

    implicitWidth: row.implicitWidth + 24
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouse.containsMouse && root.enabled ? Theme.hover : "transparent"
    }

    Row {
        id: row
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12
            rightMargin: 12
        }
        spacing: 10

        Text {
            visible: root.leadingIcon.length > 0
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeBar
            font.family: Theme.fontFamilyIcons
            color: root.enabled ? Theme.foreground : Theme.foregroundDisabled
            text: root.leadingIcon
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            color: root.enabled ? Theme.foreground : Theme.foregroundDisabled
            font.pixelSize: Theme.fontSizeMenu
            font.family: Theme.fontFamily
            // Take up remaining width minus checkmark space
            width: row.width - (root.leadingIcon.length > 0 ? 30 : 0) - (root.active ? 24 : 0)
            elide: Text.ElideRight
        }

        Text {
            visible: root.active
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSizeMenu
            font.family: Theme.fontFamilyIcons
            color: Theme.foreground
            text: "󰄬"   // checkmark
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
