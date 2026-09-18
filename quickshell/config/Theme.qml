pragma Singleton

import QtQuick
import Quickshell

// Mocha palette: Catppuccin Mocha ground, blue as the accent, pink as the
// alarm. Persona geometry, softer colour.
//
// The Takemi branch ran monochrome-plus-crimson, where one hue carried both
// "active" and "wrong". Mocha has room for two: blue is every resting accent —
// focus, selection, the thing you are pointing at — and pink is reserved for
// the things that bite, so destructive and error still read at a glance
// without a third colour entering the shell.
//
// Everything else is Mocha's own neutral ramp. Fills stay flat and keylines
// stay hard; only the hues moved.
Singleton {
    id: root

    // ---------------------------------------------------------------- colors
    // Crust, not pure black: it is the darkest thing in Mocha, so it keeps its
    // job as the hard keyline and as text punched out of an accent fill.
    readonly property color ink: "#11111b"

    readonly property color base: "#1e1e2e"
    readonly property color mantle: "#181825"
    readonly property color surface: "#313244"
    readonly property color surfaceAlt: "#45475a"
    readonly property color overlay: "#585b70"
    readonly property color outline: "#6c7086"

    readonly property color text: "#cdd6f4"
    readonly property color subtext: "#a6adc8"
    readonly property color muted: "#7f849c"

    // ------------------------------------------------------------ THE KNOBS
    // Two colours, two meanings, and nothing else in the shell carries hue.
    //
    // `accent` is blue: anything live, focused or selected. `alarm` is pink:
    // anything destructive or failed. Swap either line and everything derived
    // from it recolours.
    //
    // Keep them in step with `c.accent` / `c.alarm` in
    // ~/.config/hypr/lua/palette.lua, which is what colours the Hyprland
    // window borders. Those are the only places the colours are written.
    readonly property color accent: "#89b4fa"
    readonly property color alarm: "#f5c2e7"

    readonly property color accentDim: "#5a7dc0"
    readonly property color accentSoft: "#b4befe"

    // `primary` is the resting voice of the UI, which is now simply white.
    // Kept under the old name so the existing call sites don't all have to move.
    readonly property color primary: root.text
    readonly property color primaryDim: "#9399b2"
    readonly property color deep: root.surfaceAlt

    // `glow` is the hover highlight. Pointing at a thing lights it up blue —
    // the same signal as focus, because it is the same statement about where
    // your attention is.
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

    // Pink carries destructive/error meaning — never blue, so a dangerous
    // button can never be mistaken for a merely focused one.
    //
    // At rest it is a keyline and a label, not a fill: Mocha's pink is a
    // pastel, and a slab of it reads as a washed-out red rather than as a
    // warning. The solid pink is held back for the moment the pointer or the
    // selection is actually on the thing — then it lands, with crust punched
    // out of it at 11.8:1.
    readonly property color treatmentDestructiveFill: root.surface
    readonly property color treatmentDestructiveMark: root.alarm
    readonly property color treatmentDestructiveText: root.alarm

    readonly property color treatmentDestructiveActiveFill: root.alarm
    readonly property color treatmentDestructiveActiveMark: root.ink
    readonly property color treatmentDestructiveActiveText: root.ink
    readonly property color treatmentErrorFill: root.treatmentDestructiveActiveFill
    readonly property color treatmentErrorMark: root.treatmentDestructiveActiveMark
    readonly property color treatmentErrorText: root.treatmentDestructiveActiveText

    readonly property color treatmentUrgentFill: root.surface
    readonly property color treatmentUrgentMark: root.alarm
    readonly property color treatmentUrgentText: root.text

    readonly property color treatmentDisabledFill: root.surface
    readonly property color treatmentDisabledMark: root.outline
    readonly property color treatmentDisabledText: root.muted

    // Semantic aliases. Still only two hues: a thing is fine (text), live
    // (accent) or wrong (alarm). Nothing here introduces a third colour.
    readonly property color blue: root.accent
    readonly property color ok: root.text
    readonly property color warn: root.alarm

    // Display text carries a blue and a pink offset rather than an RGB split.
    // Same trick, this palette's two colours.
    readonly property color splitRed: root.accent
    readonly property color splitCyan: root.alarm

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

    // Load readouts sit at text until the number actually matters, then climb
    // through the accent before they reach the alarm. Going straight from text
    // to pink passes through a washed-out mid-tone that reads as a faded red
    // rather than as a rising number; routing through blue keeps every step of
    // the ramp a colour the shell already uses.
    function heat(pct: real): color {
        if (pct <= 45) return root.text;
        if (pct <= 75) return root.mix(root.text, root.accent, (pct - 45) / 30);
        return root.mix(root.accent, root.alarm, (pct - 75) / 25);
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
