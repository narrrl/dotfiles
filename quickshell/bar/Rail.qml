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

    // Hangs from the underside of the bar, flush with the screen edge. Like
    // the bar it draws no surface of its own; see Frame.
    margins.top: Theme.barHeight
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: Theme.railWidth
    color: "transparent"

    readonly property real edgeInset: Theme.padM

    // ------------------------------------------------------------------- top
    Column {
        id: upper
        anchors.top: parent.top
        anchors.topMargin: root.edgeInset
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0

        // Something is recording or watching. First on the rail and in the
        // light, because it is the one thing here you did not ask to see.
        RailIcon {
            id: privacyIcon
            visible: Privacy.active
            icon: Privacy.screen ? "󰹑" : (Privacy.camera ? "󰄀" : "󰍬")
            label: "In use"
            statusText: Privacy.detail
            live: true
        }

        Divider { visible: Privacy.active }

        RailIcon {
            id: netIcon
            icon: Net.icon
            label: "Network"
            statusText: Net.label
            suppressTooltip: netPopout.detailActive
            dim: !Sys.netUp
            onClicked: netPopout.togglePinned()
        }

        RailIcon {
            id: btIcon
            icon: Bt.icon
            label: "Bluetooth"
            statusText: Bt.label
            suppressTooltip: btPopout.detailActive
            dim: !Bt.enabled
            onClicked: btPopout.togglePinned()
        }

        Divider {}

        RailIcon {
            id: volIcon
            icon: Audio.icon
            readout: Audio.muted ? "" : Audio.volumePercent + "%"
            reserveReadout: true
            label: "Volume"
            statusText: Audio.muted ? "Muted" : Audio.volumePercent + "% · " + Audio.sinkName
            hint: "Scroll to adjust"
            suppressTooltip: audioPopout.detailActive
            dim: Audio.muted
            onClicked: audioPopout.togglePinned()
            onScrolled: delta => Audio.changeVolume(delta > 0 ? 0.05 : -0.05)
        }

        RailIcon {
            id: micIcon
            icon: Audio.micIcon
            label: "Microphone"
            statusText: Audio.micMuted ? "Muted" : Audio.micPercent + "% · " + Audio.sourceName
            hint: "Scroll to adjust"
            suppressTooltip: audioPopout.detailActive
            dim: Audio.micMuted
            onClicked: audioPopout.togglePinned()
            onScrolled: delta => Audio.setMicVolume(Audio.micVolume + (delta > 0 ? 0.05 : -0.05))
        }

        RailIcon {
            id: brightIcon
            visible: Brightness.available
            icon: Brightness.icon
            readout: Math.round(Brightness.percent) + "%"
            label: "Brightness"
            statusText: Math.round(Brightness.percent) + "%"
            hint: "Scroll to adjust"
            onScrolled: delta => Brightness.change(delta > 0 ? 5 : -5)
        }

        Divider { visible: Battery.available }

        RailIcon {
            id: battIcon
            visible: Battery.available
            icon: Battery.icon
            readout: Math.round(Battery.percent) + "%"
            label: "Battery"
            statusText: Math.round(Battery.percent) + "% · " + Battery.timeLabel
            suppressTooltip: battPopout.detailActive
            alarm: Battery.critical
            pulsing: Battery.critical
            onClicked: battPopout.togglePinned()
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

        // Only there while the idle chain is held off by hand, so it is
        // obvious why the screen never locked.
        RailIcon {
            id: awakeIcon
            visible: Idle.stayAwake
            icon: "󰅶"
            label: "Stay awake"
            statusText: "Screen will not dim or lock"
            hint: "Click to allow sleep"
            live: true
            onClicked: Idle.toggleStayAwake()
        }

        RailIcon {
            id: bellIcon
            icon: Notifs.icon
            label: "Notifications"
            statusText: Notifs.dnd
                ? "Do not disturb"
                : (Notifs.unread > 0 ? Notifs.unread + " unread" : "All caught up")
            readout: Notifs.unread > 0
                ? (Notifs.unread > 9 ? "9+" : String(Notifs.unread))
                : ""
            reserveReadout: true
            dim: Notifs.dnd
            live: Notifs.hasUnread && !Notifs.dnd
            suppressTooltip: notifPopout.detailActive
            onClicked: {
                notifPopout.togglePinned();
                Notifs.markRead();
            }
        }

        RailIcon {
            id: powerIcon
            icon: "󰐥"
            label: "Power"
            statusText: "Session actions"
            live: Actions.powerMenuOpen
            onClicked: Actions.togglePowerMenu()
        }
    }

    // The rail's counterpart to the bar's divider: a horizontal hairline.
    component Divider: Item {
        implicitWidth: Theme.railWidth
        implicitHeight: Theme.padM + 4

        Rectangle {
            anchors.centerIn: parent
            width: 16
            height: 1
            color: Theme.alpha(Theme.outline, 0.6)
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
