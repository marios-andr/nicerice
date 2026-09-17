pragma ComponentBehavior: Bound

import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Networking
import "../Util"
import "../Theme"

/*

Networking:
+ wifiEnabled
- connectivity, connectivityCheckEnabled, checkConnectivity()
+ devices // network ports on computer

NetworkDevice:
- address
- connected, disconnect(), autoconnect
- name
- state: ConnectionState
- type: [DeviceType.Wifi | DeviceType.Wired]
+ networks

WifiDevice:
- mode //802.11 mode?
+ scannerEnabled

Network:
- nmSettings
- state: ConnectionState, stateChanging
- known, forget()
+ name
- connected, connect(), connectWithSettings(NMSettings), disconnect()


WifiNetwork:
+ signalStrength
- security: WifiSecurityType
- connectWithPsk(string) if security is WpaPsk, Wpa2Psk, Sae

*/

ColumnLayout {
    id: root
    anchors.centerIn: parent
    spacing: 10

    readonly property int maxWindowHeight: 485

    signal expansion(expanded: bool)

    onExpansion: expanded => {
        if (expanded) {
            startScan();
            console.debug("Scanning started...");
        } else {
            stopScan();
            console.debug("Scanning stopped sucessfully");
        }
    }

    readonly property bool hasWifi: Networking.wifiHardwareEnabled

    function startScan() {
        if (Networks.primaryWifi !== null)
            Networks.primaryWifi.scannerEnabled = true;
    }

    function stopScan() {
        if (Networks.primaryWifi !== null)
            Networks.primaryWifi.scannerEnabled = false;
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

    // -----------------
    // -- Enable Wifi --
    // -----------------
    RowLayout {
        Layout.fillWidth: true

        Loader {
            active: root.hasWifi && root.primaryWifi !== null
            sourceComponent: RowLayout {
                ToggleSwitch {
                    isActive: Networking.wifiEnabled
                    onIsActiveChanged: {
                        Networking.wifiEnabled = isActive;
                    }
                }

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: "../icons/wifi.svg"
                    sourceSize.width: 20
                    sourceSize.height: 20
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Theme.font
                    }
                }

                Text {
                    Layout.minimumWidth: 350
                    text: "Enable Wifi"
                    color: Theme.font
                    font.family: Theme.fontFamily
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            implicitHeight: 22
            implicitWidth: 22
            radius: 8
            color: settingsMouse.containsMouse ? Theme.secondary_hover : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }

            Image {
                anchors.centerIn: parent
                source: "../icons/settings.svg"
                sourceSize.width: 20
                sourceSize.height: 20
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit
                layer.enabled: true
                layer.effect: MultiEffect {
                    colorization: 1.0
                    colorizationColor: Theme.font
                }
            }

            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Quickshell.execDetached(["bash", "-c", "nm-connection-editor"]);
                }
            }
        }
    }

    // ----------------------------------------
    // -- Available Networks - Scan Networks --
    // ----------------------------------------
    RowLayout {
        Text {
            text: "Available Networks "
            color: Theme.font
            font.family: Theme.fontFamily
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.font_inactive
        }

        // ----------
        // -- Scan --
        // ----------
        Loader {
            active: root.hasWifi && Networking.wifiEnabled && Networks.primaryWifi !== null
            sourceComponent: Rectangle {
                implicitWidth: 20
                implicitHeight: 20
                radius: 14
                color: refreshMouse.containsMouse ? Theme.secondary_hover : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Image {
                    id: refreshImage
                    Layout.alignment: Qt.AlignVCenter
                    source: "../icons/restart.svg"
                    sourceSize.width: 20
                    sourceSize.height: 20
                    width: 20
                    height: 20
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Theme.font
                    }

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: Networks.primaryWifi.scannerEnabled
                        onRunningChanged: {
                            if (!running) {
                                refreshImage.rotation = 7;
                            }
                        }
                    }
                }

                MouseArea {
                    id: refreshMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Networks.primaryWifi.scannerEnabled = !Networks.primaryWifi.scannerEnabled;
                    }
                }
            }
        }
    }

    // --------------
    // -- Networks --
    // --------------
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: plz.implicitHeight
        Layout.minimumHeight: 280
        Layout.maximumHeight: root.maxWindowHeight
        color: Theme.primary
        radius: 8

        ScrollView {
            anchors.fill: parent
            anchors.margins: 4
            clip: true
            padding: 0
            contentWidth: availableWidth

            ColumnLayout {
                id: plz
                width: parent.width

                property Network focusedNetwork: null

                Repeater {
                    model: Networks.networks
                    delegate: NetworkCard {
                        Layout.fillWidth: true

                        required property Network modelData
                        network: modelData

                        expanded: plz.focusedNetwork === network
                        onCardClicked: {
                            plz.focusedNetwork = network.known || !needsCredentials || plz.focusedNetwork === network ? null : network;
                        }

                        onConnectionFailed: reason => {
                            console.debug("Connection failed for " + network.name + ": " + reason);
                            plz.focusedNetwork = network;
                            showWrongPassword = true;
                        }

                        onNetworkStateChanged: {
                            if (network.state === ConnectionState.Connected) {
                                plz.focusedNetwork = null;
                                showWrongPassword = false;
                            }
                        }

                        // Component.onCompleted: {
                        //     console.debug(network.name + " " + WifiSecurityType.toString(network.security));
                        // }
                    }
                }
            }
        }
    }
}
