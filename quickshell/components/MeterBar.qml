import QtQuick
import "root:/config"

// A segmented load meter — slanted ticks that light up left to right. Reads as
// a gauge at a glance and keeps the panel language consistent.
Item {
    id: root

    property real value: 0            // 0..100
    property int segments: 14
    property real segmentWidth: 4
    property real spacing: 3
    property color activeColor: Theme.heat(value)
    property color idleColor: Theme.alpha(Theme.outline, 0.55)
    property real lean: Theme.skew

    readonly property int litCount: Math.round(Math.max(0, Math.min(100, value)) / 100 * segments)

    implicitWidth: segments * segmentWidth + (segments - 1) * spacing
    implicitHeight: 14

    Row {
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: root.segments

            Item {
                required property int index
                width: root.segmentWidth
                height: root.height

                Rectangle {
                    width: root.segmentWidth
                    height: root.height
                    color: parent.index < root.litCount ? root.activeColor : root.idleColor

                    // Peak segments glow, so a pegged CPU is visible peripherally.
                    opacity: parent.index < root.litCount
                        ? (parent.index >= root.segments - 2 ? 1.0 : 0.9)
                        : 1.0

                    transform: Matrix4x4 {
                        matrix: Qt.matrix4x4(
                            1, -root.lean, 0, root.height * root.lean,
                            0, 1, 0, 0,
                            0, 0, 1, 0,
                            0, 0, 0, 1)
                    }

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase }
                    }
                }
            }
        }
    }
}
