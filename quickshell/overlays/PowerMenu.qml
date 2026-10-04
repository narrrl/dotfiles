import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// Full-screen power menu. An accent wedge and stripes sweep in behind a stack of leaning
// buttons; Escape or a click on the backdrop dismisses it.
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

    function focusSelectedAction(): void {
        const entry = buttonRepeater.itemAt(root.selectedAction);
        if (entry && entry.children.length > 0)
            entry.children[0].forceActiveFocus(Qt.TabFocusReason);
    }

    function moveSelection(delta: int): void {
        root.selectedAction = (root.selectedAction + delta + root.actionModel.length)
            % root.actionModel.length;
        root.focusSelectedAction();
    }

    readonly property var actionModel: [
        { label: "Lock",      icon: "󰌾", danger: false, act: "lock" },
        { label: "Suspend",   icon: "󰤄", danger: false, act: "suspend" },
        { label: "Hibernate", icon: "󰒲", danger: false, act: "hibernate" },
        { label: "Log Out",   icon: "󰗽", danger: true,  act: "logout" },
        { label: "Reboot",    icon: "󰜉", danger: true,  act: "reboot" },
        { label: "Shut Down", icon: "󰐥", danger: true,  act: "shutdown" }
    ]

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
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.alpha(Theme.base, 0.9)
        opacity: 0

        TapHandler {
            onTapped: Actions.closePowerMenu()
        }
    }

    // Grid and column, shared with the lock screen.
    P5Backdrop {
        id: ground
        anchors.fill: parent
        reveal: 0
        stripeOpacity: 0.05
        wedgeOpacity: 0.35
        wedgeSpan: 0.34
        // The live desktop is still visible behind this, so a dot wash would be
        // laid over other people's windows rather than over a ground of our
        // own. The lock owns the halftone; here it just muddies things.
        halftone: false
    }

    // ---------------------------------------------------------------- title
    Column {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: root.width * 0.12
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -60
        spacing: -14
        opacity: 0

        SplitText {
            text: "GLORY"
            pixelSize: Theme.fsMega
            split: 4
        }

        SplitText {
            text: "TO"
            pixelSize: Theme.fsMega
            color: Theme.accent
            split: 4
        }

        SplitText {
            text: "MANKIND."
            pixelSize: Theme.fsMega
            split: 4
        }

        Text {
            text: "— YORHA"
            color: Theme.primary
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsSmall
            font.letterSpacing: 5
            topPadding: 24
            renderType: Text.NativeRendering
        }
    }

    // -------------------------------------------------------------- actions
    Column {
        id: actions
        anchors.right: parent.right
        anchors.rightMargin: root.width * 0.12
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.padM

        // The widest slab in the stack. Fixed rather than derived so the ragged
        // x offsets below cannot feed back into the Column's own width.
        readonly property int stackWidth: 312
        width: stackWidth

        Repeater {
            id: buttonRepeater

            model: root.actionModel

            // A carrier item owns the staggered slide so the button keeps its
            // own hover transform.
            Item {
                id: entry
                required property var modelData
                required property int index

                readonly property int slabWidth: actions.stackWidth

                width: entry.slabWidth
                height: 52

                opacity: 0
                transform: [
                    Translate { id: slide; x: 90 },
                    Rotation {
                        id: tilt
                        angle: -3
                        origin.x: entry.slabWidth / 2
                        origin.y: 26
                    }
                ]

                P5Button {
                    id: actionButton
                    anchors.fill: parent
                    text: entry.modelData.label
                    icon: entry.modelData.icon
                    destructive: entry.modelData.danger
                    selected: root.selectedAction === entry.index
                    accent: entry.modelData.danger ? Theme.alarm : Theme.primary
                    lean: Theme.skew
                    onClicked: root.invoke(entry.modelData.act)
                    onHoveredChanged: if (hovered) root.selectedAction = entry.index
                    onActiveFocusChanged: if (actionButton.activeFocus) root.selectedAction = entry.index
                    Keys.forwardTo: [keyController]
                }

                // Staggered entry, one button after another.
                Connections {
                    target: root
                    function onOpenChanged() {
                        if (root.open) entryAnim.restart();
                        else entry.opacity = 0;
                    }
                }

                SequentialAnimation {
                    id: entryAnim
                    PauseAnimation { duration: 40 + entry.index * 55 }
                    ParallelAnimation {
                        NumberAnimation {
                            target: entry; property: "opacity"
                            to: 1; duration: Theme.durBase
                        }
                        NumberAnimation {
                            target: slide; property: "x"
                            from: 90; to: 0
                            duration: Theme.durSlow
                            easing.type: Easing.OutCubic
                        }
                        // Slabs land out of true and snap square. Sliding alone
                        // reads like a slide deck; the tilt is what makes it
                        // land like a card being thrown down. Same direction
                        // every time — the motion is the flourish, the geometry
                        // stays disciplined.
                        NumberAnimation {
                            target: tilt; property: "angle"
                            from: -3; to: 0
                            duration: Theme.durSlow
                            easing.type: Easing.OutCubic
                            easing.overshoot: 2.2
                        }
                    }
                }
            }
        }
    }

    // Hint line.
    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        text: "↑ ↓  SELECT     ENTER  CONFIRM     ESC  CANCEL"
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsMicro
        font.letterSpacing: 4
        opacity: backdrop.opacity
        renderType: Text.NativeRendering
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
            to: 1; duration: Theme.durBase; easing.type: Easing.OutQuad
        }
        // One number now drives the slide, the stripe opacity and the wedge.
        NumberAnimation {
            target: ground; property: "reveal"
            from: 0; to: 1; duration: Theme.durLazy; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: title; property: "opacity"
            to: 1; duration: Theme.durSlow
        }
    }

    ParallelAnimation {
        id: closeAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: ground; property: "reveal"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: title; property: "opacity"
            to: 0; duration: Theme.durFast
        }
    }
}
