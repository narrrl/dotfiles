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
    Rectangle {
        visible: Notifs.unread > 0 && !Notifs.dnd
        anchors.right: parent.right
        anchors.rightMargin: 2
        anchors.top: parent.top
        anchors.topMargin: 4
        width: Math.max(12, badge.implicitWidth + 5)
        height: 12
        color: Theme.accent

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

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -Theme.skew, 0, 12 * Theme.skew,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
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
