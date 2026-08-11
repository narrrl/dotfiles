import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// Notification bell with an unread badge. Click opens the history, right click
// toggles do-not-disturb.
BarPill {
    id: root

    required property var screenRef

    accent: Notifs.dnd ? Theme.muted : Theme.primary
    padding: Theme.padS
    implicitWidth: Theme.barHeight - 4 + contentPad

    onClicked: {
        popout.pinned = !popout.pinned;
        Notifs.markRead();
    }
    onRightClicked: Notifs.toggleDnd()

    Icon {
        id: bell
        anchors.centerIn: parent
        text: Notifs.icon
        font.pixelSize: Theme.fsLarge
        color: {
            if (Notifs.dnd) return Theme.muted;
            if (Notifs.hasUnread) return Theme.accent;
            return root.hovered ? Theme.glow : Theme.primary;
        }
    }

    // Unread badge, chopped like everything else.
    Skew {
        visible: Notifs.unread > 0 && !Notifs.dnd
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.top: parent.top
        anchors.topMargin: 4
        width: Math.max(12, badge.implicitWidth + 5)
        height: 12
        color: Theme.accent

        // The badge count stays upright. It used to inherit the shear from the
        // transform on the block below, which at 8px left the digits smeared.
        Text {
            id: badge
            anchors.centerIn: parent
            text: Notifs.unread > 9 ? "9+" : Notifs.unread
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: 8
            font.weight: Font.Bold
            renderType: Text.NativeRendering
        }
    }

    Connections {
        target: Notifs
        function onPopupRequested() { bell.bump(); }
    }

    NotifPopout {
        id: popout
        anchorItem: root
        triggerHovered: root.hovered
    }
}
