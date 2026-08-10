import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// Far right. Opens the full-screen power menu.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.accent
    slash: true
    padding: Theme.padS
    active: Actions.powerMenuOpen
    implicitWidth: Theme.barHeight - 4 + contentPad

    onClicked: Actions.togglePowerMenu()

    Icon {
        id: glyph
        anchors.centerIn: parent
        text: "󰐥"
        font.pixelSize: Theme.fsLarge
        color: root.hovered || Actions.powerMenuOpen ? Theme.accent : Theme.subtext
    }

    // A crimson halo that swells under the pointer.
    Rectangle {
        anchors.centerIn: glyph
        z: -1
        width: root.hovered ? 26 : 0
        height: width
        radius: width / 2
        color: Theme.alpha(Theme.accent, 0.18)

        Behavior on width {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
        }
    }
}
