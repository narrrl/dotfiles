-- YoRHa dark — NieR:Automata's interface language on the space-1 wallpaper's
-- palette, matched to ~/.config/quickshell.
--
-- Everything static about how the desktop is painted. Motion lives next door
-- in lua/animations.lua.

local c = require("lua/palette")

hl.config({
    -- https://wiki.hypr.land/Configuring/Basics/Variables/
    general = {
        -- Measured from the quickshell hull's opening, not the screen edge: the
        -- hull reserves its own exclusive zones. 10px clears the opening's 18px
        -- corner radius, so a tiled window never touches the rim.
        gaps_in = 5,
        gaps_out = 10,

        border_size = 1,

        col = {
            active_border = c.activeBorder,
            -- Overlay, not outline: an idle window's frame is structure,
            -- and the outline grey was bright enough to compete with the
            -- focused border.
            inactive_border = c.overlay,
        },

        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
        -- before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- Concentric with the porthole: the opening's corners are 18px and
        -- the windows sit 10px inside them, so 8px keeps every gap the same
        -- width all the way round the curve. Matches Theme.frameRadius -
        -- gaps_out; change one and the other has to follow.
        rounding = 8,
        rounding_power = 2,

        -- Fully opaque, both states. Flat ink on flat ground.
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        -- A soft, wide shadow: windows float in the opening rather than
        -- being printed onto it. Dark against the planet light, invisible
        -- against the void, which is how a shadow behaves out there.
        shadow = {
            enabled = true,
            sharp = false,
            range = 24,
            render_power = 3,
            offset = { 0, 6 },
            color = "rgba(000000aa)",
            color_inactive = "rgba(00000066)",
        },

        -- Off. Every surface here is opaque, so there is nothing to blur, and
        -- blur would cost three render passes for no visible result.
        blur = {
            enabled = false,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        -- 0 = off, 1 = always, 2 = fullscreen only (G7 is a 240Hz VRR panel)
        vrr = 0,
        font_family = "JetBrainsMono Nerd Font",
        background_color = c.base,
        focus_on_activate = true,
        -- The shell powers displays down after idle (quickshell/services/Idle.qml)
        -- and back up when idle ends; these wake them even if it is not running.
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
    },

    group = {
        col = {
            border_active = c.activeBorder,
            border_inactive = c.overlay,
        },

        -- Tabs are thin rounded lines, not titled slabs. The bar already
        -- writes the focused title and its place in the group ("2/3", in
        -- quickshell/bar/ActiveWindow.qml), so titles here only repeated it in
        -- a second font. Hyprland paints a tab's indicator in the same colour
        -- as its fill, so with no fill the current tab is simply the light one.
        groupbar = {
            render_titles = false,
            gradients = false,

            indicator_height = 3,
            indicator_gap = 0,
            rounding = 2,
            round_only_edges = false,
            keep_upper_gap = false,
            gaps_in = 4,
            gaps_out = 0,

            col = {
                active = c.accent,
                inactive = c.overlay,
                locked_active = c.alarm,
                locked_inactive = c.overlay,
            },
        },
    },

    -- https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
    dwindle = {
        preserve_split = true,
    },

    -- https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
    master = {
        new_status = "master",
    },
})
