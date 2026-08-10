import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "root:/config"
import "root:/components"
import "root:/services"

// Output and input levels, the sink picker, and a per-app mixer.
Popout {
    id: root

    contentWidth: 360
    contentHeight: surface.implicitContentHeight + Theme.padM * 2

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
            LevelRow {
                width: parent.width
                icon: Audio.icon
                label: "Output"
                readout: Audio.muted ? "MUTED" : Audio.volumePercent + "%"
                value: Audio.volume
                muted: Audio.muted
                accent: Theme.primary
                onMoved: v => Audio.setVolume(v)
                onToggled: Audio.toggleMute()
            }

            // -------------------------------------------------------- input
            LevelRow {
                width: parent.width
                icon: Audio.micIcon
                label: "Input"
                readout: Audio.micMuted ? "MUTED" : Audio.micPercent + "%"
                value: Audio.micVolume
                muted: Audio.micMuted
                accent: Theme.blue
                onMoved: v => Audio.setMicVolume(v)
                onToggled: Audio.toggleMicMute()
            }

            SectionRule {
                width: parent.width
                text: "Outputs"
                visible: Audio.sinks.length > 1
            }

            Repeater {
                model: Audio.sinks.length > 1 ? Audio.sinks : []

                PickRow {
                    required property var modelData
                    width: column.width
                    label: modelData.nickname || modelData.description || modelData.name
                    icon: "󰓃"
                    selected: Audio.sink === modelData
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
                    value: modelData.audio?.volume ?? 0
                    muted: modelData.audio?.muted ?? false
                    accent: Theme.glow
                    onMoved: v => { if (modelData.audio) modelData.audio.volume = v; }
                    onToggled: { if (modelData.audio) modelData.audio.muted = !modelData.audio.muted; }
                }
            }

            P5Button {
                text: "Mixer"
                icon: "󰕾"
                onClicked: Actions.openAudioSettings()
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
                color: levelRow.muted ? Theme.accent : levelRow.accent
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
                font.italic: true
                renderType: Text.NativeRendering
            }

            Text {
                id: readoutText
                anchors.verticalCenter: parent.verticalCenter
                text: levelRow.readout
                color: levelRow.muted ? Theme.accent : Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                renderType: Text.NativeRendering
            }
        }

        P5Slider {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            value: levelRow.value
            accent: levelRow.accent
            enabledControl: !levelRow.muted
            onMoved: v => levelRow.moved(v)
        }
    }

    component SectionRule: Item {
        property string text: ""
        implicitHeight: visible ? 18 : 0

        Text {
            id: sectionLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: parent.text.toUpperCase()
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        Rectangle {
            anchors.left: sectionLabel.right
            anchors.leftMargin: Theme.padS
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 1
            color: Theme.alpha(Theme.outline, 0.6)
        }
    }

    component PickRow: Item {
        id: pickRow

        property string label: ""
        property string icon: ""
        property bool selected: false

        signal clicked()

        implicitHeight: 26

        Rectangle {
            anchors.fill: parent
            color: pickHover.hovered
                ? Theme.alpha(Theme.primary, 0.14)
                : (pickRow.selected ? Theme.alpha(Theme.primary, 0.07) : "transparent")
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: pickRow.selected ? 18 : 0
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
                text: pickRow.icon
                color: pickRow.selected ? Theme.primary : Theme.muted
                font.pixelSize: Theme.fsBody
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: pickRow.label
                color: pickRow.selected ? Theme.text : Theme.subtext
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                font.italic: true
                renderType: Text.NativeRendering
            }
        }

        HoverHandler {
            id: pickHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: pickRow.clicked()
        }
    }
}
