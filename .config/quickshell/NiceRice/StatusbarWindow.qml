import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "Theme"
import "Modules"

PanelWindow {
    id: root
    readonly property var defaultSettings: ({
            "bar": {
                "height": 45
            }
        })

    property var settings: defaultSettings

    color: "transparent"

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 0
    }

    implicitHeight: settings.bar.height

    // --- WAYLAND CONFIGURATION ---
    WlrLayershell.layer: WlrLayer.Top
    // Keyboard focus is owned by the HyprlandFocusGrab below (the same primitive
    // the Calendar/Power popups use), not by the layer-shell focus mode. A
    // WlrKeyboardFocus.Exclusive grab held the keyboard until Escape and left
    // running apps dead; OnDemand never grabbed from the keybinding at all. The
    // focus grab gives the bar the keyboard while expanded *and* fires onCleared
    // when the pointer/keyboard goes to another window, which is what hands focus
    // back to the app (and collapses the bar). Leave the layer-shell mode at its
    // default (None) so the two mechanisms don't fight.
    //
    // Grabs the keyboard for the bar while it is expanded so SUPER + SPACE can
    // drive Left/Right/Return navigation, and releases it the moment the user
    // interacts with another window (clicking/entering an app) — which returns
    // the keyboard to that app and collapses the bar.
    HyprlandFocusGrab {
        windows: [root]
        active: false
    }

    // Captures arrow keys (navigate), Return (execute) and Escape
    // (collapse) while the bar is in expanded mode.
    /*
        FocusScope {
            id: keyHandler
            anchors.fill: parent
            focus: root.barExpanded
            Keys.onLeftPressed: root.moveFocus(-1)
            Keys.onRightPressed: root.moveFocus(1)
            Keys.onUpPressed: root.stepFocused(1)
            Keys.onDownPressed: root.stepFocused(-1)
            Keys.onReturnPressed: root.activateFocused()
            Keys.onEnterPressed: root.activateFocused()
            Keys.onEscapePressed: root.barExpanded = false
        }*/

    Item {
        id: pill
        anchors.fill: parent

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: leftArea.horizontalCenter

            implicitWidth: leftArea.implicitWidth + 10
            color: Theme.background

            bottomLeftRadius: 18
            bottomRightRadius: 18
        }

        RowLayout {
            id: leftArea
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            spacing: 10

            //TODO: Media player on left-most

            NiceModule {}

            WorkspacesModule {}

            UsagesModule {}
        }

        Rectangle {
            anchors.fill: centerArea
            color: Theme.background

            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 18
            bottomRightRadius: 18
        }

        RowLayout {
            id: centerArea
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            spacing: 10

            Rectangle {
                Layout.preferredWidth: 15
                // Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
            }

            ClockModule {}

            Rectangle {
                Layout.preferredWidth: 15
                // Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
            }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: rightArea.horizontalCenter

            implicitWidth: rightArea.implicitWidth + 10
            color: Theme.background

            bottomLeftRadius: 18
            bottomRightRadius: 18
        }

        RowLayout {
            id: rightArea
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            spacing: 10

            TrayModule {}

            ServicesModule {
                NetworkingModule {}
                BluetoothModule {}
                NotificationsModule {}
            }

            AudioModule {}

            BatteryModule {}

            PowerModule {}
        }
    }
}
