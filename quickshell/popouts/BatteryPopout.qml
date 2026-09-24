import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// Charge level, time estimate, draw rate and health.
Popout {
    id: root

    contentWidth: 310
    // Derived: the charge block is a different height from the dial it
    // replaced, and the health line comes and goes.
    contentHeight: header.height + Theme.padM + readout.height + Theme.padM
        + bar.height + Theme.padM + detailText.implicitHeight + Theme.padL
        + suspendButton.height + Theme.padM * 2

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

        // The dial that used to sit here duplicated the meter below it and was
        // the only curve in the shell. The charge is now simply set large, and
        // the MeterBar underneath is left to carry the level on its own.
        Item {
            id: readout
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            height: Math.max(charge.height, detail.height)

            Column {
                id: charge
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                // No "CHARGE" caption under the number. It landed directly on
                // top of the meter, and between the header and a full-width
                // charge bar there was nothing left for it to disambiguate.
                SplitText {
                    text: Math.round(Battery.percent) + "%"
                    pixelSize: Theme.fsHuge
                    color: Battery.tint
                }
            }

            Column {
                id: detail
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.padS

                SplitText {
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignRight
                    text: Battery.timeLabel
                    pixelSize: Theme.fsBody
                }

                Text {
                    text: Battery.changeRate > 0
                        ? Battery.changeRate.toFixed(1) + " W " + (Battery.charging ? "in" : "draw")
                        : "idle"
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignRight
                    color: Theme.subtext
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    renderType: Text.NativeRendering
                }

                Text {
                    visible: Battery.health > 0
                    text: "Health " + Math.round(Battery.health) + "%"
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignRight
                    color: Battery.health < 70 ? Theme.alarm : Theme.muted
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

        Text {
            id: detailText
            anchors.top: bar.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            text: Battery.detail
            wrapMode: Text.WordWrap
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }

        // Follows the detail line rather than being pinned to the bottom of a
        // fixed-height panel, which is what left a dead band above it.
        P5Button {
            id: suspendButton
            anchors.top: detailText.bottom
            anchors.topMargin: Theme.padL
            anchors.left: parent.left
            text: "Suspend"
            icon: "󰤄"
            onClicked: {
                root.pinned = false;
                Actions.suspend();
            }
        }
    }
}
