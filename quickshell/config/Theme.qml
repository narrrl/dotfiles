pragma Singleton

import QtQuick
import Quickshell

// Takemi palette: cold teal/cyan over near-black, with Persona 5 crimson as the
// alert/accent voice. Derived from ~/.wallpapers/takemi_2.jpg.
Singleton {
    id: root

    // ---------------------------------------------------------------- colors
    readonly property color base: "#04070a"
    readonly property color mantle: "#080e14"
    readonly property color surface: "#0d1922"
    readonly property color surfaceAlt: "#14262f"
    readonly property color overlay: "#1d3a47"
    readonly property color outline: "#2b5567"

    readonly property color text: "#e2f4f8"
    readonly property color subtext: "#93b8c4"
    readonly property color muted: "#587c8a"

    readonly property color primary: "#34d3e6"   // electric teal — the house colour
    readonly property color primaryDim: "#17879b"
    readonly property color glow: "#8ef2ff"
    readonly property color blue: "#3b8fd6"
    readonly property color deep: "#0d4b5e"

    readonly property color accent: "#ff2d40"    // P5 crimson
    readonly property color accentDim: "#a8121f"
    readonly property color warn: "#ffb03a"
    readonly property color ok: "#35e08f"

    // Chromatic aberration pair, straight off the wallpaper's RGB split.
    readonly property color splitRed: "#ff2b4d"
    readonly property color splitCyan: "#25e8ff"

    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Heat ramp for load/usage readouts.
    function heat(pct: real): color {
        if (pct >= 90) return root.accent;
        if (pct >= 75) return root.warn;
        if (pct >= 45) return root.glow;
        return root.primary;
    }

    // ----------------------------------------------------------------- fonts
    readonly property string fontDisplay: "Archivo Black"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"

    readonly property int weightDisplay: Font.Black
    readonly property int weightBody: Font.Medium

    readonly property int fsMicro: 9
    readonly property int fsSmall: 11
    readonly property int fsBody: 12
    readonly property int fsLarge: 15
    readonly property int fsTitle: 20
    readonly property int fsHuge: 34
    readonly property int fsMega: 92

    // -------------------------------------------------------------- geometry
    readonly property int barHeight: 40
    readonly property int barMargin: 8
    readonly property int barGap: 8

    // Horizontal offset per unit of height. tan(14deg) — every panel leans.
    readonly property real skew: 0.249
    readonly property int cut: 9          // corner chamfer, in px
    readonly property int stroke: 2

    readonly property int padS: 6
    readonly property int padM: 12
    readonly property int padL: 20
    readonly property int padXL: 32

    readonly property int popoutWidth: 380
    readonly property int popoutGap: 10

    // ------------------------------------------------------------ animation
    // P5 motion is snappy and slightly overshooting — never soft.
    readonly property int durFast: 110
    readonly property int durBase: 190
    readonly property int durSlow: 340
    readonly property int durLazy: 620

    readonly property var easeSnap: [0.16, 1.0, 0.3, 1.0, 1, 1]        // outExpo-ish
    readonly property var easeBack: [0.34, 1.56, 0.64, 1.0, 1, 1]      // overshoot
    readonly property var easeIn: [0.55, 0.0, 0.9, 0.35, 1, 1]

    // -------------------------------------------------------------- textures
    readonly property url texHalftone: "root:/assets/halftone.png"
    readonly property url texStripes: "root:/assets/stripes.png"
    readonly property url texScanline: "root:/assets/scanline.png"

    readonly property url wallpaper: "file:///home/narl/.wallpapers/takemi_2.jpg"
}
