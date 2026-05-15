import QtQuick
import qs.Commons
import qs.Services

Text {
    id: root

    visible: KeyboardLayout.available
    color: Theme.foreground
    font.pixelSize: Theme.fontSizeBar
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    text: KeyboardLayout.shortName.toLowerCase()

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: KeyboardLayout.cycle()
    }
}
