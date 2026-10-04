import QtQuick
import "root:/config"
import "root:/components"

// Title bar for a popout, in the NieR header pattern: glyph, tracked heading,
// right-aligned status text, and a hairline rule that ends in a square.
Item {
    id: root

    property string title: ""
    property string subtitle: ""
    property string icon: ""
    property color accent: Theme.primary

    implicitHeight: 34

    Row {
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: Theme.padM

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon !== ""
            text: root.icon
            color: root.accent
            font.pixelSize: Theme.fsTitle
        }

        SplitText {
            anchors.verticalCenter: parent.verticalCenter
            text: root.title.toUpperCase()
            pixelSize: Theme.fsLarge
        }
    }

    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 6
        visible: root.subtitle !== ""
        text: root.subtitle
        color: Theme.subtext
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsMicro
        font.letterSpacing: 1
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (Theme.marker - 1) / 2
        anchors.left: parent.left
        anchors.right: endMark.left
        height: 1
        color: Theme.alpha(root.accent, 0.6)
    }

    Rectangle {
        id: endMark
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: Theme.marker
        height: Theme.marker
        color: Theme.accent
    }
}
