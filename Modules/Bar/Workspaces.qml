import QtQuick
import qs.Commons
import qs.Services

Row {
    id: root

    // Name of the output this bar lives on (e.g. "eDP-1", "HDMI-A-1").
    // Filters Niri workspaces so we show only the ones for this monitor.
    required property string outputName

    // Workspaces on this output, sorted by idx.
    readonly property var workspaces: {
        const all = Niri.sortedWorkspaces.filter(w => w.output === root.outputName);
        return all;
    }

    spacing: 12
    visible: workspaces.length > 0

    Repeater {
        model: root.workspaces

        Item {
            id: dotCell
            required property var modelData

            width: 14
            height: 14

            Rectangle {
                anchors.centerIn: parent
                width: 14
                height: 14
                radius: 7
                // `is_active` = the one visible on this output.
                // (`is_focused` is a single global flag — we don't use it here.)
                color: dotCell.modelData.is_active ? Theme.foreground : "transparent"
                border.color: Theme.foregroundDim
                border.width: dotCell.modelData.is_active ? 0 : 1.5

                Behavior on color { ColorAnimation { duration: 120 } }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Niri.switchToWorkspace(dotCell.modelData.idx)
            }
        }
    }
}
