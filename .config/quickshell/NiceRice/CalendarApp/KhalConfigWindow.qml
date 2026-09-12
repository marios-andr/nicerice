pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../Theme"
import "../Util"

FloatingWindow {
    id: root
    title: "Khal Configuration"
    color: "transparent"
    implicitWidth: 700
    implicitHeight: 600

    property var activeWizard: null

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
        spacing: 5

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

                Text {
                    Layout.margins: 10
                    text: "Khal Calendars Configuration"
                    color: Theme.font
                    font.family: Theme.fontFamily
                }

                Rectangle {
                    id: addRectangle
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    color: addMouse.containsMouse ? Theme.secondary : "transparent"
                    radius: 12

                    Image {
                        anchors.centerIn: parent
                        source: Quickshell.iconPath("list-add")
                        sourceSize.width: 25
                        sourceSize.height: 25
                        width: 25
                        height: 25
                        fillMode: Image.PreserveAspectFit
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: addCalendarMenu.visible = !addCalendarMenu.visible
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.margins: 10
                    Layout.preferredWidth: 25
                    Layout.preferredHeight: 25
                    color: "blue"
                }
            }
        }

        Repeater {
            model: KhalConfig.calendars ? KhalConfig.calendars.calendars : []
            delegate: RowLayout {
                id: cal
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                implicitHeight: 32
                required property var modelData
                property color color: cal.modelData.color

                property color textColor: {
                    let R = color.r;
                    let G = color.g;
                    let B = color.b;
                    let L = 0.2126 * R + 0.7152 * G + 0.0722 * B;
                    return L > 0.50 ? Theme.font_dark : Theme.font;
                }

                RadioButton {
                    dotSize: Theme.dotSize - 4
                    selected: false
                    visible: true
                    onClicked: {}
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: cal.modelData.color
                        }
                        GradientStop {
                            position: 1.0
                            color: Theme.background
                        }
                    }
                    topLeftRadius: 14
                    bottomLeftRadius: 14

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: cal.modelData.display_name
                        color: cal.textColor
                        font.family: Theme.fontFamily
                    }
                }
            }
        }
    }

    Popup {
        id: addCalendarMenu
        x: addRectangle.width
        y: addRectangle.height
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        modal: true
        focus: true
        padding: 4

        background: Rectangle {
            color: Theme.primary
            radius: 8
            border.width: 2
            border.color: Theme.secondary_border
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            // --------------------
            // -- Local Calendar -- TODO
            // --------------------
            Rectangle {
                Layout.preferredWidth: Math.max(localLayout.implicitWidth + 16, parent.implicitWidth)
                Layout.preferredHeight: localLayout.implicitHeight + 16
                radius: 8
                color: localMouse.containsMouse ? Theme.secondary : "transparent"

                MouseArea {
                    id: localMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {}
                }

                RowLayout {
                    id: localLayout
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        source: Quickshell.iconPath("user")
                        sourceSize.width: 20
                        sourceSize.height: 20
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Add a local calendar"
                        color: Theme.font
                        font.family: Theme.fontFamily
                    }
                }
            }

            // ---------------------
            // -- Google Calendar --
            // ---------------------

            Rectangle {
                Layout.preferredWidth: Math.max(googleLayout.implicitWidth + 16, parent.implicitWidth)
                Layout.preferredHeight: googleLayout.implicitHeight + 16
                radius: 8
                color: googleMouse.containsMouse ? Theme.secondary : "transparent"

                MouseArea {
                    id: googleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activeWizard = googleWizard
                }

                RowLayout {
                    id: googleLayout
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        Layout.alignment: Qt.AlignVCenter
                        source: "../icons/google-logo"
                        sourceSize.width: 20
                        sourceSize.height: 20
                        width: 20
                        height: 20
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: "Add a google calendar"
                        color: Theme.font
                        font.family: Theme.fontFamily
                    }
                }
            }
        }
    }

    LazyLoader {
        id: googleWizard
        active: root.activeWizard === googleWizard

        VdirsyncerSetupWindow {
            parentWindow: root
            onClosed: root.activeWizard = null
            onDone: root.activeWizard = null
        }
    }
}
