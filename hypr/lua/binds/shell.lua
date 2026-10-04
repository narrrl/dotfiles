-- Takemi shell (quickshell) IPC. Config lives in ~/.config/quickshell.

local mod = "SUPER"

local function shell(call, opts)
    hl.bind(opts.key, hl.dsp.exec_cmd("qs ipc call shell " .. call), { description = opts.description })
end

shell("lock", { key = mod .. " + CTRL + L", description = "lock screen" })
shell("power", { key = mod .. " + P", description = "power menu" })
shell("ask", { key = mod .. " + A", description = "ask claude" })
shell("dashboard", { key = mod .. " + D", description = "dashboard" })
shell("overview", { key = mod .. " + W", description = "overview of every workspace" })

-- Alt+Tab: hold Alt, tap Tab through focus history, let go to switch. The
-- overview sees the release itself; the release bind is a backstop for the
-- case where Alt comes up before the overview has the keyboard.
shell("overviewNext", { key = "ALT + Tab", description = "switch windows" })
shell("overviewPrev", { key = "ALT + SHIFT + Tab", description = "switch windows, backwards" })
hl.bind("ALT + ALT_L", hl.dsp.exec_cmd("qs ipc call shell overviewCommit"), { release = true })
shell("toggleDnd", { key = mod .. " + SHIFT + N", description = "toggle do not disturb" })
shell("toggleStayAwake", { key = mod .. " + SHIFT + I", description = "keep the screen awake" })
shell("clearNotifications", { key = mod .. " + CTRL + SHIFT + N", description = "clear notifications" })
shell("reloadConfig", { key = mod .. " + SHIFT + R", description = "reload shell config" })

-- Not a shell call, but it lives with the other session toggles.
local mirror = require("lua/mirror")
hl.bind(mod .. " + SHIFT + P", mirror.toggle, { description = "mirror laptop to all screens" })
