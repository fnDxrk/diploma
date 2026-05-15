import QtQuick
import qs.Commons
import qs.Widgets

Rectangle {
    id: root

    default property alias contentChildren: contentItem.data
    property alias contentItem: contentItem
    property int padding: Theme.popupPadding

    implicitWidth: contentItem.childrenRect.width + padding * 2
    implicitHeight: contentItem.childrenRect.height + padding * 2

    color: Theme.background
    radius: Theme.popupRadius
    border.color: Theme.border
    border.width: Theme.popupBorderWidth

    Item {
        id: contentItem

        x: root.padding
        y: root.padding
        width: childrenRect.width
        height: childrenRect.height
    }
}
