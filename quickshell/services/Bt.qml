pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

// Bluetooth via BlueZ. Connection and pairing are driven directly from the
// popout; `fluxo bt` stays available as a CLI for the existing keybind.
Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var devices: adapter
        ? adapter.devices.values.slice().sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            if (a.paired !== b.paired) return a.paired ? -1 : 1;
            return (a.deviceName || a.name || "").localeCompare(b.deviceName || b.name || "");
        })
        : []

    readonly property var connected: devices.filter(d => d.connected)
    readonly property BluetoothDevice primary: connected.length > 0 ? connected[0] : null

    readonly property string label: {
        if (!available) return "No adapter";
        if (!enabled) return "Off";
        if (connected.length === 0) return "Disconnected";
        if (connected.length === 1) return root.deviceLabel(primary);
        return connected.length + " devices";
    }

    readonly property string icon: {
        if (!available || !enabled) return "󰂲";
        if (connected.length > 0) return "󰂱";
        return "󰂯";
    }

    function deviceLabel(d: BluetoothDevice): string {
        if (!d) return "";
        return d.deviceName || d.name || d.address;
    }

    // Nerd Font glyph matching BlueZ's icon hint.
    function deviceIcon(d: BluetoothDevice): string {
        const i = d?.icon || "";
        if (i.includes("headset") || i.includes("headphone")) return "󰋋";
        if (i.includes("audio")) return "󰓃";
        if (i.includes("phone")) return "󰄜";
        if (i.includes("mouse")) return "󰍽";
        if (i.includes("keyboard")) return "󰌌";
        if (i.includes("computer")) return "󰟀";
        if (i.includes("watch")) return "󰖉";
        if (i.includes("input-gaming")) return "󰊗";
        if (i.includes("printer")) return "󰐪";
        return "󰂯";
    }

    function toggle() {
        if (adapter) adapter.enabled = !adapter.enabled;
    }

    function toggleScan() {
        if (adapter) adapter.discovering = !adapter.discovering;
    }

    function toggleDevice(d: BluetoothDevice) {
        if (!d) return;
        if (d.connected) {
            d.disconnect();
        } else if (d.paired || d.bonded) {
            d.connect();
        } else {
            d.pair();
        }
    }
}
