import QtQuick
import "root:/config"
import "root:/components"
import "root:/services"

// Dominant current-output readout for AudioPopout.
Item {
    implicitHeight: 112

    Text {
        id: outputPercent
        anchors.left: parent.left
        anchors.top: parent.top
        text: Audio.volumePercent + "%"
        color: Audio.muted ? Theme.muted : Theme.text
        font.family: Theme.fontDisplay
        font.pixelSize: Theme.fsHuge
        font.weight: Theme.weightDisplay
        font.italic: true
        renderType: Text.NativeRendering
    }

    Column {
        anchors.left: outputPercent.right
        anchors.leftMargin: Theme.padL
        anchors.right: parent.right
        anchors.verticalCenter: outputPercent.verticalCenter
        spacing: 3

        Text {
            text: "CURRENT OUTPUT"
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.weight: Font.Bold
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        Text {
            width: parent.width
            text: Audio.sinkName
            elide: Text.ElideRight
            color: Theme.subtext
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsSmall
            font.weight: Font.DemiBold
            font.italic: true
            renderType: Text.NativeRendering
        }

        Text {
            text: Audio.muted ? "MUTED" : "LIVE"
            color: Audio.muted ? Theme.treatmentOffText : Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.weight: Font.Bold
            renderType: Text.NativeRendering
        }
    }

    P5Slider {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        value: Audio.volume
        accent: Theme.accent
        enabled: !Audio.muted
        onMoved: v => Audio.setVolume(v)
    }
}
