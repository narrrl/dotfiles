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
Item {
    id: surface

    // Emitted once PAM has accepted the password.
    signal unlocked()

    property string entry: ""
    property string status: ""
    property bool failed: false
    property bool busy: pam.active

    Rectangle {
        anchors.fill: parent
        color: Theme.base
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

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.55
            blurMax: 48
            saturation: -0.15
            brightness: -0.35
        }
    }

    // Wash pulling the photo down toward the shell's ground. Was described as
    // a teal wash back when the UI was teal; the colours it actually uses are
    // the neutral surfaces, which is what it should have been all along.
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.alpha(Theme.deep, 0.55) }
            GradientStop { position: 0.6; color: Theme.alpha(Theme.base, 0.75) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.base, 0.92) }
        }
    }

    // The same wedge-and-stripes ground the power menu stands on. The wedge
    // sits under the clock, which is where the power menu puts it under the
    // title — so the two screens land the crimson mass in the same place.
    P5Backdrop {
        id: backdrop
        anchors.fill: parent
        reveal: 0
        wedgeSpan: 0.30
        wedgeOpacity: 0.30
        stripeOpacity: 0.07
    }

    // ------------------------------------------------------------ clock
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // The house mark, same wordmark the bar carries far left. Small, above the
    // clock — the lock's hero is the time, not the branding.
    SplitText {
        id: mark
        anchors.left: timeBlock.left
        anchors.bottom: timeBlock.top
        anchors.bottomMargin: 6
        text: "P5"
        pixelSize: Theme.fsTitle
        split: 2
        letterSpacing: 0
        opacity: timeBlock.opacity
    }

    Column {
        id: timeBlock
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.1
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.18
        spacing: -18

        SplitText {
            text: Qt.formatDateTime(clock.date, "HH")
            pixelSize: Theme.fsMega * 1.7
            split: 5
            splitOpacity: 0.85
        }

        SplitText {
            text: Qt.formatDateTime(clock.date, "mm")
            pixelSize: Theme.fsMega * 1.7
            color: Theme.primary
            split: 5
            splitOpacity: 0.6
        }

        Text {
            text: Qt.formatDateTime(clock.date, "dddd, dd MMMM").toUpperCase()
            color: Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsBody
            font.letterSpacing: 6
            topPadding: 34
            renderType: Text.NativeRendering
        }
    }

    // ------------------------------------------------------ status rail
    Column {
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.1
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.2
        spacing: Theme.padM
        width: 300

        RailRow {
            width: parent.width
            visible: Battery.available
            glyph: Battery.icon
            label: Math.round(Battery.percent) + "%"
            detail: Battery.timeLabel
            tone: Battery.tint
        }

        RailRow {
            width: parent.width
            glyph: Net.icon
            label: Net.label
            detail: Sys.netUp ? Sys.netIp : "no link"
            tone: Sys.netUp ? Theme.primary : Theme.muted
        }

        RailRow {
            width: parent.width
            visible: Media.hasPlayer
            glyph: Media.playing ? "󰝚" : "󰏤"
            label: Media.title
            detail: Media.artist
            tone: Theme.primary
        }

        RailRow {
            width: parent.width
            visible: Notifs.count > 0
            glyph: "󱅫"
            label: Notifs.count + " notification" + (Notifs.count === 1 ? "" : "s")
            detail: Notifs.history.length > 0 ? Notifs.history[0].summary : ""
            tone: Theme.accent
        }
    }

    // ------------------------------------------------------- auth panel
    Item {
        id: authBlock
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.14
        width: 460
        height: 150

        transform: Translate { id: shakeShift }

        SplitText {
            id: prompt
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            text: surface.failed
                ? (surface.status || "WRONG").toUpperCase()
                : (surface.busy ? "CHECKING…" : "WHO GOES THERE")
            color: surface.failed ? Theme.accent : Theme.text
            pixelSize: Theme.fsTitle
            letterSpacing: 4
            horizontalAlignment: Text.AlignHCenter
            split: surface.failed ? 4 : 1.6
        }

        // Password field: one chopped block per character.
        P5Panel {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: prompt.bottom
            anchors.topMargin: Theme.padL
            width: 380
            height: 56
            lean: 0.12
            chop: 16
            fill: Theme.mantle
            fillOpacity: 0.94
            border: surface.failed
                ? Theme.accent
                : (input.activeFocus ? Theme.primary : Theme.outline)
            borderWidth: 2
            slash: true
            slashColor: surface.failed ? Theme.accent : Theme.primary
            slashWidth: 6
            halftone: true
            halftoneColor: surface.failed ? Theme.accent : Theme.primary
            halftoneOpacity: 0.08

            Row {
                anchors.centerIn: parent
                spacing: 6
                visible: surface.entry.length > 0

                Repeater {
                    model: Math.min(surface.entry.length, 22)

                    Skew {
                        required property int index
                        width: 10
                        height: 20
                        color: surface.failed ? Theme.accent : Theme.primary

                        // Each new block snaps in.
                        Component.onCompleted: pop.start()
                        NumberAnimation {
                            id: pop
                            target: parent
                            property: "scale"
                            from: 0.2; to: 1
                            duration: Theme.durBase
                            easing.type: Easing.OutBack
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: surface.entry.length === 0 && !surface.busy
                text: "PASSWORD"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsSmall
                font.letterSpacing: 5
                renderType: Text.NativeRendering
            }

            // Busy sweep.
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                width: 60
                height: 3
                color: Theme.primary
                visible: surface.busy

                XAnimator on x {
                    running: surface.busy
                    loops: Animation.Infinite
                    from: 20
                    to: field.width - 80
                    duration: 700
                    easing.type: Easing.InOutQuad
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
                    if (surface.failed && text.length === 0) surface.failed = false;
                }

                onAccepted: surface.submit()

                Keys.onEscapePressed: {
                    input.text = "";
                    surface.failed = false;
                }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: field.bottom
            anchors.topMargin: Theme.padM
            spacing: Theme.padS

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                text: "󰌾"
                color: Theme.muted
                font.pixelSize: Theme.fsBody
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: Quickshell.env("USER") || "narl"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsSmall
                font.letterSpacing: 3
                renderType: Text.NativeRendering
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
        user: Quickshell.env("USER") || "narl"

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
                surface.failed = true;
                if (surface.status === "") surface.status = "Access denied";
                input.text = "";
                surface.entry = "";
                shake.restart();
            }
        }

        onError: err => {
            surface.failed = true;
            surface.status = "PAM error";
            input.text = "";
            surface.entry = "";
            shake.restart();
        }
    }

    SequentialAnimation {
        id: shake
        loops: 2
        NumberAnimation {
            target: shakeShift; property: "x"
            to: -16; duration: 55; easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: shakeShift; property: "x"
            to: 16; duration: 55; easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: shakeShift; property: "x"
            to: 0; duration: 90; easing.type: Easing.OutBack
        }
    }

    // Entry flourish when the lock comes up.
    Component.onCompleted: intro.start()

    ParallelAnimation {
        id: intro
        // The stripes sweep in under everything, the same move the power menu
        // opens with.
        NumberAnimation {
            target: backdrop; property: "reveal"
            from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: timeBlock; property: "opacity"
            from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: authBlock; property: "opacity"
            from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: shakeShift; property: "y"
            from: 40; to: 0; duration: Theme.durLazy; easing.type: Easing.OutBack
        }
    }
}
