import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "root:/config"
import "root:/components"
import "root:/services"

// Adapter toggle, scan, and the device list with battery levels where BlueZ
// reports them.
Popout {
    id: root

    contentWidth: 340
    contentHeight: 280

    // Discovery is expensive; run it only while the panel is open.
    onShownChanged: {
        if (!shown && Bt.discovering && Bt.adapter) Bt.adapter.discovering = false;
    }

    PopoutSurface {
        anchors.fill: parent
        tone: Bt.enabled ? Theme.accent : Theme.muted

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Bluetooth"
            icon: Bt.icon
            accent: Theme.accent
            subtitle: Bt.adapter ? Bt.adapter.name : "NO ADAPTER"
        }

        Row {
            id: controls
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            spacing: Theme.padS

            P5Button {
                text: Bt.enabled ? "On" : "Off"
                icon: Bt.enabled ? "󰂯" : "󰂲"
                accent: Bt.enabled ? Theme.accent : Theme.muted
                onClicked: Bt.toggle()
            }

            P5Button {
                text: Bt.discovering ? "Scanning" : "Scan"
                icon: "󰐷"
                accent: Bt.discovering ? Theme.accent : Theme.primary
                onClicked: Bt.toggleScan()
            }
        }

        SectionRule {
            id: listLabel
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            text: Bt.devices.length > 0 ? "Devices" : "No devices"
        }

        ListView {
            anchors.top: listLabel.bottom
            anchors.topMargin: Theme.padS
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            spacing: 2
            model: Bt.devices

            delegate: ListRow {
                id: devRow

                required property BluetoothDevice modelData

                width: ListView.view.width
                icon: Bt.deviceIcon(modelData)
                label: Bt.deviceLabel(modelData)
                detail: {
                    if (modelData.pairing) return "pairing…";
                    if (modelData.connected) return "connected";
                    if (modelData.paired || modelData.bonded) return "paired";
                    return modelData.address;
                }
                current: modelData.connected
                onClicked: Bt.toggleDevice(modelData)
                onRightClicked: if (modelData.paired) modelData.forget()

                // Device battery, where BlueZ exposes it.
                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: devRow.modelData.batteryAvailable
                    text: "󰥉"
                    color: devRow.modelData.battery > 0.25 ? Theme.subtext : Theme.alarm
                    font.pixelSize: Theme.fsSmall
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: devRow.modelData.batteryAvailable
                    text: Math.round(devRow.modelData.battery * 100) + "%"
                    color: Theme.subtext
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
