-- YoRHa dark palette — kept in step with ~/.config/quickshell/config/Theme.qml.
--
-- The wallpaper's grey-green void for the ground, its planet light as the
-- accent, the hull's red indicator as the alarm. Nothing else carries hue.
--
-- Returned as a table, so every module that paints something does
--   local c = require("lua/palette")
-- and there is exactly one place the colours are written.

local c = {}

-- ---------------------------------------------------------------- THE KNOBS
-- Two colours in this setup: the planet light for anything live (window
-- borders, group indicators, focus), the hull red for anything wrong. Change these lines and every
-- painted edge recolours with them.
--
-- Keep them in step with `accent` / `alarm` in
-- ~/.config/quickshell/config/Theme.qml, which is what colours the shell.
-- Those are the only places the colours are written.
c.accent = "rgb(eef1ea)"
c.alarm = "rgb(c8684f)"

c.accentDim = "rgb(8e978d)"
c.accentSoft = "rgb(bcc1bf)"

-- ------------------------------------------------------------------ neutrals
c.ink = "rgb(090a08)"
-- Shadows are ink, not pure black: the same green-black the shell punches
-- text out of.
c.shadow = "rgba(090a08aa)"
c.shadowInactive = "rgba(090a0866)"

c.base = "rgb(0f110e)"
c.mantle = "rgb(0c0d0b)"
c.surface = "rgb(161915)"
c.surfaceAlt = "rgb(20241f)"
c.overlay = "rgb(383e35)"
c.outline = "rgb(545c52)"

c.text = "rgb(ccd2cb)"
c.subtext = "rgb(9fa7a2)"
c.muted = "rgb(79847a)"

-- Semantic aliases, so existing references resolve without inventing hues.
c.primary = c.text
c.primaryDim = "rgb(8e978d)"
c.glow = c.accent
c.blue = c.accent
c.deep = c.surfaceAlt
c.warn = c.alarm
c.ok = c.text

-- ----------------------------------------------------------- content hues
-- Not shell colours. The shell has the light and the red and nothing else;
-- these are for *content* — terminal ANSI, syntax, TUI meters, GTK
-- success/warning — where text needs more than one voice. All muted earth,
-- none brighter than the text grey, so content never outshouts the chrome.
-- Mirrored by hand in alacritty/yorha.toml, nvim/lua/yorha.lua,
-- btop/themes/yorha.theme, fish/conf.d/yorha_theme.fish, gtk-*/gtk.css and
-- zathura/yorha. Nothing in Hyprland reads them; they are written here so the
-- whole set lives next to the two knobs.
c.content = {
    faint = "rgb(464d44)", -- between overlay and outline: comments, TUI panels
    sand = "rgb(c9b27c)", sandBright = "rgb(d8c491)", -- warning, keywords
    moss = "rgb(8fa37e)", mossBright = "rgb(a5b893)", -- success, strings
    sky = "rgb(7f9aa8)", skyBright = "rgb(96afbc)", -- ANSI blue
    lichen = "rgb(86a8a0)", lichenBright = "rgb(9cbdb4)", -- ANSI cyan
    heather = "rgb(a48ba0)", heatherBright = "rgb(b8a0b4)", -- ANSI magenta
    alarmBright = "rgb(d98068)", -- ANSI bright red
}

-- The focused window is lit by the planet: full light at the top-left, the
-- suit's grey at the far corner. One family, so it reads as light falling
-- across the frame rather than as two colours.
c.activeBorder = { colors = { c.accent, c.accentDim }, angle = 135 }

return c
