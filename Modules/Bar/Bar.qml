import Quickshell
import QtQuick
import qs.Commons
import qs.Widgets

Variants {
  model: Quickshell.screens

  PanelWindow {
    id: bar

    property var modelData
    readonly property bool popupOpen: BarPopupController.current !== ""

    screen: modelData
    anchors {
      top: true
      left: true
      right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.background


    // Click on empty bar area while a popup is open closes the popup.
    // Widget MouseAreas are above this and handle their own clicks.
    MouseArea {
      anchors.fill: parent
      enabled: bar.popupOpen
      onClicked: BarPopupController.close(BarPopupController.current)
    }

    // Left cluster: workspaces for this monitor
    Workspaces {
      outputName: bar.screen?.name ?? ""
      anchors.left: parent.left
      anchors.leftMargin: 16
      anchors.verticalCenter: parent.verticalCenter
    }

    Clock {
      anchors.centerIn: parent
    }

    Row {
      anchors.right: parent.right
      anchors.rightMargin: 16
      anchors.verticalCenter: parent.verticalCenter
      spacing: 16

      Tray {
        id: tray
        barWindow: bar
        anchors.verticalCenter: parent.verticalCenter
      }

      KeyboardLayout {
        anchors.verticalCenter: parent.verticalCenter
      }

      Bluetooth {
        id: bluetooth
        barWindow: bar
        anchors.verticalCenter: parent.verticalCenter
      }

      Network {
        id: network
        anchors.verticalCenter: parent.verticalCenter
      }

      Brightness {
        id: brightness
        barWindow: bar
        anchors.verticalCenter: parent.verticalCenter
      }

      Audio {
        id: audio
        barWindow: bar
        anchors.verticalCenter: parent.verticalCenter
      }

      Battery {
        id: battery
        barWindow: bar
        anchors.verticalCenter: parent.verticalCenter
      }
    }
  }
}
