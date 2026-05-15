import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.Commons
import qs.Services
import qs.Widgets

Rectangle {
  id: root

  required property QtObject context

  readonly property int idleTimeoutMs: 5000
  property bool idle: true

  color: "#000000"
  focus: true

  Component.onCompleted: {
    idle = true;
    cursorHidden = true;
    context.currentText = "";
    forceActiveFocus();
  }

  function wake() {
    if (idle) {
      idle = false;
      passwordField.inputItem.forceActiveFocus();
    }
    idleTimer.restart();
  }

  function sleep() {
    idle = true;
    context.currentText = "";
    root.forceActiveFocus();
    idleTimer.stop();
  }

  Keys.onPressed: event => {
    root.cursorHidden = true;
    cursorTimer.stop();
    if (root.idle) {
      root.wake();
      event.accepted = true;
    } else {
      idleTimer.restart();
    }
  }

  readonly property int cursorTimeoutMs: 2000
  property bool cursorHidden: true

  function showCursor() {
    cursorHidden = false;
    cursorTimer.restart();
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    propagateComposedEvents: true
    cursorShape: root.cursorHidden ? Qt.BlankCursor : Qt.ArrowCursor
    onPositionChanged: root.showCursor()
    onPressed: mouse => {
      root.showCursor();
      root.wake();
      mouse.accepted = false;
    }
    onWheel: wheel => {
      root.showCursor();
      root.wake();
      wheel.accepted = false;
    }
  }

  Timer {
    id: cursorTimer
    interval: root.cursorTimeoutMs
    running: false
    repeat: false
    onTriggered: root.cursorHidden = true
  }

  Timer {
    id: idleTimer
    interval: root.idleTimeoutMs
    running: true
    repeat: false
    onTriggered: {
      root.idle = true;
      root.context.currentText = "";
      root.forceActiveFocus();
    }
  }

  Connections {
    target: root.context
    function onCurrentTextChanged() {
      if (root.context.currentText !== "") idleTimer.restart();
    }
  }

  Text {
    id: bypassButton

    anchors.left: parent.left
    anchors.top: parent.top
    anchors.leftMargin: 16
    anchors.topMargin: 12

    text: "\u{f05a9}"
    font.pixelSize: 22
    font.family: "JetBrains Mono Nerd Font"
    color: bypassMouse.containsMouse ? "#ff5555" : "#555555"

    MouseArea {
      id: bypassMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.context.unlocked()
    }
  }

  Column {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: root.idle ? 0 : -100

    Behavior on anchors.verticalCenterOffset {
      NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }

    spacing: 12

    Clock {
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 96
      font.family: "JetBrains Mono"
      font.weight: Font.Light
      color: "#ffffff"
    }

    Text {
      id: dateLabel

      anchors.horizontalCenter: parent.horizontalCenter
      property var date: new Date()

      font.pixelSize: 22
      font.family: "JetBrains Mono"
      font.weight: Font.Medium
      color: "#aaaaaa"

      text: Qt.formatDate(date, "d MMMM yyyy")

      Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: dateLabel.date = new Date()
      }
    }
  }

  PasswordField {
    id: passwordField

    opacity: root.idle ? 0 : 1
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    anchors.verticalCenterOffset: 80
    context: root.context
    onEscapePressed: root.sleep()
    onKeyPressed: {
      root.cursorHidden = true;
      cursorTimer.stop();
    }

    Behavior on opacity {
      NumberAnimation { duration: 250 }
    }
  }

  Text {
    visible: !root.idle && root.context.showFailure
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: passwordField.bottom
    anchors.topMargin: 16

    text: "Incorrect password"
    color: "#ff5555"
    font.pixelSize: 16
    font.family: "JetBrains Mono"
    font.weight: Font.Medium
  }

  // Weather widget — centered along the bottom edge.
  // Hidden while entering password to keep focus on the prompt.
  Row {
    visible: Weather.available
    opacity: root.idle ? 1 : 0
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 48
    spacing: 12

    Behavior on opacity { NumberAnimation { duration: 250 } }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: Weather.icon
      color: "#ffffff"
      font.pixelSize: 32
      font.family: "JetBrains Mono Nerd Font"
    }

    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 2

      Text {
        text: Weather.display
        color: "#ffffff"
        font.pixelSize: 22
        font.family: "JetBrains Mono"
        font.weight: Font.Medium
      }

      Text {
        text: (Weather.city ? Weather.city + " · " : "") + Weather.condition
        color: "#aaaaaa"
        font.pixelSize: 14
        font.family: "JetBrains Mono"
      }
    }
  }
}
