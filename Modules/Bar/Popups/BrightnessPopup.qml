import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    Item {
        implicitWidth: 240
        implicitHeight: row.implicitHeight

        Row {
            id: row
            anchors.fill: parent
            spacing: 12

            Item {
                width: 24
                height: Theme.fontSizeBar
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    color: Theme.foreground
                    font.pixelSize: Theme.fontSizeBar
                    font.family: Theme.fontFamilyIcons
                    text: Brightness.icon
                }
            }

            Slider {
                anchors.verticalCenter: parent.verticalCenter
                width: row.width - row.spacing - 24
                value: Brightness.ratio
                onValueRequested: v => Brightness.setLevel(v)
            }
        }
    }
}
