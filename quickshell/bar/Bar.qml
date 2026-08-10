import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// One bar per monitor.
//
// Layout is three clusters: identity and system state on the left, the clock
// and player dead centre, controls on the right. The centre is genuinely
// centred, so the left cluster's window title is capped at whatever space is
// actually left over — otherwise the clusters overlap on a 1080p panel.
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

    // Half the space not taken by the centre cluster, minus breathing room.
    readonly property real sideBudget:
        (width - centreCluster.width) / 2 - Theme.barGap * 2

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
            padding: Theme.padS
            interactive: false
            implicitWidth: spacesRow.implicitWidth + contentPad * 2

            Row {
                id: spacesRow
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                spacing: Theme.padM

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

                    // Everything else on this side is fixed width, so the title
                    // gets whatever remains.
                    maxWidth: Math.max(70, root.sideBudget
                        - sigil.implicitWidth
                        - resources.implicitWidth
                        - spaces.implicitWidth
                        - Theme.barGap * 2
                        - Theme.padM * 3
                        - spacesPill.leanInset)
                }
            }
        }

        Resources {
            id: resources
            screenRef: root.modelData
        }
    }

    // ---------------------------------------------------------------- centre
    Row {
        id: centreCluster
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.barGap

        MediaPill {
            screenRef: root.modelData
        }

        Clock {
            screenRef: root.modelData
        }
    }

    // ----------------------------------------------------------------- right
    Row {
        id: rightCluster
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.barGap

        Tray {
            screenRef: root.modelData
        }

        Status {
            screenRef: root.modelData
        }

        NotifButton {
            screenRef: root.modelData
        }

        PowerButton {
            screenRef: root.modelData
        }
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
