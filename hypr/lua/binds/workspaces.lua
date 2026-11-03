-- Workspaces, including the scratchpad.

local mod = "SUPER"

-- Switch with mod + [0-9], move the active window with mod + SHIFT + [0-9].
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "workspace" })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),
        { description = "move window to workspace" })
end

-- Scroll through existing workspaces with mod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: S holds anything virtual. Chat opens wherever it is launched.
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("virtual"), { description = "scratchpad" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:virtual" }),
    { description = "send window to scratchpad" })
