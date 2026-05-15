import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Widgets
import qs.Modules.Bar.Popups

// Fullscreen invisible overlay window per screen. Hosts bar popups as Items.
// Only the MainScreen matching BarPopupController.activeScreen actually shows
// the popup — others stay inert (no duplicate popups across monitors).
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: root

        property var modelData
        readonly property bool isActiveScreen: BarPopupController.activeScreen === modelData
        readonly property bool active: BarPopupController.current !== "" && isActiveScreen

        screen: modelData
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        color: "transparent"

        mask: Region { item: root.active ? clickCatcher : null }

        Item {
            id: clickCatcher
            anchors.fill: parent
            visible: root.active
            focus: root.active

            Keys.onPressed: BarPopupController.close(BarPopupController.current)

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: BarPopupController.close(BarPopupController.current)
            }
        }

        Loader {
            active: root.active && BarPopupController.current === "brightness"
            sourceComponent: BrightnessPopup {}
        }

        Loader {
            active: root.active && BarPopupController.current === "audio"
            sourceComponent: AudioPopup {}
        }

        Loader {
            active: root.active && BarPopupController.current === "tray"
            sourceComponent: TrayPopup {}
        }

        Loader {
            active: root.active && BarPopupController.current === "battery"
            sourceComponent: BatteryPopup {}
        }

        Loader {
            active: root.active && BarPopupController.current === "bluetooth"
            sourceComponent: BluetoothPopup {}
        }
    }
}
