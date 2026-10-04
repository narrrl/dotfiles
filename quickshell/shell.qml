import QtQuick
import Quickshell
import "root:/config"
import "root:/services"
import "root:/backdrop"
import "root:/bar"
import "root:/launcher"
import "root:/dashboard"
import "root:/ask"
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
