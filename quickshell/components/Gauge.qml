import QtQuick
import QtQuick.Shapes
import "root:/config"

// Radial gauge used across the resource popout. Sweeps a 270° arc with a
// tick-marked rail behind it and the reading set in the middle.
Item {
    id: root

    property real value: 0            // 0..100
    property string label: ""
    property string readout: Math.round(value) + "%"
    property string sub: ""
    property color arcColor: Theme.heat(value)
    property real thickness: 7
    property real startAngle: 135
    property real sweep: 270
    property int ticks: 24

    implicitWidth: 96
    implicitHeight: 96

    readonly property real _r: Math.min(width, height) / 2 - thickness / 2 - 4
    readonly property real _cx: width / 2
    readonly property real _cy: height / 2

    // Rail
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.alpha(Theme.outline, 0.5)
            strokeWidth: root.thickness
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                centerX: root._cx; centerY: root._cy
                radiusX: root._r; radiusY: root._r
                startAngle: root.startAngle
                sweepAngle: root.sweep
            }
        }
    }

    // Tick marks around the rail.
    Repeater {
        model: root.ticks
        Rectangle {
            required property int index
            readonly property real a: (root.startAngle + root.sweep * (index / (root.ticks - 1))) * Math.PI / 180
            readonly property real rr: root._r + root.thickness / 2 + 3
            width: 2
            height: index % 4 === 0 ? 6 : 3
            color: Theme.alpha(Theme.primary, index % 4 === 0 ? 0.55 : 0.25)
            x: root._cx + Math.cos(a) * rr - width / 2
            y: root._cy + Math.sin(a) * rr - height / 2
            rotation: (root.startAngle + root.sweep * (index / (root.ticks - 1))) + 90
        }
    }

    // Value arc
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            fillColor: "transparent"
            strokeColor: root.arcColor
            strokeWidth: root.thickness
            capStyle: ShapePath.FlatCap
            PathAngleArc {
                id: valueArc
                centerX: root._cx; centerY: root._cy
                radiusX: root._r; radiusY: root._r
                startAngle: root.startAngle
                sweepAngle: root.sweep * Math.max(0, Math.min(100, root.value)) / 100

                Behavior on sweepAngle {
                    NumberAnimation {
                        duration: Theme.durSlow
                        easing.type: Easing.OutExpo
                    }
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: -2

        SplitText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.readout
            pixelSize: Theme.fsLarge
            color: Theme.text
            split: 1.2
            splitOpacity: 0.6
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.sub !== ""
            text: root.sub
            color: Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }
}
