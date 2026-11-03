-- Focus, layout and groups — everything that acts on the window under you.

local mod = "SUPER"

-- ------------------------------------------------------------------- window
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen(), { description = "fullscreen" })
-- Maximize: fill the opening but keep the hull, the bar and the gaps.
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "maximize" })
-- Pin a floating window so it follows you across workspaces.
hl.bind(mod .. " + O", hl.dsp.window.pin(), { description = "pin window to every workspace" })
-- hl.bind(mod .. " + t", hl.dsp.layout("togglesplit")) -- dwindle

-- -------------------------------------------------------------------- focus
local directions = { h = "l", l = "r", k = "u", j = "d" }

for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
    hl.bind(mod .. " + SHIFT + " .. key:upper(), hl.dsp.window.move({ direction = direction, group_aware = true }))
end

-- Resize from the keyboard, 40px a press, held to repeat. (SUPER+CTRL+L is
-- the lock, so resize lives on ALT.)
local resize_step = {
    h = { x = -40, y = 0 }, l = { x = 40, y = 0 },
    k = { x = 0, y = -40 }, j = { x = 0, y = 40 },
}
for key, step in pairs(resize_step) do
    hl.bind(mod .. " + ALT + " .. key,
        hl.dsp.window.resize({ x = step.x, y = step.y, relative = true }),
        { repeating = true, description = "resize window" })
end

-- ------------------------------------------------------------------- groups
hl.bind(mod .. " + n", hl.dsp.group.toggle())
-- Alt+Tab belongs to the overview (lua/binds/shell.lua), so tabs in a group
-- cycle on Super+Tab.
hl.bind(mod .. " + Tab", hl.dsp.group.next(), { description = "next window in group" })
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.group.prev(), { description = "previous window in group" })

-- -------------------------------------------------------------------- mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ----------------------------------------------------------------- keyboard
-- cycle keyboard layout (dvorak-intl <-> us-intl), see lua/input.lua
hl.bind(mod .. " + ALT + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
