import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

// Secondary input band with an explicit mute action.
Item {
    id: root

    implicitHeight: 68

    Row {
        anchors.left: parent.left
        anchors.right: muteButton.left
        anchors.rightMargin: Theme.padM
        anchors.verticalCenter: muteButton.verticalCenter
        spacing: Theme.padS

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.micIcon
            color: Audio.micMuted ? Theme.accent : Theme.text
            font.pixelSize: Theme.fsLarge
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - Theme.fsLarge - Theme.padS
            spacing: 2

            Text {
                width: parent.width
                text: Audio.sourceName
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                font.weight: Font.DemiBold
                font.italic: true
                renderType: Text.NativeRendering
            }

            Text {
                text: Audio.micMuted ? "MUTED" : Audio.micPercent + "%"
                color: Audio.micMuted ? Theme.accent : Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
        }
    }

    P5Button {
        id: muteButton
        anchors.right: parent.right
        anchors.top: parent.top
        text: Audio.micMuted ? "Unmute input" : "Mute input"
        icon: Audio.micIcon
        onClicked: Audio.toggleMicMute()
    }

    P5Slider {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        value: Audio.micVolume
        accent: Theme.primary
        enabled: !Audio.micMuted
        onMoved: v => Audio.setMicVolume(v)
    }
}
