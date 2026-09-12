pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../Theme"

PopupWindow {
    id: root
    visible: false
    implicitWidth: 638
    implicitHeight: 350
    grabFocus: true

    color: "transparent"

    property string dayLabel: Qt.formatDateTime(clock.date, "dddd")
    property string dateLabel: Qt.formatDateTime(clock.date, "MMMM d yyyy")
    property string timeLabel: Qt.formatDateTime(secsClock.date, "hh:mm:ss t")

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    SystemClock {
        id: secsClock
        precision: SystemClock.Seconds
    }

    TextInput {
        id: inputField
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.onClosed()
            } else if (event.key === Qt.Key_Up) {
                let s = calendar.selected;
                calendar.selected = new Date(s.getFullYear(), s.getMonth(), s.getDate() - 7);
            } else if (event.key === Qt.Key_Down) {
                let s = calendar.selected;
                calendar.selected = new Date(s.getFullYear(), s.getMonth(), s.getDate() + 7);
            } else if (event.key === Qt.Key_Left) {
                let s = calendar.selected;
                calendar.selected = new Date(s.getFullYear(), s.getMonth(), s.getDate() - 1);
            } else if (event.key === Qt.Key_Right) {
                let s = calendar.selected;
                calendar.selected = new Date(s.getFullYear(), s.getMonth(), s.getDate() + 1);
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.background
        radius: 8
        border.width: 6
        border.color: Theme.primary
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 0

        // ---------------
        // -- Left Side --
        // ---------------

        ColumnLayout {
            Layout.preferredWidth: parent.width / 2.5 - 1
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true

            Text {
                text: root.dayLabel
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 6
            }

            Text {
                text: root.dateLabel
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 4
            }

            Text {
                text: root.timeLabel
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
            }

            Calendar {
                id: calendar
                today: clock.date
                renderEvents: true
                firstDayOfWeek: 1 //TODO: Option to change this
                onMonthChanged: {
                    if (KhalConfig.initialized && selected)
                        KhalConfig.events.calendarDate = new Date(year, month, 1);
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: 3
            Layout.alignment: Qt.AlignVCenter
            color: Theme.primary
        }

        // ----------------
        // -- Right Side --
        // ----------------

        ColumnLayout {
            Layout.preferredWidth: parent.width - (parent.width / 2.5) - 1
            Layout.alignment: Qt.AlignTop
            Layout.fillHeight: true

            Loader {
                Layout.fillWidth: true
                visible: active
                active: !KhalConfig.initialized
                sourceComponent: Text {
                    width: parent.width
                    text: "khal is the event organizer used in the backend. khal was not found in PATH and thus events cannot be shown."
                    color: Theme.font
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                }
            }

            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                active: KhalConfig.initialized && KhalConfig.events
                sourceComponent: EventsDisplay {
                    selectedDate: calendar.selected
                    Component.onCompleted: {
                        if (!KhalConfig.events.calendarDate || isNaN(KhalConfig.events.calendarDate))
                            KhalConfig.events.calendarDate = clock.date;
                    }
                }
            }
        }
    }
}
