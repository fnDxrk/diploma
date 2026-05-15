import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Item {
    id: root

    required property var barWindow
    readonly property string popupId: "bluetooth"

    visible: Bluetooth.available
    implicitWidth: bIcon.implicitWidth
    implicitHeight: bIcon.implicitHeight

    BarIcon {
        id: bIcon
        anchors.centerIn: parent
        icon: Bluetooth.icon
        glyphs: ["󰂲", "󰂯", "󰂱"]
        fontSize: Theme.fontSizeBar
        iconColor: Bluetooth.enabled ? Theme.foreground : Theme.foregroundDim
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            const p = root.mapToItem(null, 0, 0);
            BarPopupController.toggle(root.popupId, p.x, root.width, root.barWindow.screen, root.barWindow);
        }
    }
}
