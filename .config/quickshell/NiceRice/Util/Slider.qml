import QtQuick
import QtQuick.Controls
import "../Theme"

Slider {
    id: root

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: root.height / 4
        width: root.availableWidth
        height: implicitHeight
        radius: 2
        color: Theme.secondary

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: Theme.selected
            radius: 2
        }
    }

    handle: Rectangle {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding + root.availableHeight / 2 - height / 2
        implicitWidth: root.height
        implicitHeight: root.height
        radius: 14
        color: root.pressed ? Theme.font : Theme.font_secondary
        border.color: "#bdbebf"
    }
}
