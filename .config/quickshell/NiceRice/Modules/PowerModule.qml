import QtQuick
import QtQuick.Effects
import "../Theme"
import "../Apps"
import "../Util"

Item {
    id: root
    implicitWidth: img.implicitWidth + 4
    implicitHeight: img.implicitHeight + 4

    property string iconSource: "../icons/pwr.svg"

    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        color: Theme.secondary
        radius: 14
        opacity: app.buttonHovered ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
            }
        }
    }

    Image {
        id: img
        anchors.centerIn: parent
        source: root.iconSource
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

    StatusbarApp {
        id: app
        anchorItem: root
        yOffset: 10
        onClicked: app.toggleExpanded()
        onExited: app.syncVisibility()
        appContent: PowerApp {}
    }
}
