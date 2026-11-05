-- The programs the binds reach for. Exported so lua/binds/* name them once.

return {
    terminal = "alacritty",
    fileManager = "nautilus",
    -- The launcher lives in the Quickshell process (quickshell/launcher/), so
    -- the bind toggles it over IPC instead of spawning anything. Nothing to
    -- start up means it is on screen on the same frame as the keypress.
    menu = "qs ipc call shell launcher",

    -- Clipboard history. Opens the launcher already in its ":" mode, which
    -- reads cliphist itself and copies the chosen entry back — so the picker is
    -- the same window, with the same keys, as everything else.
    clipboard = "qs ipc call shell prompt :",

    -- Proton Drive search. --fzf re-queries the daemon on every keystroke, so
    -- results appear as you type; a dmenu could only filter a list it was
    -- handed once, which made searching a two-step. It spawns its own terminal
    -- (class pdfs-prompt, floated in lua/rules/windows.lua).
    pdfs = "pdfs-prompt --gtk",

    -- bluetooth menu
    bluetooth = "fluxo bt menu",
}
