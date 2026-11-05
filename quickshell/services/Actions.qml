pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "root:/services"

// Shell-wide UI state and the handful of external commands the shell fires.
// Also exposes an IPC surface so Hyprland keybinds can drive the same actions
// (`qs ipc call shell lock`, `qs ipc call shell power`, ...).
Singleton {
    id: root

    // ------------------------------------------------------------- UI state
    property bool powerMenuOpen: false
    property bool lockRequested: false
    property bool launcherOpen: false
    property bool askOpen: false
    property bool dashboardOpen: false
    property bool overviewOpen: false
    // Opened by Alt+Tab, so letting go of Alt picks the window.
    property bool overviewHold: false

    // Seed text for the next launcher open. Lets a keybind or a script hand the
    // launcher a query it did not have to type — `qs ipc call shell prompt
    // "https://…"` is an open-with dialog for anything that can run a command.
    property string launcherSeed: ""

    // A launcher window exists on every screen, but only one of them is being
    // typed at. Latch the focused monitor at open time so the window appears
    // there alone — latched rather than live, because the launcher itself takes
    // keyboard focus and because a window should not hop mid-query.
    property string launcherScreen: ""

    // Same story for the power menu: a window per screen, one of them wanted.
    property string powerMenuScreen: ""

    // …and for the ask panel, which also takes the keyboard.
    property string askScreen: ""

    // …and for the dashboard drawer.
    property string dashboardScreen: ""

    // …and for the overview.
    property string overviewScreen: ""

    // When the dashboard was last closed from outside. A click on the bar's
    // clock first clears the drawer's focus grab, which closes it, and then
    // lands on the clock, which would toggle it straight back open. A toggle
    // that arrives within a moment of a grab-close is that same click.
    property real dashboardClosedAt: 0

    // Seed text for the next ask open. A seeded open asks straight away, so
    // `qs ipc call shell askAbout "$(wl-paste)"` is a one-shot question.
    property string askSeed: ""

    signal overviewStepped(int delta)
    signal overviewCommitted()
    // The bell's log, on the focused monitor's rail (SUPER+N).
    signal notificationsRequested()

    function togglePowerMenu() {
        if (!root.powerMenuOpen)
            root.powerMenuScreen = root.focusedScreenName();
        root.powerMenuOpen = !root.powerMenuOpen;
    }
    function closePowerMenu() { root.powerMenuOpen = false; }
    function lock() { root.powerMenuOpen = false; root.lockRequested = true; }

    function focusedScreenName(): string {
        return Hyprland.focusedMonitor?.name
            ?? Quickshell.screens[0]?.name
            ?? "";
    }

    function toggleLauncher() {
        if (!root.launcherOpen) {
            root.launcherSeed = "";
            root.launcherScreen = root.focusedScreenName();
        }
        root.launcherOpen = !root.launcherOpen;
    }
    function closeLauncher() { root.launcherOpen = false; }

    function toggleDashboard() {
        if (!root.dashboardOpen && Date.now() - root.dashboardClosedAt < 250)
            return;
        if (!root.dashboardOpen)
            root.dashboardScreen = root.focusedScreenName();
        root.dashboardOpen = !root.dashboardOpen;
    }
    function closeDashboard() {
        if (!root.dashboardOpen) return;
        root.dashboardOpen = false;
        root.dashboardClosedAt = Date.now();
    }

    function toggleOverview() {
        if (!root.overviewOpen) {
            root.overviewHold = false;
            root.overviewScreen = root.focusedScreenName();
        }
        root.overviewOpen = !root.overviewOpen;
    }
    function closeOverview() { root.overviewOpen = false; }

    // Alt+Tab and Alt+Shift+Tab. The first press opens the overview with the
    // previous window picked; Hyprland keeps the bind while it is open, so
    // later presses arrive here too and walk the focus history.
    function overviewStep(delta: int) {
        if (!root.overviewOpen) {
            root.overviewHold = true;
            root.overviewScreen = root.focusedScreenName();
            root.overviewOpen = true;
            if (delta < 0) root.overviewStepped(-2);
            return;
        }
        root.overviewStepped(delta);
    }

    function toggleAsk() {
        if (!root.askOpen) {
            root.askSeed = "";
            root.askScreen = root.focusedScreenName();
        }
        root.askOpen = !root.askOpen;
    }
    function closeAsk() { root.askOpen = false; }

    function askAbout(seed: string) {
        root.askSeed = seed;
        root.askScreen = root.focusedScreenName();
        root.askOpen = false;
        root.askOpen = true;
    }

    // Stand in for `fuzzel --dmenu`. See Apps.beginDmenu for the transport.
    function dmenuLauncher(inPath: string, outPath: string, prompt: string) {
        Apps.beginDmenu(inPath, outPath, prompt);
        root.launcherSeed = "";
        root.launcherScreen = root.focusedScreenName();
        root.launcherOpen = false;
        root.launcherOpen = true;
    }

    function promptLauncher(seed: string) {
        root.launcherSeed = seed;
        root.launcherScreen = root.focusedScreenName();
        root.launcherOpen = false;
        root.launcherOpen = true;
    }

    // ------------------------------------------------------------- commands
    // Detached, because nothing here is ever read back. Rotating a fixed set of
    // `Process` slots only moves the collision: `uwsm app` lives as long as the
    // app it started, so the fourth launch reclaims the first slot and kills the
    // app still holding it — and a shell reload kills every one of them at once.
    function run(argv: var) {
        Quickshell.execDetached(argv);
    }

    function launch(app: string) {
        root.run(["uwsm", "app", "--", app]);
    }

    // --------------------------------------------------------------- power
    function logout() { root.run(["uwsm", "stop"]); }
    function reboot() { root.run(["systemctl", "reboot"]); }
    function shutdown() { root.run(["systemctl", "poweroff"]); }
    function suspend() { root.sleep(["systemctl", "suspend"]); }
    function hibernate() { root.sleep(["systemctl", "hibernate"]); }

    // Set by lock/Lock.qml once the compositor has the lock surfaces up.
    property bool lockSecure: false
    // A sleep waiting for the lock. Suspending first would leave the desktop
    // on screen for a moment on wake, before the lock had drawn.
    property var pendingSleep: null

    function sleep(argv: var) {
        root.lock();
        if (root.lockSecure) {
            root.run(argv);
            return;
        }
        root.pendingSleep = argv;
        sleepFallback.restart();
    }

    function _sleepNow() {
        if (!root.pendingSleep) return;
        const argv = root.pendingSleep;
        root.pendingSleep = null;
        sleepFallback.stop();
        root.run(argv);
    }

    onLockSecureChanged: if (root.lockSecure) root._sleepNow()

    // A lock that never comes up must not keep the machine awake on battery.
    Timer {
        id: sleepFallback
        interval: 3000
        onTriggered: root._sleepNow()
    }
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
        function ask(): void { root.toggleAsk(); }
        function dashboard(): void { root.toggleDashboard(); }
        function askAbout(question: string): void { root.askAbout(question); }
        function prompt(seed: string): void { root.promptLauncher(seed); }
        function dmenu(inPath: string, outPath: string, prompt: string): void {
            root.dmenuLauncher(inPath, outPath, prompt);
        }
        function reloadConfig(): void { root.reloadShell(); }
        function toggleDnd(): void { Notifs.toggleDnd(); }
        function clearNotifications(): void { Notifs.clearAll(); }
        function notifications(): void { root.notificationsRequested(); }
        function toggleStayAwake(): void { Idle.toggleStayAwake(); }
        function gameMode(on: bool): void { GameMode.active = on; }
        function overview(): void { root.toggleOverview(); }
        function overviewNext(): void { root.overviewStep(1); }
        function overviewPrev(): void { root.overviewStep(-1); }
        function overviewCommit(): void { if (root.overviewHold) root.overviewCommitted(); }
        function wallpaper(path: string): void { Wallpaper.set(path); }
        // Steps whichever screen is lit: the panel's backlight or the
        // external monitor over DDC (services/Brightness.qml).
        function brightness(delta: int): void { Brightness.change(delta); }
    }
}
