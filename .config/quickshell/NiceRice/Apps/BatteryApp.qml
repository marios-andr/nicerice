import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.UPower
import "../Theme"

// TODO: Make toggle for keeping battery level at 80%
ColumnLayout {
    id: layout
    anchors.centerIn: parent

    property string iconDirectory: "../icons/"
    readonly property string batteryIconDirectory: iconDirectory + "battery/"

    // ------------------------
    // -- Battery Properties --
    // ------------------------

    readonly property bool isPluggedIn: !UPower.onBattery

    readonly property UPowerDevice battery: UPower.displayDevice

    readonly property bool hasBattery: battery !== null && battery.isLaptopBattery && battery.isPresent

    readonly property real time: {
        if (isPluggedIn)
            return battery.timeToFull;
        return battery.timeToEmpty;
    }

    readonly property real health: {
        for (let i = 0; i < UPower.devices.values.length; i++) {
            const d = UPower.devices.values[i];
            if (d.isLaptopBattery)
                return d.healthPercentage;
        }
        return UPower.displayDevice.healthPercentage;   // fallback
    }

    // -------------------
    // -- Power Profile --
    // -------------------
    readonly property var pwrProfile: PowerProfiles.profile
    function profileIconSource(profile): string {
        if (profile === PowerProfile.PowerSaver)
            return iconDirectory + "pwr_profile_eco.svg";
        else if (profile === PowerProfile.Balanced)
            return iconDirectory + "pwr_profile_balance.svg";
        else if (profile === PowerProfile.Performance)
            return iconDirectory + "pwr_profile_performance.svg";
        return "";
    }

    // ------------------
    // -- Battery Info --
    // ------------------

    RowLayout {
        visible: layout.hasBattery
        spacing: 2

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Theme.dotSize + 54
            implicitHeight: Theme.dotSize + 4
            radius: 10
            color: Theme.primary

            RowLayout {
                anchors.fill: parent
                spacing: 2

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: layout.batteryIconDirectory + "battery_time.svg"
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
                    Layout.alignment: Qt.AlignVCenter
                    text: {
                        let totalSecs = layout.time;
                        let hours = Math.trunc(totalSecs / 3600);
                        let mins = Math.trunc(totalSecs % 3600 / 60);
                        return hours + "h " + mins + "m";
                    }
                    font.family: Theme.fontFamily
                    color: Theme.font_secondary
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Theme.dotSize + 54
            implicitHeight: Theme.dotSize + 4
            radius: 10
            color: Theme.primary

            RowLayout {
                anchors.fill: parent
                spacing: 2

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: layout.batteryIconDirectory + "battery_health.svg"
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
                    Layout.alignment: Qt.AlignVCenter
                    text: layout.health.toFixed(2) + "%"
                    font.family: Theme.fontFamily
                    color: Theme.font_secondary
                }
            }
        }
    }

    // --------------------
    // -- Power Profiles --
    // --------------------

    Text {
        Layout.minimumWidth: 210
        text: "Power Profile: " + PowerProfile.toString(layout.pwrProfile)
        color: Theme.font
        font.family: Theme.fontFamily
    }

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        implicitWidth: buttonsLayout.implicitWidth + 10
        implicitHeight: buttonsLayout.implicitHeight + 10
        radius: 22
        color: Theme.secondary

        RowLayout {
            id: buttonsLayout
            anchors.centerIn: parent
            spacing: 26

            Repeater {
                model: [PowerProfile.PowerSaver, PowerProfile.Balanced, PowerProfile.Performance]
                delegate: Rectangle {
                    id: profileRoot
                    required property var modelData

                    implicitWidth: Theme.dotSize + 12
                    implicitHeight: Theme.dotSize + 12
                    color: layout.pwrProfile === modelData ? Theme.selected : "transparent"
                    radius: 22

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    scale: layout.pwrProfile === modelData ? 1.0 : 0.92
                    Behavior on scale {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack   // slight overshoot = a nice "pop" on selection
                        }
                    }

                    Image {
                        anchors.centerIn: parent
                        source: layout.profileIconSource(profileRoot.modelData)
                        sourceSize.width: 32
                        sourceSize.height: 32
                        width: 32
                        height: 32
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: Theme.font
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 22
                        color: "transparent"
                        border.color: Theme.secondary_hover
                        border.width: 2
                        opacity: profMouse.containsMouse && layout.pwrProfile !== profileRoot.modelData ? 1 : 0
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }
                    }

                    MouseArea {
                        id: profMouse
                        anchors.fill: parent

                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (profileRoot.modelData !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
                                PowerProfiles.profile = profileRoot.modelData
                        }
                    }
                }
            }
        }
    }
}
