-- Shell (quickshell) IPC. Config lives in ~/.config/quickshell.
-- The layout of the keys is described in lua/binds/apps.lua.

local mod = "SUPER"

local function shell(call, opts)
    hl.bind(opts.key, hl.dsp.exec_cmd("qs ipc call shell " .. call), { description = opts.description })
end

-- ------------------------------------------------------------------ panels
shell("dashboard", { key = mod .. " + D", description = "dashboard" })
shell("overview", { key = mod .. " + W", description = "overview of every window" })
shell("ask", { key = mod .. " + A", description = "ask claude" })
shell("notifications", { key = mod .. " + N", description = "notifications" })
shell("clearNotifications", { key = mod .. " + SHIFT + N", description = "clear notifications" })
shell("power", { key = mod .. " + P", description = "power menu" })

-- Launcher modes, opened straight in their prefix.
shell("prompt ';'", { key = mod .. " + period", description = "emoji picker" })
shell("prompt '?'", { key = mod .. " + slash", description = "keybind cheatsheet" })

-- Alt+Tab: hold Alt, tap Tab through focus history, let go to switch. The
-- overview sees the release itself; the release bind is a backstop for the
-- case where Alt comes up before the overview has the keyboard.
shell("overviewNext", { key = "ALT + Tab", description = "switch windows" })
shell("overviewPrev", { key = "ALT + SHIFT + Tab", description = "switch windows, backwards" })
hl.bind("ALT + ALT_L", hl.dsp.exec_cmd("qs ipc call shell overviewCommit"), { release = true })

-- ----------------------------------------------------------------- session
shell("lock", { key = mod .. " + CTRL + L", description = "lock screen" })
shell("toggleDnd", { key = mod .. " + CTRL + N", description = "do not disturb" })
shell("toggleStayAwake", { key = mod .. " + CTRL + I", description = "stay awake (no idle)" })
shell("prompt '@'", { key = mod .. " + CTRL + W", description = "wallpaper picker" })
shell("reloadConfig", { key = mod .. " + CTRL + R", description = "reload the shell" })

-- Not shell calls, but they live with the other session switches.
local mirror = require("lua/mirror")
hl.bind(mod .. " + CTRL + M", mirror.toggle, { description = "mirror the laptop to every screen" })

-- dvorak-intl <-> us-intl, see lua/input.lua
hl.bind(mod .. " + CTRL + SPACE", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"),
    { description = "next keyboard layout" })
