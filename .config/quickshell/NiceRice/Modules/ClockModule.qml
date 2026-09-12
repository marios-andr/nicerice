pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import "../Theme"
import "../CalendarApp"

Item {
    id: clockRoot

    property bool calendarActive: false
    onCalendarActiveChanged: {
        KhalConfig.should_load_events = calendarActive
    }

    // Qt date/time format for the time, supplied from statusbar.json.
    property string timeFormat: "HH:mm"
    // Qt date/time format for the date shown below the time when expanded.
    property string dateFormat: "ddd, dd MMM"

    implicitWidth: Math.max(timeText.implicitWidth, dateText.implicitWidth) + 6
    implicitHeight: timeText.implicitHeight + dateText.implicitHeight + 8

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

    Text {
        id: timeText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // Shift up so the date below has more room.
        anchors.verticalCenterOffset: -6
        text: Qt.formatDateTime(clock.date, clockRoot.timeFormat)
        color: Theme.font
        font.family: Theme.fontFamily
        font.pixelSize: 16
        font.bold: true
    }

    Text {
        id: dateText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: timeText.bottom
        anchors.topMargin: 1
        text: Qt.formatDateTime(clock.date, clockRoot.dateFormat)
        color: Theme.font
        font.family: Theme.fontFamily
        font.pixelSize: 11
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
                clockRoot.calendarActive = false
            }
        }
    }
}
