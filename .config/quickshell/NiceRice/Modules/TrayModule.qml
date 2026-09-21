import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import "../Theme"

Item {
    implicitWidth: layout.implicitWidth + 10
    implicitHeight: Theme.moduleHeight//layout.implicitHeight + 8

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items
            delegate: Rectangle {
                id: tray
                required property var modelData


                implicitWidth: Theme.dotSize + 2
                implicitHeight: Theme.dotSize + 2
                radius: 14
                color: mouse.containsMouse ? Theme.secondary : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Image {
                    anchors.centerIn: parent
                    source: tray.modelData.icon
                    sourceSize.width: Theme.dotSize - 2
                    sourceSize.height: Theme.dotSize - 2
                    width: Theme.dotSize - 2
                    height: Theme.dotSize - 2
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.AllButtons
                    onClicked: event => {
                        if (event.button === Qt.LeftButton) {
                            menu.open()
                        } else if (event.button === Qt.RightButton) {
                            tray.modelData.activate()
                        } else if (event.button === Qt.MiddleButton) {
                            tray.modelData.secondaryActivate()
                        }
                    }
                    onDoubleClicked: event => {
                        //TODO open owned application
                    }
                }

                // TODO: Custom openener
                QsMenuAnchor {
                    id: menu
                    menu: tray.modelData.menu
                    anchor.item: tray
                    anchor.margins.top: Theme.dotSize + 4
                }
            }
        }
    }
}
