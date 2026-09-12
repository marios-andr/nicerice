import QtQuick
import Quickshell
import Quickshell.Io
import "../Theme"

Item {
    id: root
    implicitWidth: 24
    implicitHeight: 24

    property string distroId: ""
    property string distroLogo: ""
    readonly property string iconName: distroLogo || distroId
    readonly property string iconSource: Quickshell.iconPath(iconName, "") //TODO fallback icon

    FileView {
        path: "/etc/os-release"

        onLoaded: {
            const text = this.text()
            const idMatch = text.match(/^ID=(.*)$/m)
            const logoMatch = text.match(/^LOGO=(.*)$/m)

            if (idMatch)
                root.distroId = idMatch[1].trim().replace(/^"|"$/g, "")
            if (logoMatch)
                root.distroLogo = logoMatch[1].trim().replace(/^"|"$/g, "")
        }
    }


    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        color: Theme.secondary
        radius: 14
        opacity: mouse.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["qs", "ipc", "call", "sidepanel_window", "toggle"])
        }
    }

    Image {
        id: img
        anchors.centerIn: parent
        source: root.iconSource
        sourceSize.width: root.implicitWidth
        sourceSize.height: root.implicitHeight
        width: root.implicitWidth
        height: root.implicitHeight
        fillMode: Image.PreserveAspectFit
    }
}