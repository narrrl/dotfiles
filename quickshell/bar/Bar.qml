import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// One bar per monitor.
//
// Identity, workspaces and the focused window on the left; the clock on the
// right. Status moved to the rail and the player and metrics moved to the dock,
// which is what buys the room for this to breathe — nothing here is fighting
// for horizontal space any more, so the title gets a generous cap and the type
// can run large instead of being squeezed to fit between two clusters.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "takemi-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: Theme.barMargin
        left: Theme.barMargin
        right: Theme.barMargin
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight + Theme.barMargin
    color: "transparent"

    // ------------------------------------------------------------------ left
    Row {
        id: leftCluster
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.barGap

        Sigil {
            id: sigil
            screenRef: root.modelData
        }

        BarPill {
            id: spacesPill
            accent: Theme.primary
            padding: Theme.padM
            interactive: false
            lean: Theme.leanFor(1)
            chop: Theme.chopFor(1)
            chopCorners: Theme.cornersFor(1)
            implicitWidth: spacesRow.implicitWidth + contentPad * 2

            Row {
                id: spacesRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Theme.padL

                Workspaces {
                    id: spaces
                    anchors.verticalCenter: parent.verticalCenter
                    screenRef: root.modelData
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 1
                    height: 18
                    color: Theme.alpha(Theme.outline, 0.8)
                }

                ActiveWindow {
                    anchors.verticalCenter: parent.verticalCenter
                    screenRef: root.modelData

                    // The only thing competing for this row is the clock, so the
                    // title can have most of the bar.
                    maxWidth: Math.max(120, root.width
                        - sigil.implicitWidth
                        - clock.implicitWidth
                        - spaces.implicitWidth
                        - Theme.barGap * 3
                        - Theme.padL * 2
                        - Theme.padXL
                        - spacesPill.contentPad * 2)
                }
            }
        }
    }

    // ----------------------------------------------------------------- right
    Clock {
        id: clock
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        screenRef: root.modelData
    }

    // A hairline of crimson under the whole bar — the Persona 5 underscore.
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.18; color: Theme.alpha(Theme.accent, 0.55) }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.primary, 0.35) }
            GradientStop { position: 0.82; color: Theme.alpha(Theme.accent, 0.55) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
}
