import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// The resource dashboard: four gauges, then the details that do not fit on one.
Popout {
    id: root

    contentWidth: 420
    // Derived rather than a fixed number: the meters are taller than the dials
    // they replaced, and the GPU block disappears entirely on machines without
    // one. A hardcoded height would either clip or leave a hole.
    contentHeight: header.height + Theme.padM
        + gauges.implicitHeight + Theme.padL
        + details.implicitHeight + Theme.padM * 2

    PopoutSurface {
        anchors.fill: parent
        tone: Theme.heat(Math.max(Sys.cpuUsage, Sys.memPercent))

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "System"
            icon: "󰍛"
            accent: Theme.primary
            subtitle: "UP " + Sys.uptime + "  ·  " + Sys.procs + " PROCS"
        }

        Column {
            id: gauges
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.padM

            MetricRow {
                width: parent.width
                value: Sys.cpuUsage
                label: "CPU"
                sub: Math.round(Sys.cpuTemp) + "°C"
            }

            MetricRow {
                width: parent.width
                value: Sys.memPercent
                label: "MEM"
                sub: Sys.gb(Sys.memUsed) + " / " + Sys.gb(Sys.memTotal)
            }

            MetricRow {
                width: parent.width
                visible: Sys.gpuAvailable
                value: Sys.gpuUsage
                label: "GPU"
                sub: Math.round(Sys.gpuTemp) + "°C"
            }

            MetricRow {
                width: parent.width
                value: Sys.diskPercent
                label: "DISK"
                sub: Sys.diskFree + " free"
            }
        }

        Column {
            id: details
            anchors.top: gauges.bottom
            anchors.topMargin: Theme.padL
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 3

            InfoRow {
                width: parent.width
                key: "Processor"
                value: Sys.cpuModel
            }

            InfoRow {
                width: parent.width
                key: "Load"
                value: Sys.load1.toFixed(2) + "  " + Sys.load5.toFixed(2) + "  " + Sys.load15.toFixed(2)
            }

            InfoRow {
                width: parent.width
                visible: Sys.gpuAvailable
                key: "VRAM"
                value: Sys.gb(Sys.gpuVramUsed) + " / " + Sys.gb(Sys.gpuVramTotal)
            }

            InfoRow {
                width: parent.width
                key: "Root"
                value: Sys.gb(Sys.diskUsed) + " of " + Sys.gb(Sys.diskTotal) + " used"
            }

            InfoRow {
                width: parent.width
                key: "Network"
                value: Sys.netUp
                    ? Sys.netInterface + "  ↓ " + Sys.rate(Sys.netRx) + "  ↑ " + Sys.rate(Sys.netTx)
                    : "offline"
            }
        }
    }

    component InfoRow: Item {
        id: infoRow

        property string key: ""
        property string value: ""

        implicitHeight: visible ? 17 : 0

        Text {
            id: keyLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.key.toUpperCase()
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 1.5
            renderType: Text.NativeRendering
        }

        Text {
            anchors.right: parent.right
            anchors.left: keyLabel.right
            anchors.leftMargin: Theme.padM
            anchors.verticalCenter: parent.verticalCenter
            text: infoRow.value
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
            color: Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }
}
