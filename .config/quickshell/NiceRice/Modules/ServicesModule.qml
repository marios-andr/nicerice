import QtQuick
import QtQuick.Layouts
import "../Theme"

Rectangle {

    default property alias content: layout.data

    implicitWidth: layout.implicitWidth + 10
    implicitHeight: Theme.dotSize + 8
    radius: 14
    color: hovered.hovered ? Theme.secondary_hover : Theme.primary

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6
    }

    HoverHandler {
        id: hovered
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton
        onClicked: {/*TODO: open services panel*/}
    }
}
