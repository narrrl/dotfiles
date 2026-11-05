import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// Every monitor, every workspace, every window, at once. Alt+Tab opens it on
// the focused screen with the previous window picked; more Tabs walk back
// through focus history, and letting go of Alt goes there. Hover and click
// work too, as do Enter, Escape and the workspace digits.
//
// It is a scene, like the power menu: no panel, the desktop dims, and each
// monitor is laid out as a row of small portholes — its workspaces, at its
// own aspect ratio, with live captures of the windows where they sit. The
// picked window is ringed in the light and named underneath.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: Actions.overviewOpen
        && Actions.overviewScreen === modelData.name
    visible: root.open || fade.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-overview"
    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"

    // ----------------------------------------------------------------- model
    // Rebuilt from Hyprland's IPC snapshots on open and whenever windows move
    // while open. Plain arrays rather than live models: everything here is a
    // picture of one moment.
    property var monitors: []       // [{ mon, ipc, workspaces: [{ ws, windows: [...] }] }]
    property var mru: []            // window addresses, most recent first
    property string picked: ""      // address of the picked window

    readonly property var pickedWindow: {
        for (const m of root.monitors)
            for (const w of m.workspaces)
                for (const win of w.windows)
                    if (win.address === root.picked) return win;
        return null;
    }

    function rebuild() {
        const mons = Hyprland.monitors.values.slice()
            .filter(m => m.lastIpcObject && m.lastIpcObject.width)
            .sort((a, b) => a.lastIpcObject.x - b.lastIpcObject.x);
        const all = [];
        const out = [];
        for (const mon of mons) {
            const mi = mon.lastIpcObject;
            const wss = Hyprland.workspaces.values
                .filter(ws => ws.monitor === mon)
                .filter(ws => ws.id > 0 || ws.toplevels.values.length > 0)
                .sort((a, b) => (a.id < 0) - (b.id < 0) || a.id - b.id);
            const rows = [];
            for (const ws of wss) {
                const wins = [];
                for (const tl of ws.toplevels.values) {
                    const ipc = tl.lastIpcObject;
                    if (!ipc || !ipc.at || !ipc.mapped) continue;
                    const win = {
                        toplevel: tl,
                        address: "0x" + String(tl.address).replace(/^0x/, ""),
                        x: ipc.at[0] - mi.x, y: ipc.at[1] - mi.y,
                        w: ipc.size[0], h: ipc.size[1],
                        title: ipc.title || "",
                        appClass: ipc.class || "",
                        hidden: ipc.hidden === true,
                        floating: ipc.floating === true,
                        group: (ipc.grouped || []).map(a => "0x" + String(a).replace(/^0x/, "")),
                        history: ipc.focusHistoryID ?? 999,
                    };
                    wins.push(win);
                    all.push(win);
                }
                // Tiled first, floating on top, as Hyprland draws them.
                wins.sort((a, b) => a.floating - b.floating);
                rows.push({ ws: ws, windows: wins });
            }
            out.push({ mon: mon, ipc: mi, workspaces: rows });
        }
        root.monitors = out;
        root.mru = all.sort((a, b) => a.history - b.history).map(w => w.address);
        if (!root.touched || root.mru.indexOf(root.picked) < 0)
            root.picked = root.mru.length > 1 ? root.mru[1] : (root.mru[0] ?? "");
    }

    function step(delta: int) {
        root.touched = true;
        const n = root.mru.length;
        if (n === 0) return;
        const at = Math.max(0, root.mru.indexOf(root.picked));
        root.picked = root.mru[(at + delta + n) % n];
    }

    // Hyprland will not move focus while a layer holds the keyboard
    // exclusively, so let go of it first and dispatch a moment later.
    property string pendingDispatch: ""

    function commit() {
        root.pendingDispatch = root.picked !== ""
            ? "hl.dsp.focus({ window = \"address:" + root.picked + "\" })"
            : "";
        Actions.closeOverview();
        if (root.pendingDispatch !== "") release.restart();
    }

    function goToWorkspace(id: int) {
        root.pendingDispatch = "hl.dsp.focus({ workspace = " + id + " })";
        Actions.closeOverview();
        release.restart();
    }

    Timer {
        id: release
        interval: 40
        onTriggered: Hyprland.dispatch(root.pendingDispatch)
    }

    // Whether the pointer has moved since the overview opened. A pointer that
    // happens to rest over a card would otherwise pick that window the moment
    // the cards appear under it, overriding Alt+Tab's choice.
    property bool pointerLive: false
    property point pointerStart: Qt.point(-1, -1)

    // Whether the pick came from a person rather than from the first snapshot.
    property bool touched: false

    onOpenChanged: {
        if (root.open) {
            PopupCoordinator.dismissAll();
            Hyprland.refreshMonitors();
            Hyprland.refreshWorkspaces();
            Hyprland.refreshToplevels();
            root.picked = "";
            root.touched = false;
            root.pointerLive = false;
            root.pointerStart = Qt.point(-1, -1);
            root.rebuild();
            // The IPC snapshots land a moment after the refresh request.
            settle.restart();
            keys.forceActiveFocus();
        }
    }

    Timer {
        id: settle
        interval: 60
        onTriggered: root.rebuild()
    }

    Connections {
        target: Actions
        function onOverviewStepped(delta) { if (root.open) root.step(delta); }
        function onOverviewCommitted() { if (root.open) root.commit(); }
    }

    Connections {
        target: Hyprland
        enabled: root.open
        function onRawEvent(event) {
            const n = event.name;
            if (n === "openwindow" || n === "closewindow" || n === "movewindowv2"
                    || n === "changefloatingmode" || n === "fullscreen") {
                Hyprland.refreshToplevels();
                settle.restart();
            }
        }
    }

    // ------------------------------------------------------------- backdrop
    Rectangle {
        anchors.fill: parent
        color: Theme.ink
        opacity: root.open ? 0.92 : 0

        Behavior on opacity {
            NumberAnimation { id: fade; duration: Theme.durBase; easing.type: Easing.OutCubic }
        }

        TapHandler { onTapped: Actions.closeOverview() }
    }

    // ---------------------------------------------------------------- scene
    Item {
        id: keys
        anchors.fill: parent
        focus: true

        HoverHandler {
            onPointChanged: {
                const p = point.position;
                if (root.pointerStart.x < 0) { root.pointerStart = p; return; }
                if (Math.abs(p.x - root.pointerStart.x) + Math.abs(p.y - root.pointerStart.y) > 6)
                    root.pointerLive = true;
            }
        }

        Keys.onPressed: event => {
            const k = event.key;
            if (k === Qt.Key_Escape) Actions.closeOverview();
            else if (k === Qt.Key_Return || k === Qt.Key_Enter || k === Qt.Key_Space) root.commit();
            else if (k === Qt.Key_Tab || k === Qt.Key_Right || k === Qt.Key_Down
                     || k === Qt.Key_L || k === Qt.Key_J) root.step(1);
            else if (k === Qt.Key_Backtab || k === Qt.Key_Left || k === Qt.Key_Up
                     || k === Qt.Key_H || k === Qt.Key_K) root.step(-1);
            else if (k >= Qt.Key_1 && k <= Qt.Key_9) root.goToWorkspace(k - Qt.Key_0);
            else return;
            event.accepted = true;
        }

        // Alt+Tab is a hold: letting go of Alt is the choice.
        Keys.onReleased: event => {
            if (event.key === Qt.Key_Alt && Actions.overviewHold) {
                event.accepted = true;
                root.commit();
            }
        }
    }

    Column {
        id: scene
        anchors.centerIn: parent
        spacing: Theme.padXL
        opacity: root.open ? 1 : 0

        transform: Translate {
            y: root.open ? 0 : 10

            Behavior on y {
                NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutCubic }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
        }

        // The widest a row of cards may be, and how tall all rows together.
        readonly property real maxRowWidth: root.width * 0.86
        readonly property real maxRowsHeight: root.height * 0.62

        // One scale for every card on every monitor, so a window is the same
        // size wherever it sits: the largest that fits both the widest row and
        // the summed heights.
        readonly property real k: {
            let k = 0.25;
            let totalH = 0;
            for (const m of root.monitors) {
                const w = m.ipc.width / m.ipc.scale;
                const h = m.ipc.height / m.ipc.scale;
                const n = Math.max(1, m.workspaces.length);
                k = Math.min(k, (scene.maxRowWidth - (n - 1) * Theme.padL) / (n * w));
                totalH += h;
            }
            if (totalH > 0) k = Math.min(k, scene.maxRowsHeight / totalH);
            return Math.max(0.05, k);
        }

        Repeater {
            model: root.monitors

            Column {
                id: monRow
                required property var modelData
                readonly property real logicalW: modelData.ipc.width / modelData.ipc.scale
                readonly property real logicalH: modelData.ipc.height / modelData.ipc.scale
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.padS

                // The monitor's name only matters once there is more than one.
                Text {
                    visible: root.monitors.length > 1
                    text: (monRow.modelData.mon.name + "  ·  "
                        + Math.round(monRow.logicalW) + "×" + Math.round(monRow.logicalH)).toUpperCase()
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 2
                    renderType: Text.NativeRendering
                }

                Row {
                    spacing: Theme.padL

                    Repeater {
                        model: monRow.modelData.workspaces

                        WorkspaceCard {
                            required property var modelData
                            ws: modelData.ws
                            windows: modelData.windows
                            k: scene.k
                            logicalW: monRow.logicalW
                            logicalH: monRow.logicalH
                            current: monRow.modelData.mon.activeWorkspace === modelData.ws
                                || (modelData.ws.id < 0 && monRow.modelData.ipc.specialWorkspace?.id === modelData.ws.id)
                            picked: root.picked
                            onPick: address => {
                                if (!root.pointerLive) return;
                                root.touched = true;
                                root.picked = address;
                            }
                            onActivate: address => { root.picked = address; root.commit(); }
                            onActivateWorkspace: id => root.goToWorkspace(id)
                        }
                    }
                }
            }
        }

        // ------------------------------------------------------------ caption
        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            width: scene.maxRowWidth * 0.7

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: root.pickedWindow ? root.pickedWindow.title : "No windows"
                color: Theme.accent
                elide: Text.ElideRight
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsTitle
                font.weight: Font.Light
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                visible: root.pickedWindow !== null
                text: root.pickedWindow
                    ? (root.pickedWindow.appClass + "  ·  workspace "
                       + (root.pickedWindow.toplevel.workspace?.name ?? "?")).toUpperCase()
                    : ""
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.letterSpacing: 2
                renderType: Text.NativeRendering
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "TAB  NEXT    ENTER  GO    1–9  WORKSPACE    ESC  CANCEL"
            color: Theme.overlay
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }
    }
}
