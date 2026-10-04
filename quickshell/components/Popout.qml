import QtQuick
import QtQuick.Shapes
import Quickshell
import "root:/config"

// Hover-driven panel that grows out of the hull. Opens on a short dwell, stays
// open while the pointer is over either the trigger or the panel itself, and
// can be pinned with a click.
//
// A popout is not a card floating near its trigger; it is more of the frame.
// It sits flush against the edge it opens from — the underside of the bar, or
// the inner edge of the rail — is painted in the hull colour, joins that edge
// through two concave fillets, and carries the porthole's rim round its open
// side. It slides out from behind the frame rather than fading in. This is
// caelestia's idea, and the same construction as the dashboard drawer.
//
// The panel is placed explicitly rather than by the compositor's slide
// adjustment: centred on its trigger, then clamped so the fillets never run
// into the opening's rounded corners or onto the rail.
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

    // Fillet radius, and the radius of the panel's own free corners — the same
    // as the opening's, so a popout meets the frame the way the opening does.
    readonly property real fillet: Theme.frameRadius
    readonly property real corner: Theme.frameRadius

    // How far the panel reaches back over the frame. One pixel, which covers
    // the rim the hull draws along the edge so the seam disappears.
    readonly property real seam: 1

    default property alias body: contentHolder.data

    readonly property bool wantsOpen: triggerHovered || panelHover.hovered || pinned
    readonly property bool pending: showTimer.running || remapTimer.running || remappingPinned
    readonly property bool detailActive: shown || pending

    signal dismissedFully()

    // Panels hanging off the vertical rail open sideways, out of its inner
    // edge; everything else drops from the underside of the bar.
    readonly property bool horizontal:
        fromEdge === Edges.Left || fromEdge === Edges.Right

    // Which edges of the frame the panel is attached to. A panel that would
    // land within reach of the opening's corner docks into the corner instead,
    // attached to the bar and the rail at once — otherwise it leaves a thin
    // sliver of opening between itself and the rail, two walls a few pixels
    // apart.
    //
    //   "top"          hangs from the bar          fillets left and right
    //   "right"        juts from the rail          fillets above and below
    //   "topRight"     fills the top-right corner  fillets left and below
    //   "bottomRight"  fills the bottom-right one  fillets above and left
    property string dock: horizontal ? "right" : "top"

    // How close to a corner a panel may come before it docks into it.
    readonly property real dockReach: 48

    // The window: the content, plus a fillet beside each attached edge, plus
    // the seam reaching back over the frame.
    readonly property real windowWidth: {
        switch (dock) {
        case "top": return contentWidth + fillet * 2;
        case "right": return contentWidth + seam;
        default: return contentWidth + fillet + seam;
        }
    }
    readonly property real windowHeight: {
        switch (dock) {
        case "top": return contentHeight + seam;
        case "right": return contentHeight + fillet * 2;
        default: return contentHeight + fillet + seam;
        }
    }

    // Where the content sits inside the window.
    readonly property real contentX: dock === "right" ? 0 : fillet
    readonly property real contentY: dock === "top" || dock === "topRight" ? seam : fillet

    // 0 = tucked behind the frame, 1 = fully out.
    property real reveal: 0

    // Placement, in the trigger's own coordinates. Worked out once per open
    // in place(): item positions are not bindable, and a popout should not
    // drift while it is up anyway.
    property real placeX: 0
    property real placeY: 0

    function place() {
        if (!anchorItem) return;
        const p = anchorItem.mapToItem(null, 0, 0);
        const winW = anchorItem.Window.width;
        const winH = anchorItem.Window.height;
        const f = root.fillet, R = Theme.frameRadius;

        if (root.horizontal) {
            // The rail's window starts under the bar at the opening's right
            // edge, so its x = 0 is that edge and its y = 0 is the bar's
            // underside.
            const h = root.contentHeight + f * 2;
            const y = p.y + anchorItem.height / 2 - h / 2;
            const lo = R, hi = winH - Theme.frame - R - h;

            if (y < lo + root.dockReach) {
                root.dock = "topRight";
                root.placeY = -root.seam - p.y;
            } else if (y > hi - root.dockReach) {
                root.dock = "bottomRight";
                root.placeY = winH - Theme.frame + root.seam - root.windowHeight - p.y;
            } else {
                root.dock = "right";
                root.placeY = y - p.y;
            }
            root.placeX = root.seam - root.windowWidth - p.x;
        } else {
            // The bar's window is the full screen width, so the opening runs
            // from `frame` to `width - railWidth`.
            const w = root.contentWidth + f * 2;
            const x = p.x + anchorItem.width / 2 - w / 2;
            const lo = Theme.frame + R - f;
            const hi = winW - Theme.railWidth - R + f - w;

            if (x > hi - root.dockReach) {
                root.dock = "topRight";
                root.placeX = winW - Theme.railWidth + root.seam - root.windowWidth - p.x;
            } else {
                root.dock = "top";
                root.placeX = Math.max(lo, x) - p.x;
            }
            root.placeY = winH - root.seam - p.y;
        }
    }

    anchor.item: anchorItem
    anchor.rect.x: root.placeX
    anchor.rect.y: root.placeY
    anchor.rect.w: 1
    anchor.rect.h: 1
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right
    anchor.adjustment: PopupAdjustment.None

    implicitWidth: windowWidth
    implicitHeight: windowHeight
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
        root.place();
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
        root.reveal = 0;
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

    // Everything slides as one sheet, clipped to the window, so the panel
    // appears to come out from behind the frame.
    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: sheet
            width: root.windowWidth
            height: root.windowHeight
            x: root.horizontal ? root.windowWidth * (1 - root.reveal) : 0
            y: root.horizontal ? 0 : -root.windowHeight * (1 - root.reveal)

            Shape {
                id: silhouette
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                readonly property real w: width
                readonly property real h: height
                readonly property real f: root.fillet
                readonly property real r: root.corner

                // The open side only: from the frame, round the panel, back to
                // the frame. The rim follows this; the fill closes it back
                // along the frame with `closing`.
                readonly property string edge: {
                    switch (root.dock) {
                    case "right":
                        // Down the top fillet, round the two free corners on
                        // the left, out through the bottom fillet.
                        return `M ${w} 0 A ${f} ${f} 0 0 1 ${w - f} ${f}`
                             + ` H ${r} A ${r} ${r} 0 0 0 0 ${f + r}`
                             + ` V ${h - f - r} A ${r} ${r} 0 0 0 ${r} ${h - f}`
                             + ` H ${w - f} A ${f} ${f} 0 0 1 ${w} ${h}`;
                    case "topRight":
                        // Off the bar through the left fillet, round the one
                        // free corner, onto the rail through the bottom fillet.
                        return `M 0 0 A ${f} ${f} 0 0 1 ${f} ${f}`
                             + ` V ${h - f - r} A ${r} ${r} 0 0 0 ${f + r} ${h - f}`
                             + ` H ${w - f} A ${f} ${f} 0 0 1 ${w} ${h}`;
                    case "bottomRight":
                        // Off the rail through the top fillet, round the one
                        // free corner, onto the bottom band through the left.
                        return `M ${w} 0 A ${f} ${f} 0 0 1 ${w - f} ${f}`
                             + ` H ${f + r} A ${r} ${r} 0 0 0 ${f} ${f + r}`
                             + ` V ${h - f} A ${f} ${f} 0 0 1 0 ${h}`;
                    default:
                        // Hanging from the bar: the dashboard's silhouette.
                        return `M 0 0 A ${f} ${f} 0 0 1 ${f} ${f}`
                             + ` V ${h - r} A ${r} ${r} 0 0 0 ${f + r} ${h}`
                             + ` H ${w - f - r} A ${r} ${r} 0 0 0 ${w - f} ${h - r}`
                             + ` V ${f} A ${f} ${f} 0 0 1 ${w} 0`;
                    }
                }

                // Back along the frame to the start, through the corner the
                // panel is docked into if it is docked into one.
                readonly property string closing: {
                    switch (root.dock) {
                    case "topRight": return ` L ${w} 0 Z`;
                    case "bottomRight": return ` L ${w} ${h} Z`;
                    default: return " Z";
                    }
                }

                ShapePath {
                    fillColor: Theme.hull
                    strokeColor: "transparent"
                    PathSvg { path: silhouette.edge + silhouette.closing }
                }

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: Theme.rim
                    strokeWidth: 1
                    PathSvg { path: silhouette.edge }
                }
            }

            Item {
                id: contentHolder
                focus: root.pinned
                x: root.contentX
                y: root.contentY
                width: root.contentWidth
                height: root.contentHeight

                // Read by PopoutSurface, which leaves the fill and the frame to
                // the hull when it finds itself in here.
                readonly property bool frameAttached: true

                // The handler has to live on the content item, not the window:
                // a HoverHandler parented to the PopupWindow itself latches on
                // and the panel never learns the pointer left.
                //
                // Disabled while the popout is down, which clears `hovered`. An
                // unmapped surface gets no leave event, so a handler that was
                // hovered when the window went away stayed hovered — `wantsOpen`
                // never went false again and the panel came back up and refused
                // to close.
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
        }
    }

    NumberAnimation {
        id: enterAnim
        target: root; property: "reveal"
        to: 1; duration: Theme.durSlow; easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: exitAnim
        target: root; property: "reveal"
        to: 0; duration: Theme.durBase; easing.type: Easing.InCubic
        onFinished: {
            root.shown = false;
            root.pinned = false;
            PopupCoordinator.release(root);
            root.dismissedFully();
        }
    }
}
