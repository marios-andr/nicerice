import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../Theme"

/*
Features:
+ urgency
+ appName
+ image
+ appIcon
+ summary
+ body
+ desktopEntry
- inline replies: sendInlineReply(text) if hasInlineReply === true
- actions: list<NotificationAction>
           identifier is icon name if hasActionIcons === true
           text
           invoke()
- resident
+ transient

*/

Rectangle {
    id: card
    property var notification

    signal clicked(event: MouseEvent)

    implicitHeight: Math.max(78, layout.implicitHeight + 20)
    radius: 8
    color: mouse.containsMouse ? Theme.background_hover : Theme.background
    border.width: 2
    border.color: notification.urgency === NotificationUrgency.Critical ? Theme.selected : Theme.primary

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        onClicked: (event) => {
            card.clicked(event)
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        RowLayout {
            Text {
                text: card.notification.desktopEntry || card.notification.appName
                color: Theme.font_inactive
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 7
                elide: Text.ElideRight
            }

            Text {
                text: card.notification.receivedAt ? "\u2022 " + card.notification.receivedAt : ""
                color: Theme.font_inactive
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4
            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                text: "\u0078"
                color: mouse.containsMouse ? Theme.selected : Theme.font_inactive
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 4

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Image {
                Layout.preferredHeight: 36
                Layout.preferredWidth: 36
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                visible: source.toString() !== ""
                source: Quickshell.iconPath(card.notification.image || card.notification.appIcon || card.notification.desktopEntry || "", true)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: card.notification.summary
                    color: Theme.font
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true
                    text: card.notification.body
                    color: Theme.font_secondary
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
