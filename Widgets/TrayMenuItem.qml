import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

Item {
    id: root

    required property var entry  // QsMenuEntry

    signal triggered()
    signal submenuRequested()

    implicitWidth: row.implicitWidth + Theme.menuItemHorizontalPadding * 2
    implicitHeight: entry.isSeparator ? Theme.separatorHeight : Theme.menuItemHeight

    // Hover background
    Rectangle {
        anchors.fill: parent
        radius: 4
        color: mouse.containsMouse && !root.entry.isSeparator ? Theme.hover : "transparent"
    }

    // Separator line
    Rectangle {
        visible: root.entry.isSeparator
        anchors.centerIn: parent
        width: parent.width - 8
        height: 1
        color: Theme.separator
    }

    // Content row — natural implicitWidth, no circular bindings
    Row {
        id: row

        visible: !root.entry.isSeparator
        x: Theme.menuItemHorizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Text {
            text: root.entry.text || ""
            color: root.entry.enabled ? Theme.foreground : Theme.foregroundDisabled
            font.pixelSize: Theme.fontSizeMenu
            font.family: Theme.fontFamily
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            visible: root.entry.hasChildren
            text: "›"
            color: root.entry.enabled ? Theme.foreground : Theme.foregroundDisabled
            font.pixelSize: Theme.fontSizeMenu
            font.family: Theme.fontFamily
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.entry.isSeparator && root.entry.enabled
        onClicked: {
            if (root.entry.hasChildren)
                root.submenuRequested();
            else
                root.triggered();
        }
    }
}
