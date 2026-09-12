import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../Theme"

PanelWindow {
    anchors {
        bottom: true
        right: true
    }

    margins {
        bottom: 12
        right: 12
    }

    implicitWidth: 380
    implicitHeight: Math.max(1, column.implicitHeight)
    color: "transparent"
    visible: !NotificationCenter.dnd

    exclusionMode: ExclusionMode.Ignore

    ColumnLayout { // TODO: Only one notification should be visible at a time?
        id: column
        width: parent.width

        spacing: 10

        Repeater {
            model: NotificationCenter.notifications
            delegate: Rectangle {
                id: card
                required property var modelData

                color: "transparent"
                Layout.fillWidth: true
                Layout.preferredHeight: notCard.implicitHeight

                NotificationCard {
                    id: notCard
                    anchors.fill: parent
                    notification: card.modelData

                    onClicked: (event) => {
                        if (event.button === Qt.RightButton) {
                            notification.expire();
                        } else if (event.button === Qt.LeftButton) {
                            notification.dismiss();
                        }
                    }
                }

                HoverHandler {
                    id: hover
                    onHoveredChanged: {
                        if (hovered)
                            timer.stop();
                        else
                            timer.restart();
                    }
                }

                Timer {
                    id: timer
                    running: card.modelData.urgency !== NotificationUrgency.Critical
                    interval: NotificationCenter.dnd ? 0 : 5000
                    onTriggered: card.modelData.expire()
                }
            }
        }
    }
}
