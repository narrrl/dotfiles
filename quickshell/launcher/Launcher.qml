import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "root:/config"
import "root:/components"
import "root:/popouts"
import "root:/services"

// The launcher. One input, one list, and a small amount of grammar.
//
// TYPING is always typing. Navigation lives on the arrows and on Ctrl+J/K so
// that nothing you can type is ever stolen from you — except in select mode,
// which you enter deliberately (the first arrow press does it) and which hands
// h/j/k/l over to navigation until you press Escape or Backspace. That is the
// compromise the vim keys need: a launcher whose input eats `j` is a launcher
// you cannot use to find Jellyfin.
//
// The other half of the grammar is the argument. Type a URL and the list turns
// into "open this with…", already sorted so the system default is row zero —
// so the fast path is type, Enter, done, and the slow path is one arrow key.
// Tab pins whatever is selected, which does the same thing for arguments that
// do not announce themselves as arguments.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: Actions.launcherOpen
    visible: root.open || closeAnim.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-launcher"
    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    // ----------------------------------------------------------------- state
    property string query: ""
    property var pinned: null          // an index item, frozen as the verb
    property bool selectMode: false
    property int selected: 0

    readonly property int maxRows: 8
    readonly property int rowHeight: 46

    // --------------------------------------------------------------- grammar
    readonly property string prefix: root.pinned ? "" : root.query.slice(0, 1)
    // A dmenu request owns the window outright — there is no app search to
    // fall back to, because the caller is waiting on a choice from its own
    // list.
    readonly property string mode: Apps.dmenuActive ? "dmenu"
        : root.prefix === ">" ? "shell"
        : root.prefix === "=" ? "calc"
        : root.prefix === ":" ? "clip"
        : "app"

    readonly property bool prefixed: root.mode === "shell"
        || root.mode === "calc" || root.mode === "clip"

    readonly property string body: root.prefixed
        ? root.query.slice(1)
        : root.query

    // With an app pinned, everything you type is the argument. Without one, an
    // argument only exists if what you typed is self-evidently an object.
    readonly property string argKind: root.pinned
        ? (Apps.classify(root.body) || "text")
        : Apps.classify(root.body)

    readonly property string arg: root.mode !== "app" || root.body.trim() === ""
        ? ""
        : (root.pinned || root.argKind !== "")
            ? Apps.normalizeArg(root.body, root.argKind)
            : ""

    // What is left to match app names against. When the whole query has been
    // claimed as an argument there is nothing left, and the list falls back to
    // "every app, best handler first".
    readonly property string term: root.mode !== "app" || root.pinned || root.arg !== ""
        ? ""
        : root.body

    readonly property var results: {
        if (!root.open) return [];

        if (root.mode === "calc") {
            const v = Apps.calc(root.body);
            if (v === "") return [];
            return [{ kind: "calc", name: v, sub: "copy to clipboard",
                      icon: "accessories-calculator", value: v }];
        }

        if (root.mode === "dmenu") return Apps.searchDmenu(root.body);
        if (root.mode === "clip") return Apps.searchClips(root.body);

        if (root.mode === "shell") {
            if (root.body.trim() === "") return [];
            return [
                { kind: "shell", name: root.body, sub: "run", icon: "utilities-terminal" },
                { kind: "shellterm", name: root.body, sub: "run in a terminal",
                  icon: "utilities-terminal" }
            ];
        }

        // Pinned: the verb is decided, so the list narrows to that app and the
        // things it can do — which is where "Brave, but a private window"
        // lives. Same list, one step further in.
        if (root.pinned) {
            const id = root.pinned.id;
            return Apps.index.filter(e => e.id === id)
                .sort((a, b) => (a.kind === "app" ? 0 : 1) - (b.kind === "app" ? 0 : 1));
        }

        return Apps.search(root.term, root.arg, root.argKind);
    }

    onResultsChanged: root.selected = 0

    // Typing the ":" prefix is the other way into the clipboard, and the
    // history may have moved on since the window opened.
    onModeChanged: if (root.mode === "clip") Apps.refreshClips()
    onOpenChanged: {
        if (root.open) {
            PopupCoordinator.dismissAll();
            root.reset();
            openAnim.restart();
            input.forceActiveFocus();
            input.cursorPosition = input.text.length;
            Apps.refreshClips();
        } else {
            // Dismissing a dmenu is a valid answer — an empty one. Without this
            // the caller blocks until its own timeout.
            Apps.finishDmenu("");
            closeAnim.restart();
        }
    }

    function reset(): void {
        root.query = Actions.launcherSeed;
        root.pinned = null;
        root.selectMode = false;
        root.selected = 0;
    }

    function move(delta: int): void {
        const n = root.results.length;
        if (n === 0) return;
        root.selected = (root.selected + delta + n) % n;
        list.positionViewAtIndex(root.selected, ListView.Contain);
    }

    function pin(): void {
        const item = root.results[root.selected];
        if (!item || (item.kind !== "app" && item.kind !== "action")) return;
        root.pinned = item;
        root.query = "";
        root.selectMode = false;
        input.forceActiveFocus();
    }

    function unpin(): void {
        if (!root.pinned) return;
        root.query = root.pinned.name.split(" · ")[0];
        root.pinned = null;
        input.forceActiveFocus();
    }

    function activate(): void {
        const item = root.results[root.selected];
        if (!item) return;

        switch (item.kind) {
        case "dmenu": Apps.finishDmenu(item.name); break;
        case "clip": Apps.pasteClip(item); break;
        case "calc": Apps.copy(item.value); break;
        case "shell": Apps.runShell(root.body, false); break;
        case "shellterm": Apps.runShell(root.body, true); break;
        default: Apps.launch(item, root.arg); break;
        }
        Actions.closeLauncher();
    }

    // -------------------------------------------------------------- backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.alpha(Theme.base, 0.72)
        opacity: 0

        TapHandler { onTapped: Actions.closeLauncher() }
    }

    // ----------------------------------------------------------------- panel
    Item {
        id: shell

        width: 680
        height: header.height + divider.height + listBox.height + hint.height
        anchors.horizontalCenter: parent.horizontalCenter
        // Sits above centre. A launcher pinned to the exact middle of a 1440p
        // screen puts the list below the eyeline and the input above it; the
        // input is the thing you are looking at.
        y: parent.height * 0.22

        opacity: 0
        transform: Translate { id: rise; y: 24 }

        PopoutSurface {
            anchors.fill: parent
            tone: root.arg !== "" ? Theme.accent : Theme.primary
            padding: 0
            slashWidth: root.arg !== "" ? 8 : 5

            // ------------------------------------------------------- header
            Item {
                id: header
                width: parent.width
                height: 66
                anchors.top: parent.top

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.padL
                    anchors.rightMargin: Theme.padL
                    spacing: Theme.padM

                    Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.mode === "shell" ? "" : root.mode === "calc" ? "󰃬"
                            : root.mode === "clip" ? "󰅇"
                            : root.mode === "dmenu" ? "󰘳"
                            : root.arg !== "" ? "󰏌" : "󰍉"
                        color: root.arg !== "" ? Theme.accent : Theme.primary
                        font.pixelSize: Theme.fsTitle
                    }

                    // The pin chip. Once this is on screen the input means
                    // "argument", and the chip is the only thing saying so.
                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: root.pinned !== null
                        width: visible ? chipText.width + Theme.padM * 2 : 0
                        height: 26

                        Skew {
                            anchors.fill: parent
                            color: Theme.accent
                        }

                        Text {
                            id: chipText
                            anchors.centerIn: parent
                            text: root.pinned ? root.pinned.name.toUpperCase() : ""
                            color: Theme.treatmentDestructiveText
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsMicro
                            font.weight: Font.Bold
                            font.letterSpacing: 2
                            renderType: Text.NativeRendering
                        }
                    }

                    TextInput {
                        id: input
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x
                        text: root.query
                        onTextChanged: root.query = text
                        color: root.selectMode ? Theme.muted : Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsLarge
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.ink
                        clip: true
                        focus: true
                        renderType: Text.NativeRendering

                        // Ours must run before TextInput's, or select mode's
                        // h/j/k/l would be typed into the field before we ever
                        // saw them.
                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => root.handleKey(event)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: root.pinned ? "argument…"
                                : root.mode === "shell" ? "command…"
                                : root.mode === "calc" ? "expression…"
                                : root.mode === "clip" ? "clipboard history…"
                                : root.mode === "dmenu"
                                    ? (Apps.dmenuPrompt || "choose…")
                                    : "search, or paste a link"
                            color: Theme.muted
                            font: input.font
                            renderType: Text.NativeRendering
                        }
                    }
                }

                // Count, right-aligned over the input's tail.
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padL
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.results.length > 0
                        ? (root.selected + 1) + "/" + root.results.length
                        : ""
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
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

            // -------------------------------------------------------- list
            Item {
                id: listBox
                anchors.top: divider.bottom
                width: parent.width
                height: Math.min(root.results.length, root.maxRows) * root.rowHeight
                    + (root.results.length > 0 ? Theme.padS * 2 : 0)
                clip: true

                Behavior on height {
                    NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutExpo }
                }

                ListView {
                    id: list
                    anchors.fill: parent
                    anchors.topMargin: Theme.padS
                    anchors.bottomMargin: Theme.padS
                    anchors.leftMargin: Theme.padM
                    anchors.rightMargin: Theme.padM
                    model: root.results
                    currentIndex: root.selected
                    boundsBehavior: Flickable.StopAtBounds
                    reuseItems: true

                    delegate: ResultRow {
                        required property var modelData
                        required property int index

                        width: list.width
                        entry: modelData
                        selected: index === root.selected
                        badge: root.arg !== "" ? "OPEN  ⏎" : "⏎"
                        onActivated: {
                            root.selected = index;
                            root.activate();
                        }
                        onPinRequested: {
                            root.selected = index;
                            root.pin();
                        }
                    }
                }

                // Empty state. Says which of the two ways to be empty it is,
                // because "no results" and "nothing typed" want different
                // things from you.
                Text {
                    anchors.centerIn: parent
                    visible: root.results.length === 0 && root.query !== ""
                    text: root.mode === "calc" ? "NOT AN EXPRESSION" : "NO MATCH"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    font.letterSpacing: 4
                    renderType: Text.NativeRendering
                }
            }

            // -------------------------------------------------------- hints
            Item {
                id: hint
                anchors.top: listBox.bottom
                width: parent.width
                height: 30

                Text {
                    anchors.centerIn: parent
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 3
                    renderType: Text.NativeRendering
                    text: root.selectMode
                        ? "H J K L  MOVE     L  PIN     ESC  TYPE"
                        : root.mode === "dmenu"
                            ? "⏎  CHOOSE     ESC  CANCEL     ↑↓  SELECT"
                            : root.mode === "clip"
                                ? "⏎  COPY     ESC  BACK     ↑↓  SELECT"
                                : root.pinned
                                    ? "⏎  OPEN     ESC  UNPIN     ↑↓  PICK"
                                    : "TAB  PIN     >  SHELL     =  CALC     :  CLIPBOARD"
                }
            }
        }
    }

    // ------------------------------------------------------------------ keys
    function handleKey(event: var): void {
        if (!root.open) return;

        const ctrl = (event.modifiers & Qt.ControlModifier) !== 0;

        // Escape peels one layer at a time: select mode, then the pin, then
        // the launcher. Nothing about it is ever a surprise.
        if (event.key === Qt.Key_Escape) {
            if (root.selectMode) root.selectMode = false;
            else if (root.pinned) root.unpin();
            else Actions.closeLauncher();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.activate();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Tab) {
            root.pin();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_J)
            || (ctrl && event.key === Qt.Key_N)) {
            root.selectMode = true;
            root.move(1);
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_K)
            || (ctrl && event.key === Qt.Key_P)) {
            root.selectMode = true;
            root.move(-1);
            event.accepted = true;
            return;
        }

        if (ctrl && event.key === Qt.Key_U) {
            root.query = "";
            event.accepted = true;
            return;
        }

        if (!root.selectMode) return;

        // Select mode. The letters navigate; anything else drops you back into
        // the input, having typed nothing, so a mistyped `d` costs one press
        // rather than a mangled query.
        switch (event.key) {
        case Qt.Key_J: root.move(1); event.accepted = true; return;
        case Qt.Key_K: root.move(-1); event.accepted = true; return;
        case Qt.Key_L: root.pin(); event.accepted = true; return;
        case Qt.Key_H: root.unpin(); event.accepted = true; return;
        case Qt.Key_G:
            root.selected = (event.modifiers & Qt.ShiftModifier)
                ? root.results.length - 1 : 0;
            list.positionViewAtIndex(root.selected, ListView.Contain);
            event.accepted = true;
            return;
        case Qt.Key_Backspace:
            root.selectMode = false;
            event.accepted = true;
            return;
        }

        if (event.text !== "") root.selectMode = false;
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
            to: 1; duration: Theme.durBase
        }
        NumberAnimation {
            target: rise; property: "y"
            from: 24; to: 0; duration: Theme.durSlow; easing.type: Easing.OutBack
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
            target: rise; property: "y"
            to: 16; duration: Theme.durFast; easing.type: Easing.InQuad
        }
    }
}
