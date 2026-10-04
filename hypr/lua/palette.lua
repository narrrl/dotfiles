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

-- The focused window is lit by the planet: full light at the top-left, the
-- suit's grey at the far corner. One family, so it reads as light falling
-- across the frame rather than as two colours.
c.activeBorder = { colors = { c.accent, c.accentDim }, angle = 135 }

return c
