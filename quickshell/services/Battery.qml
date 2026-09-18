pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "root:/config"
import "root:/services"

// Battery and power-profile state. UPower gives live percentage and time
// estimates; Sys.powerDetail adds the TLP/AC line fluxo reports.
Singleton {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool available: device !== null && device.isLaptopBattery && device.isPresent
    readonly property bool onBattery: UPower.onBattery

    readonly property real percent: device?.percentage !== undefined ? device.percentage * 100 : 0
    readonly property int state: device?.state ?? UPowerDeviceState.Unknown

    readonly property bool charging: state === UPowerDeviceState.Charging
        || state === UPowerDeviceState.PendingCharge
    readonly property bool full: state === UPowerDeviceState.FullyCharged

    readonly property real changeRate: device?.changeRate ?? 0     // watts
    readonly property real health: device?.healthSupported ? (device?.healthPercentage ?? 0) : 0

    readonly property bool low: available && !charging && percent <= 20
    readonly property bool critical: available && !charging && percent <= 10

    readonly property real secondsLeft: charging
        ? (device?.timeToFull ?? 0)
        : (device?.timeToEmpty ?? 0)

    readonly property string timeLabel: {
        if (root.full) return "Full";
        if (!(root.secondsLeft > 0)) return charging ? "Charging" : "Estimating…";
        const mins = Math.round(root.secondsLeft / 60);
        const h = Math.floor(mins / 60);
        const m = mins % 60;
        const dur = h > 0 ? h + "h " + m + "m" : m + "m";
        return root.charging ? dur + " to full" : dur + " left";
    }

    readonly property string detail: Sys.powerDetail

    // Ten-step battery glyph ramp, plus the charging variants.
    readonly property string icon: {
        if (!root.available) return "󰚥";
        const p = Math.max(0, Math.min(100, root.percent));
        const step = Math.min(10, Math.floor(p / 10));
        if (root.charging) {
            const charge = ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅", "󰂅"];
            return charge[step];
        }
        const drain = ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹", "󰁹"];
        return drain[step];
    }

    readonly property color tint: {
        if (root.charging || root.full) return Theme.ok;
        if (root.critical) return Theme.alarm;
        if (root.low) return Theme.warn;
        return Theme.primary;
    }

    // ------------------------------------------------------- power profiles
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile
    readonly property int profile: PowerProfiles.profile

    readonly property string profileLabel: {
        switch (root.profile) {
        case PowerProfile.PowerSaver: return "Power Saver";
        case PowerProfile.Performance: return "Performance";
        default: return "Balanced";
        }
    }

    readonly property string profileIcon: {
        switch (root.profile) {
        case PowerProfile.PowerSaver: return "󰌪";
        case PowerProfile.Performance: return "󰓅";
        default: return "󰾅";
        }
    }

    function setProfile(p: int) {
        PowerProfiles.profile = p;
    }

    function cycleProfile() {
        if (root.profile === PowerProfile.PowerSaver) {
            root.setProfile(PowerProfile.Balanced);
        } else if (root.profile === PowerProfile.Balanced
                   && PowerProfiles.hasPerformanceProfile) {
            root.setProfile(PowerProfile.Performance);
        } else {
            root.setProfile(PowerProfile.PowerSaver);
        }
    }
}
