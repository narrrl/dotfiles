import QtQuick
import Quickshell
import Quickshell.Hyprland
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
        case "layout": return "󰌌";
        default: return Audio.icon;
        }
    }

    readonly property string title: {
        switch (root.kind) {
        case "mic": return Audio.micMuted ? "Mic muted" : "Microphone";
        case "brightness": return "Brightness";
        case "layout": return "Keyboard";
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
        // One tone for every level: the accent while the channel is live, the
        // off grey while it is muted. Muted used to be the accent too, so a
        // silenced speaker flashed the same colour as a live one.
        case "mic": return Audio.micMuted ? Theme.treatmentOffText : Theme.accent;
        case "brightness": return Theme.accent;
        case "layout": return Theme.accent;
        default: return Audio.muted ? Theme.treatmentOffText : Theme.accent;
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

    // The keymap Hyprland just switched to, e.g. "English (Dvorak, intl.,
    // with dead keys)", and a short name for the readout: the variant in the
    // brackets if there is one, otherwise the language.
    property string keymap: ""
    readonly property string keymapShort: {
        const m = /\(([^,)]+)/.exec(root.keymap);
        return (m ? m[1] : root.keymap).trim();
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name !== "activelayout") return;
            // "keyboard-name,Layout name" — the layout name may hold commas.
            const at = event.data.indexOf(",");
            root.keymap = at < 0 ? event.data : event.data.slice(at + 1);
            root.flash("layout");
        }
    }

    Panel {
        id: panel
        anchors.fill: parent
        anchors.margins: 4
        fill: Theme.mantle
        fillOpacity: 0.97
        border: Theme.surfaceAlt
        borderWidth: Theme.stroke
        slash: true
        slashColor: root.tone
        slashWidth: 5
        padding: Theme.padM

        // It rises a few pixels into place instead of growing: a scale would
        // stretch the native text in the panel while it moves.
        opacity: root.shown ? 1 : 0
        transform: Translate {
            y: root.shown ? 0 : 8

            Behavior on y {
                NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { id: fade; duration: Theme.durBase }
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

            // Title left, readout hard right. This used to be a Row with a
            // `parent.width - 90` spacer, which assumed the two labels never
            // needed more than 90px between them — "BRIGHTNESS" plus "100%"
            // does, and the percentage fell off the right edge. Anchoring the
            // readout to the right and letting the title elide into whatever
            // is left makes the widest case the safe one.
            Item {
                width: parent.width
                height: Math.max(titleLabel.implicitHeight, readout.implicitHeight)

                Text {
                    id: titleLabel
                    anchors.left: parent.left
                    anchors.right: readout.left
                    anchors.rightMargin: Theme.padS
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title.toUpperCase()
                    color: Theme.subtext
                    elide: Text.ElideRight
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 2
                    renderType: Text.NativeRendering
                }

                SplitText {
                    id: readout
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    // Natural width, not a fixed one — SplitText offsets its
                    // ghosts with left/right anchor margins, so pinning the
                    // width and right-aligning the text would flatten the
                    // glitch flicker away. The title's left edge is anchored, so a
                    // widening readout only moves its own left edge.
                    text: root.kind === "layout" ? root.keymapShort : Math.round(root.level * 100) + "%"
                    pixelSize: Theme.fsBody
                }
            }

            // The layout has no level; its full name stands where the meter
            // would be.
            Text {
                visible: root.kind === "layout"
                width: parent.width
                text: root.keymap
                color: Theme.muted
                elide: Text.ElideRight
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }

            MeterBar {
                visible: root.kind !== "layout"
                width: parent.width
                height: 4
                segments: 20
                segmentWidth: (width - 19 * 2) / 20
                spacing: 2
                value: root.level * 100
                activeColor: root.tone
            }
        }
    }
}
