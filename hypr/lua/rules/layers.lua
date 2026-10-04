-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
--
-- Quickshell surfaces: the bar, popouts, the OSD and the launcher. Note
-- decoration.blur is off in lua/look.lua, so these only take effect if blur is
-- switched back on.

for _, namespace in ipairs({ "bottom", "top", "takemi-launcher" }) do
    hl.layer_rule({
        match = { namespace = namespace },
        blur = true,
        ignore_alpha = 0.5,
    })
end

-- The hull shares the top layer with the bar and the rail, which draw on it,
-- so they are ordered above it whatever order they map in. See
-- quickshell/bar/Frame.qml.
for _, namespace in ipairs({ "takemi-bar", "takemi-rail" }) do
    hl.layer_rule({
        match = { namespace = namespace },
        order = -1,
    })
end
