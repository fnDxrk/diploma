import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import qs.Commons
import qs.Widgets

BarPopup {
    id: root

    Grid {
        id: grid

        columns: Math.min(SystemTray.items.values.length, 4)
        spacing: Theme.trayIconSpacing

        Repeater {
            model: SystemTray.items

            Item {
                id: cell

                required property SystemTrayItem modelData
                required property int index

                width: Theme.trayIconSize
                height: Theme.trayIconSize

                // Image rendered into an offscreen layer so MultiEffect can
                // recolor it. On Dark themes colorization=0 → effect is a no-op
                // and the icon shows untouched.
                Image {
                    id: trayIcon
                    source: cell.modelData.icon
                    anchors.centerIn: parent
                    width: Theme.trayIconImageSize
                    height: Theme.trayIconImageSize
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: Theme.trayIconSize
                    sourceSize.height: Theme.trayIconSize
                    smooth: true
                    visible: status === Image.Ready
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: Theme.trayIconColorization
                        colorizationColor: Theme.trayIconColor
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: trayIcon.status !== Image.Ready
                    text: cell.modelData.title ? cell.modelData.title[0].toUpperCase() : "?"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeMenu + 2
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: event => {
                        if (event.button === Qt.RightButton && cell.modelData.hasMenu) {
                            // TrayMenu is anchored to the bar PanelWindow, so coords
                            // must be in bar-window space.
                            //   X: cell's X inside MainScreen (= screen X)
                            //   Y: bar height + cell's Y inside MainScreen
                            const barH = BarPopupController.barWindow?.implicitHeight ?? 0;
                            const cellX = root.x + grid.x + cell.x;
                            const cellY = root.y + grid.y + cell.y;
                            contextMenu.relativeX = cellX;
                            contextMenu.relativeY = barH + cellY + cell.height + 12;
                            contextMenu.menuHandle = cell.modelData.menu;
                        } else if (event.button === Qt.LeftButton) {
                            if (!cell.modelData.onlyMenu)
                                cell.modelData.activate();
                            BarPopupController.close("tray");
                        }
                    }
                }
            }
        }
    }

    TrayMenu {
        id: contextMenu
        anchor.window: BarPopupController.barWindow

        onItemTriggered: {
            menuHandle = null;
            BarPopupController.close("tray");
        }
        onDismissed: menuHandle = null

        // While the context menu is open, MainScreen is hidden (so tray popup
        // doesn't catch clicks and ping-pong the grab). When the context menu
        // closes (click outside / item triggered), we restore MainScreen by
        // doing nothing extra — Loader/MainScreen will resume normally because
        // BarPopupController.current is still "tray".
    }

    // When BarPopupController is closed externally (via bar click, key press,
    // or click on MainScreen overlay), make sure the context menu closes too.
    Connections {
        target: BarPopupController
        function onCurrentChanged() {
            if (BarPopupController.current !== "tray")
                contextMenu.menuHandle = null;
        }
    }
}
