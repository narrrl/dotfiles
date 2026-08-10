pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

// NetworkManager state for the network popout. Throughput and the active IP
// come from Sys (fluxo); this covers device topology and the Wi-Fi picker.
Singleton {
    id: root

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiHardwareEnabled: Networking.wifiHardwareEnabled
    readonly property int connectivity: Networking.connectivity

    readonly property var devices: Networking.devices?.values ?? []

    readonly property var wifiDevices: devices.filter(d => d.type === DeviceType.Wifi)
    readonly property var wiredDevices: devices.filter(d => d.type === DeviceType.Wired)

    readonly property WifiDevice wifi: wifiDevices.length > 0 ? wifiDevices[0] : null
    readonly property WiredDevice wired: wiredDevices.length > 0 ? wiredDevices[0] : null

    readonly property bool wiredUp: wired?.connected ?? false

    readonly property Network activeWifi: {
        if (!wifi) return null;
        const nets = wifi.networks?.values ?? [];
        for (const n of nets) if (n.connected) return n;
        return null;
    }

    // Strongest-first, one entry per SSID, current network pinned to the top.
    readonly property var wifiNetworks: {
        if (!wifi) return [];
        const seen = {};
        const out = [];
        const nets = (wifi.networks?.values ?? []).slice().sort((a, b) =>
            (b.signalStrength ?? 0) - (a.signalStrength ?? 0));
        for (const n of nets) {
            if (!n.name || seen[n.name]) continue;
            seen[n.name] = true;
            out.push(n);
        }
        return out.sort((a, b) => {
            if (a.connected !== b.connected) return a.connected ? -1 : 1;
            return (b.signalStrength ?? 0) - (a.signalStrength ?? 0);
        });
    }

    readonly property bool scanning: wifi?.scannerEnabled ?? false

    readonly property string icon: {
        if (root.wiredUp) return "󰈀";
        if (!root.wifiEnabled) return "󰤭";
        if (!root.activeWifi) return "󰤯";
        const s = root.activeWifi.signalStrength ?? 0;
        // Strength is only sampled while a scan is running, which the shell
        // does on demand. Connected-but-unsampled should read as full, not dead.
        if (s <= 0) return "󰤨";
        if (s >= 80) return "󰤨";
        if (s >= 60) return "󰤥";
        if (s >= 40) return "󰤢";
        if (s >= 20) return "󰤟";
        return "󰤯";
    }

    readonly property string label: {
        if (root.wiredUp) return "Ethernet";
        if (!root.wifiEnabled) return "Wi-Fi off";
        if (root.activeWifi) return root.activeWifi.name;
        return "Offline";
    }

    function signalIcon(strength: int): string {
        if (strength >= 80) return "󰤨";
        if (strength >= 60) return "󰤥";
        if (strength >= 40) return "󰤢";
        if (strength >= 20) return "󰤟";
        return "󰤯";
    }

    function secured(n): bool {
        return n && n.security !== undefined
            && n.security !== WifiSecurityType.Open
            && n.security !== WifiSecurityType.Unknown;
    }

    function toggleWifi() {
        Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    function setScanning(on: bool) {
        if (wifi) wifi.scannerEnabled = on;
    }
}
