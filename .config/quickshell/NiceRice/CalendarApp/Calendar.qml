pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../Theme"

Item {
    id: root

    property bool renderEvents: false
    property date today
    property date selected: today
    property int month: today.getMonth() // 0-Indexed
    property int year: today.getFullYear()
    property int firstDayOfWeek: 0
    property string formattedDate: Qt.formatDateTime(selected, "yyyy-MM-dd")

    function daysInMonth(year, month): int {
        return new Date(year, month + 1, 0).getDate();
    }

    function firstWeekday(year, month): int {
        return new Date(year, month, 1).getDay();
    }

    function buildMonthGrid(year, month) {
        const grid = [];
        const firstDay = firstWeekday(year, month); // 0-6
        const totalDays = daysInMonth(year, month);
        const prevTotalDays = daysInMonth(year, month - 1);

        // how many cells to pad before day 1, given the chosen start-of-week
        const offset = (firstDay - firstDayOfWeek + 7) % 7;

        for (let i = offset - 1; i >= 0; i--) {
            grid.push({
                day: prevTotalDays - i,
                currentMonth: false,
                date: Qt.formatDateTime(new Date(year, month-1, prevTotalDays - i), "yyyy-MM-dd")
            });
        }

        for (let d = 1; d <= totalDays; d++) {
            grid.push({
                day: d,
                currentMonth: true,
                date: Qt.formatDateTime(new Date(year, month, d), "yyyy-MM-dd")
            });
        }

        let next = 1;
        while (grid.length % 7 !== 0) {
            grid.push({
                day: next,
                currentMonth: false,
                date: Qt.formatDateTime(new Date(year, month+1, next), "yyyy-MM-dd")
            });
            next++;
        }

        return grid;
    }

    function daysOfWeek() {
        const days = ["S", "M", "T", "W", "T", "F", "S"];
        const newDays = [];

        for (let i = 0; i < 7; i++) {
            newDays.push(days[(firstDayOfWeek + i) % 7]);
        }

        return newDays;
    }

    function nextMonth() {
        if (month === 11)
            year++;
        month = (month + 1) % 12;
    }

    function prevMonth() {
        if (month === 0) {
            year = year - 1;
            month = 11;
            return;
        }
        month = month - 1;
    }

    function isSameDate(day: int, date: date): bool {
        return year === date.getFullYear() && month === date.getMonth() && day === date.getDate();
    }

    onSelectedChanged: {
        if (selected.getFullYear() !== year || selected.getMonth() !== month) {
            year = selected.getFullYear();
            month = selected.getMonth();
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent

        RowLayout {

            Rectangle {
                Layout.preferredHeight: 25
                Layout.preferredWidth: 25

                color: "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "../icons/caret-right.svg"
                    sourceSize.width: 25
                    sourceSize.height: 25
                    width: 25
                    height: 25
                    rotation: 180
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Theme.font
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.prevMonth()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Text {
                    anchors.centerIn: parent

                    text: {
                        return Qt.formatDateTime(new Date(root.year, root.month, 1), "MMMM yyyy");
                    }
                    color: Theme.font_secondary
                    font.family: Theme.fontFamily
                }
            }

            Rectangle {
                Layout.preferredHeight: 25
                Layout.preferredWidth: 25

                color: "transparent"

                Image {
                    anchors.centerIn: parent
                    source: "../icons/caret-right.svg"
                    sourceSize.width: 25
                    sourceSize.height: 25
                    width: 25
                    height: 25
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Theme.font
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.nextMonth()
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7

            Repeater {
                model: root.daysOfWeek()
                delegate: Item {
                    required property string modelData
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 21

                    Text {

                        anchors.centerIn: parent
                        text: modelData
                        color: Theme.font_inactive
                        font.family: Theme.fontFamily
                    }
                }
            }
        }

        GridLayout {
            columns: 7
            columnSpacing: 7

            Repeater {
                model: root.buildMonthGrid(root.year, root.month)
                delegate: Rectangle {
                    id: dateRec
                    required property var modelData

                    Layout.preferredHeight: 25
                    Layout.preferredWidth: 25
                    color: {
                        if (modelData.currentMonth && root.isSameDate(modelData.day, root.selected))
                            return Theme.selected;
                        if (dayMouse.containsMouse)
                            return Theme.secondary_hover;
                        if (modelData.currentMonth && root.isSameDate(modelData.day, root.today))
                            return Theme.secondary;
                        return "transparent";
                    }
                    radius: 12

                    Text {
                        anchors.centerIn: parent
                        text: dateRec.modelData.day
                        color: dateRec.modelData.currentMonth ? Theme.font_secondary : Theme.font_inactive
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        implicitHeight: 4
                        implicitWidth: 4
                        color: Theme.selected
                        radius: 6
                        visible: {
                            if (!root.renderEvents)
                                return false;

                            if (!KhalConfig.initialized || !KhalConfig.events)
                                return false;
                            let events = KhalConfig.events.lookup[dateRec.modelData.date];
                            return events ? events.length > 0 : false;
                        }
                    }

                    MouseArea {
                        id: dayMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let day = dateRec.modelData.day;
                            if (!dateRec.modelData.currentMonth) {
                                let inc = (day > 20 ? -1 : 1);
                                root.selected = new Date(root.year, root.month + inc, day);
                                return;
                            }
                            root.selected = new Date(root.year, root.month, day);
                        }
                    }
                }
            }
        }
    }
}
