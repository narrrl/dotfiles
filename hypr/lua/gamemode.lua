-- Game mode: while a fullscreen game is on screen, neither the compositor nor
-- the shell spends anything on the desktop it covers.
--
--     on  <=>  some monitor shows a game, fullscreen, on its active workspace
--
-- Like lua/lid.lua, the answer is re-derived from live state on every trigger
-- and nothing is remembered, so a reload mid-game simply finds the game again.
--
-- A game is a window that says so through the content-type protocol
-- (gamescope does), or one whose class gives it away: Proton names every Steam
-- game steam_app_<id>. Add to GAME_CLASSES for anything else.
--
-- The shell is told through its IPC and pauses its own polling and animation
-- (quickshell/services/GameMode.qml).

-- Lua patterns, matched against the window class.
local GAME_CLASSES = {
    "^steam_app_%d+$",
    "^gamescope$",
}

-- What game mode sets. What it puts back is read from the config as loaded, so
-- lua/look.lua and lua/animations.lua stay the only place those are decided. A
-- reload resets every option before the config runs, so this never reads game
-- mode's own values back.
local GAME = {
    -- Nothing under a fullscreen window is worth animating, and leaving the
    -- game should be instant.
    ["animations.enabled"] = false,
    ["decoration.shadow.enabled"] = false,
    -- Hand the game's frames straight to the display instead of compositing
    -- them every refresh. Only while playing: with it on all the time, some
    -- ordinary fullscreen apps flicker or show the wrong colours.
    ["render.direct_scanout"] = 1,
}

local NORMAL = {}
for option in pairs(GAME) do
    NORMAL[option] = hl.get_config(option)
end

-- ------------------------------------------------------------- reading state

local function is_game(win)
    if win.content_type == "game" then
        return true
    end
    local class = win.class or ""
    for _, pattern in ipairs(GAME_CLASSES) do
        if class:match(pattern) then
            return true
        end
    end
    return false
end

-- `ignore` is a window being closed: during window.close it can still be
-- listed, and counting it would keep game mode on after the game has gone.
-- Fullscreen 2 is real fullscreen; a maximised game (1) still shows the hull.
local function playing(ignore)
    for _, win in ipairs(hl.get_windows()) do
        if win ~= ignore
            and win.mapped
            and win.fullscreen >= 2
            and win.monitor
            and win.monitor.active_workspace == win.workspace
            and is_game(win)
        then
            return true
        end
    end
    return false
end

-- ---------------------------------------------------------------- reconciling

-- A fresh config is the normal one, so only a game found at load needs
-- applying. The shell heard the last "false" before the reload.
local active = false

local function tell_shell()
    hl.exec_cmd("qs ipc call shell gameMode " .. tostring(active))
end

local function reconcile(ignore)
    local want = playing(ignore)
    if want == active then
        return
    end

    active = want
    hl.config(active and GAME or NORMAL)
    tell_shell()
end

-- ------------------------------------------------------------------ triggers

for _, event in ipairs({
    "window.open",
    "window.fullscreen",
    "window.move_to_workspace",
    -- Proton sets the class after the window opens.
    "window.class",
    "workspace.active",
    "monitor.removed",
}) do
    hl.on(event, function()
        reconcile()
    end)
end

hl.on("window.close", function(win)
    reconcile(win)
end)

-- A shell started mid-game (Super+Shift+R, or a crash) begins with game mode
-- off. Its bar mapping is the sign it is up and listening.
hl.on("layer.opened", function(layer)
    if active and layer.namespace == "takemi-bar" then
        tell_shell()
    end
end)

reconcile()
