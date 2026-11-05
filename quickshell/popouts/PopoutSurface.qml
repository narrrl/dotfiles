import QtQuick
import "root:/config"
import "root:/components"

// The slab every popout sits on. Pure preset — it declares no children of its
// own, so Panel's default content property stays usable by callers.
Panel {
    property color tone: Theme.primary
    property bool textured: false

    // Inside a Popout the panel is part of the hull, which paints the fill
    // and the rim itself; the surface only lays out the content. Elsewhere —
    // the launcher, the ask panel — it is a free-standing panel of its own.
    readonly property bool attached: parent?.frameAttached ?? false

    fill: attached ? "transparent" : Theme.mantle
    // Zero, not a transparent fill: Panel re-applies this opacity to the
    // fill colour, which turned "transparent" into 97% black.
    fillOpacity: attached ? 0 : 0.97
    // The frame is structure: a neutral hairline. A free-standing panel takes
    // the frame's own corner radius, so it reads as a piece of the hull set
    // down somewhere else rather than as a hard card.
    border: Theme.surfaceAlt
    borderWidth: attached ? 0 : Theme.stroke
    halftone: textured
    halftoneColor: tone
    halftoneOpacity: 0.06
    ticks: false
    radius: Theme.frameRadius
    tickColor: tone
    padding: Theme.padM
}
