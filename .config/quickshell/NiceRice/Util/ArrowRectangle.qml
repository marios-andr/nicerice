import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    property color color: "#1e1e2e"
    property real tip: 12          // how far the triangle sticks out to the right
    property real radius: 0
    property real leftRadius
    property real rightRadius

    property bool rightArrowEnabled: true
    property bool leftArrowEnabled: false

    preferredRendererType: Shape.CurveRenderer

    Rectangle {
        x: root.leftArrowEnabled ? root.tip : 0
        width: root.width - (root.rightArrowEnabled ? root.tip : 0) - (root.leftArrowEnabled ? root.tip : 0)
        height: root.height
        radius: root.radius
        topLeftRadius: root.leftRadius
        bottomLeftRadius: root.leftRadius
        topRightRadius: root.rightRadius
        bottomRightRadius: root.rightRadius
        color: root.color
    }

    ShapePath {
        fillColor: root.leftArrowEnabled ? root.color : "transparent"
        strokeWidth: -1

        startX: 0; startY: 0
        PathLine { x: 0;        y: 0 }
        PathLine { x: root.tip; y: root.height / 2 } 
        PathLine { x: 0;        y: root.height }      
        PathLine { x: root.tip; y: root.height}
        PathLine { x: root.tip; y: 0}
    }

    ShapePath {
        fillColor: root.rightArrowEnabled ? root.color : "transparent"
        strokeWidth: -1

        startX: 0; startY: 0
        PathLine { x: root.width - root.tip; y: 0 }        // top edge
        PathLine { x: root.width;            y: root.height / 2 }  // triangle point
        PathLine { x: root.width - root.tip; y: root.height }      // back to bottom
        PathLine { x: root.width - root.tip; y: 0}
    }
}