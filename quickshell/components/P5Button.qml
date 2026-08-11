import QtQuick
import "root:/config"

// Chopped, leaning button. On hover it lunges toward the pointer and flips to
// crimson-on-white; on press it snaps flat.
Item {
    id: root

    property string text: ""
    property string icon: ""
    property color accent: Theme.primary
    property color hoverFill: Theme.accent
    property bool destructive: false
    property bool selected: false
    property real lean: Theme.skew
    property real lunge: 6
    property bool wide: false

    signal clicked()

    readonly property bool hovered: hover.hovered || root.selected
    readonly property bool pressed: tap.pressed

    implicitWidth: wide ? 260 : (row.implicitWidth + panel.contentPad * 2)
    implicitHeight: 44

    P5Panel {
        id: panel
        anchors.fill: parent
        lean: root.lean
        padding: Theme.padS
        fill: root.hovered ? (root.destructive ? root.hoverFill : Theme.text) : Theme.surface
        fillOpacity: root.hovered ? 1.0 : 0.9
        border: root.hovered ? "transparent" : Theme.alpha(root.accent, 0.55)
        slash: !root.hovered
        slashColor: root.destructive ? Theme.accent : root.accent
        halftone: root.hovered
        halftoneColor: root.destructive ? Theme.text : Theme.base
        halftoneOpacity: 0.14

        Behavior on fillOpacity {
            NumberAnimation { duration: Theme.durFast }
        }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: Theme.padM

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.icon !== ""
                text: root.icon
                font.pixelSize: Theme.fsTitle
                color: root.hovered
                    ? (root.destructive ? Theme.text : Theme.base)
                    : root.accent
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: root.hovered
                    ? (root.destructive ? Theme.text : Theme.base)
                    : Theme.text
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsBody
                font.weight: Theme.weightDisplay
                font.italic: true
                font.letterSpacing: 1.5
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation { duration: Theme.durFast }
                }
            }
        }
    }

    transform: Translate {
        x: root.pressed ? 0 : (root.hovered ? root.lunge : 0)

        Behavior on x {
            NumberAnimation {
                duration: Theme.durBase
                easing.type: Easing.OutBack
            }
        }
    }

    scale: root.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutExpo }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap
        onTapped: root.clicked()
    }
}
