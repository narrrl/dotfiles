import QtQuick
import QtQuick.Effects

// Layer effect that clips whatever it is applied to into the silhouette of
// `maskItem` — used to chop album art into the shell's panel shape.
MultiEffect {
    property Item maskItem

    maskEnabled: maskItem !== null
    maskSource: maskItem

    // The chopped corners should read as cuts, not fades — but a spread of 0
    // is a hard `alpha < 0.5 ? 0 : 1` step, which throws away the one thing
    // that makes the cut look drawn rather than pixelated: the mask Shape's own
    // coverage antialiasing. Every partially covered pixel along a diagonal got
    // rounded to all-or-nothing and the art came out with a visible staircase
    // down both leaning edges. A narrow spread lets that single-pixel ramp
    // through and nothing wider — still a cut, just not a jagged one.
    maskThresholdMin: 0.5
    maskSpreadAtMin: 0.3
}
