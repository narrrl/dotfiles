import QtQuick
import "root:/config"
import "root:/components"

// A load meter: a soft rounded track with the level filling it from the left.
// It used to be a row of separate segments; one continuous line reads calmer,
// and a level that glides reads as a quantity rather than as a count.
//
// `segments`, `segmentWidth` and `spacing` are accepted and ignored, so the
// call sites that still size a segmented meter do not have to be chased down.
Item {
    id: root

    property real value: 0            // 0..100
    property int segments: 14
    property real segmentWidth: 4
    property real spacing: 3
    property color activeColor: Theme.heat(value)
    property color idleColor: Theme.alpha(Theme.outline, 0.35)
    property real lean: Theme.skew

    implicitWidth: segments * segmentWidth + (segments - 1) * spacing
    implicitHeight: 4

    readonly property real fraction: Math.max(0, Math.min(100, root.value)) / 100

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.idleColor
    }

    Rectangle {
        height: parent.height
        // Never narrower than its own height, so a near-zero level is a dot
        // rather than a sliver.
        width: root.fraction > 0 ? Math.max(height, parent.width * root.fraction) : 0
        radius: height / 2
        color: root.activeColor

        Behavior on width {
            NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: Theme.durBase }
        }
    }
}
