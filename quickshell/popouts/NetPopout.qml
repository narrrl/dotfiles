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

            P5Button {
                text: Net.wifiEnabled ? "Wi-Fi On" : "Wi-Fi Off"
                icon: Net.wifiEnabled ? "󰖩" : "󰖪"
                accent: Net.wifiEnabled ? Theme.primary : Theme.muted
                onClicked: Net.toggleWifi()
            }

            P5Button {
                text: "Settings"
                icon: "󰒓"
                onClicked: Actions.openNetworkSettings()
            }
        }

        Text {
            id: apsLabel
            anchors.top: controls.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            text: Net.scanning ? "SCANNING…" : "NETWORKS"
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
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

            delegate: Item {
                id: apRow

                required property var modelData

                width: ListView.view.width
                height: 30

                Rectangle {
                    anchors.fill: parent
                    color: apHover.hovered
                        ? Theme.alpha(Theme.primary, 0.14)
                        : (apRow.modelData.connected ? Theme.alpha(Theme.primary, 0.07) : "transparent")
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: 3
                    height: apRow.modelData.connected ? 20 : 0
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
                        text: Net.signalIcon(apRow.modelData.signalStrength ?? 0)
                        color: apRow.modelData.connected ? Theme.primary : Theme.subtext
                        font.pixelSize: Theme.fsBody
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: apRow.modelData.name
                        color: apRow.modelData.connected ? Theme.text : Theme.subtext
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fsSmall
                        font.italic: true
                        font.weight: apRow.modelData.connected ? Font.Black : Font.Medium
                        renderType: Text.NativeRendering
                    }

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: Net.secured(apRow.modelData)
                        text: "󰌾"
                        color: Theme.muted
                        font.pixelSize: Theme.fsMicro
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padS
                    anchors.verticalCenter: parent.verticalCenter
                    text: apRow.modelData.known ? "SAVED" : ""
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    id: apHover
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    onTapped: {
                        if (apRow.modelData.connected) {
                            apRow.modelData.disconnect();
                        } else {
                            // Saved networks connect directly; new secured ones
                            // need a passphrase, which NetworkManager's own
                            // agent will prompt for.
                            apRow.modelData.connect();
                        }
                    }
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

        Rectangle {
            anchors.fill: parent
            color: Theme.alpha(rateBlock.tone, 0.08)
            border.width: 1
            border.color: Theme.alpha(rateBlock.tone, 0.35)

            transform: Matrix4x4 {
                matrix: Qt.matrix4x4(1, -Theme.skew, 0, rateBlock.height * Theme.skew,
                                     0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
            }
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
                    font.pixelSize: 8
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
