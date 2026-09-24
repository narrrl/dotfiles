import QtQuick
import "root:/config"
import "root:/components"

// Shared chrome for every bar module.
//
// The bar is one continuous slab, so by default a module draws no panel of its
// own — it is content inside the bar's surface, and marks hover with an accent
// underline rather than by lighting up a card. That is what stops the bar from
// reading as a row of floating islands.
//
// `standalone: true` brings back the individual leaning slab, for the few
// places that genuinely are separate surfaces.
Item {
    id: root

    property color accent: Theme.accent
    property bool active: false
    property bool slash: false
    property real lean: Theme.skew
    property bool leanLeft: false
    property real padding: Theme.padM
    property bool interactive: true
    property bool halftone: false
    property bool standalone: false

    property real chop: Theme.cut
    property var chopCorners: [1, 3]

    readonly property bool hovered: hover.hovered
    readonly property real leanInset: standalone ? panelLoader.item?.leanInset ?? 0 : 0

    // The hover rule's own strip, reserved at the bottom of the module.
    //
    // The rule used to be drawn into the same box as the content, so anything
    // taller than about 32px — the media pill's art, the metric meters — had a
    // accent line struck through its bottom edge on hover. Reserving the band
    // and centring content in what is left is what keeps the rule under the
    // module instead of across it.
    // The band reserved the full rule plus its inset — 7px off a 40px module,
    // all of it taken from the bottom — so every module's content was centred
    // 3.5px above the slab's own centre and the whole bar read as top-heavy.
    // The rule is pushed closer to the edge now and the band keeps only enough
    // clearance to stop the tallest content (the media pill's 24px art) from
    // touching it, so content sits within a pixel of the slab's centre line.
    readonly property real ruleHeight: 2
    readonly property real ruleInset: 3
    readonly property real ruleBand: root.standalone ? 0 : 2

    // Modules with a notion of progress (the player's track position) draw it in
    // the same band, so it can never be struck through the content. A module
    // cannot do this for itself: anything it declares becomes a child of the
    // content holder, whose bottom edge is above the band, and the rule lands
    // across the text instead of under it. Negative means "no progress".
    property real progress: -1

    // Total horizontal inset a module must add on top of its content width.
    readonly property real contentPad: standalone
        ? (panelLoader.item?.contentPad ?? root.padding)
        : root.padding

    default property alias content: holder.data

    signal clicked()
    signal rightClicked()
    signal middleClicked()
    signal scrolled(real delta)

    implicitHeight: Theme.barHeight

    Loader {
        id: panelLoader
        anchors.fill: parent
        active: root.standalone

        sourceComponent: P5Panel {
            lean: root.lean
            leanLeft: root.leanLeft
            chop: root.chop
            chopCorners: root.chopCorners
            padding: root.padding
            halftone: root.halftone
            halftoneColor: root.accent

            fill: root.active ? Theme.surfaceAlt : Theme.surface
            fillOpacity: 1.0
            border: root.hovered || root.active
                ? root.accent
                : Theme.alpha(Theme.outline, 0.9)
            borderWidth: root.hovered || root.active ? Theme.stroke : 1

            slash: root.slash || root.active
            slashColor: root.accent
        }
    }

    Item {
        id: holder
        anchors.fill: parent
        anchors.leftMargin: root.contentPad
        anchors.rightMargin: root.contentPad
        anchors.bottomMargin: root.ruleBand
    }

    // Hover mark for in-bar modules: an accent rule under the content, wiping
    // out from the leading edge. Sheared to match the one angle everything uses.
    Item {
        visible: !root.standalone && root.interactive
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.ruleInset
        height: root.ruleHeight
        clip: true

        // Track progress, shown until the pointer arrives and the hover rule
        // takes the band over.
        //
        // Deliberately untweened. MPRIS position is polled once a second, and a
        // 480 ms ease on a 1 Hz input meant this rule was mid-animation roughly
        // half of every second — about 115 animated frames per second on a
        // 240 Hz screen, each one rebuilding this Skew's Shape geometry through
        // the curve renderer and re-rendering the pill's layer textures with it.
        // Stepping once per second costs 1 frame instead of 115, matches the rate
        // the underlying data actually arrives at, and makes a seek land exactly
        // where it was dropped instead of gliding there.
        Skew {
            height: parent.height
            width: parent.width * Math.max(0, Math.min(1, root.progress))
            color: Theme.accent
            visible: root.progress >= 0 && !root.hovered && !root.active
        }

        Skew {
            height: parent.height
            width: root.hovered || root.active ? parent.width : 0
            color: root.accent

            Behavior on width {
                NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
            }
        }
    }

    HoverHandler {
        id: hover
        enabled: root.interactive
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.RightButton
        onTapped: root.rightClicked()
    }

    TapHandler {
        enabled: root.interactive
        acceptedButtons: Qt.MiddleButton
        onTapped: root.middleClicked()
    }

    WheelHandler {
        enabled: root.interactive
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.scrolled(event.angleDelta.y)
    }
}
