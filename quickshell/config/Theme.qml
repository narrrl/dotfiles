pragma Singleton

import QtQuick
import Quickshell

// YoRHa dark: the NieR:Automata interface language, lit the way
// ~/.wallpapers/space-1.jpg is lit.
//
// NieR's menus are sand paper and graphite — monochrome, hairline rules,
// letter-spaced capitals, a small square marking where you are, and selection
// shown by inverting the row rather than by colouring it. That language is
// kept whole. The colours are not NieR's: the game's beige is a lit room, and
// this rice is the dark outside the porthole. The ground is the wallpaper's
// grey-green void, the text is the same sage grey the suit catches, and the
// one bright thing on screen is the planet's white — so focus and selection
// are a slab of that light with the void punched out of it.
//
// There is still no third colour. The only warm thing in the wallpaper is the
// tiny red of the hull's indicator lights, and that is what `alarm` is.
Singleton {
    id: root

    // ---------------------------------------------------------------- colors
    // Darker than the ground: text punched out of a light fill, and the
    // shadow under display text.
    readonly property color ink: "#090a08"

    // The void. Green-black rather than neutral so the shell and the
    // wallpaper read as one dark, not two.
    readonly property color base: "#0f110e"
    readonly property color mantle: "#0c0d0b"
    readonly property color surface: "#161915"
    readonly property color surfaceAlt: "#20241f"
    readonly property color overlay: "#383e35"

    // The hull the desktop is framed by. Darker than anything inside the
    // opening, so the frame reads as the inside of the ship and the windows as
    // what you are looking out at.
    readonly property color hull: root.mantle
    readonly property color rim: "#2a2f28"
    readonly property color outline: "#545c52"

    readonly property color text: "#ccd2cb"
    readonly property color subtext: "#9fa7a2"
    readonly property color muted: "#79847a"

    // ------------------------------------------------------------ THE KNOBS
    // Two colours, two meanings, and nothing else in the shell carries hue.
    //
    // `accent` is the planet light: anything live, focused or selected. It is
    // barely a colour at all, which is the point — NieR marks attention with
    // brightness and inversion, not with hue. `alarm` is the hull's red:
    // anything destructive, failed or critical. Things that are merely off —
    // muted, disabled, do-not-disturb — stay in the grey ramp; see the `Off`
    // treatment below.
    //
    // Keep them in step with `c.accent` / `c.alarm` in
    // ~/.config/hypr/lua/palette.lua, which is what colours the Hyprland
    // window borders. Those are the only places the colours are written.
    readonly property color accent: "#eef1ea"
    readonly property color alarm: "#c8684f"

    readonly property color accentDim: "#8e978d"
    readonly property color accentSoft: "#bcc1bf"

    // `primary` is the resting voice of the UI — the sage text grey. Kept under
    // the old name so the existing call sites don't all have to move.
    readonly property color primary: root.text
    readonly property color primaryDim: "#8e978d"
    readonly property color deep: root.surfaceAlt

    // `glow` is the hover highlight: pointing at a thing brightens it toward
    // the planet light, the same signal as focus at a lower volume.
    readonly property color glow: root.accent

    // ------------------------------------------------ semantic treatments
    // These tokens describe interaction meaning, not new palette entries. Each
    // state is composed only from ink, the grey ramp, the light and the red, so
    // callers do not invent one-off state colours.
    readonly property color treatmentRestFill: root.surface
    readonly property color treatmentRestMark: root.overlay
    readonly property color treatmentRestText: root.text

    // Hover lifts the surface a step and brings the marker up to full light.
    // It never inverts: inversion is the cursor, and the pointer resting on
    // something is not the same statement as the keyboard choosing it.
    readonly property color treatmentHoverFill: root.surfaceAlt
    readonly property color treatmentHoverMark: root.accent
    readonly property color treatmentHoverText: root.accent

    // Focus and selection are the NieR cursor: the row inverted, a slab of the
    // planet light with ink punched out of it.
    readonly property color treatmentFocusFill: root.accent
    readonly property color treatmentFocusMark: root.ink
    readonly property color treatmentFocusText: root.ink
    readonly property color treatmentSelectedFill: root.treatmentFocusFill
    readonly property color treatmentSelectedMark: root.treatmentFocusMark
    readonly property color treatmentSelectedText: root.treatmentFocusText

    readonly property color treatmentActiveFill: root.surfaceAlt
    readonly property color treatmentActiveMark: root.accent
    readonly property color treatmentActiveText: root.accent

    // Red carries destructive/error meaning — never the light, so a dangerous
    // button can never be mistaken for a merely focused one.
    //
    // At rest it is a hairline and a label, not a fill. The solid red is held
    // back for the moment the pointer or the selection is actually on the
    // thing, with ink punched out of it.
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
    readonly property color treatmentDisabledMark: root.overlay
    readonly property color treatmentDisabledText: root.muted

    // Off is a state the user chose — muted, do-not-disturb, radio switched
    // off. It is neither live nor wrong, so it sinks into the grey ramp.
    readonly property color treatmentOffFill: root.surface
    readonly property color treatmentOffMark: root.overlay
    readonly property color treatmentOffText: root.muted


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

    // Load readouts sit at text until the number actually matters, brighten
    // toward the light, and only then warm into the red. Every step of the ramp
    // is a colour the shell already uses.
    function heat(pct: real): color {
        if (pct <= 55) return root.text;
        if (pct <= 80) return root.mix(root.text, root.accent, (pct - 55) / 25);
        return root.mix(root.accent, root.alarm, (pct - 80) / 20);
    }

    // ----------------------------------------------------------------- fonts
    // NieR sets its UI in FOT-Rodin, a plain Japanese gothic, upright and
    // widely tracked. Noto Sans is the closest free face that is already on
    // the machine. Display text is never italic and never heavy; the wide
    // tracking is what makes it read as a heading.
    readonly property string fontDisplay: "Noto Sans"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"

    readonly property int weightDisplay: Font.Medium
    readonly property int weightBody: Font.Normal

    // Letter-spacing for uppercase labels and headings.
    readonly property real tracking: 2.5

    readonly property int fsMicro: 10
    readonly property int fsSmall: 11
    readonly property int fsBody: 12
    readonly property int fsLarge: 15
    readonly property int fsTitle: 20
    readonly property int fsHuge: 34
    readonly property int fsMega: 92

    readonly property int fsRailIcon: 17

    // -------------------------------------------------------------- geometry
    // The hull. The bar along the top, the rail down the right and a thin band
    // down the left and along the bottom are one continuous surface, and the
    // desktop is the rounded opening cut out of it — the porthole the
    // wallpaper is looking through. `frame` is the band's thickness where
    // there is no bar or rail, `frameRadius` the opening's corner.
    readonly property int barHeight: 40
    readonly property int railWidth: 48
    readonly property int frame: 8
    readonly property int frameRadius: 18

    // Nothing leans and nothing is chopped. Both knobs are kept so the shape
    // code still has one place to ask.
    readonly property real skew: 0
    readonly property int cut: 0
    readonly property int stroke: 1

    // No printed drop and no ink contour: on a dark ground they only thicken
    // the edge. The shadow under display text is the one offset left.
    readonly property real dropOffset: 0
    readonly property real keylineWidth: 0

    // Corners. Everything is soft — the porthole is the shape the whole
    // desktop is built around, and every smaller surface is a gentler echo of
    // it rather than a hard block.
    //
    //   radiusS  pills and small chips: buttons, tags, meter tracks
    //   radiusM  rows and panels inside a surface
    //   radiusL  anything that sits a padS inside the frame's own curve:
    //            frameRadius - padS, so its corner is concentric with the
    //            corner it sits in and the gap between them stays even
    readonly property int radiusS: 6
    readonly property int radiusM: 10
    readonly property int radiusL: frameRadius - padS

    // The dot that marks the current row, and the length of the corner
    // ticks a panel can still ask for.
    readonly property int marker: 6
    readonly property int tick: 8

    readonly property int padS: 6
    readonly property int padM: 12
    readonly property int padL: 20
    readonly property int padXL: 32

    readonly property int popoutWidth: 380
    readonly property int popoutGap: 10

    // ------------------------------------------------------------ animation
    // NieR motion is calm and mechanical: things glide in and settle, they
    // never bounce.
    readonly property int durFast: 120
    readonly property int durBase: 220
    readonly property int durSlow: 380
    readonly property int durLazy: 700

    readonly property var easeSnap: [0.22, 1.0, 0.36, 1.0, 1, 1]       // outQuint
    readonly property var easeGlide: [0.4, 0.0, 0.2, 1.0, 1, 1]        // standard
    readonly property var easeIn: [0.55, 0.0, 0.9, 0.35, 1, 1]

    // -------------------------------------------------------------- textures
    // A 1px dot every 8px, the ground NieR's menus are printed on.
    readonly property url texDots: "root:/assets/dots.png"

    // Last resort only, for when ~/.config/quickshell/wallpaper is empty or
    // missing. The live wallpaper comes from the Wallpaper singleton, which
    // the backdrop and the lock screen both read.
    readonly property url fallbackWallpaper: "file:///home/narl/.wallpapers/space-1.jpg"
}
