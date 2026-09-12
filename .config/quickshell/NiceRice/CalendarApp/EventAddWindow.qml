pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "." as CalendarApp
import "../Theme"

/*
khal new [-a CALENDAR] [OPTIONS] [START [END | DELTA] [TIMEZONE] SUMMARY
[:: DESCRIPTION]]

-l, –location=LOCATION specify where this event will be held.

-g, –categories=CATEGORIES specify which categories this event belongs to. Comma separated list of categories. Beware: some servers (e.g. SOGo) do not support multiple categories.

-r, –repeat=RRULE specify if and how this event should be recurring. Valid values for RRULE are daily, weekly, monthly and yearly

-u, –until=UNTIL specify until when a recurring event should run

–url specify the URL element of the event

–alarms DURATION,… will add alarm times as DELTAs comma separated for this event, DURATION should look like 1day 10minutes or 1d3H10m, negative DURATIONs will set alarm after the start of the event.
*/
Scope {
    id: scope
    property date wDate

    IpcHandler {
        target: "event_add_window"

        function open(date: string): void {
            loader.active = true;
            scope.wDate = new Date(date);
        }

        function close(): void {
            loader.active = false;
        }
    }

    LazyLoader {
        id: loader
        active: false
        onActiveChanged: {
            if (active)
                KhalConfig.reload();
        }

        FloatingWindow {
            id: root
            title: "Add Event"
            color: "transparent"
            implicitWidth: 700
            implicitHeight: 600

            onClosed: loader.active = false

            Rectangle {
                anchors.fill: parent
                color: Theme.background
                radius: 8
                border.width: 6
                border.color: Theme.primary
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 15

                Rectangle {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.margins: 6
                    Layout.preferredHeight: topLayout.implicitHeight
                    color: Theme.background_hover

                    RowLayout {
                        id: topLayout
                        anchors.left: parent.left
                        anchors.right: parent.right

                        ComboBox {
                            Layout.leftMargin: 10
                            model: KhalConfig.calendars ? KhalConfig.calendars.calendars.map(e => e.display_name) : [""]
                            currentValue: KhalConfig.calendars.default_calendar
                            implicitContentWidthPolicy: ComboBox.WidestText
                            onAccepted: {}
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.preferredHeight: topLayout.imgSize + 10
                        }

                        property int imgSize: 38

                        Rectangle {
                            Layout.preferredWidth: topLayout.imgSize
                            Layout.preferredHeight: topLayout.imgSize
                            color: cancelMouse.containsMouse ? Theme.secondary : "transparent"
                            radius: 14

                            Image {
                                anchors.centerIn: parent
                                source: Quickshell.iconPath("remove")
                                sourceSize.width: topLayout.imgSize
                                sourceSize.height: topLayout.imgSize
                                width: topLayout.imgSize
                                height: topLayout.imgSize
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                id: cancelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                // onClicked: addCalendarMenu.visible = !addCalendarMenu.visible
                            }
                        }

                        Rectangle {
                            Layout.rightMargin: 10
                            Layout.preferredWidth: topLayout.imgSize
                            Layout.preferredHeight: topLayout.imgSize
                            color: acceptMouse.containsMouse ? Theme.secondary : "transparent"
                            radius: 14

                            Image {
                                anchors.centerIn: parent
                                source: Quickshell.iconPath("answer")
                                sourceSize.width: topLayout.imgSize
                                sourceSize.height: topLayout.imgSize
                                width: topLayout.imgSize
                                height: topLayout.imgSize
                                fillMode: Image.PreserveAspectFit
                            }

                            MouseArea {
                                id: acceptMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                // onClicked: addCalendarMenu.visible = !addCalendarMenu.visible
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.fillWidth: true

                    Text {
                        text: "Title "
                        color: Theme.font
                        font.family: Theme.fontFamily
                    }

                    Rectangle {
                        Layout.leftMargin: 10
                        Layout.rightMargin: 10
                        Layout.fillWidth: true
                        implicitHeight: 32
                        color: nameField.hovered ? Theme.secondary_hover : Theme.secondary
                        border.width: 1
                        border.color: Theme.secondary_border

                        TextField {
                            id: nameField
                            anchors.fill: parent
                            anchors.margins: 4
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Normal
                            color: Theme.font
                            font.family: Theme.fontFamily
                            selectByMouse: true
                            background: Item {}
                            hoverEnabled: true
                            onTextChanged: root.invalidName = false
                            // Keys.onTabPressed: pathField.focus = true
                        }
                    }
                }

                RowLayout {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.fillWidth: true

                    Image {
                        Layout.alignment: Qt.AlignTop
                        source: Quickshell.iconPath("view-calendar")
                        sourceSize.width: 24
                        sourceSize.height: 24
                        width: 24
                        height: 24
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        Layout.leftMargin: 23
                        Layout.fillWidth: true

                        Button {
                            id: startDate
                            text: Qt.formatDateTime(startCal.selected, "ddd, d MMM yyyy")
                            background: Rectangle {
                                color: startDate.hovered ? Theme.secondary : "transparent"
                            }
                            onClicked: startDatePopup.open()
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                            Popup {
                                id: startDatePopup
                                y: startDate.height - 1
                                contentItem: CalendarApp.Calendar {
                                    id: startCal
                                    today: scope.wDate
                                    firstDayOfWeek: 1 //TODO: Option to change this
                                    onSelectedChanged: {
                                        if (selected > endCal.selected) {
                                            endCal.selected = selected;
                                        }
                                        startDatePopup.close();
                                    }
                                }

                                background: Rectangle {
                                    color: Theme.background_hover
                                    radius: 2
                                }
                            }
                        }

                        Button {
                            id: endDate
                            text: Qt.formatDateTime(endCal.selected, "ddd, d MMM yyyy")
                            background: Rectangle {
                                color: endDate.hovered ? Theme.secondary : "transparent"
                            }
                            onClicked: endDatePopup.open()
                            HoverHandler {
                                cursorShape: Qt.PointingHandCursor
                            }
                            Popup {
                                id: endDatePopup
                                y: endDate.height - 1
                                contentItem: CalendarApp.Calendar {
                                    id: endCal
                                    today: scope.wDate
                                    firstDayOfWeek: 1 //TODO: Option to change this
                                    onSelectedChanged: {
                                        if (startCal.selected > selected) {
                                            selected = startCal.selected;
                                        }
                                        endDatePopup.close();
                                    }
                                }

                                background: Rectangle {
                                    color: Theme.background_hover
                                    radius: 2
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
