import QtQuick
import QtQuick.Effects

// Layer effect that recolours whatever it is applied to into a flat silhouette
// of `tintColor` — used for the white texture tiles and for tray icons.
//
// Colorization alone keeps the source's lightness, so a dark icon came out as a
// dark shade of the tint and all but vanished against the rail. Brightness runs
// first and lifts every pixel to white, which leaves colorization nothing to
// preserve but the alpha.
MultiEffect {
    property color tintColor: "white"

    brightness: 1.0
    colorization: 1.0
    colorizationColor: tintColor
}
