pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "root:/config"

// Notification server. Replaces dunst: the shell owns the org.freedesktop
// .Notifications name and renders popups and the history list itself.
Singleton {
    id: root

    property bool dnd: false

    // Newest first. Popups read the head of this list.
    property list<Notification> history: []
    property int maxHistory: 60

    readonly property int count: history.length
    readonly property bool hasUnread: unread > 0
    property int unread: 0

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        inlineReplySupported: true
        persistenceSupported: true

        onNotification: notif => {
            // Hold the notification open until we drop it ourselves.
            notif.tracked = true;

            root.history = [notif, ...root.history].slice(0, root.maxHistory);
            root.unread++;

            if (!root.dnd) root.popupRequested(notif);
        }
    }

    signal popupRequested(Notification notif)

    function dismiss(notif: Notification) {
        if (!notif) return;
        const idx = root.history.indexOf(notif);
        if (idx !== -1) {
            const next = root.history.slice();
            next.splice(idx, 1);
            root.history = next;
        }
        notif.dismiss();
    }

    function clearAll() {
        const all = root.history.slice();
        root.history = [];
        root.unread = 0;
        for (const n of all) n.dismiss();
    }

    function markRead() {
        root.unread = 0;
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }

    readonly property string icon: {
        if (root.dnd) return "󰂛";
        if (root.hasUnread) return "󱅫";
        return "󰂚";
    }

    // Urgency-driven accents for the popup chrome.
    function urgencyColor(u: int): color {
        switch (u) {
        case NotificationUrgency.Critical: return Theme.accent;
        case NotificationUrgency.Low: return Theme.muted;
        default: return Theme.primary;
        }
    }

    function appIconFor(notif: Notification): string {
        if (!notif) return "󰂚";
        const app = (notif.appName || "").toLowerCase();
        if (app.includes("spotify")) return "";
        if (app.includes("discord")) return "󰙯";
        if (app.includes("slack")) return "󰒱";
        if (app.includes("thunderbird") || app.includes("mail")) return "󰇮";
        if (app.includes("firefox")) return "";
        if (app.includes("volume") || app.includes("audio")) return "󰕾";
        if (app.includes("screenshot") || app.includes("grim")) return "󰄄";
        return "󰂚";
    }

    // How long a popup stays up, in ms.
    function timeoutFor(notif: Notification): int {
        if (!notif) return 5000;
        if (notif.urgency === NotificationUrgency.Critical) return 0;   // sticky
        if (notif.expireTimeout > 0) return notif.expireTimeout;
        if (notif.urgency === NotificationUrgency.Low) return 3500;
        return 6000;
    }
}
