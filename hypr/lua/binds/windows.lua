-- Focus, layout and groups — everything that acts on the window under you.

local mod = "SUPER"

-- ------------------------------------------------------------------- window
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen())
-- hl.bind(mod .. " + t", hl.dsp.layout("togglesplit")) -- dwindle

-- -------------------------------------------------------------------- focus
local directions = { h = "l", l = "r", k = "u", j = "d" }

for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mod .. " + SHIFT + " .. key:upper(), hl.dsp.window.move({ direction = direction, group_aware = true }))
end

-- ------------------------------------------------------------------- groups
hl.bind(mod .. " + n", hl.dsp.group.toggle())
hl.bind("ALT + Tab", hl.dsp.group.next())
-- hl.bind("ALT + Tab", hl.dsp.group.prev())

-- -------------------------------------------------------------------- mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ----------------------------------------------------------------- keyboard
-- cycle keyboard layout (dvorak-intl <-> us-intl), see lua/input.lua
hl.bind(mod .. " + ALT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
