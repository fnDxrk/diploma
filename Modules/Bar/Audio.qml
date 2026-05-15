import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Item {
  id: root

  required property var barWindow

  readonly property real scrollStep: 0.05
  readonly property string popupId: "audio"

  implicitWidth: bIcon.implicitWidth
  implicitHeight: bIcon.implicitHeight

  BarIcon {
    id: bIcon
    anchors.centerIn: parent
    icon: Audio.icon
    glyphs: ["󰝟", "󰕿", "󰖀", "󰕾"]
    fontSize: Theme.fontSizeAudio
    weight: Font.Medium
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton

    onClicked: {
      const p = root.mapToItem(null, 0, 0);
      BarPopupController.toggle(root.popupId, p.x, root.width, root.barWindow.screen, root.barWindow);
    }

    onWheel: event => {
      if (event.angleDelta.y > 0)
        Audio.bump(root.scrollStep);
      else if (event.angleDelta.y < 0)
        Audio.bump(-root.scrollStep);
    }
  }
}
