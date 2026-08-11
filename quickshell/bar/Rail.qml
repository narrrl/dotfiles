import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// The right-hand status rail — one slab, not a stack of cards.
//
// Connectivity, audio, power, tray and notifications all sit inside a single
// continuous column, divided by hairline rules the same way the bar divides its
// modules. Same lean, same chamfer, same keyline as the bar and the dock, so
// the three surfaces read as one system.
//
// On a 1080p panel this is the cheap edge: 48px of width is 2.5% of the screen,
// where the same 48px of height would be 4.4% on top of what the bar takes.
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

    // The slab.
    P5Panel {
        id: slab
        anchors.fill: parent
        vertical: true
        lean: Theme.skew
        chop: Theme.cut
        chopCorners: [1, 3]
        padding: 0
        fill: Theme.surface
        fillOpacity: 1.0
        border: Theme.alpha(Theme.outline, 0.9)
        borderWidth: 1
        slash: true
        slashColor: Theme.accent
        slashWidth: 5

        // Same as the bar — see the note there. The doubled corner is worse on
        // the rail, because its chopped corners sit against the wallpaper's
        // high-contrast stripes rather than against other chrome.
        drop: false
    }

    readonly property real edgeInset: Theme.railWidth * Theme.skew + Theme.padM

    // ------------------------------------------------------------------- top
    Column {
        id: upper
        anchors.top: parent.top
        anchors.topMargin: root.edgeInset
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        RailIcon {
            id: netIcon
            icon: Net.icon
            dim: !Sys.netUp
            onClicked: netPopout.pinned = !netPopout.pinned
            onRightClicked: Net.toggleWifi()
            onMiddleClicked: Actions.openNetworkSettings()
        }

        RailIcon {
            id: btIcon
            icon: Bt.icon
            dim: !Bt.enabled
            onClicked: btPopout.pinned = !btPopout.pinned
            onRightClicked: Bt.toggle()
        }

        Divider {}

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
            onScrolled: delta => Brightness.change(delta > 0 ? 5 : -5)
        }

        Divider { visible: Battery.available }

        RailIcon {
            id: battIcon
            visible: Battery.available
            icon: Battery.icon
            readout: Math.round(Battery.percent) + "%"
            alert: Battery.critical
            pulsing: Battery.critical
            onClicked: battPopout.pinned = !battPopout.pinned
        }
    }

    // ---------------------------------------------------------------- bottom
    Column {
        id: lower
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.edgeInset
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        Tray {
            id: tray
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Divider { visible: tray.visible }

        RailIcon {
            id: bellIcon
            icon: Notifs.icon
            readout: Notifs.unread > 0
                ? (Notifs.unread > 9 ? "9+" : String(Notifs.unread))
                : ""
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
            alert: Actions.powerMenuOpen
            onClicked: Actions.togglePowerMenu()
        }
    }

    // The rail's counterpart to the bar's divider: a horizontal hairline,
    // sheared to the same angle the rail's own edges lean at.
    component Divider: Item {
        implicitWidth: Theme.railWidth
        implicitHeight: Theme.padM + 4

        Skew {
            anchors.centerIn: parent
            width: 22
            height: 1
            vertical: true
            color: Theme.alpha(Theme.outline, 0.9)
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
