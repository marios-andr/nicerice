import QtQuick
import "../Theme"

Item {
    id: root
    implicitHeight: dotSize + 6
    implicitWidth: dotSize + 6

    property int dotSize: Theme.dotSize

    property bool selected

    signal clicked

    Rectangle {
        anchors.centerIn: parent
        implicitHeight: root.implicitHeight
        implicitWidth: root.implicitWidth
        color: mouse.containsMouse ? Theme.secondary_hover : "transparent"
        radius: 14

        Rectangle {
            anchors.centerIn: parent
            implicitHeight: root.dotSize
            implicitWidth: root.dotSize
            color: root.selected ? Theme.selected : "transparent"
            border.width: 1
            border.color: root.selected ? Theme.selected : Theme.font_inactive
            radius: 14

            Behavior on color {
                ColorAnimation {
                    duration: 80
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.clicked()
            }

            Rectangle {
                anchors.centerIn: parent
                implicitHeight: parent.implicitHeight / 2
                implicitWidth: parent.implicitWidth / 2
                color: root.selected ? Theme.font : "transparent"
                radius: 14

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }
            }
        }
    }
}
