import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Scope {
  id: root

  function lock() {
    auth.currentText = "";
    auth.showFailure = false;
    session.locked = true;
  }

  Auth {
    id: auth
    onUnlocked: session.locked = false
  }

  WlSessionLock {
    id: session

    locked: false

    WlSessionLockSurface {
      Surface {
        anchors.fill: parent
        context: auth
      }
    }
  }

  IpcHandler {
    target: "lockscreen"
    function lock() { root.lock(); }
  }
}
