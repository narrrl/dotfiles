-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--
-- Rules are evaluated top to bottom and the last match wins, so order matters.
-- Named rules are all evaluated before anonymous ones.

-- ==========================================
-- MATCHERS
-- ==========================================
-- Dialogs and utility apps that should float in the center
local DIALOG_TITLES = "^(Open Form|Open File|Select a File|Choose a file|Open Workspace|Choose Directory.*|Save As.*|Save File.*|branchdialog|pinentry-gtk-2|Confirm to replace files|File Operation Progress|Open Files.*|Anmelden.*|File Upload.*|TRuDI-Export laden)$"
-- pdfs-prompt is the Proton Drive search: io.narl.* is its GTK window, plain
-- pdfs-prompt the terminal `pdfs-prompt --fzf` spawns for itself. Every
-- terminal it knows how to start sets that same class, so this one rule holds
-- whichever is installed.
local DIALOG_CLASSES = "^(pavucontrol|blueman-manager|nm-connection-editor|org.pulseaudio.pavucontrol|io.narl.proton-drive-linux-prompt|pdfs-prompt)$"

local STEAM = "^(steam)$"
local GAMESCOPE = "^(gamescope)$"

-- ==========================================
-- GENERAL & FIXES
-- ==========================================
-- Ignore maximize requests from apps. You'll probably like this.
-- hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- Fix some dragging issues with XWayland
-- hl.window_rule({
--     match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
--     no_focus = true,
-- })
hl.window_rule({ match = { class = "^$", title = "^$" }, no_blur = true })

-- Hold idle off while any window is fullscreen. Players do not all ask for
-- that themselves (Brave goes through D-Bus, which nothing here listens to),
-- and the shell's dim and lock (quickshell/services/Idle.qml) respect inhibitors.
hl.window_rule({ match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- ==========================================
-- FLOATING & CENTERED DIALOGS
-- ==========================================
-- Float, size, center, no blur — one rule per matcher instead of four.
for _, match in ipairs({ { title = DIALOG_TITLES }, { class = DIALOG_CLASSES } }) do
    hl.window_rule({
        match = match,
        float = true,
        -- Sized for the 1440p panel; 800x600 left file pickers cramped.
        size = { 1100, 720 },
        center = true,
        no_blur = true,
    })
end

-- GTK file chooser by class, for the portal dialogs whose title is in the
-- user's language and so slips past DIALOG_TITLES.
hl.window_rule({
    match = { class = "^(xdg-desktop-portal-gtk)$" },
    float = true,
    size = { 1100, 720 },
    center = true,
})

-- The polkit password prompt: small, centred, on top of whatever asked.
hl.window_rule({
    match = { class = "^(hyprpolkitagent|org.hyprland.polkitagent)$" },
    float = true,
    center = true,
    pin = true,
})

-- Browser Picture-in-Picture: a small pinned float in the bottom-right corner
-- of the opening, keeping its aspect when resized.
hl.window_rule({
    match = { title = "^(Picture[- ]in[- ][Pp]icture)$" },
    float = true,
    pin = true,
    keep_aspect_ratio = true,
    size = { 640, 360 },
    move = "monitor_w-window_w-72 monitor_h-window_h-24",
})

-- ==========================================
-- WORKSPACE ASSIGNMENTS
-- ==========================================
-- hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "1" })
-- hl.window_rule({ match = { class = "^(kitty)$" },   workspace = "2" })
-- hl.window_rule({ match = { class = "^(Code)$" },    workspace = "3" })
hl.window_rule({ match = { class = GAMESCOPE }, workspace = "1" })

-- Special workspaces
hl.window_rule({ match = { class = "^(Spotify|spotify)$" }, workspace = "special:virtual" })

-- ==========================================
-- STEAM & GAMING
-- ==========================================
-- hl.window_rule({ match = { class = STEAM, title = "^(Steam)$" }, workspace = "3 silent" })

-- Fixed sizes for specific Steam windows
hl.window_rule({ match = { class = STEAM, title = "^(Friends List)$" }, size = { 400, 800 } })
hl.window_rule({ match = { class = STEAM, title = "^(Steam Settings)$" }, size = { 1000, 800 } })
hl.window_rule({ match = { class = STEAM, title = "^(Add Non-Steam Game)$" }, size = { 1000, 800 } })

-- Float and disable blur for Steam windows that aren't the main window
hl.window_rule({
    match = { class = STEAM, title = "negative:^(Steam)$" },
    float = true,
    no_blur = true,
    -- center = true,
})

-- Steam games run fullscreen. (steam_app_<id> is the class Proton and native
-- titles get.)
hl.window_rule({ match = { class = "^(steam_app_.*)$" }, fullscreen = true, idle_inhibit = "always" })

-- Allow tearing for games started with Gamescope (only takes effect if
-- general.allow_tearing is switched on in lua/look.lua).
hl.window_rule({ match = { class = GAMESCOPE }, immediate = true })
