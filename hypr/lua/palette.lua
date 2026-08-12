-- Takemi palette — kept in step with ~/.config/quickshell/config/Theme.qml.
--
-- Crimson, black, white. Nothing else carries hue.
--
-- Returned as a table, so every module that paints something does
--   local c = require("lua/palette")
-- and there is exactly one place the colours are written.

local c = {}

-- ----------------------------------------------------------------- THE KNOB
-- The one colour in this setup. Change this line and the window borders,
-- group indicators and focus states all recolour with it.
--
-- Keep it in step with `readonly property color accent` in
-- ~/.config/quickshell/config/Theme.qml, which is what colours the shell.
-- Those are the only two places the colour is written.
c.accent = "rgb(ff2d40)"

c.accentDim = "rgb(8f1826)"
c.accentSoft = "rgb(ff6b78)"

-- ------------------------------------------------------------------ neutrals
c.ink = "rgb(000000)"

c.base = "rgb(0a0a0c)"
c.mantle = "rgb(0d0d10)"
c.surface = "rgb(141418)"
c.surfaceAlt = "rgb(1c1c22)"
c.overlay = "rgb(26262e)"
c.outline = "rgb(3a3a44)"

c.text = "rgb(ffffff)"
c.subtext = "rgb(c8c8ce)"
c.muted = "rgb(6b6b70)"

-- Retired hues, kept as aliases so existing references resolve. The shell has
-- no teal any more — the wallpaper is the colour in the composition.
c.primary = c.text
c.primaryDim = "rgb(9a9aa2)"
c.glow = c.accent
c.blue = c.primaryDim
c.deep = c.surfaceAlt
c.warn = c.accentSoft
c.ok = c.text

-- Crimson into its own shadow, on the diagonal. The accent is the only hue
-- here — a gradient into a second colour is what put blue in the border.
c.activeBorder = { colors = { c.accent, c.accentDim }, angle = 135 }

return c
