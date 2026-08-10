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
        tone: Bt.enabled ? Theme.blue : Theme.muted

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Bluetooth"
            icon: Bt.icon
            accent: Theme.blue
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
                accent: Bt.enabled ? Theme.blue : Theme.muted
                onClicked: Bt.toggle()
            }

            P5Button {
                text: Bt.discovering ? "Scanning" : "Scan"
                icon: "󰐷"
                accent: Bt.discovering ? Theme.accent : Theme.primary
                onClicked: Bt.toggleScan()
            }
        }

        Text {
            id: listLabel
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            text: Bt.devices.length > 0 ? "DEVICES" : "NO DEVICES"
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
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

            delegate: Item {
                id: devRow

                required property BluetoothDevice modelData

                width: ListView.view.width
                height: 34

                Rectangle {
                    anchors.fill: parent
                    color: devHover.hovered
                        ? Theme.alpha(Theme.blue, 0.16)
                        : (devRow.modelData.connected ? Theme.alpha(Theme.blue, 0.08) : "transparent")
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: devRow.modelData.connected ? 22 : 0
                    color: Theme.accent

                    Behavior on height {
                        NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutBack }
                    }
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padM
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.padS

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Bt.deviceIcon(devRow.modelData)
                        color: devRow.modelData.connected ? Theme.blue : Theme.subtext
                        font.pixelSize: Theme.fsLarge
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -2

                        Text {
                            text: Bt.deviceLabel(devRow.modelData)
                            color: devRow.modelData.connected ? Theme.text : Theme.subtext
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fsSmall
                            font.italic: true
                            font.weight: devRow.modelData.connected ? Font.Black : Font.Medium
                            renderType: Text.NativeRendering
                        }

                        Text {
                            text: {
                                if (devRow.modelData.pairing) return "pairing…";
                                if (devRow.modelData.connected) return "connected";
                                if (devRow.modelData.paired || devRow.modelData.bonded) return "paired";
                                return devRow.modelData.address;
                            }
                            color: Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            renderType: Text.NativeRendering
                        }
                    }
                }

                // Device battery, where BlueZ exposes it.
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padS
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 3
                    visible: devRow.modelData.batteryAvailable

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰥉"
                        color: devRow.modelData.battery > 0.25 ? Theme.ok : Theme.warn
                        font.pixelSize: Theme.fsSmall
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Math.round(devRow.modelData.battery * 100) + "%"
                        color: Theme.subtext
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsMicro
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    id: devHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    acceptedButtons: Qt.LeftButton
                    onTapped: Bt.toggleDevice(devRow.modelData)
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: if (devRow.modelData.paired) devRow.modelData.forget()
                }
            }
        }
    }
}
