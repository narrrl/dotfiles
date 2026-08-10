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

    // Extra surface around the content so the entry overshoot and glow are not
    // clipped by the window edge.
    readonly property int bleed: 24

    default property alias body: contentHolder.data

    readonly property bool wantsOpen: triggerHovered || panelHover.hovered || pinned

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

    property bool shown: false

    onWantsOpenChanged: {
        if (wantsOpen) {
            hideTimer.stop();
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

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root.dismiss()
    }

    function open() {
        exitAnim.stop();
        shown = true;
        enterAnim.restart();
    }

    function dismiss() {
        if (!shown) return;
        enterAnim.stop();
        exitAnim.restart();
    }

    Item {
        id: contentHolder
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
        HoverHandler {
            id: panelHover
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
            root.dismissedFully();
        }
    }
}
