-- Presentation mode: every external output shows the laptop panel.
--
-- Toggled from lua/binds/shell.lua. Mirroring is just a `mirror` field on the
-- monitor rule, so switching it off clears that field and re-applies the specs
-- from lua/monitors.lua to put the Samsung back where it belongs.
--
-- Anything plugged in while mirroring is on gets mirrored too, which is the
-- usual order at a talk: press the key, then find the HDMI cable.

local monitors = require("lua/monitors")

local M = {}

local function notify(text)
    hl.notification.create({ text = text, timeout = 3000 })
end

-- The panel is off while docked with the lid shut, see lua/lid.lua. Mirroring
-- a disabled output would leave every screen black.
local function builtin()
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.name == monitors.laptop then
            return mon
        end
    end
    return nil
end

-- A mirroring output drops out of hl.get_monitors(), so the only place left
-- to find it is the panel's own `mirrors` list. That list is also the state:
-- a Lua flag would reset on every config reload while the outputs stay
-- mirrored.
local function mirroring(panel)
    local names = {}
    for _, mon in ipairs(panel and panel.mirrors or {}) do
        table.insert(names, mon.name)
    end
    return names
end

-- Outputs keep their own mode while mirroring, and the panel image gets
-- rescaled to fit it every frame. The Dells at 1920x1200 flicker with that,
-- so match the panel's resolution; Hyprland falls back to the preferred mode
-- if the output cannot do it.
local function mirror_all(panel)
    local mode = panel.width .. "x" .. panel.height
    for _, mon in ipairs(monitors.externals_present()) do
        hl.monitor({ output = mon.name, mirror = monitors.laptop, mode = mode, position = "auto" })
    end
end

-- The bar, popouts and wallpaper stay on the outputs they were created for,
-- so respawn the shell the same way lua/autostart.lua starts it.
local function restart_clients()
    hl.exec_cmd("sh -c 'qs kill; exec uwsm app -- qs'")
end

-- hl.monitor() only takes effect after the calling handler returns, so
-- anything that has to see the new layout goes on a timer.
local function later(fn)
    hl.timer(fn, { timeout = 500, type = "oneshot" })
end

-- Clearing `mirror` alone brings the image back, but Hyprland never
-- re-announces the output to clients: Quickshell keeps seeing
-- only the panel, however often they restart. Cycling the output through
-- disabled makes it a fresh wl_output. Undeclared outputs get their auto
-- defaults back, apply_external() then overrides what lua/monitors.lua knows
-- better.
local function unmirror_all(names)
    for _, name in ipairs(names) do
        hl.monitor({ output = name, mirror = "", disabled = true })
    end
    later(function()
        for _, name in ipairs(names) do
            hl.monitor({ output = name, disabled = false, mode = "preferred", position = "auto" })
        end
        monitors.apply_external()
        later(restart_clients)
    end)
end

function M.toggle()
    local panel = builtin()
    local mirrored = mirroring(panel)

    if #mirrored > 0 then
        unmirror_all(mirrored)
        notify("Mirroring off")
    elseif panel then
        mirror_all(panel)
        later(restart_clients)
        notify("Mirroring " .. monitors.laptop .. " to all screens")
    else
        notify("Laptop panel is off, open the lid first")
    end
end

hl.on("monitor.added", function()
    local panel = builtin()
    if #mirroring(panel) > 0 then
        mirror_all(panel)
    end
end)

return M
