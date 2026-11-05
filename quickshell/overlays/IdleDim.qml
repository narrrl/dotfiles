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
        opacity: 0

        // States, not a Behavior: a Behavior whose duration is bound to
        // Idle.dimmed can start before that binding updates, so waking up
        // would replay the slow fade in reverse.
        states: State {
            name: "dimmed"
            when: Idle.dimmed
            PropertyChanges { shade.opacity: 0.6 }
        }

        transitions: [
            Transition {
                to: "dimmed"
                NumberAnimation { property: "opacity"; duration: 8000; easing.type: Easing.InOutSine }
            },
            Transition {
                from: "dimmed"
                NumberAnimation { property: "opacity"; duration: Theme.durBase; easing.type: Easing.OutCubic }
            }
        ]
    }
}
