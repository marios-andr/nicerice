pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {

    readonly property NetworkDevice connectedDevice: devices.values.find(d => d.connected) ?? null
    readonly property Network connectedNetwork: connectedDevice?.networks?.values.find(n => n.connected) ?? null
    readonly property NetworkDevice primaryWifi: wifiDevices.values.find(d => d.connected) ?? wifiDevices.values[0] ?? null

    property alias wiredDevices: wiredDevices
    property alias wifiDevices: wifiDevices
    property alias devices: devices
    property alias networks: networks

    function networkIcon(network: Network): string {
        if (!(network instanceof WifiNetwork)) {
            return "network-wired-activated";
        }
        let icon = "network-wireless-";

        const strength = network.signalStrength;
        if (strength >= 0.8)
            icon += "100";
        else if (strength >= 0.6)
            icon += "80";
        else if (strength >= 0.4)
            icon += "60";
        else if (strength >= 0.2)
            icon += "40";
        else
            icon += "20";

        return icon;
    }

    ScriptModel {
        id: wiredDevices
        values: [...Networking.devices.values].filter(d => d.type === DeviceType.Wired)
    }

    ScriptModel {
        id: wifiDevices
        values: [...Networking.devices.values].filter(d => d.type === DeviceType.Wifi).sort((a, b) => (b.connected - a.connected))
    }

    ScriptModel {
        id: devices
        values: [...wiredDevices.values, ...wifiDevices.values]
    }

    ScriptModel {
        id: networks
        values: [...devices.values].map(d => [...d.networks.values].sort((a, b) => b.connected - a.connected)).reduce((acc, arr) => acc.concat(arr), [])
    }
}