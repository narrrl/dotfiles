-- Focus, layout and groups — everything that acts on the window under you.

local mod = "SUPER"

-- ------------------------------------------------------------------- window
-- Close takes SHIFT so it cannot happen by a slip.
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.close(), { description = "close window" })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen(), { description = "fullscreen" })
-- Maximize: fill the opening but keep the hull, the bar and the gaps.
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "maximize" })
hl.bind(mod .. " + V", hl.dsp.window.float(), { description = "float / tile" })

-- Float, and pin to every workspace: a video or a reference that follows you.
-- Pinning only works on floating windows, so float first. Again to unpin; the
-- window stays floating.
hl.bind(mod .. " + SHIFT + V", function()
    local win = hl.get_active_window()
    if not win then return end
    if not win.pinned and not win.floating then
        hl.dispatch(hl.dsp.window.float())
    end
    hl.dispatch(hl.dsp.window.pin())
end, { description = "float and pin to every workspace" })
-- hl.bind(mod .. " + t", hl.dsp.layout("togglesplit")) -- dwindle

-- -------------------------------------------------------------------- focus
local directions = { h = "l", l = "r", k = "u", j = "d" }

for key, direction in pairs(directions) do
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }), { description = "focus" })
    hl.bind(mod .. " + SHIFT + " .. key:upper(),
        hl.dsp.window.move({ direction = direction, group_aware = true }),
        { description = "move window" })
end

-- Resize from the keyboard, 40px a press, held to repeat.
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
hl.bind(mod .. " + G", hl.dsp.group.toggle(), { description = "group / ungroup" })
-- Alt+Tab belongs to the overview (lua/binds/shell.lua), so tabs in a group
-- cycle on Super+Tab.
hl.bind(mod .. " + Tab", hl.dsp.group.next(), { description = "next window in group" })
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.group.prev(), { description = "previous window in group" })

-- -------------------------------------------------------------------- mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
