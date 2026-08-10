import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// Focused window title, glitching on every change the way a Persona 5 caption
// snaps into place.
Item {
    id: root

    required property var screenRef

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screenRef)
    readonly property HyprlandToplevel toplevel: Hyprland.activeToplevel

    // Only speak for the monitor this bar lives on.
    readonly property bool mine: toplevel !== null
        && (root.monitor === null || toplevel.monitor === null
            || toplevel.monitor.id === root.monitor.id)

    readonly property string title: mine && toplevel.title ? toplevel.title : "—"

    // The bar shrinks this when the three clusters would otherwise collide.
    property real maxWidth: 240

    implicitWidth: Math.min(maxWidth, Math.max(70, label.implicitWidth + 4))
    implicitHeight: 20

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutExpo }
    }

    Marquee {
        id: label
        anchors.fill: parent
        text: root.title
        color: root.mine ? Theme.subtext : Theme.muted
        pixelSize: Theme.fsSmall
        family: Theme.fontDisplay
        italic: true
        weight: Font.DemiBold
    }

    onTitleChanged: flash.restart()

    // A quick crimson wipe under the title on focus change.
    Rectangle {
        id: wipe
        anchors.bottom: parent.bottom
        height: 2
        width: 0
        color: Theme.accent
        opacity: 0
    }

    SequentialAnimation {
        id: flash
        ParallelAnimation {
            NumberAnimation {
                target: wipe; property: "width"
                from: 0; to: root.width
                duration: Theme.durBase; easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: wipe; property: "opacity"
                from: 0; to: 1; duration: Theme.durFast
            }
        }
        NumberAnimation {
            target: wipe; property: "opacity"
            to: 0; duration: Theme.durSlow
        }
    }
}
