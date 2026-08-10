import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import "root:/config"
import "root:/components"
import "root:/services"

// Full-screen power menu. Crimson stripes sweep in behind a stack of leaning
// buttons; Escape or a click on the backdrop dismisses it.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    visible: Actions.powerMenuOpen || closeAnim.running

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-power"
    WlrLayershell.keyboardFocus: Actions.powerMenuOpen
        ? WlrKeyboardFocus.Exclusive
        : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    readonly property bool open: Actions.powerMenuOpen

    onOpenChanged: {
        if (open) {
            openAnim.restart();
        } else {
            closeAnim.restart();
        }
    }

    // ------------------------------------------------------------- backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.alpha(Theme.base, 0.82)
        opacity: 0

        TapHandler {
            onTapped: Actions.closePowerMenu()
        }
    }

    // Diagonal stripe field sweeping in from the left.
    Image {
        id: stripes
        anchors.fill: parent
        source: Theme.texStripes
        fillMode: Image.Tile
        opacity: 0
        smooth: false

        layer.enabled: true
        layer.effect: TintEffect {
            tintColor: Theme.accent
        }

        transform: Translate {
            id: stripeShift
            x: -root.width
        }
    }

    // A crimson wedge behind the buttons.
    Shape {
        id: wedge
        anchors.fill: parent
        opacity: 0
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Theme.alpha(Theme.accentDim, 0.35)
            strokeColor: "transparent"
            PathPolyline {
                path: [
                    Qt.point(root.width * 0.18, 0),
                    Qt.point(root.width * 0.52, 0),
                    Qt.point(root.width * 0.34, root.height),
                    Qt.point(0, root.height),
                    Qt.point(root.width * 0.18, 0)
                ]
            }
        }
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
            text: "TAKE"
            pixelSize: Theme.fsMega
            split: 4
            splitOpacity: 0.9
        }

        SplitText {
            text: "YOUR"
            pixelSize: Theme.fsMega
            color: Theme.accent
            split: 4
            splitOpacity: 0.5
        }

        SplitText {
            text: "TIME."
            pixelSize: Theme.fsMega
            split: 4
            splitOpacity: 0.9
        }

        Text {
            text: "— TAE TAKEMI"
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

        Repeater {
            id: buttonRepeater

            model: [
                { label: "Lock",      icon: "󰌾", danger: false, act: "lock" },
                { label: "Suspend",   icon: "󰤄", danger: false, act: "suspend" },
                { label: "Hibernate", icon: "󰒲", danger: false, act: "hibernate" },
                { label: "Log Out",   icon: "󰗽", danger: true,  act: "logout" },
                { label: "Reboot",    icon: "󰜉", danger: true,  act: "reboot" },
                { label: "Shut Down", icon: "󰐥", danger: true,  act: "shutdown" }
            ]

            // A carrier item owns the staggered slide so the button keeps its
            // own hover transform.
            Item {
                id: entry
                required property var modelData
                required property int index

                width: 280
                height: 52

                opacity: 0
                transform: Translate { id: slide; x: 90 }

                P5Button {
                    anchors.fill: parent
                    text: entry.modelData.label
                    icon: entry.modelData.icon
                    destructive: entry.modelData.danger
                    accent: entry.modelData.danger ? Theme.accent : Theme.primary
                    lunge: -10
                    onClicked: root.invoke(entry.modelData.act)
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
                            easing.type: Easing.OutBack
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
        text: "ESC TO CANCEL"
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
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: Actions.closePowerMenu()
    }

    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: backdrop; property: "opacity"
            to: 1; duration: Theme.durBase; easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: stripes; property: "opacity"
            to: 0.1; duration: Theme.durSlow
        }
        NumberAnimation {
            target: stripeShift; property: "x"
            from: -root.width; to: 0
            duration: Theme.durLazy; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: wedge; property: "opacity"
            to: 1; duration: Theme.durSlow; easing.type: Easing.OutExpo
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
            target: stripes; property: "opacity"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: wedge; property: "opacity"
            to: 0; duration: Theme.durFast
        }
        NumberAnimation {
            target: title; property: "opacity"
            to: 0; duration: Theme.durFast
        }
    }
}
