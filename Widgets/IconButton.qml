import QtQuick
import qs.Commons

// Clickable icon. Hover background, optional active state for toggles.
// Fixed square size so different glyphs don't shift surrounding layout.
Item {
    id: root

    property string icon: ""
    property bool active: false
    property int iconSize: Theme.fontSizeBar
    property int padding: 6

    signal clicked()

    // Square: width == height. Width is generous so any glyph fits without shifting.
    readonly property int side: iconSize + padding * 2 + 4
    implicitWidth: side
    implicitHeight: side

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: mouse.containsMouse ? Theme.hover : "transparent"
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: root.iconSize
        font.family: Theme.fontFamilyIcons
        color: root.active ? Theme.foreground : Theme.foregroundDim
        text: root.icon
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }
}
