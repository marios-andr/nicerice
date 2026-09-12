import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import "../Util"
import "../Theme"

/*
Data: TODO
- paired // pair(), forget()
- pairing // cancelPair()
- bonded
- batteryAvailable, battery
+ deviceName
+ address
+ connected // connect(), disconnect()
+ icon // Quickshell.iconPath()
+ state

*/
ColumnLayout {
    id: layout
    anchors.centerIn: parent
    spacing: 10

    readonly property int maxWindowHeight: 485

    // ----------------------
    // -- Enable Bluetooth --
    // ----------------------
    RowLayout {
        Layout.fillWidth: true

        ToggleSwitch {
            isActive: Bluetooths.adapterEnabled
            onIsActiveChanged: {
                Bluetooths.adapter.enabled = isActive;
            }
        }

        Image {
            Layout.alignment: Qt.AlignVCenter
            source: Quickshell.iconPath("network-bluetooth-symbolic")
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
            text: "Enable Bluetooth"
            color: Theme.font
            font.family: Theme.fontFamily
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
                    Quickshell.execDetached(["bash", "-c", "blueman-manager"]);
                }
            }
        }
    }

    // ---------------------------------
    // -- Available Devices - Refresh --
    // ---------------------------------
    RowLayout {
        Text {
            text: "Available Devices "
            color: Theme.font
            font.family: Theme.fontFamily
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.font_inactive
        }

        // -------------
        // -- Refresh --
        // -------------
        Rectangle {
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
                    running: Bluetooths.adapterEnabled && Bluetooths.adapter.discovering
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
                    if (Bluetooths.adapter.discovering)
                        Bluetooths.adapter.discovering = false;
                    else {
                        Bluetooths.adapter.discovering = true;
                        discoverTimer.restart();
                    }
                }
            }

            Timer {
                id: discoverTimer
                interval: 5000
                onTriggered: {
                    Bluetooths.adapter.discovering = false;
                }
            }
        }
    }

    // -------------
    // -- Devices --
    // -------------

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: plz.implicitHeight
        Layout.minimumHeight: 280
        Layout.maximumHeight: layout.maxWindowHeight
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

                Repeater {
                    model: Bluetooths.visibleDevices
                    delegate: Rectangle {
                        id: device
                        required property var modelData

                        Layout.fillWidth: true
                        implicitHeight: 40
                        radius: 12
                        color: deviceMouse.containsMouse ? Theme.secondary : Theme.primary

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        MouseArea {
                            id: deviceMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                device.modelData.connected = !device.modelData.connected;
                            }
                        }

                        RowLayout {
                            anchors.fill: parent

                            Image {
                                Layout.preferredHeight: 36
                                Layout.preferredWidth: 36
                                Layout.alignment: Qt.AlignTop
                                fillMode: Image.PreserveAspectFit
                                visible: source.toString() !== ""
                                source: Quickshell.iconPath(device.modelData.icon, true) || "../icons/bluetooth-device.svg"
                            }

                            ColumnLayout {
                                Layout.fillWidth: true

                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: device.modelData.deviceName
                                    color: Theme.font
                                    font.family: Theme.fontFamily
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.alignment: Qt.AlignVCenter
                                    text: device.modelData.icon + "\u2022" + device.modelData.address
                                    color: Theme.font_inactive
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 4
                                    elide: Text.ElideRight
                                }
                            }

                            Spinner {
                                sizeUnit: 0.7
                                visible: device.modelData.state === BluetoothDeviceState.Connecting || device.modelData.state === BluetoothDeviceState.Disconnecting
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                color: "transparent"
                                implicitWidth: 26
                                implicitHeight: 26

                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    source: Quickshell.iconPath("network-bluetooth-activated")
                                    opacity: device.modelData.connected || deviceMouse.containsMouse ? 1 : 0
                                    sourceSize.width: 26
                                    sourceSize.height: 26
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    fillMode: Image.PreserveAspectFit
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: device.modelData.connected ? Theme.font : Theme.connect
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }

                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    source: "../icons/circle_off.svg"
                                    opacity: deviceMouse.containsMouse && device.modelData.connected ? 1 : 0
                                    sourceSize.width: 26
                                    sourceSize.height: 26
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    fillMode: Image.PreserveAspectFit
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: Theme.selected
                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 150
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
