import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.Pam
import "root:/config"
import "root:/components"
import "root:/services"
import "root:/lock"

// The lock screen's whole face, kept separate from WlSessionLockSurface so it
// can be instantiated in an ordinary window for development without actually
// locking the session.
//
// Quiet on purpose. The wallpaper stays almost whole — the porthole, the
// planet, the girl looking out — and the face is one small group of type set
// in the dark of the porthole: the mark, the time, the date, a short status
// log, and a rounded field to type into. Nothing sweeps, splits or shakes;
// the group resolves in, and a wrong password nudges it once and turns its
// dots to rust.
Item {
    id: surface

    // Emitted once PAM has accepted the password.
    signal unlocked()

    property string entry: ""
    property string status: ""
    property bool failed: false
    property bool busy: pam.active
    readonly property real uiScale: Math.max(0.72, Math.min(1.3,
        Math.min(width / 1920, height / 1080)))

    Rectangle {
        anchors.fill: parent
        color: Theme.ink
    }

    // ------------------------------------------------------- background
    // Whatever hyprpaper is actually displaying, not a path written down once
    // and left to rot. `screenName` lets a multi-monitor lock show each screen
    // its own picture; it falls back to the first wallpaper hyprpaper reports.
    property string screenName: ""

    Image {
        id: wall
        anchors.fill: parent
        source: surface.screenName !== ""
            ? Wallpaper.forMonitor(surface.screenName)
            : Wallpaper.source
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
        opacity: 0

        // Barely softened: enough that the scene steps back behind the type,
        // not so much that it stops being a place.
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.2
            blurMax: 32
            saturation: -0.1
            brightness: -0.18
        }
    }

    // Shade deepening toward the left, where the type sits in the porthole's
    // dark, and a breath of it along the foot.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.alpha(Theme.ink, 0.72) }
            GradientStop { position: 0.45; color: Theme.alpha(Theme.ink, 0.28) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.ink, 0.18) }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.6; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.ink, 0.5) }
        }
    }

    // ------------------------------------------------------------- face
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Column {
        id: face
        // Sized by uiScale rather than drawn small and stretched with `scale`:
        // a scale transform blurs native text, and every label here is native.
        // Whole pixels, too, or the glyphs land between them.
        x: Math.round(parent.width * 0.14)
        y: Math.round(parent.height * 0.2)
        width: Math.round(380 * surface.uiScale)
        opacity: 0
        spacing: 0

        transform: Translate { id: drift }

        // The house mark, the same porthole the bar carries far left.
        Porthole {
            size: Math.round(26 * surface.uiScale)
        }

        Text {
            topPadding: Math.round(Theme.padM * surface.uiScale)
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Theme.accent
            font.family: Theme.fontDisplay
            font.pixelSize: Math.round(Theme.fsMega * 1.35 * surface.uiScale)
            font.weight: Font.Light
            font.letterSpacing: 2 * surface.uiScale
            // Display size, where curves beat hinted bitmaps.
            renderType: Text.CurveRendering
        }

        Text {
            leftPadding: Math.round(4 * surface.uiScale)
            text: Qt.formatDateTime(clock.date, "dddd  ·  dd MMMM").toUpperCase()
            color: Theme.subtext
            font.family: Theme.fontDisplay
            font.pixelSize: Math.round(Theme.fsBody * surface.uiScale)
            font.weight: Theme.weightDisplay
            font.letterSpacing: 5 * surface.uiScale
            renderType: Text.NativeRendering
        }

        // The one line the face says to you. Nothing here is in a hurry.
        Text {
            topPadding: Math.round(Theme.padL * surface.uiScale)
            leftPadding: Math.round(4 * surface.uiScale)
            text: "Take your time."
            color: Theme.subtext
            font.family: Theme.fontDisplay
            font.pixelSize: Math.round(Theme.fsLarge * surface.uiScale)
            font.weight: Font.Light
            renderType: Text.NativeRendering
        }

        Item { width: 1; height: Math.round(Theme.padXL * surface.uiScale) }

        // ------------------------------------------------------ status log
        Column {
            width: parent.width
            leftPadding: Math.round(4 * surface.uiScale)

            StatusRow {
                width: parent.width - parent.leftPadding
                uiScale: surface.uiScale
                visible: Battery.available
                label: "Battery"
                detail: Math.round(Battery.percent) + "%"
                    + (Battery.timeLabel ? "  " + Battery.timeLabel : "")
                tone: Battery.tint
            }

            StatusRow {
                width: parent.width - parent.leftPadding
                uiScale: surface.uiScale
                label: "Network"
                detail: Sys.netUp ? Net.label : "no link"
                tone: Sys.netUp ? Theme.accentSoft : Theme.overlay
            }

            StatusRow {
                width: parent.width - parent.leftPadding
                uiScale: surface.uiScale
                visible: Media.hasPlayer
                label: Media.playing ? "Playing" : "Paused"
                detail: Media.artist ? Media.title + " — " + Media.artist : Media.title
                tone: Media.playing ? Theme.accent : Theme.primaryDim
            }

            StatusRow {
                width: parent.width - parent.leftPadding
                uiScale: surface.uiScale
                visible: Notifs.count > 0
                label: "Notices"
                detail: Notifs.count + (Notifs.count === 1 ? " message" : " messages")
                tone: Theme.accentSoft
            }
        }

        Item { width: 1; height: Math.round(Theme.padXL * surface.uiScale) }

        // ------------------------------------------------------ the field
        Item {
            id: authBlock
            width: parent.width
            height: field.height + hint.height + hint.anchors.topMargin

            transform: Translate { id: nudge }

            Rectangle {
                id: field
                width: parent.width
                height: Math.round(48 * surface.uiScale)
                radius: height / 2
                color: Theme.alpha(Theme.hull, 0.86)
                border.width: 1
                border.color: surface.failed
                    ? Theme.alarm
                    : (input.activeFocus && surface.entry.length > 0 ? Theme.outline : Theme.rim)

                Behavior on border.color {
                    ColorAnimation { duration: Theme.durBase }
                }

                Icon {
                    id: lockGlyph
                    anchors.left: parent.left
                    anchors.leftMargin: Math.round(Theme.padL * surface.uiScale)
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰌾"
                    color: surface.failed ? Theme.alarm : Theme.muted
                    font.pixelSize: Math.round(Theme.fsLarge * surface.uiScale)
                }

                Text {
                    anchors.left: lockGlyph.right
                    anchors.leftMargin: Math.round(Theme.padM * surface.uiScale)
                    anchors.verticalCenter: parent.verticalCenter
                    visible: surface.entry.length === 0
                    text: "PASSWORD"
                    color: Theme.muted
                    font.family: Theme.fontDisplay
                    font.pixelSize: Math.round(Theme.fsSmall * surface.uiScale)
                    font.letterSpacing: Theme.tracking * 2 * surface.uiScale
                    renderType: Text.NativeRendering
                }

                // One dot per character, each resolving in as it is typed.
                // They breathe while PAM is checking.
                Row {
                    id: dots
                    anchors.left: lockGlyph.right
                    anchors.leftMargin: Math.round(Theme.padM * surface.uiScale)
                    anchors.right: enter.left
                    anchors.rightMargin: Math.round(Theme.padM * surface.uiScale)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Math.round(7 * surface.uiScale)
                    clip: true

                    Repeater {
                        model: Math.min(surface.entry.length, 28)

                        Rectangle {
                            id: pip
                            required property int index
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.round(7 * surface.uiScale)
                            height: width
                            radius: width / 2
                            color: surface.failed ? Theme.alarm : Theme.accent
                            opacity: 0
                            scale: 0.4

                            Component.onCompleted: arrive.start()

                            ParallelAnimation {
                                id: arrive
                                NumberAnimation {
                                    target: pip; property: "opacity"
                                    to: 1; duration: Theme.durBase; easing.type: Easing.OutCubic
                                }
                                NumberAnimation {
                                    target: pip; property: "scale"
                                    to: 1; duration: Theme.durBase; easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    SequentialAnimation on opacity {
                        running: surface.busy
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.35; duration: 520; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1; duration: 520; easing.type: Easing.InOutSine }
                    }
                }

                // Submit: a disc at the field's end that lights once there is
                // something to send.
                Rectangle {
                    id: enter
                    readonly property bool ready: surface.entry.length > 0 && !surface.busy
                    anchors.right: parent.right
                    anchors.rightMargin: Math.round(8 * surface.uiScale)
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(32 * surface.uiScale)
                    height: width
                    radius: width / 2
                    color: enter.ready ? Theme.accent : "transparent"
                    border.width: enter.ready ? 0 : 1
                    border.color: Theme.rim

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase }
                    }

                    Icon {
                        anchors.centerIn: parent
                        text: "󰁔"
                        color: enter.ready ? Theme.ink : Theme.overlay
                        font.pixelSize: Math.round(Theme.fsLarge * surface.uiScale)
                    }

                    TapHandler {
                        onTapped: surface.submit()
                    }
                }

                // The real input, invisible but focused.
                TextInput {
                    id: input
                    anchors.fill: parent
                    opacity: 0
                    focus: true
                    echoMode: TextInput.Password
                    enabled: !surface.busy
                    activeFocusOnTab: true

                    onTextChanged: {
                        surface.entry = text;
                        if (surface.failed && text.length > 0) surface.failed = false;
                    }

                    onAccepted: surface.submit()

                    Keys.onEscapePressed: {
                        input.text = "";
                        surface.failed = false;
                    }
                }
            }

            // Under the field: who is locked, what is happening, or what went
            // wrong — one line, never more.
            Row {
                id: hint
                anchors.top: field.bottom
                anchors.topMargin: Math.round(Theme.padS * surface.uiScale)
                anchors.left: parent.left
                anchors.leftMargin: Math.round(Theme.padL * surface.uiScale)
                spacing: Math.round(Theme.padS * surface.uiScale)

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.round(4 * surface.uiScale)
                    height: width
                    radius: width / 2
                    color: surface.failed ? Theme.alarm : Theme.overlay
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: surface.failed
                        ? (surface.status || "Access denied").toUpperCase()
                        : (surface.busy ? "VERIFYING" : (Quickshell.env("USER") || "user"))
                    color: surface.failed ? Theme.alarm : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Math.round(Theme.fsMicro * surface.uiScale)
                    font.letterSpacing: 2 * surface.uiScale
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    // Keep focus on the field no matter what.
    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: if (!input.activeFocus && !surface.busy) input.forceActiveFocus()
    }

    function submit() {
        if (surface.busy || surface.entry.length === 0) return;
        surface.failed = false;
        surface.status = "";
        pam.start();
    }

    PamContext {
        id: pam

        config: "hyprlock"
        user: Quickshell.env("USER") || "USER"

        onPamMessage: {
            if (pam.responseRequired) pam.respond(surface.entry);
            else if (pam.message) surface.status = pam.message;
        }

        onCompleted: result => {
            if (result === PamResult.Success) {
                surface.unlocked();
                input.text = "";
                surface.entry = "";
                surface.failed = false;
            } else {
                input.text = "";
                surface.entry = "";
                surface.failed = true;
                if (surface.status === "") surface.status = "Access denied";
                refuse.restart();
            }
        }

        onError: err => {
            input.text = "";
            surface.entry = "";
            surface.failed = true;
            surface.status = "PAM error";
            refuse.restart();
        }
    }

    // A wrong password: the field leans away once and comes back, a head
    // shaken slowly rather than a buzzer.
    SequentialAnimation {
        id: refuse
        NumberAnimation {
            target: nudge; property: "x"
            to: -7; duration: 90; easing.type: Easing.OutSine
        }
        NumberAnimation {
            target: nudge; property: "x"
            to: 5; duration: 140; easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: nudge; property: "x"
            to: 0; duration: 220; easing.type: Easing.OutCubic
        }
    }

    // The lock comes up the way the scene would if you opened your eyes: the
    // picture first, then the type settling a few pixels into place.
    Component.onCompleted: intro.start()

    SequentialAnimation {
        id: intro
        NumberAnimation {
            target: wall; property: "opacity"
            from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutCubic
        }
        ParallelAnimation {
            NumberAnimation {
                target: face; property: "opacity"
                from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: drift; property: "y"
                from: 14; to: 0; duration: Theme.durLazy; easing.type: Easing.OutQuint
            }
        }
    }
}
