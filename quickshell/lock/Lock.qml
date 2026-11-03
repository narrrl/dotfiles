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
    onSecureChanged: Actions.lockSecure = lock.secure

    WlSessionLockSurface {
        id: lockSurface
        color: "black"

        LockFace {
            anchors.fill: parent
            // So each screen blurs its own wallpaper, should screens ever get
            // different ones (see Wallpaper.forMonitor).
            screenName: lockSurface.screen ? lockSurface.screen.name : ""
            onUnlocked: Actions.lockRequested = false
        }
    }
}
