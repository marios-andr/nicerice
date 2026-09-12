import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../Theme"

ColumnLayout {
    id: layout
    implicitWidth: 130
    anchors.centerIn: parent
    spacing: 10

    Repeater {
        model: [
            {
                name: "Shut Down",
                icon: "../icons/pwr.svg",
                action: function () {
                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/nicerice/scripts/nicerice-power.sh -p"]);
                }
            },
            {
                name: "Restart",
                icon: "../icons/restart.svg",
                action: function () {
                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/nicerice/scripts/nicerice-power.sh -r"]);
                }
            },
            {
                name: "Suspend",
                icon: "../icons/suspend.svg",
                action: function () {
                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/nicerice/scripts/nicerice-power.sh -s"]);
                }
            },
            {
                name: "Logout",
                icon: "../icons/logout.svg",
                action: function () {
                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/nicerice/scripts/nicerice-power.sh -e"]);
                }
            },
            {
                name: "Lock",
                icon: "../icons/lock.svg",
                action: function () {
                    Quickshell.execDetached(["bash", "-c", Quickshell.env("HOME") + "/.config/nicerice/scripts/nicerice-power.sh -l"]);
                }
            },
        ]
        delegate: Rectangle {
            id: entry
            required property var modelData

            implicitWidth: layout.implicitWidth
            implicitHeight: Theme.dotSize + 1

            color: entryMouse.containsMouse ? Theme.secondary : "transparent"
            radius: 14

            RowLayout {
                anchors.fill: parent
                spacing: 2

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: entry.modelData.icon
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

                Text {
                    text: entry.modelData.name
                    color: Theme.font
                    font.family: Theme.fontFamily
                }
            }

            MouseArea {
                id: entryMouse
                anchors.fill: parent

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: entry.modelData.action()
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 7
                anchors.rightMargin: 7
                anchors.top: parent.bottom
                implicitHeight: 1
                color: Theme.font_inactive
            }
        }
    }
}
