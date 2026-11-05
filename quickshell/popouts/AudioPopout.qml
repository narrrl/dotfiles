import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "root:/config"
import "root:/components"
import "root:/services"

// Audio is the expressive vertical slice for rail popouts: output owns the
// composition, input is a clear secondary band, and application streams recede
// into a compact mixer below both device controls.
Popout {
    id: root

    contentWidth: 400
    contentHeight: surface.implicitContentHeight + Theme.padM * 2
    initialFocusItem: outputMuteButton

    PopoutSurface {
        id: surface
        anchors.fill: parent
        tone: Theme.primary

        readonly property real implicitContentHeight: header.height + column.implicitHeight + Theme.padM * 2

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: "Audio"
            icon: Audio.icon
            accent: Theme.primary
            subtitle: Audio.sinkName
        }

        Column {
            id: column
            anchors.top: header.bottom
            anchors.topMargin: Theme.padM
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.padM

            // ------------------------------------------------------- output
            AudioOutputHero {
                width: parent.width
            }

            Column {
                width: parent.width
                spacing: Theme.padS

                ActionButton {
                    id: outputMuteButton
                    width: parent.width
                    text: Audio.muted ? "Unmute output" : "Mute output"
                    icon: Audio.icon
                    onClicked: Audio.toggleMute()
                }

                ActionButton {
                    width: parent.width
                    text: "Open audio mixer"
                    icon: "󰕾"
                    onClicked: Actions.openAudioSettings()
                }
            }

            // -------------------------------------------------------- input
            SectionRule {
                width: parent.width
                text: "Input"
            }

            AudioInputBand {
                width: parent.width
            }

            SectionRule {
                width: parent.width
                text: "Outputs"
                visible: Audio.sinks.length > 1
            }

            Repeater {
                model: Audio.sinks.length > 1 ? Audio.sinks : []

                ListRow {
                    required property var modelData
                    width: column.width
                    label: modelData.nickname || modelData.description || modelData.name
                    icon: "󰓃"
                    current: Audio.sink === modelData
                    onClicked: Audio.setSink(modelData)
                }
            }

            SectionRule {
                width: parent.width
                text: "Applications"
                visible: Audio.streams.length > 0
            }

            Repeater {
                model: Audio.streams

                LevelRow {
                    required property var modelData
                    width: column.width
                    icon: "󰝚"
                    label: Audio.streamName(modelData)
                    readout: modelData.audio ? Math.round(modelData.audio.volume * 100) + "%" : ""
                    value: modelData.audio ? modelData.audio.volume : 0
                    muted: modelData.audio ? modelData.audio.muted : false
                    accent: Theme.glow
                    onMoved: v => { if (modelData.audio) modelData.audio.volume = v; }
                    onToggled: { if (modelData.audio) modelData.audio.muted = !modelData.audio.muted; }
                }
            }

        }
    }

    // ------------------------------------------------------------- pieces
    component LevelRow: Item {
        id: levelRow

        property string icon: ""
        property string label: ""
        property string readout: ""
        property real value: 0
        property bool muted: false
        property color accent: Theme.primary

        signal moved(real value)
        signal toggled()

        implicitHeight: 42

        Row {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Theme.padS

            Icon {
                id: levelIcon
                anchors.verticalCenter: parent.verticalCenter
                text: levelRow.icon
                color: levelRow.muted ? Theme.treatmentOffText : levelRow.accent
                font.pixelSize: Theme.fsLarge

                TapHandler { onTapped: levelRow.toggled() }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: levelRow.width - levelIcon.width - readoutText.width - Theme.padS * 3
                text: levelRow.label
                elide: Text.ElideRight
                color: Theme.text
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                font.weight: Font.DemiBold
                renderType: Text.NativeRendering
            }

            Text {
                id: readoutText
                anchors.verticalCenter: parent.verticalCenter
                text: levelRow.readout
                color: levelRow.muted ? Theme.treatmentOffText : Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
        }

        LevelSlider {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            value: levelRow.value
            accent: levelRow.accent
            enabled: !levelRow.muted
            onMoved: v => levelRow.moved(v)
        }
    }
}
