import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Commons

// Common OSD window — one per screen via Variants. Only the window whose
// `screen` matches the externally-provided `targetScreen` actually renders;
// others stay invisible. This keeps OSDs on the right monitor in
// multi-screen setups.
//
// Caller usage:
//   LazyLoader {
//       active: OsdController.current === "volume"
//       OsdPanel {
//           targetScreen: OsdController.activeScreen
//           iconText: Audio.icon
//           ratio: Audio.ratio
//           showTrack: true
//       }
//   }
//
// targetScreen is read from each PanelWindow instance and compared to its
// own screen to decide visibility — Variants gives us one PanelWindow per
// connected output, only one of them matches.
Variants {
    id: variants
    model: Quickshell.screens

    // Visible inputs from caller — exposed as a "facade" so users of OsdPanel
    // don't need to know about Variants.
    property string iconText: ""
    property color iconColor: Theme.foreground
    property bool showTrack: false
    property real ratio: 0
    property color trackFillColor: Theme.foreground
    property var targetScreen: null

    PanelWindow {
        id: panel

        property var modelData
        readonly property bool isActive: variants.targetScreen === modelData

        // Geometry constants
        readonly property int pillWidth: 300
        readonly property int pillHeight: 40
        readonly property int squareSize: 80

        screen: modelData
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        anchors.bottom: true
        margins.bottom: 90
        exclusiveZone: 0

        implicitWidth: variants.showTrack ? pillWidth : squareSize
        implicitHeight: variants.showTrack ? pillHeight : squareSize
        color: "transparent"
        visible: isActive

        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: variants.showTrack ? height / 2 : Theme.popupRadius
            color: Theme.backgroundTranslucent

            Text {
                visible: !variants.showTrack
                anchors.centerIn: parent
                font.pixelSize: Theme.fontSizeOsdIconLarge
                font.family: Theme.fontFamilyIcons
                color: variants.iconColor
                text: variants.iconText
            }

            RowLayout {
                visible: variants.showTrack
                anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 15
                }

                Text {
                    Layout.preferredWidth: 30
                    font.pixelSize: Theme.fontSizeOsdIcon
                    font.family: Theme.fontFamilyIcons
                    color: variants.iconColor
                    verticalAlignment: Text.AlignVCenter
                    text: variants.iconText
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 10
                    radius: 10
                    color: Theme.trackInactive

                    Rectangle {
                        anchors {
                            left: parent.left
                            top: parent.top
                            bottom: parent.bottom
                        }
                        implicitWidth: parent.width * Math.max(0, Math.min(1, variants.ratio))
                        radius: parent.radius
                        color: variants.trackFillColor
                    }
                }
            }
        }
    }
}
