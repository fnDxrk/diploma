import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    Column {
        width: 320
        spacing: 10

        // ===== OUTPUT =====

        Row {
            width: parent.width
            spacing: 10

            IconButton {
                id: outMute
                anchors.verticalCenter: parent.verticalCenter
                icon: Audio.icon
                active: !Audio.muted
                iconSize: Theme.fontSizeAudio
                onClicked: Audio.toggleMute()
            }

            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - outMute.width - parent.spacing
                value: Audio.ratio
                onValueRequested: v => Audio.setRatio(v)
            }
        }

        Dropdown {
            width: parent.width
            leadingIcon: Audio.icon
            model: Audio.sinks
            selected: Audio.sink
            labelFunction: n => Audio.labelFor(n)
            onItemSelected: n => Audio.setDefaultSink(n)
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.separator
        }

        // ===== INPUT =====

        Row {
            width: parent.width
            spacing: 10

            IconButton {
                id: micMute
                anchors.verticalCenter: parent.verticalCenter
                icon: Mic.icon
                active: !Mic.muted
                iconSize: Theme.fontSizeAudio
                onClicked: Mic.toggleMute()
            }

            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - micMute.width - parent.spacing
                value: Mic.ratio
                onValueRequested: v => Mic.setRatio(v)
            }
        }

        Dropdown {
            width: parent.width
            leadingIcon: Mic.icon
            model: Mic.sources
            selected: Mic.source
            labelFunction: n => Mic.labelFor(n)
            onItemSelected: n => Mic.setDefaultSource(n)
        }
    }
}
