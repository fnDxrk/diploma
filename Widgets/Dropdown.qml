import QtQuick
import qs.Commons

// Inline dropdown: header always visible, list expands below on click.
// Hover on any row shows a themed Tooltip with the full label.
Item {
    id: root

    property var model: []
    property var selected: null
    property var labelFunction: item => String(item)
    property string leadingIcon: ""

    property bool expanded: false

    signal itemSelected(var item)

    implicitWidth: 200
    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: 2

        // ----- Header -----
        Rectangle {
            id: header
            width: parent.width
            height: 32
            radius: 6
            color: headerMouse.containsMouse ? Theme.hover : "transparent"

            Row {
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    leftMargin: 12
                    rightMargin: 12
                }
                spacing: 10

                Text {
                    visible: root.leadingIcon.length > 0
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeBar
                    font.family: Theme.fontFamilyIcons
                    color: Theme.foreground
                    text: root.leadingIcon
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: header.width - 24 - (root.leadingIcon.length > 0 ? 30 : 0) - 16
                    text: root.selected ? root.labelFunction(root.selected) : "—"
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeMenu
                    font.family: Theme.fontFamilyIcons
                    color: Theme.foreground
                    text: root.expanded ? "󰅃" : "󰅀"
                }
            }

            MouseArea {
                id: headerMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.expanded = !root.expanded
            }

            Tooltip {
                text: root.selected ? root.labelFunction(root.selected) : ""
                visible: headerMouse.containsMouse && root.selected
            }
        }

        // ----- Items list -----
        Column {
            id: items
            width: parent.width
            spacing: 2
            visible: root.expanded

            Repeater {
                model: root.model

                Rectangle {
                    required property var modelData
                    width: items.width
                    height: 28
                    radius: 6
                    color: itemMouse.containsMouse ? Theme.hover : "transparent"

                    Row {
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            leftMargin: 12
                            rightMargin: 12
                        }
                        spacing: 10

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 16
                            text: root.labelFunction(modelData)
                            color: Theme.foreground
                            font.pixelSize: Theme.fontSizeMenu
                            font.family: Theme.fontFamily
                            elide: Text.ElideRight
                        }

                        Text {
                            visible: modelData === root.selected
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Theme.fontSizeMenu
                            font.family: Theme.fontFamilyIcons
                            color: Theme.foreground
                            text: "󰄬"
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.itemSelected(modelData);
                            root.expanded = false;
                        }
                    }

                    Tooltip {
                        text: root.labelFunction(parent.modelData)
                        visible: itemMouse.containsMouse
                    }
                }
            }
        }
    }
}
