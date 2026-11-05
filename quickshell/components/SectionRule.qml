import QtQuick
import "root:/config"

// Section caption for popouts: a spaced mono label running into a hairline.
// Every panel used to label its lists differently — a bare caption here, a
// caption and rule there — which is part of why no two popouts looked related.
Item {
    id: root

    property string text: ""

    implicitHeight: visible ? 18 : 0

    Text {
        id: label
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.text.toUpperCase()
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsMicro
        font.weight: Font.Bold
        font.letterSpacing: 2
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.left: label.right
        anchors.leftMargin: Theme.padS
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: Theme.alpha(Theme.outline, 0.5)
    }
}
