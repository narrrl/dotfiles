-- Mocha palette — kept in step with ~/.config/quickshell/config/Theme.qml.
--
-- Catppuccin Mocha ground, blue accent, mauve alarm. Nothing else carries hue.
--
-- Returned as a table, so every module that paints something does
--   local c = require("lua/palette")
-- and there is exactly one place the colours are written.

local c = {}

-- ---------------------------------------------------------------- THE KNOBS
-- Two colours in this setup: blue for anything live (window borders, group
-- indicators, focus), mauve for anything wrong. Change these lines and every
-- painted edge recolours with them.
--
-- Keep them in step with `accent` / `alarm` in
-- ~/.config/quickshell/config/Theme.qml, which is what colours the shell.
-- Those are the only places the colours are written.
c.accent = "rgb(89b4fa)"
c.alarm = "rgb(cba6f7)"

c.accentDim = "rgb(5a7dc0)"
c.accentSoft = "rgb(b4befe)"

-- ------------------------------------------------------------------ neutrals
c.ink = "rgb(11111b)"

c.base = "rgb(1e1e2e)"
c.mantle = "rgb(181825)"
c.surface = "rgb(313244)"
c.surfaceAlt = "rgb(45475a)"
c.overlay = "rgb(585b70)"
c.outline = "rgb(6c7086)"

c.text = "rgb(cdd6f4)"
c.subtext = "rgb(a6adc8)"
c.muted = "rgb(7f849c)"

-- Semantic aliases, so existing references resolve without inventing hues.
c.primary = c.text
c.primaryDim = "rgb(9399b2)"
c.glow = c.accent
c.blue = c.accent
c.deep = c.surfaceAlt
c.warn = c.alarm
c.ok = c.text

-- Blue into lavender, on the diagonal. Both ends are the accent's own family,
-- so the border never reads as two colours arguing.
c.activeBorder = { colors = { c.accent, c.accentSoft }, angle = 135 }

return c
