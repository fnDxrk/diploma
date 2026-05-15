import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Scope {
    id: root

    readonly property string osdId: "brightness"
    property bool initialized: false

    Component.onCompleted: initTimer.start()

    Timer {
        id: initTimer
        interval: 500
        onTriggered: root.initialized = true
    }

    Connections {
        target: Brightness

        function onRatioChanged() {
            if (!root.initialized) return;
            OsdController.show(root.osdId);
        }
    }

    LazyLoader {
        active: OsdController.current === root.osdId

        OsdPanel {
            showTrack: true
            iconText: Brightness.icon
            ratio: Brightness.ratio
            targetScreen: OsdController.activeScreen
        }
    }
}
