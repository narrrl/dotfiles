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
    padding: Theme.padS
    implicitWidth: Theme.barHeight + contentPad

    onClicked: Actions.toggleLauncher()
    onRightClicked: Actions.reloadShell()

    Porthole {
        anchors.centerIn: parent
        size: 18
        lit: root.hovered
    }
}
