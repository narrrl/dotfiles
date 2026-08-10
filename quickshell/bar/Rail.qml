import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// The right-hand status rail.
//
// Everything that used to be crammed into the right third of the top bar lives
// here instead: connectivity, audio, power, tray, notifications. On a 1080p
// panel this is the cheap edge — 48px of width is 2.5% of the screen, where the
// same 48px of height would have been 4.4% on top of what the top bar already
// takes.
//
// Slabs are grouped by what they do rather than spaced evenly, and each pulls a
// different lean and chamfer from the shape tables, so the column reads as a
// stack of distinct cards instead of a ladder.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "takemi-rail"

    anchors {
        top: true
        bottom: true
        right: true
    }

    margins {
        top: Theme.barHeight + Theme.barMargin * 2
        bottom: Theme.barMargin
        right: Theme.barMargin
    }

    implicitWidth: Theme.railWidth
    exclusiveZone: Theme.railWidth + Theme.barMargin
    color: "transparent"

    // Corner furniture. The dock pins a crimson wedge to the bottom-left; this
    // is its opposite number, so the desktop is bracketed on the diagonal
    // rather than merely edged. Decorative only — it sits under the slabs and
    // takes no input.
    Shape {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 30
        height: 30
        z: -1
        preferredRendererType: Shape.CurveRenderer
        opacity: 0.9

        ShapePath {
            fillColor: Theme.accent
            strokeColor: "transparent"
            PathPolyline {
                path: [
                    Qt.point(30, 30),
                    Qt.point(30, 4),
                    Qt.point(2, 30),
                    Qt.point(30, 30)
                ]
            }
        }
    }

    // ------------------------------------------------------------------- top
    Column {
        id: upper
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.railGap

        // Connectivity.
        RailGroup {
            variant: 0
            accent: Sys.netUp ? Theme.primary : Theme.muted
            implicitHeight: linkCol.implicitHeight + contentPad * 2

            Column {
                id: linkCol
                anchors.centerIn: parent
                spacing: Theme.padS

                RailIcon {
                    id: netIcon
                    icon: Net.icon
                    tint: Theme.primary
                    dim: !Sys.netUp
                    onClicked: netPopout.pinned = !netPopout.pinned
                    onRightClicked: Net.toggleWifi()
                    onMiddleClicked: Actions.openNetworkSettings()
                }

                RailIcon {
                    id: btIcon
                    icon: Bt.icon
                    tint: Theme.primary
                    dim: !Bt.enabled
                    onClicked: btPopout.pinned = !btPopout.pinned
                    onRightClicked: Bt.toggle()
                }
            }
        }

        // Audio and backlight.
        RailGroup {
            variant: 1
            accent: Audio.muted || Audio.micMuted ? Theme.accent : Theme.primary
            implicitHeight: audioCol.implicitHeight + contentPad * 2

            Column {
                id: audioCol
                anchors.centerIn: parent
                spacing: Theme.padS

                RailIcon {
                    id: volIcon
                    icon: Audio.icon
                    readout: Audio.muted ? "" : Audio.volumePercent + "%"
                    alert: Audio.muted
                    onClicked: Audio.toggleMute()
                    onRightClicked: audioPopout.pinned = !audioPopout.pinned
                    onMiddleClicked: Actions.openAudioSettings()
                    onScrolled: delta => Audio.changeVolume(delta > 0 ? 0.05 : -0.05)
                }

                RailIcon {
                    id: micIcon
                    icon: Audio.micIcon
                    alert: Audio.micMuted
                    onClicked: Audio.toggleMicMute()
                    onRightClicked: audioPopout.pinned = !audioPopout.pinned
                    onScrolled: delta => Audio.setMicVolume(Audio.micVolume + (delta > 0 ? 0.05 : -0.05))
                }

                RailIcon {
                    id: brightIcon
                    visible: Brightness.available
                    icon: Brightness.icon
                    readout: Math.round(Brightness.percent) + "%"
                    tint: Theme.primary
                    onScrolled: delta => Brightness.change(delta > 0 ? 5 : -5)
                }
            }
        }

        // Battery.
        RailGroup {
            variant: 2
            visible: Battery.available
            accent: Battery.critical ? Theme.accent : Theme.primary
            implicitHeight: battIcon.implicitHeight + contentPad * 2

            RailIcon {
                id: battIcon
                anchors.centerIn: parent
                icon: Battery.icon
                readout: Math.round(Battery.percent) + "%"
                tint: Battery.tint
                alert: Battery.critical
                pulsing: Battery.critical
                onClicked: battPopout.pinned = !battPopout.pinned
            }
        }
    }

    // ---------------------------------------------------------------- bottom
    Column {
        id: lower
        anchors.bottom: parent.bottom

        // Clear of the corner wedge, which would otherwise sit entirely behind
        // the bottom slab and never be seen.
        anchors.bottomMargin: 26
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.railGap

        // Tray.
        RailGroup {
            variant: 3
            visible: tray.visible
            accent: Theme.primary
            implicitHeight: tray.implicitHeight + contentPad * 2

            Tray {
                id: tray
                anchors.centerIn: parent
            }
        }

        // Notifications and power — the two that act on the session rather than
        // report on it, so they sit apart at the foot of the rail.
        RailGroup {
            variant: 4
            accent: Notifs.dnd ? Theme.muted : Theme.primary
            implicitHeight: actionCol.implicitHeight + contentPad * 2

            Column {
                id: actionCol
                anchors.centerIn: parent
                spacing: Theme.padS

                RailIcon {
                    id: bellIcon
                    icon: Notifs.icon
                    readout: Notifs.unread > 0
                        ? (Notifs.unread > 9 ? "9+" : String(Notifs.unread))
                        : ""
                    tint: Notifs.hasUnread ? Theme.accent : Theme.primary
                    dim: Notifs.dnd
                    alert: Notifs.hasUnread && !Notifs.dnd
                    onClicked: {
                        notifPopout.pinned = !notifPopout.pinned;
                        Notifs.markRead();
                    }
                    onRightClicked: Notifs.toggleDnd()
                }

                RailIcon {
                    id: powerIcon
                    icon: "󰐥"
                    tint: Actions.powerMenuOpen ? Theme.accent : Theme.subtext
                    onClicked: Actions.togglePowerMenu()
                }
            }
        }
    }

    // ------------------------------------------------------------- popouts
    // All of these hang off the left edge of the rail, opening into the screen.
    NetPopout {
        id: netPopout
        anchorItem: netIcon
        triggerHovered: netIcon.hovered
        fromEdge: Edges.Left
    }

    BtPopout {
        id: btPopout
        anchorItem: btIcon
        triggerHovered: btIcon.hovered
        fromEdge: Edges.Left
    }

    AudioPopout {
        id: audioPopout
        anchorItem: volIcon
        triggerHovered: volIcon.hovered || micIcon.hovered
        fromEdge: Edges.Left
    }

    BatteryPopout {
        id: battPopout
        anchorItem: battIcon
        triggerHovered: battIcon.hovered
        fromEdge: Edges.Left
        visible: Battery.available && shown
    }

    NotifPopout {
        id: notifPopout
        anchorItem: bellIcon
        triggerHovered: bellIcon.hovered
        fromEdge: Edges.Left
    }
}
