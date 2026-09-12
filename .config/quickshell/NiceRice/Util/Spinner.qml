import QtQuick
import QtQuick.Shapes
import "../Theme"

Item {
    id: root

    property color spinnerColor: Theme.font
    property real sizeUnit: 1
    readonly property real ringWidth: 2 * sizeUnit

    width: Theme.dotSize * sizeUnit
    height: Theme.dotSize * sizeUnit

    // outer continuous rotation — matches `animation: rotate 1s linear infinite`
    RotationAnimation on rotation {
        from: 0; to: 360
        duration: 1000
        loops: Animation.Infinite
        easing.type: Easing.Linear
        running: root.visible
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeColor: root.spinnerColor
            strokeWidth: root.ringWidth
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap

            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.ringWidth / 2
                radiusY: root.height / 2 - root.ringWidth / 2
                startAngle: -90   // 12 o'clock

                // mimics the "prixClipFix" grow/shrink sweep, roughly matching its 2s cycle
                SequentialAnimation on sweepAngle {
                    loops: Animation.Infinite
                    NumberAnimation { from: 8; to: 300; duration: 1000; easing.type: Easing.InOutCubic }
                    NumberAnimation { from: 300; to: 8; duration: 1000; easing.type: Easing.InOutCubic }
                }
            }
        }
    }
}