import QtQuick
import qs.Commons
import qs.Services
import qs.Widgets

Row {
  id: root

  spacing: 5

  BarIcon {
    anchors.verticalCenter: parent.verticalCenter
    icon: Network.icon
    glyphs: ["󰈀", "󰤨", "󰤥", "󰤢", "󰤟", "󰤯", "󰤮", "󰪎"]
    fontSize: Theme.fontSizeBar
    weight: Font.Medium
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.foreground
    font.pixelSize: Theme.fontSizeBar
    font.family: Theme.fontFamily
    font.weight: Font.Medium
    text: Network.ssid
    visible: Network.hasWifi && !Network.hasWired
  }
}
