-- The programs the binds reach for. Exported so lua/binds/* name them once.

return {
    terminal = "alacritty",
    fileManager = "nautilus",
    menu = "fuzzel",

    -- clipboard history picker
    clipboard = "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy",

    -- pdf picker
    pdfs = "pdfs-prompt --dmenu --menu 'fuzzel --dmenu --width 60'",

    -- bluetooth menu
    bluetooth = "fluxo bt menu",
}
