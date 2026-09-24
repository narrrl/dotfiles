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

    onClicked: Actions.toggleLauncher()
    onRightClicked: Actions.reloadShell()

    // The wordmark. Was the Death arcana skull (nf-md-skull, U+F068C) — a
    // pictogram in a shell that otherwise says everything in heavy italic
    // type. SplitText puts it in the display face with the ink print
    // offset every other heading carries, so the house mark is built out of
    // the same parts as the rest of the bar.
    SplitText {
        id: mark
        anchors.centerIn: parent
        text: "P5"
        pixelSize: Theme.fsLarge
        letterSpacing: 0
        color: root.hovered ? Theme.accent : Theme.primary
    }

    // Kick the ghosts out and let them snap back. The skull could spin a full
    // turn and still read as a skull; a wordmark upside down just reads as
    // broken, so the click gets the glitch instead.
    Connections {
        target: root
        function onClicked() { mark.glitch(); }
    }
}
