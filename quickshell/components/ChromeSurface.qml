import QtQuick
import "root:/config"
import "root:/components"

// Calm, permanent-chrome preset. It is deliberately flat and opaque: one
// neutral hairline, no texture, no ticks, and no accent unless active.
P5Panel {
    property bool active: false
    property color tone: Theme.treatmentActiveMark

    fill: Theme.treatmentRestFill
    fillOpacity: 1.0
    border: Theme.treatmentRestMark
    borderWidth: 1
    halftone: false
    sheen: false
    slash: active
    slashColor: tone
    slashWidth: 2
    padding: Theme.padS
}
