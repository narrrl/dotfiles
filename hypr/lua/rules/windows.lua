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

-- ==========================================
-- FLOATING & CENTERED DIALOGS
-- ==========================================
-- Float, size, center, no blur — one rule per matcher instead of four.
for _, match in ipairs({ { title = DIALOG_TITLES }, { class = DIALOG_CLASSES } }) do
    hl.window_rule({
        match = match,
        float = true,
        size = { 800, 600 },
        center = true,
        no_blur = true,
    })
end

-- ==========================================
-- WORKSPACE ASSIGNMENTS
-- ==========================================
-- hl.window_rule({ match = { class = "^(firefox)$" }, workspace = "1" })
-- hl.window_rule({ match = { class = "^(kitty)$" },   workspace = "2" })
-- hl.window_rule({ match = { class = "^(Code)$" },    workspace = "3" })
hl.window_rule({ match = { class = GAMESCOPE }, workspace = "1" })

-- Special workspaces
hl.window_rule({ match = { class = "^(Spotify|spotify)$" }, workspace = "special:virtual" })
hl.window_rule({ match = { class = "^(discord|vesktop)$" }, workspace = "special:discord" })

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

-- Allow tearing for games started with Gamescope
hl.window_rule({ match = { class = GAMESCOPE }, immediate = true })
