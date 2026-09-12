import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower
import "../Theme"
import "../Apps"
import "../Util"

Item { // TODO: 67 battery
    id: root
    implicitWidth: rowLayout.implicitWidth + 10
    implicitHeight: rowLayout.implicitHeight + 8

    // The aggregate battery UPower exposes for the whole machine.
    readonly property var device: UPower.displayDevice

    // True when this machine has a real, present laptop battery. This is the
    // sole condition for showing the module (a desktop reports none).
    readonly property bool hasBattery: device !== null && device.isLaptopBattery && device.isPresent

    // True while a power adapter is connected (the system is NOT draining the
    // battery). Drives the charging icon.
    readonly property bool pluggedIn: !UPower.onBattery

    // Rounded charge percentage (0–100). UPower's percentage is a 0.0–1.0
    // fraction, so scale it up before rounding.
    readonly property int percent: device ? Math.round(device.percentage * 100) : 0

    readonly property int profile: PowerProfiles.profile

    // The amount of icons dedicated to the percentage of the battery.
    property int iconCount: 11
    // The directory the battery icons are stored in.
    property string batteryIconDirectory: "../icons/battery/"

    // The icon source of the tray image, based on the breeze-dark symbols
    readonly property string iconSource: {
        let source = "battery-";

        if (!hasBattery)
            return Quickshell.iconPath(source + "missing")
        
        let level = 100;
        let p = 100 / iconCount;
        for (let i = 1; i < iconCount; i++)
            if (percent < p * i) {
                level = (i - 1) * 10
                break;
            }

        if (level === 0)
            source += "000"
        else if (level === 100)
            source += "100"
        else
            source += "0" + level
        
        if (pluggedIn)
            source += "-charging"

        if (profile === PowerProfile.PowerSaver)
            source += "-profile-powersave"

        return Quickshell.iconPath(source)
    }

    Rectangle {
        anchors.fill: parent
        color: app.buttonHovered ? Theme.secondary : Theme.primary
        radius: 14

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 2

        Image {
            Layout.alignment: Qt.AlignVCenter
            source: root.iconSource
            sourceSize.width: 20
            sourceSize.height: 20
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
        }

        Rectangle {
            visible: root.hasBattery
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: Theme.dotSize + 20
            implicitHeight: Theme.dotSize
            radius: 10
            color: app.buttonHovered ? Theme.secondary_hover : Theme.secondary

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150
                }
            }

            Text {
                anchors.centerIn: parent
                text: root.percent + "%"
                font.family: Theme.fontFamily
                color: Theme.font_secondary
            }
        }
    }

    StatusbarApp {
        id: app
        anchorItem: root
        yOffset: 6
        onClicked: app.toggleExpanded()
        onExited: app.syncVisibility()
        appContent: BatteryApp {}
    }
}
