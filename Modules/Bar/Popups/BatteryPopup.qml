import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    Column {
        width: 280
        spacing: 12

        // ----- Battery status (laptops only) -----

        Row {
            visible: Battery.available
            width: parent.width
            spacing: 10

            BarIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: Battery.icon
                glyphs: ["󰂄", "󰁹", "󰂂", "󰂁", "󰂀", "󰁿", "󰁾", "󰁽", "󰁼", "󰁻", "󰁺"]
                fontSize: Theme.fontSizeAudio
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: Battery.available ? `${Math.round(Battery.percentage * 100)}%` : ""
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeBar
                    font.family: Theme.fontFamily
                    font.weight: Font.Medium
                }

                Text {
                    text: Battery.charging ? "Charging" : "On battery"
                    color: Theme.foregroundDim
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamily
                }
            }
        }

        // ----- Power profile picker -----

        Column {
            visible: Power.available
            width: parent.width
            spacing: 6

            Text {
                text: "Power profile"
                color: Theme.foregroundDim
                font.pixelSize: Theme.fontSizeMenu
                font.family: Theme.fontFamily
            }

            Row {
                width: parent.width
                spacing: 6

                Repeater {
                    model: Power.profiles

                    Rectangle {
                        required property string modelData
                        readonly property bool isActive: Power.profile === modelData

                        width: (parent.width - parent.spacing * 2) / 3
                        height: 36
                        radius: 6
                        color: isActive ? Theme.foreground
                              : (mouse.containsMouse ? Theme.hover : "transparent")
                        border.color: Theme.foregroundDim
                        border.width: isActive ? 0 : 1

                        Text {
                            anchors.centerIn: parent
                            text: Power.iconFor(modelData)
                            color: parent.isActive ? Theme.background : Theme.foreground
                            font.pixelSize: Theme.fontSizeBar
                            font.family: Theme.fontFamilyIcons
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Power.setProfile(modelData)
                        }

                        Tooltip {
                            text: {
                                if (parent.modelData === "performance") return "Performance";
                                if (parent.modelData === "power-saver") return "Power saver";
                                return "Balanced";
                            }
                            visible: mouse.containsMouse
                            screenWidth: root.screenWidth
                            triggerScreenX: root.screenXOf(parent)
                            triggerWidth: parent.width
                        }
                    }
                }
            }
        }

        // ----- Full charge (TLP-only) -----

        Rectangle {
            visible: Power.supportsFullCharge
            width: parent.width
            height: 36
            radius: 6
            color: fcMouse.containsMouse ? Theme.hover : "transparent"
            border.color: Theme.foregroundDim
            border.width: 1

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂄"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeBar
                    font.family: Theme.fontFamilyIcons
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Full charge"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamily
                }
            }

            MouseArea {
                id: fcMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: { Power.fullCharge(); BarPopupController.close("battery"); }
            }

            Tooltip {
                text: "Override charge threshold once. Requires password."
                visible: fcMouse.containsMouse
                screenWidth: root.screenWidth
                triggerScreenX: root.screenXOf(parent)
                triggerWidth: parent.width
            }
        }
    }
}
