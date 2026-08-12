-- Takemi — Persona 5 flavoured theme, matched to ~/.config/quickshell.
--
-- Everything static about how the desktop is painted. Motion lives next door
-- in lua/animations.lua.

local c = require("lua/palette")

hl.config({
    -- https://wiki.hypr.land/Configuring/Basics/Variables/
    general = {
        gaps_in = 5,
        gaps_out = { top = 6, right = 8, bottom = 8, left = 8 },

        border_size = 2,

        col = {
            active_border = c.activeBorder,
            inactive_border = c.outline,
        },

        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/
        -- before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        -- Persona 5 has no rounded corners. Neither do we.
        rounding = 0,

        -- Fully opaque, both states. Flat ink on flat ground.
        active_opacity = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled = true,
            range = 18,
            render_power = 3,
            offset = { 0, 4 },
            color = "rgba(000000ee)",
            color_inactive = "rgba(00000088)",
        },

        -- Off. Blur is the signature of the glass-and-frost look, which is the
        -- opposite of what this theme is doing — every surface here is opaque,
        -- flat and hard-edged. With nothing translucent left to blur it also
        -- costs three render passes for no visible result.
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
            border_inactive = c.outline,
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
