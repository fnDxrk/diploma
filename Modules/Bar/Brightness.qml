import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Item {
  id: root

  required property var barWindow

  readonly property real scrollStep: 0.05
  readonly property string popupId: "brightness"

  // Backlight is internal-panel only — eDP-* / DSI-* on most laptops.
  // External monitors (HDMI/DP) don't expose /sys/class/backlight, so hide
  // the icon on those bars to avoid the illusion that it controls them.
  visible: Brightness.available && root.barWindow.screen
           && /^(eDP|DSI|LVDS)/i.test(root.barWindow.screen.name)
  implicitWidth: bIcon.implicitWidth
  implicitHeight: bIcon.implicitHeight

  BarIcon {
    id: bIcon
    anchors.centerIn: parent
    icon: Brightness.icon
    glyphs: ["󰃞", "󰃟", "󰃠"]
    fontSize: Theme.fontSizeBar
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
        Brightness.bump(root.scrollStep);
      else if (event.angleDelta.y < 0)
        Brightness.bump(-root.scrollStep);
    }
  }
}
