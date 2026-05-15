import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets

PopupWindow {
    id: root

    // Inputs
    property var menuHandle: null      // QsMenuHandle (or QsMenuEntry with hasChildren)
    property int relativeX: 0
    property int relativeY: 0

    signal dismissed()
    signal itemTriggered()             // bubble-up: any leaf item triggered → close whole chain

    anchor.rect.x: relativeX
    anchor.rect.y: relativeY
    visible: menuHandle !== null
    // grabFocus would steal keyboard from MainScreen (which captures keys via
    // Exclusive). MainScreen also handles outside-click for us, so we don't
    // need our own grab.
    grabFocus: false
    implicitWidth: surface.implicitWidth
    implicitHeight: surface.implicitHeight
    color: "transparent"

    onVisibleChanged: {
        if (!visible) {
            // grabFocus closed us — clean up submenu and notify parent
            if (submenuLoader.active)
                submenuLoader.active = false;
            root.dismissed();
        }
    }

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    PopupSurface {
        id: surface

        padding: Theme.menuPadding

        ColumnLayout {
            id: column

            spacing: 2

            Repeater {
                model: opener.children

                TrayMenuItem {
                    id: item

                    required property var modelData
                    required property int index

                    entry: modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: implicitHeight

                    onTriggered: {
                        modelData.triggered();
                        root.itemTriggered();
                    }

                    onSubmenuRequested: {
                        // Position submenu at the right edge of this item
                        const itemTopInWindow = column.y + item.y;
                        submenuLoader.targetEntry = modelData;
                        submenuLoader.targetX = root.relativeX + root.implicitWidth - 4;
                        submenuLoader.targetY = root.relativeY + surface.padding + itemTopInWindow;
                        submenuLoader.active = true;
                    }
                }
            }
        }
    }

    // Recursive submenu — created on demand.
    // Loaded via URL string so QML doesn't see TrayMenu referencing itself statically.
    Loader {
        id: submenuLoader

        property var targetEntry: null
        property int targetX: 0
        property int targetY: 0

        active: false
        source: active ? "TrayMenu.qml" : ""

        onLoaded: {
            item.anchor.window = root.anchor.window;
            item.menuHandle = submenuLoader.targetEntry;
            item.relativeX = submenuLoader.targetX;
            item.relativeY = submenuLoader.targetY;
            item.itemTriggered.connect(root.itemTriggered);
            item.dismissed.connect(() => submenuLoader.active = false);
        }
    }
}
