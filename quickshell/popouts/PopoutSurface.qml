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
    border: Theme.alpha(tone, 0.75)
    borderWidth: Theme.stroke
    halftone: textured
    halftoneColor: tone
    halftoneOpacity: 0.06
    sheen: true
    slash: true
    slashColor: tone
    slashWidth: 5
    lean: 0.06
    chop: 16
    padding: Theme.padM
}
