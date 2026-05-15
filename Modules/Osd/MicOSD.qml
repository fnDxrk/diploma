import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Scope {
    id: root

    readonly property string osdId: "mic"
    property bool initialized: false

    Component.onCompleted: initTimer.start()

    Timer {
        id: initTimer
        interval: 500
        onTriggered: root.initialized = true
    }

    Connections {
        target: Mic

        function onMutedChanged() {
            if (!root.initialized) return;
            OsdController.show(root.osdId);
        }
    }

    LazyLoader {
        active: OsdController.current === root.osdId

        OsdPanel {
            iconText: Mic.icon
            iconColor: Mic.muted ? Theme.foregroundDim : Theme.foreground
            targetScreen: OsdController.activeScreen
        }
    }
}
