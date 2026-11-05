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
    // Docker's veth pairs show up as wired too; NetworkManager leaves them
    // unmanaged, and so does the popout.
    readonly property var wiredDevices: devices.filter(d => d.type === DeviceType.Wired && d.nmManaged)

    readonly property WifiDevice wifi: wifiDevices.length > 0 ? wifiDevices[0] : null
    // The port in use, or failing that the first one there is.
    readonly property WiredDevice wired: wiredDevices.find(d => d.connected) ?? wiredDevices[0] ?? null

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
        // Connected but not yet sampled should read as full, not dead.
        return s <= 0 ? "󰤨" : root.signalIcon(s);
    }

    readonly property string label: {
        if (root.wiredUp) return "Ethernet";
        if (!root.wifiEnabled) return "Wi-Fi off";
        if (root.activeWifi) return root.activeWifi.name;
        return "Offline";
    }

    // Strength is a fraction, 0 to 1, not a percentage.
    function signalIcon(strength: real): string {
        if (strength >= 0.8) return "󰤨";
        if (strength >= 0.6) return "󰤥";
        if (strength >= 0.4) return "󰤢";
        if (strength >= 0.2) return "󰤟";
        return "󰤯";
    }

    // "1 Gb/s" when up, otherwise why not. NetworkManager reports Mb/s.
    function wiredDetail(d): string {
        if (!d.hasLink) return d.name + "  ·  no cable";
        if (!d.connected) return d.name + "  ·  disconnected";
        const mbps = d.linkSpeed ?? 0;
        if (mbps <= 0) return d.name;
        return d.name + "  ·  " + (mbps >= 1000 ? (mbps / 1000) + " Gb/s" : mbps + " Mb/s");
    }

    function toggleWired(d) {
        if (d.connected) d.disconnect();
        else if (d.network) d.network.connect();
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
