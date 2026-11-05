import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/popouts"
import "root:/services"

// The ask panel. It comes down off the top edge, takes the keyboard, and hands
// a question to Claude.
//
// Deliberately not the launcher: the launcher is a list you pick from in one
// keystroke, this is a conversation you read. The shape says so — full width of
// the question, answer below it, and the thing drops from the top rather than
// rising into the middle so the two are never mistaken for each other mid-type.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // One screen at a time, latched at open — same reason as the launcher: the
    // window takes focus, and a prompt should not hop monitors mid-question.
    readonly property bool open: Actions.askOpen
        && Actions.askScreen === modelData.name
    visible: root.open || closeAnim.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-ask"
    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    readonly property int panelWidth: Math.min(860, root.width - Theme.padXL * 2)
    readonly property int maxTranscript: Math.round(root.height * 0.55)

    onOpenChanged: {
        if (root.open) {
            PopupCoordinator.dismissAll();
            input.text = Actions.askSeed;
            openAnim.restart();
            input.forceActiveFocus();
            input.cursorPosition = input.text.length;
            if (Actions.askSeed !== "") root.send();
        } else {
            closeAnim.restart();
        }
    }

    function send(): void {
        const q = input.text.trim();
        if (q === "" || Ask.busy) return;
        Ask.ask(q);
        input.text = "";
    }

    function copyLast(): void {
        for (let i = Ask.turns.length - 1; i >= 0; i--) {
            if (Ask.turns[i].role === "assistant" && Ask.turns[i].text !== "") {
                Actions.copyText(Ask.turns[i].text);
                return;
            }
        }
    }

    // -------------------------------------------------------------- backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.alpha(Theme.base, 0.6)
        opacity: 0

        TapHandler { onTapped: Actions.closeAsk() }
    }

    // ----------------------------------------------------------------- panel
    Item {
        id: shell

        width: root.panelWidth
        height: header.height + divider.height + body.height + hint.height
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0

        opacity: 0
        // The drop. The offset is animated, never bound: binding it to the
        // panel's own height means every height change — every streamed line —
        // snaps the panel back off the top of the screen.
        transform: Translate { id: drop; y: 0 }

        PopoutSurface {
            anchors.fill: parent
            tone: Ask.busy ? Theme.accent : Theme.primary
            padding: 0
            slashWidth: Ask.busy ? 8 : 5

            // -------------------------------------------------------- header
            Item {
                id: header
                width: parent.width
                height: 62
                anchors.top: parent.top

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.padL
                    anchors.rightMargin: Theme.padL
                    spacing: Theme.padM

                    // Pulses rather than spins. Native text rendering is
                    // subpixel-antialiased, so a rotated glyph smears into
                    // colour fringes; scale keeps it on the pixel grid.
                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰭹"
                        color: Ask.busy ? Theme.accent : Theme.primary
                        font.pixelSize: Theme.fsTitle
                        pulsing: Ask.busy
                        pulseScale: 1.12
                    }

                    TextInput {
                        id: input
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x - modelChip.width - Theme.padM
                        color: Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsLarge
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.ink
                        clip: true
                        focus: true
                        renderType: Text.NativeRendering

                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => root.handleKey(event)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: Ask.busy ? "thinking…"
                                : Ask.turns.length > 0 ? "follow up…" : "ask anything"
                            color: Theme.muted
                            font: input.font
                            renderType: Text.NativeRendering
                        }
                    }

                    // The model, which is also the control for it: Ctrl+M walks
                    // the ring and writes the choice back to ask.json, so the
                    // panel and the file never disagree.
                    Item {
                        id: modelChip
                        anchors.verticalCenter: parent.verticalCenter
                        width: modelText.width + Theme.padM * 2
                        height: 24

                        Skew {
                            anchors.fill: parent
                            color: Theme.surface
                        }

                        Text {
                            id: modelText
                            anchors.centerIn: parent
                            text: Ask.model.toUpperCase()
                            color: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsMicro
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                            renderType: Text.NativeRendering
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Ask.cycleModel()
                        }
                    }
                }
            }

            Skew {
                id: divider
                anchors.top: header.bottom
                width: parent.width
                height: Theme.stroke
                color: Theme.alpha(Theme.outline, 0.8)
                lean: 0
            }

            // --------------------------------------------------- transcript
            Item {
                id: body
                anchors.top: divider.bottom
                width: parent.width
                height: Math.min(transcript.contentHeight + Theme.padM * 2,
                                 root.maxTranscript)
                visible: Ask.turns.length > 0 || Ask.error !== ""
                clip: true

                Behavior on height {
                    NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
                }

                ListView {
                    id: transcript
                    anchors.fill: parent
                    anchors.margins: Theme.padM
                    anchors.leftMargin: Theme.padL
                    anchors.rightMargin: Theme.padL
                    model: Ask.turns
                    spacing: Theme.padM
                    boundsBehavior: Flickable.StopAtBounds

                    // Stay at the bottom while an answer streams in, but leave
                    // the view alone the moment it is scrolled by hand.
                    property bool pinned: true
                    onMovementEnded: pinned = atYEnd
                    onContentHeightChanged: if (pinned) positionViewAtEnd()

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Column {
                        required property var modelData
                        width: transcript.width
                        spacing: Theme.padS

                        Text {
                            visible: modelData.role === "user"
                            text: "YOU"
                            color: Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsMicro
                            font.letterSpacing: 3
                            renderType: Text.NativeRendering
                        }

                        Text {
                            width: parent.width
                            text: modelData.text
                            textFormat: modelData.role === "assistant"
                                ? Text.MarkdownText : Text.PlainText
                            color: modelData.role === "user" ? Theme.subtext : Theme.text
                            linkColor: Theme.accent
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsBody
                            wrapMode: Text.Wrap
                            renderType: Text.NativeRendering
                            onLinkActivated: link => Actions.run(["xdg-open", link])
                        }
                    }

                    footer: Text {
                        width: transcript.width
                        visible: Ask.error !== ""
                        topPadding: visible ? Theme.padM : 0
                        text: Ask.error
                        color: Theme.alarm
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsSmall
                        wrapMode: Text.Wrap
                        renderType: Text.NativeRendering
                    }
                }
            }

            // -------------------------------------------------------- hints
            Item {
                id: hint
                anchors.top: body.visible ? body.bottom : divider.bottom
                width: parent.width
                height: 28

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padL
                    anchors.verticalCenter: parent.verticalCenter
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 3
                    renderType: Text.NativeRendering
                    text: Ask.busy
                        ? "⏎  QUEUE     CTRL+S  STOP     ESC  HIDE"
                        : "⏎  ASK     CTRL+M  MODEL     CTRL+Y  COPY     CTRL+L  NEW     ESC  HIDE"
                }

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padL
                    anchors.verticalCenter: parent.verticalCenter
                    visible: Ask.turns.length > 0
                    text: Math.floor(Ask.turns.length / 2) + " TURN"
                        + (Ask.turns.length > 2 ? "S" : "")
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    // ------------------------------------------------------------------ keys
    function handleKey(event: var): void {
        if (!root.open) return;

        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;

        if (event.key === Qt.Key_Escape || (ctrl && event.key === Qt.Key_C)) {
            // Hide, do not clear. The thread outlives the panel so that closing
            // it to read something and reopening to ask about that is one
            // conversation, not two.
            Actions.closeAsk();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            // Shift+Enter is a newline; a multi-line question is still one
            // question. Plain Enter sends.
            if ((event.modifiers & Qt.ShiftModifier) === 0) {
                root.send();
                event.accepted = true;
            }
            return;
        }

        if (ctrl && event.key === Qt.Key_L) {
            Ask.clear();
            input.text = "";
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_S) {
            Ask.stop();
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_M) {
            Ask.cycleModel();
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_Y) {
            root.copyLast();
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_U) {
            input.text = "";
            event.accepted = true;
            return;
        }

        // The transcript scrolls on the arrows, because the input is one line
        // and has nowhere for them to go.
        if (event.key === Qt.Key_PageDown || (ctrl && event.key === Qt.Key_J)) {
            transcript.flick(0, -900);
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_PageUp || (ctrl && event.key === Qt.Key_K)) {
            transcript.flick(0, 900);
            event.accepted = true;
            return;
        }
    }

    // ------------------------------------------------------------- animation
    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 1; duration: Theme.durBase; easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: shell; property: "opacity"
            to: 1; duration: Theme.durFast
        }
        NumberAnimation {
            target: drop; property: "y"
            from: -shell.height; to: 0
            duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: closeAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: shell; property: "opacity"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: drop; property: "y"
            to: -shell.height; duration: Theme.durFast; easing.type: Easing.InQuad
        }
    }
}
