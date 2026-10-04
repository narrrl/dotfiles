-- https://wiki.hypr.land/Configuring/Basics/Autostart/
--
-- Everything that used to be exec-once now runs off the start event.

hl.on("hyprland.start", function()
    -- Takemi shell — bar, popouts, notifications, OSD, power menu and lock
    -- screen. Config lives in ~/.config/quickshell. It owns
    -- org.freedesktop.Notifications, so dunst must stay masked
    -- (systemctl --user mask dunst.service).
    hl.exec_cmd("uwsm app -- qs")

    hl.exec_cmd("uwsm app -- nm-applet --indicator")
    -- hyprpaper is not started here: its systemd unit is enabled for
    -- graphical-session.target, and a second copy here ran alongside it.

    -- clipboard history, text and images
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- pdfs-prompt has no hidden/resident mode, so the first search of the
    -- session is cold. Run one throwaway query once the Proton Drive daemon
    -- is up to pull the binary into the page cache and warm the daemon's index.
    hl.exec_cmd("uwsm app -- pdfs-prompt --preload")

    -- hl.exec_cmd("uwsm app -- nextcloud --background")
    -- hl.exec_cmd("uwsm app -- rclone mount google_drive: ~/gdrive")
    -- hl.exec_cmd("uwsm app -- protonvpn-app")
    -- hl.exec_cmd("uwsm app -- /usr/bin/discord --enable-features=UseOzonePlatform --ozone-platform=wayland --start-minimized")
    -- hl.exec_cmd("uwsm app -- /usr/lib/xdg-desktop-portal-hyprland")
    -- hl.exec_cmd("sleep 5 && ~/.config/hypr/scripts/replay-ctrl.sh start")
end)
