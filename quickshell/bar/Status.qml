import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// Network, bluetooth, audio, mic, backlight and battery, in one slab. Each
// glyph carries its own popout.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.primary
    padding: Theme.padS
    interactive: false
    implicitWidth: layout.implicitWidth + contentPad * 2

    Row {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: Theme.padM

        StatusIcon {
            id: netIcon
            icon: Net.icon
            label: Sys.netUp ? Sys.rate(Sys.netRx + Sys.netTx) : ""
            labelWidth: 62
            tint: Theme.primary
            dim: !Sys.netUp
            onClicked: netPopout.pinned = !netPopout.pinned
            onRightClicked: Net.toggleWifi()
            onMiddleClicked: Actions.openNetworkSettings()
        }

        StatusIcon {
            id: btIcon
            icon: Bt.icon
            tint: Bt.connected.length > 0 ? Theme.blue : Theme.primary
            dim: !Bt.enabled
            onClicked: btPopout.pinned = !btPopout.pinned
            onRightClicked: Bt.toggle()
        }

        StatusIcon {
            id: volIcon
            icon: Audio.icon
            label: Audio.muted ? "" : Audio.volumePercent + "%"
            labelWidth: Audio.muted ? 0 : 34
            alert: Audio.muted
            onClicked: Audio.toggleMute()
            onRightClicked: audioPopout.pinned = !audioPopout.pinned
            onMiddleClicked: Actions.openAudioSettings()
            onScrolled: delta => Audio.changeVolume(delta > 0 ? 0.05 : -0.05)
        }

        StatusIcon {
            id: micIcon
            icon: Audio.micIcon
            alert: Audio.micMuted
            onClicked: Audio.toggleMicMute()
            onRightClicked: audioPopout.pinned = !audioPopout.pinned
            onScrolled: delta => Audio.setMicVolume(Audio.micVolume + (delta > 0 ? 0.05 : -0.05))
        }

        StatusIcon {
            id: brightIcon
            visible: Brightness.available
            icon: Brightness.icon
            label: Math.round(Brightness.percent) + "%"
            labelWidth: 34
            // Brightness is never an alarm — it stays white and lets the
            // battery be the only thing in the cluster that can go crimson.
            tint: Theme.text
            onScrolled: delta => Brightness.change(delta > 0 ? 5 : -5)
        }

        StatusIcon {
            id: battIcon
            visible: Battery.available
            icon: Battery.icon
            label: Math.round(Battery.percent) + "%"
            labelWidth: 34
            tint: Battery.tint
            alert: Battery.critical
            pulsing: Battery.critical
            onClicked: battPopout.pinned = !battPopout.pinned
        }
    }

    NetPopout {
        id: netPopout
        anchorItem: netIcon
        triggerHovered: netIcon.hovered
    }

    BtPopout {
        id: btPopout
        anchorItem: btIcon
        triggerHovered: btIcon.hovered
    }

    AudioPopout {
        id: audioPopout
        anchorItem: volIcon
        triggerHovered: volIcon.hovered || micIcon.hovered
    }

    BatteryPopout {
        id: battPopout
        anchorItem: battIcon
        triggerHovered: battIcon.hovered
        visible: Battery.available && shown
    }
}
