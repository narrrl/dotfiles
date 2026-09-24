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
    // A neutral keyline. `tone` used to colour the whole border at 75%, and
    // since most panels pass the resting text colour that put a pale 2px frame
    // around every popout — the loudest thing on screen for no reason. The
    // tone lives in the slash now; the frame is structure.
    border: Theme.surfaceAlt
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
