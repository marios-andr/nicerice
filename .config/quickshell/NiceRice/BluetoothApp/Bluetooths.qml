pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool adapterEnabled: adapter !== null && adapter.enabled
    readonly property bool adapterConnected: visibleDevices.values.some(d => d.connected)

    readonly property alias visibleDevices: visibleDevices

    ScriptModel {
        id: visibleDevices
        values: [...Bluetooth.devices.values].filter(d => d.deviceName !== "").sort((a, b) => (b.connected - a.connected) || a.deviceName.localeCompare(b.deviceName))
    }

}