-- Persona × Mocha — Persona 5 shapes on the Catppuccin Mocha palette, matched
-- to ~/.config/quickshell.
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
            -- Surface-level, not outline: an idle window's frame is structure,
            -- and the outline grey was bright enough to compete with the
            -- focused border.
            inactive_border = c.surfaceAlt,
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

        -- A hard crust offset, the same printed drop the shell's panels
        -- carry, rather than a soft blur. Sharp with a 1px range leaves a
        -- clean band down the right and bottom edges only.
        shadow = {
            enabled = true,
            sharp = true,
            range = 1,
            offset = { 4, 4 },
            color = c.ink,
            color_inactive = c.ink,
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
