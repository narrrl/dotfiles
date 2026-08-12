-- Workspaces, including the two scratchpads.

local mod = "SUPER"

-- Switch with mod + [0-9], move the active window with mod + SHIFT + [0-9].
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through existing workspaces with mod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpads: S holds anything virtual, D holds chat.
local special = { S = "virtual", D = "discord" }

for key, name in pairs(special) do
    hl.bind(mod .. " + " .. key, hl.dsp.workspace.toggle_special(name))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = "special:" .. name }))
end
