import QtQuick
import qs.Commons
import qs.Widgets

// Generic clock label. Defaults to bar styling via Theme; usage sites can
// override font/size/color (e.g. lockscreen uses 96px).
Text {
  id: root

  color: Theme.foreground
  font.pixelSize: Theme.fontSizeBar
  font.family: Theme.fontFamily
  font.weight: Font.Medium

  function updateTime() {
    const now = new Date();
    const pad = n => String(n).padStart(2, '0');
    text = `${pad(now.getHours())}:${pad(now.getMinutes())}`;
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.updateTime()
  }

  Component.onCompleted: updateTime()
}
