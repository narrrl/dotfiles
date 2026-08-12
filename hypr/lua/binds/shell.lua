-- Takemi shell (quickshell) IPC. Config lives in ~/.config/quickshell.

local mod = "SUPER"

local function shell(call, opts)
    hl.bind(opts.key, hl.dsp.exec_cmd("qs ipc call shell " .. call), { description = opts.description })
end

shell("lock", { key = mod .. " + CTRL + L", description = "lock screen" })
shell("power", { key = mod .. " + P", description = "power menu" })
shell("toggleDnd", { key = mod .. " + SHIFT + N", description = "toggle do not disturb" })
shell("clearNotifications", { key = mod .. " + CTRL + SHIFT + N", description = "clear notifications" })
shell("reloadConfig", { key = mod .. " + SHIFT + R", description = "reload shell config" })
