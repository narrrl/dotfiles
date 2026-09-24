import QtQuick
import "root:/config"

// Display text, screen-printed: the body sits on a hard crust copy knocked a
// pixel and a half down-right — the same offset `P5Panel` puts behind every
// slab. Drives most headings in the shell.
//
// This used to carry a permanent RGB split, a blue and a mauve ghost either
// side of the body. On crimson-and-black that read as misregistered print; on
// Mocha's pastels it read as blur, and it turned every heading in the shell
// soft. The two ghosts still exist, but only for the moment `glitch()` runs.
Item {
    id: root

    property string text: ""
    property int pixelSize: Theme.fsLarge
    property int weight: Theme.weightDisplay
    property string family: Theme.fontDisplay
    property bool italic: true
    property color color: Theme.text
    property int elide: Text.ElideNone
    property int horizontalAlignment: Text.AlignLeft
    property real letterSpacing: 0.5

    // Print shadow. Scales gently with size so a 34px heading does not sit on
    // the same hairline offset as an 11px label.
    property real shadowOffset: Math.max(1, Math.round(root.pixelSize / 10))
    property color shadowColor: Theme.ink

    // Ghost offset and resting strength. Resting strength is zero, so the
    // ghosts are invisible until `glitch()` kicks them out. A caller that sets
    // `splitOpacity` is asking for the old permanent split and still gets it.
    property real split: 1.6
    property real splitOpacity: 0

    // 0..1, driven only by `glitch()`. Kept apart from `split` and
    // `splitOpacity` so the animation never has to remember a caller's values.
    property real kick: 0

    readonly property real ghostOffset: root.split + root.kick * 4
    readonly property real ghostOpacity: Math.max(root.splitOpacity, root.kick * 0.85)

    implicitWidth: body.implicitWidth
    implicitHeight: body.implicitHeight

    component Layer: Text {
        anchors.fill: parent
        text: root.text
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

    Layer {
        anchors.leftMargin: root.shadowOffset
        anchors.rightMargin: -root.shadowOffset
        anchors.topMargin: root.shadowOffset
        anchors.bottomMargin: -root.shadowOffset
        color: root.shadowColor
    }

    Layer {
        visible: root.ghostOpacity > 0.01
        anchors.leftMargin: -root.ghostOffset
        anchors.topMargin: root.ghostOffset * 0.4
        color: Theme.accent
        opacity: root.ghostOpacity
    }

    Layer {
        visible: root.ghostOpacity > 0.01
        anchors.leftMargin: root.ghostOffset
        anchors.topMargin: -root.ghostOffset * 0.4
        color: Theme.alarm
        opacity: root.ghostOpacity
    }

    Layer {
        id: body
        color: root.color
    }

    // Kick the ghosts outward briefly — used on track changes, mode flips, etc.
    function glitch() {
        glitchAnim.restart();
    }

    SequentialAnimation {
        id: glitchAnim
        NumberAnimation {
            target: root; property: "kick"
            to: 1; duration: Theme.durFast
            easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: root; property: "kick"
            to: 0; duration: Theme.durSlow
            easing.type: Easing.OutCubic
        }
    }
}
