import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons
import qs.Widgets

Item {
    id: root

    required property var barWindow
    readonly property string popupId: "tray"

    visible: SystemTray.items.values.length > 0
    implicitWidth: arrow.implicitWidth
    implicitHeight: arrow.implicitHeight

    Text {
        id: arrow
        font.pixelSize: Theme.fontSizeArrow
        font.family: Theme.fontFamilyIcons
        color: Theme.foreground
        text: BarPopupController.current === root.popupId ? "\u{f0143}" : "\u{f0140}"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                const p = root.mapToItem(null, 0, 0);
                BarPopupController.toggle(root.popupId, p.x, root.width, root.barWindow.screen, root.barWindow);
            }
        }
    }
}
