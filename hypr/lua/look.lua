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
        -- NieR panels are plain rectangles. The only curve on screen is the
        -- porthole the quickshell hull cuts round the desktop.
        rounding = 0,

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
        font_family = "FiraCode Nerd Font",
        background_color = c.base,
        focus_on_activate = true,
    },

    group = {
        col = {
            border_active = c.activeBorder,
            border_inactive = c.surfaceAlt,
        },

        groupbar = {
            font_family = "JetBrainsMono Nerd Font",
            font_size = 11,

            height = 24,
            gradients = false,

            -- --- Active tab ---
            col = {
                active = c.accent,
                inactive = c.surface,
            },
            text_color = c.ink,

            -- --- Inactive tab ---
            text_color_inactive = c.muted,

            indicator_height = 3,
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
