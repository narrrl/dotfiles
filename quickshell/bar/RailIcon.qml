import QtQuick
import "root:/config"
import "root:/components"

// One slot on the right-hand rail: a glyph with an optional micro readout
// stacked beneath it, and a crimson bar that wipes down the leading edge on
// hover. The rail is only 48px wide, so unlike StatusIcon the readout sits
// under the glyph rather than beside it, and anything longer than a percentage
// belongs in the popout instead.
Item {
    id: root

    property string icon: ""
    property string readout: ""
    property string label: ""
    property string statusText: ""
    property string hint: ""
    property bool suppressTooltip: false
    property color tint: Theme.primary
    property bool alert: false
    property bool dim: false
    property bool pulsing: false

    // Hold the readout line open even while there is nothing to put in it.
    // Volume drops its percentage when muted and the bell only carries a count
    // when something is unread, so without this the slot collapsed from 42px to
    // 32px and every icon below it jumped a third of its own height.
    property bool reserveReadout: false

    readonly property bool hasReadout: root.readout !== "" || root.reserveReadout
    readonly property bool hovered: hover.hovered

    // Clearance between the wipe and the rail's left edge, chosen so the bar
    // stays inside the slab once `scale` has expanded the icon about its centre.
    readonly property real wipeInset: 5

    signal clicked()
    signal scrolled(real delta)

    implicitWidth: Theme.railWidth
    implicitHeight: root.hasReadout ? root.glyphBand + readoutLine.height + 1 : root.glyphBand

    // The glyph always sits centred in a fixed band at the top of the slot and
    // the readout hangs below it, rather than the pair being centred together.
    // Centring the pair meant the icon slid up and down by a few px whenever its
    // number appeared or vanished — the icons stopped lining up with each other
    // exactly when something was changing and you were looking at them.
    readonly property real glyphBand: 32

    // Nerd Font's status glyphs are not all centred inside their own advance —
    // the muted-speaker and muted-mic marks carry their cross out to the right,
    // so centring the advance box left them visibly off-axis next to the wifi
    // and bluetooth glyphs. Centre the ink instead, capped so a glyph with an
    // odd bounding box cannot slide far off the rail's axis.
    readonly property real opticalShift: {
        const ink = glyphMetrics.tightBoundingRect;
        if (ink.width <= 0) return 0;
        const off = glyphMetrics.advanceWidth / 2 - (ink.x + ink.width / 2);
        return Math.max(-4, Math.min(4, off));
    }

    TextMetrics {
        id: glyphMetrics
        text: root.icon
        font.family: Theme.fontIcon
        font.pixelSize: Theme.fsLarge
    }

    Item {
        id: layout
        anchors.fill: parent

        Icon {
            id: glyph
            x: (root.width - width) / 2 + root.opticalShift
            y: (root.glyphBand - height) / 2
            text: root.icon
            pulsing: root.pulsing
            font.pixelSize: Theme.fsLarge
            color: {
                if (root.alert) return Theme.accent;
                if (root.dim) return Theme.muted;
                if (root.hovered) return Theme.glow;
                return root.tint;
            }

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }

        Text {
            id: readoutLine
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.glyphBand + 1
            visible: root.readout !== ""
            text: root.readout
            color: root.dim ? Theme.muted : Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }
    }

    // Leading-edge wipe. On the rail this runs vertically down the left side,
    // mirroring the slash P5Panel puts on horizontal modules.
    //
    // Held off the edge by `wipeInset`: the icon spans the rail's full width, so
    // at x = 0 this landed exactly on the slab's own border, and the 1.08 hover
    // scale then pushed it out past the silhouette onto the desktop. The inset
    // has to survive that scale, which is why it is not simply 1 or 2.
    //
    // It is crimson rather than `tint` because it only ever appears on hover,
    // and hover is crimson everywhere else in the shell (Theme.glow). Painting
    // it white put a white bar on the rail's edge for no stated reason.
    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: root.wipeInset
        anchors.verticalCenter: parent.verticalCenter
        width: 2
        height: root.hovered ? root.height - 4 : 0
        color: Theme.glow

        Behavior on height {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
        }
    }

    scale: root.hovered ? 1.08 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
    }

    onAlertChanged: if (alert) glyph.bump()

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.clicked()
    }
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => root.scrolled(event.angleDelta.y)
    }

    P5Tooltip {
        anchorItem: root
        triggerHovered: root.hovered
        title: root.label
        status: root.statusText
        hint: root.hint
        suppressed: root.suppressTooltip
    }
}
