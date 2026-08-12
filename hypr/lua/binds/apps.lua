-- Launching things.
-- https://wiki.hypr.land/Configuring/Basics/Binds/

local apps = require("lua/apps")
local mod = "SUPER" -- Sets "Windows" key as main modifier

hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(apps.terminal), { description = "terminal" })
hl.bind(mod .. " + E", hl.dsp.exec_cmd(apps.fileManager), { description = "file manager" })
hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd(apps.menu), { description = "app launcher" })
hl.bind(mod .. " + M", hl.dsp.exec_cmd(apps.pdfs), { description = "pdf picker" })
hl.bind(mod .. " + B", hl.dsp.exec_cmd(apps.bluetooth), { description = "bluetooth menu" })

-- Clipboard history. On release so the picker does not inherit the held ALT.
hl.bind("ALT + m", hl.dsp.exec_cmd(apps.clipboard), { release = true, description = "clipboard history" })
