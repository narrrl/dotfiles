import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// Charge level, time estimate, draw rate and health.
Popout {
    id: root

    contentWidth: 310
    contentHeight: 296

    PopoutSurface {
        anchors.fill: parent
        tone: Battery.tint

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Power"
            icon: Battery.icon
            accent: Battery.tint
            subtitle: Battery.charging ? "CHARGING" : (Battery.onBattery ? "ON BATTERY" : "AC")
        }

        Row {
            id: readout
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.padM

            Gauge {
                width: 92; height: 92
                value: Battery.percent
                label: "CHARGE"
                arcColor: Battery.tint
                readout: Math.round(Battery.percent) + "%"
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.padS

                SplitText {
                    text: Battery.timeLabel
                    pixelSize: Theme.fsBody
                    split: 1.1
                    splitOpacity: 0.55
                }

                Text {
                    text: Battery.changeRate > 0
                        ? Battery.changeRate.toFixed(1) + " W " + (Battery.charging ? "in" : "draw")
                        : "idle"
                    color: Theme.subtext
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    renderType: Text.NativeRendering
                }

                Text {
                    visible: Battery.health > 0
                    text: "Health " + Math.round(Battery.health) + "%"
                    color: Battery.health < 70 ? Theme.warn : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    renderType: Text.NativeRendering
                }
            }
        }

        MeterBar {
            id: bar
            anchors.top: readout.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            height: 12
            segments: 20
            segmentWidth: (width - 19 * 3) / 20
            spacing: 3
            value: Battery.percent
            activeColor: Battery.tint
        }

        P5Button {
            id: suspendButton
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            text: "Suspend"
            icon: "󰤄"
            onClicked: {
                root.pinned = false;
                Actions.suspend();
            }
        }

        Text {
            anchors.top: bar.bottom
            anchors.topMargin: Theme.padS
            anchors.bottom: suspendButton.top
            anchors.bottomMargin: Theme.padS
            anchors.left: parent.left
            anchors.right: parent.right
            text: Battery.detail
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }
}
