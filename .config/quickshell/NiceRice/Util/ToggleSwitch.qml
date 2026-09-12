import QtQuick
import "../Theme"

Rectangle {
    id: root
    implicitWidth: dotSize * 2 + 4
    implicitHeight: dotSize + 6
    radius: 14
    color: isActive ? Theme.selected : Theme.primary

    property int dotSize: Theme.dotSize - 4

    property bool isActive: false

    Behavior on color {
        ColorAnimation { duration: 200 }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: !root.isActive ? 3 : root.dotSize + 1
        anchors.verticalCenter: parent.verticalCenter
        implicitWidth: root.dotSize
        implicitHeight: root.dotSize
        radius: 14
        color: Theme.font

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.isActive = !root.isActive
    }
}