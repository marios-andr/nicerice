import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../Theme"
import "../Util"

ColumnLayout {
    id: root

    readonly property int maxWindowHeight: 485

    // ----------------
    // -- Enable DND --
    // ----------------
    RowLayout {
        Layout.fillWidth: true

        ToggleSwitch {
            isActive: NotificationCenter.dnd
            onIsActiveChanged: {
                NotificationCenter.dnd = isActive;
            }
        }

        Image {
            Layout.alignment: Qt.AlignVCenter
            source: Quickshell.iconPath("notifications-disabled", true)
            sourceSize.width: 20
            sourceSize.height: 20
            width: 20
            height: 20
            fillMode: Image.PreserveAspectFit
        }

        Text {
            Layout.minimumWidth: 350
            text: "Enable Do Not Disturb"
            color: Theme.font
            font.family: Theme.fontFamily
        }
    }

    // -------------------------------
    // -- Notifications - Clear All --
    // -------------------------------
    RowLayout {
        Text {
            text: "Notifications "
            color: Theme.font
            font.family: Theme.fontFamily
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            implicitHeight: 1
            color: Theme.font_inactive
        }

        Rectangle {
            implicitWidth: 52
            implicitHeight: 17
            color: "transparent"

            Text {
                text: "clear all"
                color: clearAllMouse.containsMouse ? Theme.selected : Theme.font_inactive
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }

            MouseArea {
                id: clearAllMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: NotificationCenter.clearNotifications()
            }
        }
    }

    // -------------------
    // -- Notifications --
    // -------------------

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: plz.implicitHeight + 20
        Layout.minimumHeight: 280
        Layout.maximumHeight: root.maxWindowHeight
        color: Theme.primary
        bottomLeftRadius: 8
        bottomRightRadius: 8

        ScrollView {
            anchors.fill: parent
            clip: true

            ColumnLayout {
                id: plz
                width: parent.width

                Repeater {
                    model: NotificationCenter.history
                    delegate: Rectangle { // Grouped notifications
                        id: group
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: layout.implicitHeight
                        color: "transparent"

                        ColumnLayout {
                            id: layout
                            anchors.fill: parent
                            anchors.margins: 2

                            RowLayout {//TODO: Expand group, clear entire group? Make notifications looked stacked on top of eachother
                                Layout.fillWidth: true

                                Image {
                                    Layout.preferredHeight: 25
                                    Layout.preferredWidth: 25
                                    fillMode: Image.PreserveAspectFit
                                    visible: source.toString() !== ""
                                    source: Quickshell.iconPath(group.modelData.appIcon, true)
                                }

                                Text {
                                    text: group.modelData.appName
                                    color: Theme.font
                                    font.family: Theme.fontFamily
                                }
                            }

                            Loader { // Needed because of race condition between NotificationCard updating and group disappearing
                                Layout.fillWidth: true

                                active: group.modelData.notifications.count > 0
                                sourceComponent: NotificationCard {
                                    notification: group.modelData.notifications.count > 0 ? group.modelData.notifications.get(group.modelData.notifications.count - 1) : null
                                    anchors.fill: parent

                                    onClicked: event => {
                                        NotificationCenter.deleteNotification(notification);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            visible: NotificationCenter.notificationCount === 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "\u{1f44d}"
                font.pixelSize: 30
            }

            Text {
                text: "No unread notifications"
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: 20
            }
        }
    }
}
