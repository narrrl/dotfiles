import QtQuick
import Quickshell
import "root:/config"
import "root:/services"
import "root:/bar"
import "root:/launcher"
import "root:/overlays"
import "root:/lock"

// Takemi — a Persona 5 flavoured Quickshell desktop.
//
//   bar/       the top bar and its modules
//   popouts/   hover panels hanging off bar modules
//   launcher/  the application launcher
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

    Lock {}
}
