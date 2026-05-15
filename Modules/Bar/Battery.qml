import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Item {
    id: root

    required property var barWindow
    readonly property string popupId: "battery"

    // Visible always — even on desktops without battery, this is the trigger
    // for the power menu. On laptops shows battery icon + %, on desktops
    // just a power glyph.
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 5

        BarIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: Battery.available ? Battery.icon : "󰐥"
            glyphs: Battery.available
                    ? ["󰂄", "󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺"]
                    : ["󰐥"]
            fontSize: Theme.fontSizeBar
            weight: Font.Medium
        }

        Text {
            visible: Battery.available
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.foreground
            font.pixelSize: Theme.fontSizeBar
            font.family: Theme.fontFamily
            font.weight: Font.Medium
            text: `${Battery.level}%`
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            const p = root.mapToItem(null, 0, 0);
            BarPopupController.toggle(root.popupId, p.x, root.width, root.barWindow.screen, root.barWindow);
        }
    }
}
