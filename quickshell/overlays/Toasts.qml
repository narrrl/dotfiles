import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "root:/config"
import "root:/components"
import "root:/services"

// Floating notification stack under the bar, top right. Replaces dunst.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // A toast window exists on every screen, but each notification lands only
    // on the monitor that had focus when it arrived. Latched per toast rather
    // than live, so a card does not hop screens while it is being read.

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-toasts"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; right: true }
    margins {
        top: Theme.barHeight + Theme.barMargin * 2
        right: Theme.barMargin
    }

    implicitWidth: 400
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: root.live.length > 0

    // Toasts currently on screen, newest first.
    property list<Notification> live: []
    property int maxLive: 5

    Connections {
        target: Notifs
        function onPopupRequested(notif) {
            if (Actions.focusedScreenName() !== root.modelData.name) return;
            root.live = [notif, ...root.live].slice(0, root.maxLive);
        }
    }

    function retire(notif) {
        const idx = root.live.indexOf(notif);
        if (idx === -1) return;
        const next = root.live.slice();
        next.splice(idx, 1);
        root.live = next;
    }

    Column {
        id: stack
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width
        spacing: Theme.padS

        Repeater {
            model: root.live

            Item {
                id: toast
                required property var modelData

                width: stack.width
                height: card.implicitHeight

                NotifCard {
                    id: card
                    width: parent.width
                    notif: toast.modelData
                    onDismissed: {
                        Notifs.dismiss(toast.modelData);
                        root.retire(toast.modelData);
                    }
                }

                // Countdown rule that drains along the bottom edge.
                //
                // It used to be a full-bleed rectangle across the whole toast,
                // which meant it ran straight through the card's chopped
                // bottom-left corner and out the other side — a stray bar
                // hanging off the card at the one place the silhouette is
                // supposed to be cut. It lives inside the cut now, and ends
                // where the leaning right edge does.
                readonly property real fuseSpan: Math.max(0,
                    width - card.chop - card.implicitHeight * card.lean)

                Skew {
                    id: fuse
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 1
                    x: card.chop
                    height: 2
                    width: toast.fuseSpan
                    lean: card.lean
                    color: Theme.alpha(card.tone, 0.7)
                    visible: life.running
                }

                NumberAnimation {
                    id: life
                    target: fuse
                    property: "width"
                    from: toast.fuseSpan
                    to: 0
                    running: false
                    duration: Notifs.timeoutFor(toast.modelData)
                    easing.type: Easing.Linear
                    onFinished: root.retire(toast.modelData)
                }

                // Slide in from the right, Persona-style.
                opacity: 0
                transform: Translate { id: shove; x: 60 }

                Component.onCompleted: {
                    enter.start();
                    const ms = Notifs.timeoutFor(toast.modelData);
                    if (ms > 0) life.start();
                }

                ParallelAnimation {
                    id: enter
                    NumberAnimation {
                        target: toast; property: "opacity"
                        to: 1; duration: Theme.durBase
                    }
                    NumberAnimation {
                        target: shove; property: "x"
                        from: 60; to: 0
                        duration: Theme.durSlow
                        easing.type: Easing.OutBack
                    }
                }

                // Hovering a toast pauses its fuse.
                HoverHandler {
                    id: toastHover
                    onHoveredChanged: {
                        if (!life.duration) return;
                        if (hovered) life.pause();
                        else if (life.paused) life.resume();
                    }
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: root.retire(toast.modelData)
                }
            }
        }
    }
}
