import QtQuick
import "root:/config"

// Display text with the wallpaper's RGB split baked in: a crimson and a cyan
// ghost sitting a pixel off the white body. Drives most headings in the shell.
Item {
    id: root

    property string text: ""
    property int pixelSize: Theme.fsLarge
    property int weight: Theme.weightDisplay
    property string family: Theme.fontDisplay
    property bool italic: true
    property color color: Theme.text
    property real split: 1.6
    property real splitOpacity: 0.85
    property int elide: Text.ElideNone
    property int horizontalAlignment: Text.AlignLeft
    property real letterSpacing: 0.5

    implicitWidth: body.implicitWidth
    implicitHeight: body.implicitHeight

    Text {
        id: ghostRed
        anchors.fill: parent
        anchors.leftMargin: -root.split
        anchors.topMargin: root.split * 0.4
        text: root.text
        color: Theme.splitRed
        opacity: root.splitOpacity
        elide: root.elide
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: Text.AlignVCenter
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        font.italic: root.italic
        font.letterSpacing: root.letterSpacing
        renderType: Text.NativeRendering
    }

    Text {
        id: ghostCyan
        anchors.fill: parent
        anchors.leftMargin: root.split
        anchors.topMargin: -root.split * 0.4
        text: root.text
        color: Theme.splitCyan
        opacity: root.splitOpacity
        elide: root.elide
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: Text.AlignVCenter
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        font.italic: root.italic
        font.letterSpacing: root.letterSpacing
        renderType: Text.NativeRendering
    }

    Text {
        id: body
        anchors.fill: parent
        text: root.text
        color: root.color
        elide: root.elide
        horizontalAlignment: root.horizontalAlignment
        verticalAlignment: Text.AlignVCenter
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        font.italic: root.italic
        font.letterSpacing: root.letterSpacing
        renderType: Text.NativeRendering
    }

    // Kick the ghosts outward briefly — used on track changes, mode flips, etc.
    function glitch() {
        glitchAnim.restart();
    }

    SequentialAnimation {
        id: glitchAnim
        NumberAnimation {
            target: root; property: "split"
            to: 5.5; duration: Theme.durFast
            easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: root; property: "split"
            to: 1.6; duration: Theme.durSlow
            easing.type: Easing.OutBack
        }
    }
}
