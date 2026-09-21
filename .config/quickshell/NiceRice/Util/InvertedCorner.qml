import QtQuick
import QtQuick.Shapes

Item {
    id: root
    property real radius: 20
    property color color: "#1e1e2e"

    // 0 = top-left, 1 = top-right, 2 = bottom-right, 3 = bottom-left
    property int corner: 0

    implicitWidth: radius
    implicitHeight: radius
    rotation: corner * 90

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer  // smooth AA edges

        ShapePath {
            fillColor: root.color
            strokeWidth: -1  // no outline

            startX: 0; startY: 0
            PathLine { x: root.radius; y: 0 }
            PathArc {
                x: 0; y: root.radius
                radiusX: root.radius; radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
            PathLine { x: 0; y: 0 }
        }
    }
}