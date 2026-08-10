import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// Volume / mic / brightness heads-up, bottom centre. Appears on change and
// fades out on its own.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool primaryScreen: Quickshell.screens.length === 0
        || Quickshell.screens[0] === modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-osd"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { bottom: true }
    margins.bottom: 90

    implicitWidth: 300
    implicitHeight: 78
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: primaryScreen && (shown || fade.running)

    property bool shown: false
    property string kind: "volume"

    // Suppress the burst of change signals that fires while services warm up.
    property bool armed: false
    Timer {
        interval: 1500
        running: true
        onTriggered: root.armed = true
    }

    readonly property string glyph: {
        switch (root.kind) {
        case "mic": return Audio.micIcon;
        case "brightness": return Brightness.icon;
        default: return Audio.icon;
        }
    }

    readonly property string title: {
        switch (root.kind) {
        case "mic": return Audio.micMuted ? "Mic muted" : "Microphone";
        case "brightness": return "Brightness";
        default: return Audio.muted ? "Muted" : "Volume";
        }
    }

    readonly property real level: {
        switch (root.kind) {
        case "mic": return Audio.micMuted ? 0 : Audio.micVolume;
        case "brightness": return Brightness.percent / 100;
        default: return Audio.muted ? 0 : Audio.volume;
        }
    }

    readonly property color tone: {
        switch (root.kind) {
        case "mic": return Audio.micMuted ? Theme.accent : Theme.blue;
        case "brightness": return Theme.warn;
        default: return Audio.muted ? Theme.accent : Theme.primary;
        }
    }

    function flash(k: string) {
        if (!root.armed) return;
        root.kind = k;
        root.shown = true;
        glyphIcon.bump();
        hold.restart();
    }

    Timer {
        id: hold
        interval: 1600
        onTriggered: root.shown = false
    }

    Connections {
        target: Audio
        function onVolumeBumped() { root.flash("volume"); }
        function onMicBumped() { root.flash("mic"); }
    }

    Connections {
        target: Brightness
        function onBumped() { root.flash("brightness"); }
    }

    P5Panel {
        id: panel
        anchors.fill: parent
        anchors.margins: 4
        fill: Theme.mantle
        fillOpacity: 0.97
        border: Theme.alpha(root.tone, 0.85)
        borderWidth: Theme.stroke
        slash: true
        slashColor: root.tone
        slashWidth: 5
        halftone: true
        halftoneColor: root.tone
        halftoneOpacity: 0.08
        sheen: true
        lean: 0.09
        chop: 14
        padding: Theme.padM

        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.9

        Behavior on opacity {
            NumberAnimation { id: fade; duration: Theme.durBase }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutBack }
        }

        Icon {
            id: glyphIcon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.glyph
            color: root.tone
            font.pixelSize: 30
            width: 36
        }

        Column {
            anchors.left: glyphIcon.right
            anchors.leftMargin: Theme.padM
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Row {
                width: parent.width

                Text {
                    text: root.title.toUpperCase()
                    color: Theme.subtext
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 2
                    renderType: Text.NativeRendering
                }

                Item {
                    width: parent.width - 90
                    height: 1
                }

                SplitText {
                    text: Math.round(root.level * 100) + "%"
                    pixelSize: Theme.fsBody
                    split: 1
                    splitOpacity: 0.5
                }
            }

            MeterBar {
                width: parent.width
                height: 10
                segments: 20
                segmentWidth: (width - 19 * 3) / 20
                spacing: 3
                value: root.level * 100
                activeColor: root.tone
            }
        }
    }
}
