import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    Column {
        width: 340
        spacing: 10

        // ----- Header -----

        RowLayout {
            width: parent.width
            height: 32

            Text {
                text: "Bluetooth"
                color: Theme.foreground
                font.pixelSize: Theme.fontSizeBar
                font.family: Theme.fontFamily
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            Toggle {
                checked: Bluetooth.enabled
                onToggled: Bluetooth.toggleEnabled()
            }
        }

        // ----- Scan row -----

        RowLayout {
            visible: Bluetooth.enabled
            width: parent.width
            height: 28

            Text {
                text: Bluetooth.discovering ? "Scanning…" : "Available devices"
                color: Theme.foregroundDim
                font.pixelSize: Theme.fontSizeMenu
                font.family: Theme.fontFamily
            }

            Item { Layout.fillWidth: true }

            // Clear discovered (only visible when there's something to clear)
            Rectangle {
                visible: Bluetooth.hasDiscovered
                Layout.preferredWidth: 70
                Layout.preferredHeight: 26
                radius: 4
                color: clearMouse.containsMouse ? Theme.hover : "transparent"
                border.color: Theme.foregroundDim
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Clear"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Bluetooth.clearDiscovered()
                }
            }

            Rectangle {
                Layout.preferredWidth: 90
                Layout.preferredHeight: 26
                radius: 4
                color: scanMouse.containsMouse ? Theme.hover : "transparent"
                border.color: Theme.foregroundDim
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: Bluetooth.discovering ? "Stop" : "Scan"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamily
                }

                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Bluetooth.setDiscovering(!Bluetooth.discovering)
                }
            }
        }

        Rectangle {
            visible: Bluetooth.enabled
            width: parent.width
            height: 1
            color: Theme.separator
        }

        // ----- Devices list -----

        ScrollView {
            visible: Bluetooth.enabled && Bluetooth.devices.length > 0
            width: parent.width
            height: 280
            clip: true

            ListView {
                anchors.fill: parent
                spacing: 2
                model: Bluetooth.devices

                delegate: Rectangle {
                    id: deviceRow
                    required property var modelData

                    readonly property bool isConnecting: modelData.state === Bluetooth.stateConnecting
                    readonly property bool isDisconnecting: modelData.state === Bluetooth.stateDisconnecting

                    width: ListView.view.width
                    height: 44
                    radius: 6
                    color: itemMouse.containsMouse ? Theme.hover : "transparent"

                    RowLayout {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 10
                            rightMargin: 10
                        }
                        spacing: 10

                        // Status icon
                        Text {
                            text: deviceRow.modelData.connected ? "󰂱"
                                  : (deviceRow.modelData.paired ? "󰂯" : "󰂲")
                            color: deviceRow.modelData.connected ? Theme.foreground : Theme.foregroundDim
                            font.pixelSize: Theme.fontSizeBar
                            font.family: Theme.fontFamilyIcons
                        }

                        // Click area: name + status text only (forget is separate)
                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height

                            Column {
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    width: parent.width
                                    text: Bluetooth.labelFor(deviceRow.modelData)
                                    color: Theme.foreground
                                    font.pixelSize: Theme.fontSizeMenu
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                }

                                Text {
                                    width: parent.width
                                    visible: text.length > 0
                                    text: deviceRow.isConnecting ? "Connecting…"
                                          : deviceRow.isDisconnecting ? "Disconnecting…"
                                          : deviceRow.modelData.pairing ? "Pairing…"
                                          : deviceRow.modelData.connected ? "Connected"
                                          : deviceRow.modelData.paired ? "Paired"
                                          : ""
                                    color: Theme.foregroundDim
                                    font.pixelSize: Theme.fontSizeMenu - 2
                                    font.family: Theme.fontFamily
                                }
                            }

                            MouseArea {
                                id: itemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: !deviceRow.isConnecting && !deviceRow.isDisconnecting
                                onClicked: {
                                    const d = deviceRow.modelData;
                                    if (!d.paired) {
                                        Bluetooth.safePair(d);
                                    } else if (d.connected) {
                                        Bluetooth.disconnect(d);
                                    } else {
                                        Bluetooth.safeConnect(d);
                                    }
                                }
                            }
                        }

                        Text {
                            visible: deviceRow.modelData.batteryAvailable
                            text: `${Math.round((deviceRow.modelData.battery ?? 0) * 100)}%`
                            color: Theme.foregroundDim
                            font.pixelSize: Theme.fontSizeMenu
                            font.family: Theme.fontFamily
                        }

                        // Forget button
                        Rectangle {
                            visible: deviceRow.modelData.paired
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: 4
                            color: forgetMouse.containsMouse ? "#ff5555" : "transparent"
                            border.color: forgetMouse.containsMouse ? "#ff5555" : "#80ff5555"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: forgetMouse.containsMouse ? "#ffffff" : "#ff5555"
                                font.pixelSize: Theme.fontSizeMenu
                                font.family: Theme.fontFamily
                                font.weight: Font.Bold
                            }

                            MouseArea {
                                id: forgetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Bluetooth.forget(deviceRow.modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
