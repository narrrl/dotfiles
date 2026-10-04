import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// Focused window title. Rapid application title churn is settled before it is
// painted, then the stable caption lands like a misregistered print layer.
Item {
    id: root

    required property var screenRef

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screenRef)
    readonly property HyprlandToplevel toplevel: Hyprland.activeToplevel

    // Only speak for the monitor this bar lives on.
    readonly property bool mine: toplevel !== null
        && (root.monitor === null || toplevel.monitor === null
            || toplevel.monitor.id === root.monitor.id)

    readonly property string incomingTitle: mine && toplevel.title ? toplevel.title : "—"

    // Where the focused window sits in its group, as "2/3", or "" when it is
    // not grouped. Hyprland's group bar draws only indicator lines (see
    // hypr/lua/look.lua), so the bar is the one place the title is written.
    readonly property string groupLabel: {
        const ipc = root.mine ? root.toplevel.lastIpcObject : null;
        const members = ipc?.grouped ?? [];
        if (members.length < 2) return "";
        const bare = a => String(a).replace(/^0x/, "");
        const at = members.findIndex(m => bare(m) === bare(root.toplevel.address));
        return (at < 0 ? "?" : at + 1) + "/" + members.length;
    }

    // lastIpcObject is a snapshot, refreshed only on request. Ask again
    // whenever focus or group membership may have changed.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const n = event.name;
            if (n === "activewindowv2" || n === "togglegroup"
                    || n === "moveintogroup" || n === "moveoutofgroup"
                    || n === "closewindow" || n === "openwindow")
                Hyprland.refreshToplevels();
        }
    }
    property string displayedTitle: "—"

    // Which toplevel the landing transition last played for. The landing is a
    // focus-change stamp, so it has to key off window identity rather than off
    // the caption text — see commitTitle().
    property var landedToplevel: null

    // The bar shrinks this when the three clusters would otherwise collide.
    property real maxWidth: 240

    implicitWidth: Math.min(maxWidth,
        Math.max(70, label.implicitWidth + 4 + (groupTag.visible ? groupTag.width + Theme.padS : 0)))
    implicitHeight: 20

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutExpo }
    }

    Item {
        id: titleStage
        anchors.fill: parent
        clip: true

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - (groupTag.visible ? groupTag.width + Theme.padS : 0)
            text: root.displayedTitle
            color: root.mine ? Theme.subtext : Theme.muted
            elide: Text.ElideRight
            font.pixelSize: Theme.fsSmall
            font.family: Theme.fontDisplay
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
        }

        // Accent duplicate: visible only during the landing transition. The
        // small opposing offset gives the title NieR's brief corruption flicker
        // without leaving permanent motion in the bar.
        Text {
            id: ghost
            anchors.verticalCenter: parent.verticalCenter
            width: label.width
            text: root.displayedTitle
            color: Theme.accent
            opacity: 0
            elide: Text.ElideRight
            font: label.font
            renderType: Text.NativeRendering
        }

        Text {
            id: groupTag
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: root.groupLabel !== ""
            text: root.groupLabel
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }

    // Adopt the settled caption, and stamp it only when focus actually moved.
    //
    // The landing used to restart on any title change, which is not the same
    // thing: plenty of windows rewrite their own title on a timer — a terminal
    // running a task with a spinner or a percentage, a browser tab with a live
    // clock — and each rewrite restarted seven overlapping animations totalling
    // over half a second. At a title churning twice a second on a 240 Hz screen
    // the bar never stopped animating, and repainting it that hard measured at
    // roughly 18% of a CPU core with nothing else happening. Keying the stamp to
    // window identity restores what the effect was described as doing.
    function commitTitle(): void {
        const focusMoved = root.toplevel !== root.landedToplevel;

        if (root.displayedTitle !== root.incomingTitle)
            root.displayedTitle = root.incomingTitle;
        else if (!focusMoved)
            return;

        if (focusMoved) {
            root.landedToplevel = root.toplevel;
            titleLanding.restart();
        }
    }

    // Browser tabs, terminals and editors can update titles several times in a
    // frame. Keep the old caption steady until the stream settles instead of
    // restarting an animation for every intermediate value.
    Timer {
        id: titleSettle
        interval: 120
        repeat: false
        onTriggered: root.commitTitle()
    }

    onIncomingTitleChanged: titleSettle.restart()

    // Focus can move to a window whose caption happens to match the outgoing
    // one, which changes no title and so would otherwise never land.
    onToplevelChanged: titleSettle.restart()

    Component.onCompleted: {
        displayedTitle = incomingTitle;
        // Adopt the current window silently, so a config reload does not play a
        // focus-change stamp for a focus that did not change.
        landedToplevel = toplevel;
    }

    // A quick accent wipe under the title on focus change.
    Rectangle {
        id: wipe
        anchors.bottom: parent.bottom
        height: 2
        width: 0
        color: Theme.accent
        opacity: 0
    }

    SequentialAnimation {
        id: titleLanding
        ParallelAnimation {
            NumberAnimation {
                target: wipe; property: "width"
                from: 0; to: root.width
                duration: Theme.durBase; easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: wipe; property: "opacity"
                from: 0; to: 1; duration: Theme.durFast
            }
            NumberAnimation {
                target: label; property: "x"
                from: -10; to: 0
                duration: Theme.durBase; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: label; property: "opacity"
                from: 0.35; to: 1; duration: Theme.durFast
            }
            NumberAnimation {
                target: ghost; property: "x"
                from: 9; to: -3
                duration: Theme.durBase; easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: ghost; property: "opacity"
                from: 0.8; to: 0; duration: Theme.durBase
            }
        }
        NumberAnimation {
            target: wipe; property: "opacity"
            to: 0; duration: Theme.durSlow
        }
    }
}
