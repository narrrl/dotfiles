import QtQuick
import Quickshell
import "root:/config"

// Hover-driven panel that hangs off a bar item. Opens on a short dwell, stays
// open while the pointer is over either the trigger or the panel itself, and
// can be pinned with a click. Slides in from behind the bar with an overshoot.
PopupWindow {
    id: root

    required property Item anchorItem
    property bool triggerHovered: false
    property bool pinned: false
    property int showDelay: 140
    property int hideDelay: 200
    property int fromEdge: Edges.Bottom
    property real contentWidth: Theme.popoutWidth
    property real contentHeight: 200
    property Item initialFocusItem: null
    property bool remappingPinned: false

    // Extra surface around the content so the entry overshoot and glow are not
    // clipped by the window edge.
    readonly property int bleed: 24

    default property alias body: contentHolder.data

    readonly property bool wantsOpen: triggerHovered || panelHover.hovered || pinned
    readonly property bool pending: showTimer.running || remapTimer.running || remappingPinned
    readonly property bool detailActive: shown || pending

    signal dismissedFully()

    // Panels hanging off the vertical rail open sideways, so the entry slide has
    // to follow whichever axis the popout actually travels along, and start on
    // the side nearest its trigger.
    readonly property bool horizontal:
        fromEdge === Edges.Left || fromEdge === Edges.Right
    readonly property string slideProperty: horizontal ? "x" : "y"
    readonly property real slideOrigin: bleed + (fromEdge === Edges.Left
        || fromEdge === Edges.Top ? 14 : -14)

    anchor.item: anchorItem
    anchor.edges: fromEdge
    anchor.gravity: fromEdge
    anchor.adjustment: horizontal
        ? PopupAdjustment.SlideY
        : PopupAdjustment.SlideX
    anchor.margins.top: Theme.popoutGap
    anchor.margins.bottom: Theme.popoutGap
    anchor.margins.left: Theme.popoutGap
    anchor.margins.right: Theme.popoutGap

    implicitWidth: contentWidth + bleed * 2
    implicitHeight: contentHeight + bleed * 2
    color: "transparent"
    visible: shown
    grabFocus: pinned && shown

    property bool shown: false

    onWantsOpenChanged: {
        if (wantsOpen) {
            hideTimer.stop();
            if (!pinned && !remappingPinned)
                showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.restart();
        }
    }

    Timer {
        id: showTimer
        interval: root.showDelay
        onTriggered: root.open()
    }

    onVisibleChanged: {
        if (!visible && shown)
            dismissImmediately();
    }
    onClosed: {
        if (remappingPinned) {
            remappingPinned = false;
            remapTimer.restart();
        } else if (shown || pinned) {
            dismissImmediately();
        }
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root.dismiss()
    }

    function open() {
        PopupCoordinator.claim(root);
        exitAnim.stop();
        shown = true;
        enterAnim.restart();
    }

    // Focus policy is fixed at map time. A hover-visible passive surface must
    // therefore unmap before returning as a click-owned keyboard popup.
    function openPinned() {
        showTimer.stop();
        hideTimer.stop();
        PopupCoordinator.claim(root);
        if (shown) {
            remappingPinned = true;
            shown = false;
            enterAnim.stop();
            exitAnim.stop();
            pinned = true;
        } else {
            pinned = true;
            open();
            focusTimer.restart();
        }
    }

    function togglePinned() {
        if (pinned) {
            pinned = false;
            dismiss();
        } else {
            openPinned();
        }
    }

    function dismiss() {
        if (!shown) {
            if (pinned || pending)
                dismissImmediately();
            return;
        }
        pinned = false;
        PopupCoordinator.release(root);
        enterAnim.stop();
        exitAnim.restart();
    }

    function dismissImmediately() {
        showTimer.stop();
        hideTimer.stop();
        remapTimer.stop();
        focusTimer.stop();
        enterAnim.stop();
        exitAnim.stop();
        remappingPinned = false;
        pinned = false;
        shown = false;
        contentHolder.opacity = 0;
        contentHolder.scale = 0.94;
        contentHolder.x = root.bleed;
        contentHolder.y = root.bleed;
        PopupCoordinator.release(root);
        root.dismissedFully();
    }

    Timer {
        id: remapTimer
        interval: 0
        onTriggered: {
            root.open();
            focusTimer.restart();
        }
    }

    Timer {
        id: focusTimer
        interval: 0
        onTriggered: {
            const target = root.initialFocusItem || contentHolder;
            target.forceActiveFocus(Qt.TabFocusReason);
        }
    }

    Item {
        id: contentHolder
        focus: root.pinned
        x: root.bleed
        y: root.bleed
        width: root.contentWidth
        height: root.contentHeight

        opacity: 0
        transformOrigin: {
            switch (root.fromEdge) {
            case Edges.Left: return Item.Right;
            case Edges.Right: return Item.Left;
            case Edges.Top: return Item.Bottom;
            default: return Item.Top;
            }
        }
        scale: 0.94

        // The handler has to live on the content item, not the window: a
        // HoverHandler parented to the PopupWindow itself latches on and the
        // panel never learns the pointer left.
        //
        // Disabled while the popout is down, which clears `hovered`. An unmapped
        // surface gets no leave event, so a handler that was hovered when the
        // window went away stayed hovered — `wantsOpen` never went false again
        // and the panel came back up and refused to close.
        HoverHandler {
            id: panelHover
            enabled: root.shown
        }

        Keys.onEscapePressed: event => {
            if (root.pinned) {
                event.accepted = true;
                root.dismissImmediately();
            }
        }
    }

    ParallelAnimation {
        id: enterAnim
        NumberAnimation {
            target: contentHolder; property: "opacity"
            to: 1.0; duration: Theme.durBase; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: contentHolder; property: "scale"
            to: 1.0; duration: Theme.durSlow; easing.type: Easing.OutBack
        }
        NumberAnimation {
            target: contentHolder; property: root.slideProperty
            from: root.slideOrigin; to: root.bleed
            duration: Theme.durSlow; easing.type: Easing.OutBack
        }
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation {
            target: contentHolder; property: "opacity"
            to: 0.0; duration: Theme.durFast; easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: contentHolder; property: "scale"
            to: 0.96; duration: Theme.durFast; easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: contentHolder; property: root.slideProperty
            to: root.bleed + (root.slideOrigin - root.bleed) * 0.6
            duration: Theme.durFast; easing.type: Easing.InQuad
        }
        onFinished: {
            root.shown = false;
            root.pinned = false;
            contentHolder.x = root.bleed;
            contentHolder.y = root.bleed;
            PopupCoordinator.release(root);
            root.dismissedFully();
        }
    }
}
