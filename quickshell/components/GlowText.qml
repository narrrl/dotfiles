import QtQuick
import QtQuick.Effects
import "root:/config"

// A line of type lit from inside, like a tube in a dark console: a soft halo
// that breathes slowly, and every so often a short, uneven stutter where the
// light catches — two or three dips, then steady again for a while. The
// stutters come at random intervals so it never settles into a rhythm you
// could count.
//
// Only the halo and the opacity move, never the geometry, so the glyphs stay
// on the pixel grid. Set `active` false while the text is off screen to stop
// the animation.
Item {
    id: root

    property string text: ""
    property color color: Theme.accent
    property color glowColor: root.color
    property string family: Theme.fontDisplay
    property int pixelSize: Theme.fsLarge
    property int weight: Font.Light
    property real letterSpacing: 0
    property bool active: true

    // 0..1, how lit the tube is at this instant.
    property real lit: 1
    // Slow breathing on the halo alone, between `low` and 1.
    property real breath: 1

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    Text {
        id: label
        visible: false
        text: root.text
        color: root.color
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        font.letterSpacing: root.letterSpacing
        // Greyscale antialiasing: the glyphs are drawn into the effect's
        // texture, and native subpixel rendering there leaves colour fringes.
        renderType: Text.CurveRendering
    }

    // A wide, faint halo under a tight, brighter one, so the light both
    // spreads into the dark and hugs the strokes.
    MultiEffect {
        source: label
        anchors.fill: label
        autoPaddingEnabled: true
        opacity: root.lit

        shadowEnabled: true
        shadowColor: root.glowColor
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowBlur: 1.0
        blurMax: Math.max(32, Math.round(root.pixelSize * 2))
        shadowOpacity: 0.7 * root.breath
        shadowScale: 1.02
    }

    MultiEffect {
        source: label
        anchors.fill: label
        autoPaddingEnabled: true
        opacity: 0.55 + 0.45 * root.lit

        shadowEnabled: true
        shadowColor: root.glowColor
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        shadowBlur: 1.0
        blurMax: Math.max(8, Math.round(root.pixelSize * 0.35))
        shadowOpacity: 0.9 * root.lit
    }

    SequentialAnimation on breath {
        running: root.active
        loops: Animation.Infinite
        NumberAnimation { to: 0.6; duration: 2600; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.0; duration: 2600; easing.type: Easing.InOutSine }
    }

    // One stutter: uneven dips of uneven length, then back to full.
    SequentialAnimation {
        id: stutter
        NumberAnimation { target: root; property: "lit"; to: 0.25; duration: 40 }
        NumberAnimation { target: root; property: "lit"; to: 0.9; duration: 60 }
        PauseAnimation { duration: 70 }
        NumberAnimation { target: root; property: "lit"; to: 0.4; duration: 30 }
        NumberAnimation { target: root; property: "lit"; to: 1.0; duration: 180; easing.type: Easing.OutCubic }
    }

    Timer {
        id: nextStutter
        running: root.active
        repeat: true
        interval: 6000
        onTriggered: {
            stutter.restart();
            nextStutter.interval = 4000 + Math.random() * 10000;
        }
    }

    onActiveChanged: if (!root.active) { stutter.stop(); root.lit = 1; }
}
