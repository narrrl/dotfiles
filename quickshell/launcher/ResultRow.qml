import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/config"
import "root:/components"

// One line in the result list. Rest is bare — no fill, no border — so a list of
// forty apps reads as a column of text rather than forty boxes. Only the
// selected row gets a slab, and it takes the full inverted treatment: white
// fill, black text. That is the strongest contrast the palette has, which is
// what the row you are about to launch should be wearing.
Item {
    id: root

    required property var entry
    required property bool selected
    property bool hovered: false
    property string badge: ""

    signal activated
    signal pinRequested

    implicitHeight: 46

    // Selection slab. Leans like everything else; drawn as a Skew so the
    // diagonals get analytic antialiasing instead of a pixel staircase.
    Skew {
        anchors.fill: parent
        anchors.leftMargin: -Theme.padS
        anchors.rightMargin: -Theme.padS
        radius: Theme.radiusM
        color: root.selected ? Theme.treatmentSelectedFill : "transparent"
        opacity: root.selected ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutQuad }
        }
    }

    // Hover is an accent tick in the gutter rather than a second slab, so
    // pointing at a row cannot be mistaken for selecting it.
    Skew {
        anchors.verticalCenter: parent.verticalCenter
        x: -Theme.padS
        width: 3
        height: root.hovered && !root.selected ? parent.height - 10 : 0
        color: Theme.accent

        Behavior on height {
            NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutCubic }
        }
    }

    Row {
        anchors.fill: parent
        anchors.leftMargin: Theme.padM
        anchors.rightMargin: Theme.padM
        spacing: Theme.padM

        IconImage {
            anchors.verticalCenter: parent.verticalCenter
            implicitSize: 26
            asynchronous: true
            source: root.entry.icon ? Quickshell.iconPath(root.entry.icon, true) : ""
            visible: source !== ""
        }

        // Entries with no icon still need to occupy the same gutter, or their
        // labels wander left and the column stops being a column.
        Icon {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            text: "󰣆"
            color: root.selected ? Theme.treatmentSelectedText : Theme.muted
            visible: !root.entry.icon && root.entry.kind !== "dmenu"
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 26 - Theme.padM * 2 - trailing.width
            spacing: -1

            Text {
                width: parent.width
                text: root.entry.name
                elide: Text.ElideRight
                color: root.selected ? Theme.treatmentSelectedText : Theme.text
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsBody
                font.weight: root.selected ? Font.Bold : Theme.weightBody
                renderType: Text.NativeRendering
            }

            Text {
                width: parent.width
                text: root.entry.sub
                visible: text !== ""
                elide: Text.ElideRight
                color: root.selected ? Theme.alpha(Theme.ink, 0.6) : Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }
        }
    }

    // Trailing hint: the key that fires this row. Only the selected row shows
    // one, because a column of ⏎ glyphs tells you nothing.
    Text {
        id: trailing
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.padM
        text: root.selected ? root.badge : ""
        color: Theme.alpha(Theme.ink, 0.55)
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsMicro
        font.letterSpacing: 2
        renderType: Text.NativeRendering
    }

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onTapped: (point, button) => {
            if (button === Qt.RightButton) root.pinRequested();
            else root.activated();
        }
    }
}
