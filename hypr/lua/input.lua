-- https://wiki.hypr.land/Configuring/Basics/Variables/#input

hl.config({
    input = {
        -- index 0 = dvorak-intl (default), index 1 = us-intl
        -- switch with $mainMod ALT, SPACE (see lua/binds/windows.lua)
        kb_layout = "us,us",
        kb_variant = "dvorak-intl,intl",
        kb_model = "",
        kb_rules = "",
        kb_options = "caps:backspace",

        follow_mouse = 0,

        accel_profile = "flat",
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Three fingers sideways on the laptop's touchpad move between workspaces.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Layouts are inherited from the global input block so that layout switching
-- applies to these too. Only bind resolution differs here.
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
for _, name in ipairs({
    "at-translated-set-2-keyboard",
    "topre-corporation-hhkb-professional",
    "kbdfans-kbd67mkiirgbv3-keyboard",
}) do
    hl.device({ name = name, resolve_binds_by_sym = true })
end
