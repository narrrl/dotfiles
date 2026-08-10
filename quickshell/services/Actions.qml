pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "root:/services"

// Shell-wide UI state and the handful of external commands the shell fires.
// Also exposes an IPC surface so Hyprland keybinds can drive the same actions
// (`qs ipc call shell lock`, `qs ipc call shell power`, ...).
Singleton {
    id: root

    // ------------------------------------------------------------- UI state
    property bool powerMenuOpen: false
    property bool lockRequested: false
    property bool sidebarOpen: false

    signal osdRequested(string kind)

    function togglePowerMenu() { root.powerMenuOpen = !root.powerMenuOpen; }
    function closePowerMenu() { root.powerMenuOpen = false; }
    function lock() { root.powerMenuOpen = false; root.lockRequested = true; }

    // ------------------------------------------------------------- commands
    // Each slot gets its own Process so a slow one cannot cancel another.
    Process { id: slotA }
    Process { id: slotB }
    Process { id: slotC }

    property int _slot: 0

    function run(argv: var) {
        const slots = [slotA, slotB, slotC];
        const p = slots[root._slot % slots.length];
        root._slot++;
        p.running = false;
        p.command = argv;
        p.running = true;
    }

    function launch(app: string) {
        root.run(["uwsm", "app", "--", app]);
    }

    // --------------------------------------------------------------- power
    function logout() { root.run(["uwsm", "stop"]); }
    function reboot() { root.run(["systemctl", "reboot"]); }
    function shutdown() { root.run(["systemctl", "poweroff"]); }
    function suspend() { root.lock(); root.run(["systemctl", "suspend"]); }
    function hibernate() { root.lock(); root.run(["systemctl", "hibernate"]); }
    function reloadShell() { Quickshell.reload(true); }

    // ------------------------------------------------------------- helpers
    function openAudioSettings() { root.launch("pavucontrol"); }
    function openSystemMonitor() { root.run(["alacritty", "-e", "btop"]); }
    function openNetworkSettings() { root.run(["nm-connection-editor"]); }
    function copyText(s: string) { root.run(["wl-copy", "--", s]); }

    IpcHandler {
        target: "shell"

        function lock(): void { root.lock(); }
        function power(): void { root.togglePowerMenu(); }
        function reloadConfig(): void { root.reloadShell(); }
        function toggleDnd(): void { Notifs.toggleDnd(); }
        function clearNotifications(): void { Notifs.clearAll(); }
    }
}
