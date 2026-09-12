pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../Theme"

PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: windowWidth
    color: "transparent"

    anchors {
        left: true
        top: true
        bottom: true
    }

    margins {
        top: 52
        bottom: 12
        left: animMargin
    }

    readonly property int windowWidth: 420
    readonly property int buttonSize: 48
    property int animMargin: 0
    property Component activeComponent: HomeView {}

    function closeWindow() {
        animMargin = -windowWidth;
        closeTimer.restart();
    }

    Behavior on animMargin {
        NumberAnimation {
            duration: 350
            easing.type: Easing.OutQuint
        }
    }

    Timer {
        id: closeTimer
        interval: 350
        onTriggered: {
            root.closed();
        }
    }

    // --- CLICK OUTSIDE TO CLOSE (Native Hyprland) ---
    HyprlandFocusGrab {
        windows: [root]
        active: true
        onCleared: {
            root.closeWindow();
        }
    }

    // --- ESCAPE KEY LISTENER ---
    Shortcut {
        sequence: "Escape"
        onActivated: {
            root.closeWindow();
        }
    }

    component SidebarButton: Rectangle {
        Layout.preferredWidth: root.buttonSize
        Layout.preferredHeight: root.buttonSize
        color: btnComponent === root.activeComponent || btnMouse.containsMouse ? Theme.secondary : "transparent"

        property string iconPath
        property Component btnComponent
        property bool isDefault

        Component.onCompleted: {
            if (isDefault)
                root.activeComponent = btnComponent;
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.activeComponent !== parent.btnComponent)
                    root.activeComponent = parent.btnComponent;
            }
        }

        Image {
            anchors.centerIn: parent
            source: Quickshell.iconPath(parent.iconPath)
            sourceSize.width: 32
            sourceSize.height: 32
            width: 32
            height: 32
            fillMode: Image.PreserveAspectFit
        }
    }

    Item {
        anchors.fill: parent
        anchors.margins: 5

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            radius: 10
            opacity: 0.95
            border.width: 2
            border.color: Theme.primary
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 2

            Loader {
                Layout.fillWidth: true
                active: root.activeComponent
                sourceComponent: root.activeComponent
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: root.buttonSize
                color: Theme.background_hover
                topRightRadius: 8
                bottomRightRadius: 8

                ColumnLayout {
                    anchors.fill: parent
                    SidebarButton {
                        Layout.alignment: Qt.AlignTop
                        topRightRadius: 8
                        isDefault: true
                        iconPath: "home"
                        btnComponent: HomeView {}
                    }
                }
            }
        }
    }
}
