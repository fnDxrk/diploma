import QtQuick
import QtQuick.Controls.Basic

Rectangle {
  id: root

  required property QtObject context

  signal escapePressed()
  signal keyPressed()

  property bool passwordVisible: false
  property alias inputItem: passwordBox

  implicitWidth: 340
  implicitHeight: 52
  radius: height / 2
  color: "#1a1a1a"
  border.color: passwordBox.activeFocus ? "#ffffff" : "#333333"
  border.width: 1
  antialiasing: true
  layer.enabled: true
  layer.samples: 16
  layer.smooth: true

  TextField {
    id: passwordBox

    anchors.left: parent.left
    anchors.right: revealButton.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 48
    anchors.rightMargin: 4

    background: Item {}
    horizontalAlignment: TextInput.AlignHCenter

    selectByMouse: true
    selectionColor: "#444444"
    selectedTextColor: "#ffffff"

    clip: true
    color: "#ffffff"
    placeholderText: "Password"
    placeholderTextColor: "#666666"
    font.pixelSize: 16
    font.family: "JetBrains Mono"

    focus: false
    enabled: !root.context.unlockInProgress
    echoMode: root.passwordVisible ? TextInput.Normal : TextInput.Password
    inputMethodHints: Qt.ImhSensitiveData

    onTextChanged: root.context.currentText = text
    onAccepted: root.context.tryUnlock()
    Keys.onPressed: event => {
      root.keyPressed();
      event.accepted = false;
    }
    Keys.onEscapePressed: root.escapePressed()

    Connections {
      target: root.context

      function onCurrentTextChanged() {
        passwordBox.text = root.context.currentText;
      }

      function onShowFailureChanged() {
        if (root.context.showFailure) passwordBox.selectAll();
      }
    }
  }

  Text {
    id: revealButton

    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.rightMargin: 12

    width: 36
    height: 36
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    font.pixelSize: 20
    font.family: "JetBrains Mono Nerd Font"
    color: revealMouse.containsMouse ? "#ffffff" : "#888888"
    text: root.passwordVisible ? "\u{f06d1}" : "\u{f06d0}"

    MouseArea {
      id: revealMouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.passwordVisible = !root.passwordVisible
    }
  }
}
