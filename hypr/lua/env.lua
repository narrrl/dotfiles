-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
--
-- Note: this session starts through uwsm, which would rather have these in
-- ~/.config/uwsm/env (toolkit, cursor, GPU) and ~/.config/uwsm/env-hyprland
-- (HYPR*, AQ_*). They are kept here for now so the config stays self-contained.

-- cursor
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "24")

-- session
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")

-- toolkits
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")

-- AMD graphics / video acceleration
hl.env("LIBVA_DRIVER_NAME", "radeonsi")
hl.env("VDPAU_DRIVER", "radeonsi")
hl.env("AMD_VULKAN_ICD", "RADV")

-- misc
hl.env("EDITOR", "nvim")

-- hl.env("INTEL_DEBUG", "noccs")
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- hl.env("debug:full_cm_proto", "true")


-- headroom

hl.env("HEADROOM_ROLLOUT_CHANNEL", "beta")

hl.env("HEADROOM_OUTPUT_SHAPER", "1")
