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
    // Curve glyphs, not native ones. Native glyphs are rasterised once at rest
    // size and the bitmap is stretched when `scale` moves, so every pulse and
    // bump came out blurred and stepped. Curves are drawn from the outline at
    // whatever size the icon is at that frame.
    renderType: Text.CurveRendering

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
            to: 1.12; duration: Theme.durFast; easing.type: Easing.OutExpo
        }
        NumberAnimation {
            target: root; property: "scale"
            to: 1.0; duration: Theme.durSlow; easing.type: Easing.OutCubic
        }
    }
}
