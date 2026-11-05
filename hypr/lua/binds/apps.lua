-- Launching things.
-- https://wiki.hypr.land/Configuring/Basics/Binds/
--
-- How the keys are laid out, across every file in binds/:
--
--   SUPER + key          open or go to the thing the key names
--   SUPER + SHIFT + key  the same, but take the focused window along
--                        (or the bigger version of it)
--   SUPER + CTRL + key   switches for the session: lock, quiet, awake,
--                        mirror, layout, wallpaper, camera, reload
--   SUPER + ALT + hjkl   resize
--   PRINT                pictures; SHIFT to a file, CTRL without selecting,
--                        SUPER for video
--
-- ALT alone is left to the apps, except ALT+TAB. Letters resolve by symbol
-- (lua/input.lua), so they mean the same on Dvorak and QWERTY.

local apps = require("lua/apps")
local mod = "SUPER"

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(apps.terminal), { description = "terminal" })
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(apps.menu), { description = "app launcher" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(apps.fileManager), { description = "file explorer" })
hl.bind(mod .. " + R", hl.dsp.exec_cmd(apps.pdfs), { description = "read a pdf" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(apps.bluetooth), { description = "bluetooth menu" })
hl.bind(mod .. " + C", hl.dsp.exec_cmd(apps.clipboard), { description = "clipboard history" })
