// The Samsung on DP-1 drops off the bus when its display powers down, so DPMS
// off (services/Idle.qml) removes an output under every window on it. With
// Qt's threaded render loop the render thread can still be swapping a surface
// the GUI thread just destroyed, which segfaults in Mesa and takes the lock
// screen down with it. The basic loop renders on the GUI thread, so it cannot.
//@ pragma Env QSG_RENDER_LOOP=basic

import QtQuick
import Quickshell
import "root:/config"
import "root:/services"
import "root:/backdrop"
import "root:/bar"
import "root:/launcher"
import "root:/dashboard"
import "root:/ask"
import "root:/overview"
import "root:/overlays"
import "root:/lock"

// Takemi — a YoRHa-dark Quickshell desktop: NieR:Automata's interface
// language, lit like the wallpaper.
//
//   backdrop/  the wallpaper, drifting with the workspace
//   bar/       the hull, the top bar, the rail and their modules
//   popouts/   hover panels hanging off bar modules
//   launcher/  the application launcher
//   dashboard/ the drawer that drops from the bar
//   overview/  every monitor, workspace and window at once (Alt+Tab)
//   ask/       the question panel, dropped from the top edge
//   overlays/  power menu, notification toasts, OSD
//   lock/      session lock
//   services/  data sources (fluxo, pipewire, bluez, upower, mpris, …)
//   config/    palette, type, geometry, motion
ShellRoot {
    // Services are lazily constructed on first use. The shell wants several of
    // them warm from the start — polling, the notification server, the audio
    // OSD — so touch them here rather than waiting for a hover.
    Component.onCompleted: {
        void Sys.cpuUsage;
        void Audio.ready;
        void Battery.available;
        void Brightness.percent;
        void Notifs.count;
        void Media.hasPlayer;
        void Net.wifiEnabled;
        void Bt.available;
        void Actions.powerMenuOpen;
        void Apps.index;
        void Idle.stayAwake;
        void Wallpaper.path;
    }

    Variants {
        model: Quickshell.screens

        Backdrop {}
    }

    Variants {
        model: Quickshell.screens

        Frame {}
    }

    Variants {
        model: Quickshell.screens

        Bar {}
    }

    Variants {
        model: Quickshell.screens

        Rail {}
    }

    Variants {
        model: Quickshell.screens

        Launcher {}
    }

    Variants {
        model: Quickshell.screens

        Dashboard {}
    }

    Variants {
        model: Quickshell.screens

        AskPanel {}
    }

    Variants {
        model: Quickshell.screens

        Overview {}
    }

    Variants {
        model: Quickshell.screens

        PowerMenu {}
    }

    Variants {
        model: Quickshell.screens

        Toasts {}
    }

    Variants {
        model: Quickshell.screens

        Osd {}
    }

    Variants {
        model: Quickshell.screens

        IdleDim {}
    }

    Lock {}
}
