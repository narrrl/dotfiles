import QtQuick
import Quickshell
import "root:/config"
import "root:/lock"

// Development harness: renders the lock screen in an ordinary window so it can
// be styled and screenshotted without locking the session.
//
//   qs -p lockpreview.qml
//
// PAM still runs for real here, so a correct password simply closes the window.
ShellRoot {
    FloatingWindow {
        implicitWidth: 1600
        implicitHeight: 900
        color: Theme.base

        LockFace {
            anchors.fill: parent
            onUnlocked: console.log("PAM accepted — the real lock would release here")
        }
    }
}
