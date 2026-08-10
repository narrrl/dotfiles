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
        }

        Divider {}

        Metric {
            label: "MEM"
            value: Sys.memPercent
            readout: Sys.memUsed.toFixed(1) + "G"
        }

        Divider { visible: Sys.gpuAvailable }

        Metric {
            visible: Sys.gpuAvailable
            label: "GPU"
            value: Sys.gpuUsage
            readout: Math.round(Sys.gpuUsage) + "%"
        }
    }

    component Divider: Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 18
        color: Theme.alpha(Theme.outline, 0.8)
        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -Theme.skew, 0, 18 * Theme.skew,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        }
    }

    // The CPU/MEM/GPU labels are gone: three characters of chrome per metric,
    // repeated three times, in the most cramped part of the shell. The number
    // over its meter is legible on its own, and dropping them buys the room to
    // set the figure in display italic instead of squeezing it into mono.
    component Metric: Column {
        id: metric

        property string label: ""
        property real value: 0
        property string readout: ""

        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            text: metric.readout
            color: Theme.heat(metric.value)
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsBody
            font.weight: Theme.weightDisplay
            font.italic: true
            font.letterSpacing: 0.5
            renderType: Text.NativeRendering

            Behavior on color {
                ColorAnimation { duration: Theme.durBase }
            }
        }

        MeterBar {
            value: metric.value
            segments: 9
            segmentWidth: 3
            spacing: 2
            height: 5
        }
    }

    SysPopout {
        id: popout
        anchorItem: root
        triggerHovered: root.hovered
    }
}
