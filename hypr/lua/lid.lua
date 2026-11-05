-- Laptop lid handling.
--
-- One rule, applied from several triggers:
--
--     panel off  <=>  lid is shut AND something else is plugged in
--
-- and one more for the hinge itself: shutting the lid with nothing else
-- plugged in suspends. logind is set to ignore the lid (HandleLidSwitch=ignore,
-- so docked lid-shut stays awake); this is what puts an undocked laptop to
-- sleep. The shell locks before any suspend (quickshell/services/Idle.qml).
--
-- Both halves are re-checked every time, so the session can never end up with
-- zero outputs. Undocking with the lid shut brings the panel back; booting
-- alone after a docked shutdown just works, because nothing about the previous
-- session is remembered.
--
-- That last part is the fix for the old design: scripts/lid_handler.sh wrote a
-- lid_state.conf that got sourced on the next start, so a laptop that was shut
-- while docked came up believing it still had an external display and blanked
-- its own panel. Lid state now comes from the kernel instead, and the external
-- check is a live one.

local monitors = require("lua/monitors")

-- ------------------------------------------------------------- reading state

-- The kernel's own view of the hinge. Present on this machine as
-- /proc/acpi/button/lid/LID/state; the device name differs per vendor, hence
-- the glob. Returns nil if the file is missing or unparseable.
local function acpi_lid_closed()
    local pipe = io.popen("cat /proc/acpi/button/lid/*/state 2>/dev/null")
    if not pipe then
        return nil
    end

    local out = pipe:read("a") or ""
    pipe:close()

    if out:find("closed", 1, true) then
        return true
    elseif out:find("open", 1, true) then
        return false
    end
    return nil
end

-- Whatever the last switch event said, used only when ACPI has nothing for us.
local last_switch_closed = nil

local function lid_closed()
    local acpi = acpi_lid_closed()
    if acpi ~= nil then
        return acpi
    end
    return last_switch_closed == true
end

-- ---------------------------------------------------------------- reconciling

local function count_externals(ignore)
    local n = 0
    for _, mon in ipairs(monitors.externals_present()) do
        if mon.name ~= ignore then
            n = n + 1
        end
    end
    return n
end

-- nil until the first decision, so the first pass always applies.
local panel_off = nil

-- `ignore` is the output being unplugged: during monitor.removed it can still
-- be listed, and counting it would keep the panel switched off.
local function reconcile(ignore)
    -- Nothing enumerated yet means we are still parsing the config on a cold
    -- start. Leave the defaults from lua/monitors.lua alone and wait for the
    -- start event.
    local all = hl.get_monitors()
    if #all == 0 then
        return
    end

    local externals = count_externals(ignore)

    local want_off = lid_closed() and externals > 0

    if want_off == panel_off then
        return
    end

    panel_off = want_off

    if want_off then
        monitors.disable_builtin()
    else
        monitors.enable_builtin()
    end
    monitors.apply_external()

    -- Quickshell follows monitor hotplug by itself, wallpaper included.
end

-- ------------------------------------------------------------------ triggers

hl.bind("switch:on:Lid Switch", function()
    last_switch_closed = true
    reconcile()
    if count_externals() == 0 then
        hl.exec_cmd("systemctl suspend")
    end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
    last_switch_closed = false
    reconcile()
end, { locked = true })

-- Docking and undocking. Removal passes the output that is going away.
hl.on("monitor.added", function()
    reconcile()
end)

hl.on("monitor.removed", function(mon)
    reconcile(mon and mon.name)
end)

-- Cold start: outputs are not up yet at this point, so this settles once they
-- are. On `hyprctl reload` the start event does not fire again, but the
-- monitor list is already populated, so run it inline too.
hl.on("hyprland.start", function()
    reconcile()
end)

reconcile()
