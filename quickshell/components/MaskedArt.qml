import QtQuick
import QtQuick.Effects

// Layer effect that clips whatever it is applied to into the silhouette of
// `maskItem` — used to chop album art into the shell's panel shape.
MultiEffect {
    property Item maskItem

    maskEnabled: maskItem !== null
    maskSource: maskItem
    // Hard edge — the chopped corners should read as cuts, not fades.
    maskThresholdMin: 0.5
    maskSpreadAtMin: 0.0
}
