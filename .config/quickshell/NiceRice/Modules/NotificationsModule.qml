import QtQuick
import Quickshell
import "../Theme"
import "../Notifications"
import "../Util"

Item {
    id: root
    implicitWidth: 23
    implicitHeight: 23

    Image {
        anchors.centerIn: parent
        source: Quickshell.iconPath(!NotificationCenter.dnd ? "notifications": "notifications-disabled")
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

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        implicitHeight: 6
        implicitWidth: 6
        radius: 8
        color: NotificationCenter.notificationCount > 0 ? Theme.selected : "transparent"
    }

    StatusbarApp {
        id: app
        anchorItem: root
        yOffset: 11
        onClicked: app.toggleExpanded()
        onExited: app.syncVisibility()
        appContent: NotificationsApp {}
    }
}
