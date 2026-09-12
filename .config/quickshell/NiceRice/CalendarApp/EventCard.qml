import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../Theme"


// TODO: Fix multi-day events
Item {
    id: root
    implicitHeight: !selected ? unselLayout.implicitHeight : selLayout.implicitHeight
    property var event
    property color color: {
        if (!event["calendar-color"])
            return "blue";
        if (event["calendar-color"].startsWith("#"))
            return event["calendar-color"].slice(0, 7);
        return event["calendar-color"];
    }
    property color textColor: {
        let R = color.r;
        let G = color.g;
        let B = color.b;
        let L = 0.2126 * R + 0.7152 * G + 0.0722 * B;
        return L > 0.50 ? Theme.font_dark : Theme.font;
    }
    property bool selected

    signal clicked

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.selected
        color: mouse.containsMouse ? Theme.secondary : Theme.primary
        radius: 8
    }

    RowLayout {
        id: unselLayout
        anchors.fill: parent
        spacing: 3
        visible: !root.selected

        Rectangle {
            implicitWidth: 3
            implicitHeight: textLayout.implicitHeight + 4
            color: root.color
        }

        ColumnLayout {
            id: textLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.event["title"] + "   " + root.event["repeat-symbol"]
                color: Theme.font
                font.family: Theme.fontFamily
                wrapMode: Text.WordWrap
            }

            Text {
                visible: root.event["start-time"]
                text: root.event["start-time"] + " - " + root.event["end-time"]
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }

        //TODO: alarms
    }

    ColumnLayout {
        id: selLayout
        anchors.fill: parent
        visible: root.selected
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerLayout.implicitHeight + 10
            color: root.color
            topLeftRadius: 8
            topRightRadius: 8

            ColumnLayout {
                id: headerLayout
                anchors.fill: parent
                anchors.margins: 5

                Text {
                    Layout.fillWidth: true
                    text: "\u{1f4c5} " + root.event["calendar"]
                    color: root.textColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: root.event["title"] + "   " + root.event["repeat-symbol"]
                    color: root.textColor
                    font.family: Theme.fontFamily
                    wrapMode: Text.WordWrap
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: footerLayout.implicitHeight + 10
            color: Theme.secondary
            bottomLeftRadius: 8
            bottomRightRadius: 8

            ColumnLayout {
                id: footerLayout
                anchors.fill: parent
                anchors.margins: 5

                RowLayout {
                    Layout.fillWidth: true

                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.iconPath("view-calendar")
                        sourceSize.width: 20
                        sourceSize.height: 20
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: root.color
                        }
                    }

                    Text {
                        text: root.event["start-date-long"]
                        color: Theme.font
                        font.family: Theme.fontFamily
                    }
                }

                RowLayout {
                    visible: !root.event["all-day"]
                    Layout.fillWidth: true

                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.iconPath("clock")
                        sourceSize.width: 20
                        sourceSize.height: 20
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: root.color
                        }
                    }

                    Text {
                        text: root.event["start-time"] + " - " + root.event["end-time"] + "  " + root.event["duration"]
                        color: Theme.font
                        font.family: Theme.fontFamily
                    }
                }

                Text {
                    visible: root.event["description"]
                    text: root.event["description"]
                    color: Theme.font
                    font.family: Theme.fontFamily
                }
            }
        }
    }
}
