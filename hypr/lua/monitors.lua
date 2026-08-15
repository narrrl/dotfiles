-- https://wiki.hypr.land/Configuring/Basics/Monitors/
--
-- Declares every display once and exports the table, so lua/lid.lua can turn
-- the laptop panel on and off without duplicating any of these numbers.
--
-- Load-time behaviour is deliberately dumb: the built-in panel is always
-- enabled here. Deciding to switch it off needs to know whether anything else
-- is actually plugged in, and during a cold start the outputs are not
-- enumerated yet — so that decision lives in lua/lid.lua, which re-runs it on
-- every lid and hotplug event. Worst case the panel flickers on for a moment
-- while docked; the alternative failure is a black screen.

local M = {}

M.laptop = "eDP-1"

M.external = {
    -- samsung home monitor. Other modes it has run at, if you ever need them:
    -- "2560x1440@144", "1920x1080@144", "1280x720@240"
    { output = "desc:Samsung Electric Company LC27G7xT H4ZRA00734", mode = "2560x1440@240", position = "-2560x0", scale = 1 },
}

-- `disabled = false` is load-bearing, not decoration. hl.monitor() merges into
-- whatever rule the output already has, so a spec that simply omits the flag
-- leaves an earlier `disabled = true` in place: the panel stays dark and the
-- mode/position are applied to a monitor nobody can see. Opening the lid while
-- docked hit exactly that.
M.builtin = { output = M.laptop, mode = "1920x1080@60", position = "0x0", scale = 1, disabled = false }

-- Anything not declared above falls back to Hyprland's auto placement, so a
-- borrowed projector or a monitor at the office still lights up.

function M.apply_external()
    for _, mon in ipairs(M.external) do
        hl.monitor(mon)
    end
end

function M.enable_builtin()
    hl.monitor(M.builtin)
end

function M.disable_builtin()
    hl.monitor({ output = M.laptop, disabled = true })
end

-- Every connected output except the laptop panel. Empty during early startup,
-- which callers have to treat as "do not know yet", never as "nothing here".
function M.externals_present()
    local found = {}
    for _, mon in ipairs(hl.get_monitors()) do
        if mon.name ~= M.laptop then
            table.insert(found, mon)
        end
    end
    return found
end

M.enable_builtin()
M.apply_external()

return M
