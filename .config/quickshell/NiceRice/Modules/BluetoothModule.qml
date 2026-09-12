import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../BluetoothApp"
import "../Util"

Loader {
    active: Bluetooth.defaultAdapter !== null
    sourceComponent: Item {
        id: root
        implicitWidth: 23
        implicitHeight: 23

        Image {
            anchors.centerIn: parent
            source: {
                if (!Bluetooths.adapterEnabled) {
                    return Quickshell.iconPath("network-bluetooth-inactive-symbolic");
                } else if (Bluetooths.adapterConnected)
                    return Quickshell.iconPath("network-bluetooth-activated-symbolic");
                return Quickshell.iconPath("network-bluetooth-symbolic");
            }
            sourceSize.width: size
            sourceSize.height: size
            width: size
            height: size
            fillMode: Image.PreserveAspectFit

            property int size: app.buttonHovered ? 23 : 20

            Behavior on size {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        StatusbarApp {
            id: app
            anchorItem: root
            yOffset: 11
            onClicked: app.toggleExpanded()
            onExited: app.syncVisibility()
            appContent: BluetoothApp {}
        }
    }
}
