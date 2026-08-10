import QtQuick
import "root:/config"

// Nerd Font glyph with an optional pulse, used for every status indicator.
Text {
    id: root

    property bool pulsing: false
    property real pulseScale: 1.18

    font.family: Theme.fontIcon
    font.pixelSize: Theme.fsLarge
    color: Theme.primary
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
    renderType: Text.NativeRendering

    Behavior on color {
        ColorAnimation { duration: Theme.durBase }
    }

    SequentialAnimation on scale {
        running: root.pulsing
        loops: Animation.Infinite
        alwaysRunToEnd: true
        NumberAnimation { to: root.pulseScale; duration: 620; easing.type: Easing.OutExpo }
        NumberAnimation { to: 1.0; duration: 620; easing.type: Easing.InOutQuad }
    }

    function bump() {
        bumpAnim.restart();
    }

    SequentialAnimation {
        id: bumpAnim
        NumberAnimation {
            target: root; property: "scale"
            to: 1.35; duration: Theme.durFast; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: root; property: "scale"
            to: 1.0; duration: Theme.durSlow; easing.type: Easing.OutBack
        }
    }
}
