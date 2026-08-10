import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/services"
import "root:/lock"

// Session lock. Replaces hyprlock; authenticates through the existing
// /etc/pam.d/hyprlock stack, which is just `auth include login`.
//
// The visuals live in LockFace so they can be exercised in an ordinary window
// (see lockpreview.qml) without locking the session to test a colour.
WlSessionLock {
    id: lock

    locked: Actions.lockRequested

    WlSessionLockSurface {
        color: "black"

        LockFace {
            anchors.fill: parent
            onUnlocked: Actions.lockRequested = false
        }
    }
}
