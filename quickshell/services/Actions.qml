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
    property bool launcherOpen: false

    // Seed text for the next launcher open. Lets a keybind or a script hand the
    // launcher a query it did not have to type — `qs ipc call shell prompt
    // "https://…"` is an open-with dialog for anything that can run a command.
    property string launcherSeed: ""

    signal osdRequested(string kind)

    function togglePowerMenu() { root.powerMenuOpen = !root.powerMenuOpen; }
    function closePowerMenu() { root.powerMenuOpen = false; }
    function lock() { root.powerMenuOpen = false; root.lockRequested = true; }

    function toggleLauncher() {
        if (!root.launcherOpen) root.launcherSeed = "";
        root.launcherOpen = !root.launcherOpen;
    }
    function closeLauncher() { root.launcherOpen = false; }

    // Stand in for `fuzzel --dmenu`. See Apps.beginDmenu for the transport.
    function dmenuLauncher(inPath: string, outPath: string, prompt: string) {
        Apps.beginDmenu(inPath, outPath, prompt);
        root.launcherSeed = "";
        root.launcherOpen = false;
        root.launcherOpen = true;
    }

    function promptLauncher(seed: string) {
        root.launcherSeed = seed;
        root.launcherOpen = false;
        root.launcherOpen = true;
    }

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
        function launcher(): void { root.toggleLauncher(); }
        function prompt(seed: string): void { root.promptLauncher(seed); }
        function dmenu(inPath: string, outPath: string, prompt: string): void {
            root.dmenuLauncher(inPath, outPath, prompt);
        }
        function reloadConfig(): void { root.reloadShell(); }
        function toggleDnd(): void { Notifs.toggleDnd(); }
        function clearNotifications(): void { Notifs.clearAll(); }
    }
}
