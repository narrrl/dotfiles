import QtQuick
import QtQuick.Effects

// Layer effect that recolours whatever it is applied to — used to tint the
// white texture tiles without shipping a copy per colour.
MultiEffect {
    property color tintColor: "white"

    colorization: 1.0
    colorizationColor: tintColor
}
