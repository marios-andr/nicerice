pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../Theme"

Item {
    id: root
    anchors.fill: parent

    default property alias content: root.data

    readonly property Item contentItem: appLoader.item ? appLoader.item.content : null
    readonly property bool expanded: appLoader.item ? appLoader.item.expanded : false
    readonly property bool buttonHovered: mouse.containsMouse

    property bool needsKeyboardFocus: false

    property var anchorItem
    property int yOffset
    property int padding: 6

    property int defaultWidth: 150
    property int defaultHeight: 60

    property Component appContent

    signal expansion
    signal clicked
    signal entered
    signal exited

    function toggleExpanded() {
        appLoader.active = true;
        appLoader.item.expanded = !appLoader.item.expanded;
    }

    function syncVisibility() {
        if (mouse.containsMouse || (appLoader.item?.hovered && appLoader.item?.expanded)) {
            closeTimer.stop();
            appLoader.active = true;
            appLoader.item.expanded = true;
        } else {
            closeTimer.restart();
        }
    }

    Timer {
        id: closeTimer
        interval: 110
        onTriggered: {
            if (appLoader.item !== null)
                appLoader.item.expanded = false;
            appLoader.active = false;
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
        onEntered: root.entered()
        onExited: root.exited()
    }

    LazyLoader {
        id: appLoader
        active: false

        PopupWindow {
            id: app
            color: "transparent"

            readonly property alias content: contentLoader.item

            property bool hovered
            property bool expanded: false

            property int unloadGraceMs: 2000

            implicitWidth: (contentLoader.item ? contentLoader.item.implicitWidth : root.defaultWidth) + root.padding * 2
            implicitHeight: (contentLoader.item ? contentLoader.item.implicitHeight : root.defaultHeight) + root.padding * 2

            anchor.item: root.anchorItem
            anchor.rect.y: root.parent.height + root.yOffset
            visible: false

            onExpandedChanged: {
                if (expanded) {
                    hideTimer.stop();
                    unloadTimer.stop();
                    app.visible = true;
                } else {
                    hideTimer.restart();
                    unloadTimer.restart();
                }

                if ("expansion" in contentLoader.item)
                    contentLoader.item.expansion(app.expanded);
                root.expansion();
            }

            HyprlandFocusGrab {
                id: grab
                windows: [app]
                active: app.hovered && itemContainer.focusedItem !== null
                onCleared: app.expanded = false
            }

            HoverHandler {
                id: hoverHandler
                onHoveredChanged: {
                    app.hovered = hoverHandler.hovered;
                    root.syncVisibility();
                }
            }

            Timer {
                id: hideTimer
                interval: 150
                onTriggered: app.visible = false
            }

            Timer {
                id: unloadTimer
                interval: app.unloadGraceMs
                onTriggered: {
                    app.keepContentAlive = false;
                    appLoader.loaded = false;
                }
            }

            Item {
                id: itemContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                clip: true

                implicitHeight: !app.expanded ? 0 : app.implicitHeight
                height: implicitHeight

                property var focusedItem: Window.activeFocusItem

                Behavior on height {
                    NumberAnimation {
                        duration: 110
                        easing.type: Easing.OutInQuad
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.background
                    radius: 12
                }

                Loader {
                    id: contentLoader
                    anchors.fill: parent
                    anchors.margins: root.padding
                    asynchronous: false // keep sync so sizing is correct the instant it opens
                    sourceComponent: root.appContent
                }

                TapHandler {
                    acceptedButtons: Qt.AllButtons
                    onPressedChanged: {
                        if (pressed && itemContainer.focusedItem)
                            itemContainer.focusedItem.focus = false;
                    }
                }
            }
        }
    }
}
