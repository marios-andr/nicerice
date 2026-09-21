pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import ".."
import "../Theme"
import "../Util"

Scope {
    id: scope

    IpcHandler {
        target: "app_launcher"

        function open(): void {
            loader.active = true;
        }

        function toggle(): void {
            loader.active = !loader.active;
        }

        function close(): void {
            if (loader.active)
                loader.item.closeWindow();
        }
    }

    LazyLoader {
        id: loader
        active: false

        PanelWindow {
            id: root
            WlrLayershell.layer: WlrLayer.Top
            exclusionMode: ExclusionMode.Ignore
            implicitHeight: windowHeight
            onClosed: loader.active = false

            ProviderManager {
                id: provider
                input: input.text
            }

            anchors {
                left: true
                right: true
                bottom: true
            }

            margins {
                bottom: animMargin
                left: sideMargin
                right: sideMargin
            }

            readonly property int windowHeight: Math.min(512, Math.max(column.implicitHeight + entryHeight / 2, 58))
            readonly property int entryHeight: 62
            property int sideMargin: 460
            property int animMargin: 0

            function closeWindow() {
                hyprlandFocus.active = false;
                animMargin = -windowHeight;
                closeTimer.restart();
            }

            Behavior on animMargin {
                NumberAnimation {
                    duration: 230
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
                id: hyprlandFocus
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

            color: "transparent"

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: inv1.implicitWidth
                anchors.rightMargin: inv2.implicitWidth
                color: Theme.background
                topLeftRadius: 12
                topRightRadius: 12

                InvertedCorner {
                    id: inv1
                    anchors.right: parent.left
                    anchors.bottom: parent.bottom
                    corner: 2
                    radius: 20
                    color: Theme.background
                }

                InvertedCorner {
                    id: inv2
                    anchors.left: parent.right
                    anchors.bottom: parent.bottom
                    corner: 3
                    radius: 20
                    color: Theme.background
                }
            }

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.leftMargin: inv1.implicitWidth + 10
                anchors.rightMargin: inv2.implicitWidth + 10
                anchors.topMargin: 8
                anchors.bottomMargin: 8

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    implicitHeight: count * root.entryHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    model: provider.results
                    currentIndex: 0

                    ScrollBar.vertical: ScrollBar {}

                    highlight: Rectangle {
                        width: list.width
                        height: root.entryHeight
                        color: Theme.primary_hover
                        radius: 5
                        y: list.currentItem.y
                        Behavior on y {
                            NumberAnimation {
                                duration: 100
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    delegate: Row {
                        id: entry
                        height: root.entryHeight
                        width: list.width
                        spacing: 5
                        // color: "red"
                        required property var modelData

                        Image {
                            property int size: 54
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(entry.modelData.icon, true)
                            sourceSize.width: size
                            sourceSize.height: size
                            width: size
                            height: size
                            fillMode: Image.PreserveAspectFit
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: entry.modelData.name
                            color: Theme.font
                            font.family: Theme.fontFamily
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32

                    radius: 18
                    color: Theme.primary
                    RowLayout {
                        anchors.fill: parent

                        ArrowRectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 44
                            leftRadius: 18
                            color: Theme.secondary

                            Image {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: -2
                                source: Quickshell.iconPath("search")
                                sourceSize.width: size
                                sourceSize.height: size
                                width: size
                                height: size
                                fillMode: Image.PreserveAspectFit

                                property int size: 28
                            }
                        }

                        ArrowRectangle {
                            visible: provider.active.icon !== ""
                            Layout.fillHeight: true
                            Layout.preferredWidth: 48
                            Layout.leftMargin: -12
                            leftArrowEnabled: true
                            color: Theme.secondary

                            Image {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: 0
                                source: Quickshell.iconPath(provider.active.icon)
                                sourceSize.width: size
                                sourceSize.height: size
                                width: size
                                height: size
                                fillMode: Image.PreserveAspectFit

                                property int size: 24
                            }
                        }

                        TextInput {
                            id: input
                            Layout.fillWidth: true
                            color: Theme.font
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            selectionColor: Theme.selected
                            selectedTextColor: "black"
                            focus: true
                            clip: true
                            Keys.onDownPressed: {
                                if (list.currentIndex === list.count - 1)
                                    list.currentIndex = -1;
                                list.incrementCurrentIndex();
                            }
                            Keys.onUpPressed: {
                                if (list.currentIndex === 0)
                                    list.currentIndex = list.count;
                                list.decrementCurrentIndex();
                            }
                            Keys.onReturnPressed: {
                                provider.launchSelected(list.currentItem?.modelData);
                                root.closeWindow();
                            }
                        }

                        Image {
                            Layout.rightMargin: 8
                            source: Quickshell.iconPath("tab-close")
                            sourceSize.width: size
                            sourceSize.height: size
                            width: size
                            height: size
                            fillMode: Image.PreserveAspectFit

                            property int size: 24

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    input.clear();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
