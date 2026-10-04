import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "root:/config"
import "root:/components"
import "root:/services"

// Full-screen power menu, built like the lock screen: the desktop dims to the
// void, and one small group of type stands in it — the mark, the motto, a
// line about the session, and a NieR menu of six rows. The selected row is a
// pill of light with the text punched out of it; the three that end the
// session light in rust instead. Escape or a click on the dark dismisses it.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // Only the screen that had focus when the menu was asked for shows it; the
    // other copies stay dormant so the keyboard has one place to land.
    readonly property bool open: Actions.powerMenuOpen
        && Actions.powerMenuScreen === modelData.name

    visible: root.open || closeAnim.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-power"
    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    property int selectedAction: 0

    function moveSelection(delta: int): void {
        root.selectedAction = (root.selectedAction + delta + root.actionModel.length)
            % root.actionModel.length;
    }

    readonly property var actionModel: [
        { label: "Lock",      icon: "󰌾", danger: false, act: "lock" },
        { label: "Suspend",   icon: "󰤄", danger: false, act: "suspend" },
        { label: "Hibernate", icon: "󰒲", danger: false, act: "hibernate" },
        { label: "Log Out",   icon: "󰗽", danger: true,  act: "logout" },
        { label: "Reboot",    icon: "󰜉", danger: true,  act: "reboot" },
        { label: "Shut Down", icon: "󰐥", danger: true,  act: "shutdown" }
    ]

    FileView {
        id: hostFile
        path: "/etc/hostname"
    }

    onOpenChanged: {
        if (open) {
            PopupCoordinator.dismissAll();
            selectedAction = 0;
            openAnim.restart();
        } else {
            closeAnim.restart();
        }
    }

    // ------------------------------------------------------------- backdrop
    // The desktop stays faintly there behind the dark, deepest on the left
    // where the menu stands.
    Rectangle {
        id: backdrop
        anchors.fill: parent
        opacity: 0
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.alpha(Theme.ink, 0.97) }
            GradientStop { position: 0.5; color: Theme.alpha(Theme.ink, 0.93) }
            GradientStop { position: 1.0; color: Theme.alpha(Theme.ink, 0.86) }
        }

        TapHandler {
            onTapped: Actions.closePowerMenu()
        }
    }

    // ---------------------------------------------------------------- group
    Column {
        id: group
        x: root.width * 0.14
        anchors.verticalCenter: parent.verticalCenter
        width: 340
        opacity: 0

        transform: Translate { id: drift }

        Porthole {
            size: 26
        }

        Text {
            topPadding: Theme.padM
            text: "Take your time."
            color: Theme.accent
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsHuge
            font.weight: Font.Light
            font.letterSpacing: 1
            renderType: Text.NativeRendering
        }

        Text {
            topPadding: Theme.padS
            leftPadding: 2
            text: [(Quickshell.env("USER") || "user") + "@" + hostFile.text().trim(),
                   Sys.uptime ? "UP " + Sys.uptime : ""].filter(t => t !== "").join("  ·  ")
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        Item { width: 1; height: Theme.padXL }

        // ------------------------------------------------------------ menu
        Repeater {
            id: buttonRepeater

            model: root.actionModel

            Item {
                id: entry
                required property var modelData
                required property int index

                readonly property bool selected: root.selectedAction === entry.index
                readonly property color tone: entry.modelData.danger ? Theme.alarm : Theme.accent

                width: group.width
                height: 44
                opacity: 0

                transform: Translate { id: rise; y: 6 }

                // The divider after the third row: what pauses the session
                // above, what ends it below.
                Rectangle {
                    visible: entry.index === 3
                    anchors.top: parent.top
                    x: Theme.padL
                    width: parent.width - Theme.padL * 2
                    height: 1
                    color: Theme.alpha(Theme.outline, 0.35)
                }

                Rectangle {
                    id: slab
                    anchors.fill: parent
                    anchors.topMargin: 3
                    anchors.bottomMargin: 3
                    radius: height / 2
                    color: entry.selected ? entry.tone : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    id: marker
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padL
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.marker
                    height: Theme.marker
                    radius: width / 2
                    color: entry.selected ? Theme.ink
                        : (entry.modelData.danger ? Theme.alpha(Theme.alarm, 0.6) : Theme.overlay)
                }

                Icon {
                    id: glyph
                    anchors.left: marker.right
                    anchors.leftMargin: Theme.padM
                    anchors.verticalCenter: parent.verticalCenter
                    // Fixed width so the labels line up whatever the glyph.
                    width: 20
                    horizontalAlignment: Text.AlignHCenter
                    text: entry.modelData.icon
                    color: entry.selected ? Theme.ink : Theme.muted
                    font.pixelSize: Theme.fsLarge
                }

                Text {
                    anchors.left: glyph.right
                    anchors.leftMargin: Theme.padM
                    anchors.verticalCenter: parent.verticalCenter
                    text: entry.modelData.label.toUpperCase()
                    color: entry.selected ? Theme.ink : Theme.text
                    font.family: Theme.fontDisplay
                    font.pixelSize: Theme.fsBody
                    font.weight: Theme.weightDisplay
                    font.letterSpacing: Theme.tracking * 1.5
                    renderType: Text.NativeRendering
                }

                HoverHandler {
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: if (hovered) root.selectedAction = entry.index
                }

                TapHandler {
                    onTapped: root.invoke(entry.modelData.act)
                }

                // Staggered entry: each row resolves a beat after the last.
                Connections {
                    target: root
                    function onOpenChanged() {
                        if (root.open) entryAnim.restart();
                        else entry.opacity = 0;
                    }
                }

                SequentialAnimation {
                    id: entryAnim
                    PauseAnimation { duration: 120 + entry.index * 40 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: entry; property: "opacity"
                            to: 1; duration: Theme.durSlow; easing.type: Easing.OutCubic
                        }
                        NumberAnimation {
                            target: rise; property: "y"
                            from: 6; to: 0; duration: Theme.durSlow; easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        Text {
            topPadding: Theme.padXL
            leftPadding: Theme.padL
            text: "↑ ↓  SELECT    ENTER  CONFIRM    ESC  CANCEL"
            color: Theme.overlay
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }
    }

    function invoke(what: string) {
        Actions.closePowerMenu();
        switch (what) {
        case "lock": Actions.lock(); break;
        case "suspend": Actions.suspend(); break;
        case "hibernate": Actions.hibernate(); break;
        case "logout": Actions.logout(); break;
        case "reboot": Actions.reboot(); break;
        case "shutdown": Actions.shutdown(); break;
        }
    }

    // Escape closes. The layer takes exclusive focus while open.
    Item {
        id: keyController
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: Actions.closePowerMenu()
        Keys.onPressed: event => {
            if (!root.open) return;
            if (event.key === Qt.Key_Up || event.key === Qt.Key_K) {
                root.moveSelection(-1);
                event.accepted = true;
            } else if (event.key === Qt.Key_Down || event.key === Qt.Key_J) {
                root.moveSelection(1);
                event.accepted = true;
            } else if (keyController.activeFocus
                       && !event.isAutoRepeat
                       && (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                           || event.key === Qt.Key_Space)) {
                root.invoke(root.actionModel[root.selectedAction].act);
                event.accepted = true;
            }
        }
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 1; duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: group; property: "opacity"
            to: 1; duration: Theme.durLazy; easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: drift; property: "y"
            from: 14; to: 0; duration: Theme.durLazy; easing.type: Easing.OutQuint
        }
    }

    ParallelAnimation {
        id: closeAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 0; duration: Theme.durBase; easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: group; property: "opacity"
            to: 0; duration: Theme.durFast
        }
    }
}
