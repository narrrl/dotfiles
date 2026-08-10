pragma Singleton

import QtQuick
import Quickshell

// Takemi palette. Two hues, no exceptions: a cold teal that carries every
// resting state, and Persona 5 crimson that means alarm and nothing else.
// Anything that used to be blue/green/amber now resolves into one of those two
// families, so a splash of red in the bar always reads as "something is wrong".
// Derived from ~/.wallpapers/takemi_2.jpg.
Singleton {
    id: root

    // ---------------------------------------------------------------- colors
    // True black, for keylines and drop shapes. `base` is the near-black the
    // surfaces sit on; `ink` is never tinted and never blended.
    readonly property color ink: "#000000"

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
    readonly property color deep: "#0d4b5e"

    readonly property color accent: "#ff2d40"    // P5 crimson — alarm, only ever alarm
    readonly property color accentDim: "#a8121f"
    readonly property color accentSoft: "#ff6b78" // the "getting there" step below accent

    // Retired hues, kept as aliases so call sites keep working while resolving
    // into the two-hue system. Do not introduce new uses.
    readonly property color blue: root.primaryDim
    readonly property color ok: root.primary
    readonly property color warn: root.accentSoft

    // Chromatic aberration pair, straight off the wallpaper's RGB split.
    readonly property color splitRed: "#ff2b4d"
    readonly property color splitCyan: "#25e8ff"

    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Linear blend, t = 0 gives a, t = 1 gives b.
    function mix(a: color, b: color, t: real): color {
        const k = Math.max(0, Math.min(1, t));
        return Qt.rgba(a.r + (b.r - a.r) * k,
                       a.g + (b.g - a.g) * k,
                       a.b + (b.b - a.b) * k,
                       a.a + (b.a - a.a) * k);
    }

    // Heat ramp for load/usage readouts. Deliberately *not* a hue cycle: it sits
    // flat teal until load actually matters, then bleeds continuously into
    // crimson. A number that has gone red means the same thing everywhere.
    function heat(pct: real): color {
        if (pct <= 55) return root.primary;
        return root.mix(root.primary, root.accent, (pct - 55) / 45);
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

    // Right-hand status rail and the floating bottom-left dock.
    readonly property int railWidth: 48
    readonly property int railGap: 10
    readonly property int dockMargin: 14
    // Low enough that the cluster stops competing with whatever window is
    // underneath it — at 0.25 it just muddies text it happens to overlap. The
    // corner wedge stays fully opaque as the thing you aim at.
    readonly property real dockIdleOpacity: 0.13
    readonly property int dockRevealZone: 140   // px of screen bottom that wakes it

    // Horizontal offset per unit of height. tan(14deg) — every panel leans.
    readonly property real skew: 0.249
    readonly property int cut: 9          // corner chamfer, in px
    readonly property int stroke: 2

    // Pure-black keyline copy sitting behind every panel. This is what makes a
    // shape read as screen-printed rather than as a clipped rectangle.
    readonly property real dropOffset: 4
    readonly property real keylineWidth: 2

    readonly property int padS: 6
    readonly property int padM: 12
    readonly property int padL: 20
    readonly property int padXL: 32

    readonly property int popoutWidth: 380
    readonly property int popoutGap: 10

    // ------------------------------------------------------- shape variance
    // Persona geometry is never a repeating pattern, so modules pull their lean
    // and chamfer from these tables by index rather than sharing one default.
    // Deterministic, so the bar looks the same every launch.
    readonly property var leanTable: [0.32, 0.18, 0.26, 0.0, 0.29, 0.14, 0.35, 0.21]
    readonly property var chopTable: [12, 5, 18, 8, 14, 4, 10, 16]
    readonly property var cornerTable: [
        [1, 3], [0, 2], [1], [0, 2, 3], [3], [1, 3], [2], [0, 1, 3]
    ]

    function leanFor(i: int): real { return root.leanTable[i % root.leanTable.length]; }
    function chopFor(i: int): real { return root.chopTable[i % root.chopTable.length]; }
    function cornersFor(i: int): var { return root.cornerTable[i % root.cornerTable.length]; }

    // Every other module leans against its neighbour, so the row reads as
    // opposing diagonals instead of a comb.
    function leanLeftFor(i: int): bool { return i % 3 === 1; }

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
