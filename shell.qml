import Quickshell
import QtQuick
import qs.Commons
import qs.Widgets
import qs.Themes
import qs.Modules.Bar
import qs.Modules.MainScreen
import qs.Modules.Osd
import qs.Modules.Lockscreen

ShellRoot {
  id: root

  // Available theme objects — instantiated once, picked by Settings.theme name.
  Dark { id: darkTheme }
  Light { id: lightTheme }

  // Map theme name from Settings to the actual object. Add new themes here.
  function themeFor(name) {
    switch (name) {
      case "Light": return lightTheme;
      case "Dark":
      default:      return darkTheme;
    }
  }

  // React to Settings.theme: applied at startup and whenever JSON is edited.
  Component.onCompleted: Theme.current = themeFor(Settings.theme)

  Connections {
    target: Settings
    function onThemeChanged() {
      Theme.current = root.themeFor(Settings.theme);
    }
  }

  Bar {}
  MainScreen {}
  VolumeOSD {}
  BrightnessOSD {}
  MicOSD {}
  Lockscreen {}
}
