import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/services"

// The first stage of idle (services/Idle.qml): the screen dims the way a room
// does when the lights go down, slowly enough that you notice it before the
// lock does. Any input lifts it at once. Input passes straight through.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-dim"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    mask: Region {}

    visible: Idle.dimmed || shade.opacity > 0

    Rectangle {
        id: shade
        anchors.fill: parent
        color: Theme.ink
        opacity: Idle.dimmed ? 0.6 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Idle.dimmed ? 8000 : Theme.durBase
                easing.type: Idle.dimmed ? Easing.InOutSine : Easing.OutCubic
            }
        }
    }
}
