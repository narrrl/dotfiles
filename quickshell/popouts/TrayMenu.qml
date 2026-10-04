import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// The tray's context menu, on the shell's own slab.
//
// Quickshell can hand a StatusNotifier menu straight to Qt's platform menu
// implementation, but that draws a stock widget popup — square corners, system
// palette, no lean — hanging off the corner of a shell that has none of those
// things. This walks the menu with QsMenuOpener instead and draws it as a
// P5Panel, so a right click on a tray icon produces the same object language as
// everything else on the rail.
//
// Dismissal is a Hyprland focus grab: click anywhere outside and the compositor
// tells us to close.
PopupWindow {
    id: root

    required property Item anchorItem
    property var menuHandle: null

    // Room around the slab for the entry overshoot and the offset black copy.
    readonly property int bleed: 20
    readonly property int minWidth: 160
    readonly property int maxWidth: 320

    // The slab's own lean and padding, which the entries sit inside. Sizing the
    // window to the entry widths alone left every label short by that inset and
    // elided perfectly ordinary items.
    readonly property real slabLean: Theme.skew
    readonly property real slabPad: Theme.padS

    readonly property real contentHeight: list.implicitHeight + slabPad * 2
    readonly property real contentWidth:
        Math.max(root.minWidth, Math.min(root.maxWidth, list.menuWidth))
        + (slabPad + contentHeight * slabLean) * 2

    anchor.item: anchorItem
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Left
    anchor.adjustment: PopupAdjustment.SlideY
    anchor.margins.right: Theme.popoutGap

    implicitWidth: contentWidth + bleed * 2
    implicitHeight: contentHeight + bleed * 2
    color: "transparent"
    visible: shown

    property bool shown: false


    function open() {
        if (!menuHandle) return;
        PopupCoordinator.claim(root);
        closeAnim.stop();
        shown = true;
        openAnim.restart();
    }

    function close() {
        if (!shown) return;
        openAnim.stop();
        closeAnim.restart();
    }

    function toggle() {
        if (shown) close(); else open();
    }

    // Shared name used by PopupCoordinator for every transient surface.
    function dismiss() {
        close();
    }

    function dismissImmediately() {
        openAnim.stop();
        closeAnim.stop();
        shown = false;
        holder.opacity = 0;
        holder.scale = 0.94;
        holder.x = root.bleed;
        PopupCoordinator.release(root);
    }

    // The grab can only take hold once the popup is actually mapped. Asked for
    // in the same tick as `shown`, Hyprland has no surface to hand it and
    // clears it immediately — which closed the menu the instant it opened.
    Timer {
        id: grabDelay
        interval: 60
        running: root.shown
    }

    HyprlandFocusGrab {
        active: root.shown && !grabDelay.running
        windows: [root]
        onCleared: root.close()
    }

    Item {
        id: holder
        x: root.bleed
        y: root.bleed
        width: root.contentWidth
        height: root.contentHeight

        opacity: 0
        scale: 0.94
        transformOrigin: Item.Right

        PopoutSurface {
            anchors.fill: parent
            tone: Theme.accent
            padding: root.slabPad
            lean: root.slabLean

            TrayMenuList {
                id: list
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                // Only walk the menu while it is on screen. Bound unconditionally,
                // every tray app would get a GetLayout the moment the shell
                // starts, for a menu nobody has asked for yet.
                menuHandle: root.shown ? root.menuHandle : null
                onActivated: root.close()
            }
        }
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: holder; property: "opacity"
            to: 1.0; duration: Theme.durBase; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: holder; property: "scale"
            to: 1.0; duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: holder; property: "x"
            from: root.bleed + 14; to: root.bleed
            duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnim
        NumberAnimation {
            target: holder; property: "opacity"
            to: 0.0; duration: Theme.durFast; easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: holder; property: "scale"
            to: 0.96; duration: Theme.durFast; easing.type: Easing.InQuad
        }
        onFinished: {
            root.shown = false;
            holder.x = root.bleed;
            PopupCoordinator.release(root);
        }
    }
}
