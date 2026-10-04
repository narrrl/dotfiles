import QtQuick
import Quickshell
import Quickshell.Networking
import "root:/config"
import "root:/components"
import "root:/services"

// Link state, throughput, and the Wi-Fi picker.
Popout {
    id: root

    contentWidth: 360
    contentHeight: 300

    // Scan only while the popout is actually on screen.
    onShownChanged: Net.setScanning(shown)

    PopoutSurface {
        anchors.fill: parent
        tone: Sys.netUp ? Theme.primary : Theme.muted

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Network"
            icon: Net.icon
            subtitle: Sys.netUp ? Sys.netIp : "OFFLINE"
        }

        // Throughput
        Row {
            id: rates
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.padM

            RateBlock {
                width: (parent.width - Theme.padM) / 2
                glyph: "󰇚"
                label: "Down"
                value: Sys.rate(Sys.netRx)
                tone: Theme.primary
            }

            RateBlock {
                width: (parent.width - Theme.padM) / 2
                glyph: "󰕒"
                label: "Up"
                value: Sys.rate(Sys.netTx)
                tone: Theme.accent
            }
        }

        Row {
            id: controls
            anchors.top: rates.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            spacing: Theme.padS

            ActionButton {
                text: Net.wifiEnabled ? "Wi-Fi On" : "Wi-Fi Off"
                icon: Net.wifiEnabled ? "󰖩" : "󰖪"
                accent: Net.wifiEnabled ? Theme.primary : Theme.muted
                onClicked: Net.toggleWifi()
            }

            ActionButton {
                text: "Settings"
                icon: "󰒓"
                onClicked: Actions.openNetworkSettings()
            }
        }

        SectionRule {
            id: apsLabel
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            text: Net.scanning ? "Scanning…" : "Networks"
        }

        ListView {
            anchors.top: apsLabel.bottom
            anchors.topMargin: Theme.padS
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            spacing: 2
            model: Net.wifiNetworks

            delegate: ListRow {
                id: apRow

                required property var modelData

                width: ListView.view.width
                icon: Net.signalIcon(modelData.signalStrength ?? 0)
                label: modelData.name
                current: modelData.connected

                onClicked: {
                    if (apRow.modelData.connected) {
                        apRow.modelData.disconnect();
                    } else {
                        // Saved networks connect directly; new secured ones
                        // need a passphrase, which NetworkManager's own
                        // agent will prompt for.
                        apRow.modelData.connect();
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: apRow.modelData.known
                    text: "SAVED"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
                }

                Icon {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Net.secured(apRow.modelData)
                    text: "󰌾"
                    color: Theme.muted
                    font.pixelSize: Theme.fsSmall
                }
            }
        }
    }

    component RateBlock: Item {
        id: rateBlock

        property string glyph: ""
        property string label: ""
        property string value: ""
        property color tone: Theme.primary

        implicitHeight: 40

        Skew {
            anchors.fill: parent
            color: Theme.alpha(rateBlock.tone, 0.08)
            borderWidth: 1
            borderColor: Theme.alpha(rateBlock.tone, 0.35)
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.padS

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                text: rateBlock.glyph
                color: rateBlock.tone
                font.pixelSize: Theme.fsLarge
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: -1

                Text {
                    text: rateBlock.label.toUpperCase()
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1.5
                    renderType: Text.NativeRendering
                }

                Text {
                    text: rateBlock.value
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }
            }
        }
    }
}
