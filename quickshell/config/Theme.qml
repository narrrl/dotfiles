pragma Singleton

import QtQuick
import Quickshell

// Takemi palette: crimson, black, white. Nothing else.
//
// White does the work: text, icons, idle indicators. Crimson is the only accent
// and it always means the same thing — active, or wrong. Black is structure,
// used as a hard keyline rather than as a shadow. There are no gradients in
// this shell; every fill is flat.
//
// The wallpaper is teal. The UI used to be teal too, and the two fought each
// other into a murky blue-grey. Letting the UI go monochrome-plus-red is what
// lets the wallpaper read as the colour in the composition.
Singleton {
    id: root

    // ---------------------------------------------------------------- colors
    readonly property color ink: "#000000"

    readonly property color base: "#0a0a0c"
    readonly property color mantle: "#0d0d10"
    readonly property color surface: "#141418"
    readonly property color surfaceAlt: "#1c1c22"
    readonly property color overlay: "#26262e"
    readonly property color outline: "#3a3a44"

    readonly property color text: "#ffffff"
    readonly property color subtext: "#c8c8ce"
    readonly property color muted: "#6b6b70"

    // ------------------------------------------------------------ THE KNOB
    // The one colour in this shell. Change this line and the entire accent
    // recolours — everything below is derived from it, and nothing else in the
    // palette carries hue at all.
    //
    // Keep it in step with `$accent` at the top of
    // ~/.config/hypr/modules/takemi.conf, which is what colours the Hyprland
    // window borders. Those are the only two places the colour is written.
    readonly property color accent: "#ff2d40"

    readonly property color accentDim: Qt.darker(root.accent, 1.9)
    readonly property color accentSoft: Qt.lighter(root.accent, 1.35)

    // `primary` is the resting voice of the UI, which is now simply white.
    // Kept under the old name so the existing call sites don't all have to move.
    readonly property color primary: root.text
    readonly property color primaryDim: "#9a9aa2"
    readonly property color deep: root.surfaceAlt

    // `glow` is the hover highlight. It used to be a brighter teal, which now
    // that everything rests at white would have made hover invisible — so it
    // resolves to crimson. Pointing at a thing lights it up red.
    readonly property color glow: root.accent

    // ------------------------------------------------ semantic treatments
    // These tokens describe interaction meaning, not new palette entries. Each
    // state is composed only from Takemi's black, white, crimson, and neutral
    // surfaces so callers do not invent one-off state colors.
    readonly property color treatmentRestFill: root.surface
    readonly property color treatmentRestMark: root.outline
    readonly property color treatmentRestText: root.text

    readonly property color treatmentHoverFill: root.surface
    readonly property color treatmentHoverMark: root.accent
    readonly property color treatmentHoverText: root.text

    readonly property color treatmentFocusFill: root.text
    readonly property color treatmentFocusMark: root.ink
    readonly property color treatmentFocusText: root.ink
    readonly property color treatmentSelectedFill: root.treatmentFocusFill
    readonly property color treatmentSelectedMark: root.treatmentFocusMark
    readonly property color treatmentSelectedText: root.treatmentFocusText

    readonly property color treatmentActiveFill: root.surface
    readonly property color treatmentActiveMark: root.accent
    readonly property color treatmentActiveText: root.text

    // Crimson carries destructive/error meaning. Text and keylines stay black:
    // black-on-crimson is 5.70:1, while small white-on-crimson is only 3.68:1.
    readonly property color treatmentDestructiveFill: root.accent
    readonly property color treatmentDestructiveMark: root.ink
    readonly property color treatmentDestructiveText: root.ink
    readonly property color treatmentErrorFill: root.treatmentDestructiveFill
    readonly property color treatmentErrorMark: root.treatmentDestructiveMark
    readonly property color treatmentErrorText: root.treatmentDestructiveText

    readonly property color treatmentUrgentFill: root.surface
    readonly property color treatmentUrgentMark: root.accent
    readonly property color treatmentUrgentText: root.text

    readonly property color treatmentDisabledFill: root.surface
    readonly property color treatmentDisabledMark: root.outline
    readonly property color treatmentDisabledText: root.muted

    // Retired hues. Aliases only — do not introduce new uses.
    //
    // `warn` used to be accentSoft, which put a washed-out pink-red on screen
    // wherever something was merely notable. That reads as a faded accent, not
    // as a decision. There is no half-crimson in this palette: a thing is wrong
    // (accent) or it is not (text). `warn` now resolves to the real accent, so
    // low battery shouts properly and everything merely informational is white.
    readonly property color blue: root.primaryDim
    readonly property color ok: root.text
    readonly property color warn: root.accent

    // Display text carries a crimson and a black offset rather than an RGB
    // split. Same trick, correct palette.
    readonly property color splitRed: root.accent
    readonly property color splitCyan: root.ink

    function alpha(c: color, a: real): color {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function mix(a: color, b: color, t: real): color {
        const k = Math.max(0, Math.min(1, t));
        return Qt.rgba(a.r + (b.r - a.r) * k,
                       a.g + (b.g - a.g) * k,
                       a.b + (b.b - a.b) * k,
                       a.a + (b.a - a.a) * k);
    }

    // Load readouts sit white until the number actually matters, then bleed to
    // crimson. Not a hue cycle — red always means the same thing.
    function heat(pct: real): color {
        if (pct <= 55) return root.text;
        return root.mix(root.text, root.accent, (pct - 55) / 45);
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

    // The right-hand rail uses the same lean and chamfer as the bar — a
    // vertical panel leans its horizontal edges by a fraction of its width,
    // which works out to the same 14 degrees.
    readonly property int railWidth: 48

    // ONE angle, everywhere. tan(14deg). Persona geometry is disciplined, not
    // random: every edge in the shell leans by exactly this much in exactly the
    // same direction, and every corner is chopped by exactly `cut`. Varying
    // these per module reads as noise, not as style.
    readonly property real skew: 0.249
    readonly property int cut: 10
    readonly property int stroke: 2

    // Pure-black keyline and offset copy behind panels. This is the one piece of
    // layering the style needs; it is not a soft shadow and never blurs.
    readonly property real dropOffset: 3
    readonly property real keylineWidth: 2

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

    // Last resort only. The live wallpaper comes from the Wallpaper singleton,
    // which asks hyprpaper what is actually on screen — a path written down
    // here goes stale the moment the wallpaper is switched, which is exactly
    // what happened to the lock screen.
    readonly property url fallbackWallpaper: "file:///home/narl/.wallpapers/takemi_1.jpg"
}
