import QtQuick
import "root:/config"
import "root:/components"

// Calm, permanent-chrome preset. It is deliberately flat and opaque: one
// neutral keyline, no texture, no offset copy, and no accent unless active.
P5Panel {
    property bool active: false
    property color tone: Theme.treatmentActiveMark

    fill: Theme.treatmentRestFill
    fillOpacity: 1.0
    border: Theme.treatmentRestMark
    borderWidth: 1
    // Keep the hard ink contour. Removing both texture and keyline made the
    // permanent slabs read as generic broadcast HUD chrome.
    keyline: true
    drop: false
    halftone: false
    sheen: false
    slash: active
    slashColor: tone
    slashWidth: 4
    lean: 0.06
    chop: Theme.cut
    padding: Theme.padS
}
