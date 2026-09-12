import QtQuick
import Quickshell
import Quickshell.Networking
import "../Util"
import "../NetworkingApp"

Loader {
    active: Networking.backend !== NetworkBackendType.None
    sourceComponent: Item {
        id: root
        implicitWidth: 23
        implicitHeight: 23

        // TODO: check for Networking.connectivity
        function iconSource(): string {
            let hi = app.contentItem
            if (Networking.connectivity === NetworkConnectivity.None || Networking.connectivity === NetworkConnectivity.Unknown)
                return "network-wired-unavailable";
            let icon = Networks.networkIcon(Networks.connectedNetwork)
            if (Networking.connectivity === NetworkConnectivity.Limited) {
                icon += "-limited"
            }
            return icon;
        }

        Image {
            anchors.centerIn: parent
            source: Quickshell.iconPath(root.iconSource())
            sourceSize.width: size
            sourceSize.height: size
            width: size
            height: size
            fillMode: Image.PreserveAspectFit

            property int size: app.buttonHovered ? 23 : 20

            Behavior on size {
                NumberAnimation { duration: 100 }
            }
        }

        StatusbarApp {
            id: app
            anchorItem: root
            yOffset: 11
            needsKeyboardFocus: true
            onClicked: app.toggleExpanded()
            onExited: app.syncVisibility()
            appContent: NetworkingApp {}
        }
    }
}
