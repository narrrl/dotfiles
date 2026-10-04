import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/popouts"

// Compact CPU / MEM / GPU readout. Each metric is a number over a segmented
// meter; hovering opens the full gauge cluster.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.heat(Math.max(Sys.cpuUsage, Sys.memPercent))

    padding: Theme.padM
    implicitWidth: layout.implicitWidth + contentPad * 2

    onClicked: Actions.openSystemMonitor()

    Row {
        id: layout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        spacing: Theme.padM

        Metric {
            label: "CPU"
            value: Sys.cpuUsage
            readout: Math.round(Sys.cpuUsage) + "%"
            widest: "100%"
        }

        Divider {}

        Metric {
            label: "MEM"
            value: Sys.memPercent
            readout: Sys.memUsed.toFixed(1) + "G"
            widest: "88.8G"
        }

        Divider { visible: Sys.gpuAvailable }

        Metric {
            visible: Sys.gpuAvailable
            label: "GPU"
            value: Sys.gpuUsage
            readout: Math.round(Sys.gpuUsage) + "%"
            widest: "100%"
        }
    }

    component Divider: Item {
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: rule.width
        implicitHeight: 18

        // Sized to hold its own lean — see the note on the bar's divider.
        Skew {
            id: rule
            anchors.centerIn: parent
            width: parent.height * Theme.skew + 1
            height: parent.height
            color: Theme.alpha(Theme.outline, 0.5)
        }
    }

    // A tiny fixed label makes every number self-describing without turning the
    // compact meter cluster back into three separate cards.
    component Metric: Column {
        id: metric

        property string label: ""
        property real value: 0
        property string readout: ""

        // The widest reading this metric will ever show. The number column is
        // sized from this rather than from the live text, because sizing to the
        // live text is what made the whole right-hand group breathe in and out:
        // "9%" and "100%" are ~14px apart in Archivo Black, so every tick of the
        // CPU sampler nudged the metrics, the media pill and the clock sideways.
        // Reserving the maximum costs a few px of blank and buys a bar that
        // never moves.
        property string widest: "100%"

        readonly property real numberWidth: Math.max(gauge.width, metrics.advanceWidth)
        readonly property real headWidth: labelText.implicitWidth + head.spacing + numberWidth

        anchors.verticalCenter: parent.verticalCenter
        spacing: 2
        width: Math.max(headWidth, 44)

        TextMetrics {
            id: metrics
            text: metric.widest
            font: gauge.font
        }

        Row {
            id: head
            spacing: 4

            Text {
                id: labelText
                anchors.baseline: gauge.baseline
                text: metric.label
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                renderType: Text.NativeRendering
            }

            Text {
                id: gauge
                text: metric.readout
                color: Theme.heat(metric.value)
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsBody
                font.weight: Theme.weightDisplay
                font.letterSpacing: 0.5
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation { duration: Theme.durBase }
                }
            }
        }

        // Ends flush with the reading above it instead of stopping short at a
        // fixed 43px, so each metric reads as one block.
        MeterBar {
            value: metric.value
            segments: 9
            spacing: 2
            height: 5
            width: metric.width
            segmentWidth: (width - 8 * spacing) / 9
        }
    }

    SysPopout {
        id: popout
        anchorItem: root
        triggerHovered: root.hovered
    }
}
