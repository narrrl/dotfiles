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

    readonly property int count: history.filter(n => n).length

    // The history by sender, for the log: one entry per app, newest first
    // inside each, the apps ordered by their newest notification.
    readonly property var groups: {
        const byApp = {};
        const order = [];
        for (const n of root.history) {
            if (!n) continue;
            const app = n.appName || "System";
            if (!(app in byApp)) { byApp[app] = []; order.push(app); }
            byApp[app].push(n);
        }
        return order.map(app => ({ app: app, items: byApp[app] }));
    }

    // The server hands out ids in rising order, so everything in the log above
    // the newest id seen when the log was last opened is unread. Derived from
    // the history rather than counted, so dismissing an entry anywhere takes
    // it off the count too.
    property int readId: 0
    readonly property int unread: history.filter(n => n && n.id > root.readId).length
    readonly property bool hasUnread: unread > 0

    NotificationServer {
        id: server

        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        actionsSupported: true
        actionIconsSupported: true
        imageSupported: true
        // No reply field in the toasts or the log yet, so don't let apps offer
        // a reply action that goes nowhere.
        inlineReplySupported: false
        persistenceSupported: true

        onNotification: notif => {
            // Hold the notification open until we drop it ourselves.
            notif.tracked = true;
            root.adopt(notif);

            const next = [notif, ...root.history.filter(n => n)];
            for (const n of next.slice(root.maxHistory)) root.release(n);
            root.history = next.slice(0, root.maxHistory);

            // A game holds every toast but a critical one; the log has them all.
            const held = GameMode.active && notif.urgency !== NotificationUrgency.Critical;
            if (!root.dnd && !held) root.popupRequested(notif);
        }
    }

    // The server outlives a reload, and keeps what it was tracking; this
    // object does not. Take those back into the log, already read.
    Component.onCompleted: {
        const kept = server.trackedNotifications.values.slice().sort((a, b) => b.id - a.id);
        for (const n of kept) root.adopt(n);
        root.history = kept.slice(0, root.maxHistory);
        for (const n of kept.slice(root.maxHistory)) root.release(n);
        root.markRead();
    }

    // An app may close its own notification at any time, and the server then
    // destroys the object, leaving a null in the history. The lock keeps it
    // alive, frozen as it was, until the log lets it go; closing it only takes
    // it off screen.
    function adopt(notif: Notification) {
        root.holds[notif.id] = hold.createObject(root, { object: notif });
        notif.closed.connect(() => {
            root.retracted = Object.assign({}, root.retracted, { [notif.id]: true });
            root.notifRetracted(notif);
        });
    }

    Component {
        id: hold
        RetainableLock { locked: true }
    }

    // One lock per notification in the history, by id.
    property var holds: ({})
    // Ids of the notifications whose app has closed them. They stay in the log
    // but can no longer be acted on.
    property var retracted: ({})

    signal popupRequested(Notification notif)
    signal notifRetracted(Notification notif)

    function isRetracted(notif: Notification): bool {
        return !notif || root.retracted[notif.id] === true;
    }

    // Close a notification if its app has not, and let the object go.
    function release(notif: Notification) {
        if (!notif) return;
        const id = notif.id;
        if (!root.isRetracted(notif)) notif.dismiss();
        root.holds[id]?.destroy();
        delete root.holds[id];
        if (id in root.retracted) {
            const next = Object.assign({}, root.retracted);
            delete next[id];
            root.retracted = next;
        }
    }

    function dismiss(notif: Notification) {
        if (!notif) return;
        root.history = root.history.filter(n => n && n !== notif);
        root.release(notif);
    }

    function dismissApp(app: string) {
        const from = n => n.appName || "System";
        const gone = root.history.filter(n => n && from(n) === app);
        root.history = root.history.filter(n => n && from(n) !== app);
        for (const n of gone) root.release(n);
    }

    function clearAll() {
        const all = root.history.filter(n => n);
        root.history = [];
        for (const n of all) root.release(n);
    }

    function markRead() {
        root.readId = Math.max(root.readId, ...root.history.filter(n => n).map(n => n.id));
    }

    // Run one of a notification's actions and take it out of the log. Done
    // here rather than in the card: invoking closes a non-resident
    // notification, which takes its toast, and the card with it, off screen
    // before the card's handler has finished.
    function invoke(notif: Notification, action: NotificationAction) {
        if (!notif || root.isRetracted(notif)) return;
        action.invoke();
        root.dismiss(notif);
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
        case NotificationUrgency.Critical: return Theme.alarm;
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
