import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Effects
import "../Theme"

Item {
    id: root

    property real percentage: 0
    property string iconSource: ""

    property int diameter: Theme.dotSize
    property int ringThickness: 2
    property color ringBg: Theme.tertiary
    property color ringFg: Theme.selected
    property color iconColor: Theme.font

    implicitWidth: Theme.dotSize
    implicitHeight: Theme.dotSize

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root.ringThickness
            strokeColor: root.ringBg
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: (root.diameter - root.ringThickness) / 2
                radiusY: (root.diameter - root.ringThickness) / 2
                startAngle: 0
                sweepAngle: 360
            }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: root.ringThickness
            strokeColor: root.ringFg
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: root.diameter / 2
                centerY: root.diameter / 2
                radiusX: (root.diameter - root.ringThickness) / 2
                radiusY: (root.diameter - root.ringThickness) / 2
                startAngle: -90
                sweepAngle: 360 * Math.max(0, Math.min(1, root.percentage))

                Behavior on sweepAngle {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }

    Image {
        // Layout.alignment: Qt.AlignVCenter
        anchors.centerIn: parent
        source: root.iconSource
        sourceSize.width: 20
        sourceSize.height: 20
        width: 20
        height: 20
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        layer.effect: MultiEffect {
            colorization: 1.0
            colorizationColor: Theme.font
            Behavior on colorizationColor {
                ColorAnimation {
                    duration: 500
                    easing.type: Easing.OutQuint
                }
            }
        }
    }
}
