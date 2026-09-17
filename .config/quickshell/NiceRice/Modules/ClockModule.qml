pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import "../Theme"
import "../CalendarApp"

Item {
    id: clockRoot

    property bool calendarActive: false
    onCalendarActiveChanged: {
        KhalConfig.should_load_events = calendarActive;
    }

    // Qt date/time format for the time, supplied from statusbar.json.
    property string timeFormat: "HH:mm"
    // Qt date/time format for the date shown below the time when expanded.
    property string dateFormat: "ddd, dd MMM"

    implicitWidth: timeText.implicitWidth + dateText.implicitWidth + 14
    implicitHeight: Theme.moduleHeight//Math.max(timeText.implicitHeight + dateText.implicitHeight) - 4

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: mouse.containsMouse ? Theme.secondary : Theme.primary

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: 4
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Text {
            id: timeText
            Layout.alignment: Qt.AlignBottom
            text: Qt.formatDateTime(clock.date, clockRoot.timeFormat)
            color: Theme.font
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.bold: true
        }

        Text {
            id: dateText
            Layout.alignment: Qt.AlignBottom
            text: Qt.formatDateTime(clock.date, clockRoot.dateFormat)
            color: Theme.font
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 5
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            clockRoot.calendarActive = !clockRoot.calendarActive;
        }
    }

    LazyLoader {
        id: loader
        active: clockRoot.calendarActive

        CalendarApp {
            id: app
            visible: loader.active
            anchor.item: clockRoot
            anchor.rect.x: clockRoot.width / 2 - width / 2
            anchor.rect.y: clockRoot.height + 15
            onClosed: {
                clockRoot.calendarActive = false;
            }
        }
    }
}
