import QtQuick
import "root:/config"
import "root:/components"

// The slab every popout sits on. Pure preset — it declares no children of its
// own, so P5Panel's default content property stays usable by callers.
P5Panel {
    property color tone: Theme.primary
    property bool textured: false

    fill: Theme.mantle
    fillOpacity: 0.97
    // The frame is structure: a neutral hairline. The tone goes into the
    // corner ticks, which is where NieR puts the one bright mark on a panel.
    border: Theme.surfaceAlt
    borderWidth: Theme.stroke
    halftone: textured
    halftoneColor: tone
    halftoneOpacity: 0.06
    ticks: true
    tickColor: tone
    padding: Theme.padM
}
