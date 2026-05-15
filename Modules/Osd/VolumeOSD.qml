import QtQuick
import Quickshell
import qs.Commons
import qs.Services

Scope {
    id: root

    readonly property string osdId: "volume"
    property bool initialized: false

    Component.onCompleted: initTimer.start()

    Timer {
        id: initTimer
        interval: 500
        onTriggered: root.initialized = true
    }

    Connections {
        target: Audio

        function onVolumeChanged() {
            if (!root.initialized) return;
            OsdController.show(root.osdId);
        }

        function onMutedChanged() {
            if (!root.initialized) return;
            OsdController.show(root.osdId);
        }
    }

    LazyLoader {
        active: OsdController.current === root.osdId

        OsdPanel {
            showTrack: true
            iconText: Audio.icon
            iconColor: Audio.muted ? Theme.foregroundDim : Theme.foreground
            ratio: Audio.ratio
            trackFillColor: Audio.muted ? Theme.trackMuted : Theme.foreground
            targetScreen: OsdController.activeScreen
        }
    }
}
