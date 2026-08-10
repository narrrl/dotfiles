import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// The house mark, far left. Click launches the app menu; right click reloads
// the shell, which is handy while tweaking the config.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.accent
    slash: true
    padding: Theme.padS
    lean: Theme.skew
    implicitWidth: Theme.barHeight + contentPad

    onClicked: Actions.launch("fuzzel")
    onRightClicked: Actions.reloadShell()

    Icon {
        id: mark
        anchors.centerIn: parent
        text: "󰋠"
        font.pixelSize: Theme.fsTitle
        color: root.hovered ? Theme.accent : Theme.primary
    }

    // Spin the mark on click, then settle.
    Connections {
        target: root
        function onClicked() { spin.restart(); }
    }

    SequentialAnimation {
        id: spin
        NumberAnimation {
            target: mark; property: "rotation"
            from: 0; to: 360; duration: Theme.durSlow
            easing.type: Easing.OutExpo
        }
    }
}
