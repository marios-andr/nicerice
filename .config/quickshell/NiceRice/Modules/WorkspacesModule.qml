import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../Theme"

Item {
    id: wsRoot
    implicitWidth: rowLayout.implicitWidth + 16
    implicitHeight: rowLayout.implicitHeight + 8

    // Minimum number of workspaces to always display, even when empty. The list
    // still grows beyond this to reveal any higher-numbered workspace that
    // exists (e.g. switching to workspace 6 while this is 5 adds a 6th dot).
    property int minWorkspaces: 5

    // The individual workspace buttons, exposed so StatusbarWindow can splice
    // them into its keyboard-navigation list. Rebuilt whenever workspaces are
    // added or removed.
    property var navButtons: []

    function rebuildNavButtons(): void {
        let a = [];
        for (let i = 0; i < rep.count; i++)
            a.push(rep.itemAt(i));
        wsRoot.navButtons = a;
    }

    // Computes the maximum workspace id to render. Used for workspaceIds,
    // and separated from it to stop needless rebuilding of the repeaters.
    readonly property int maxWorkspaceId: {
        let maxId = Math.max(1, wsRoot.minWorkspaces);
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].id > maxId)
                maxId = list[i].id;
        return maxId;
    }

    // The workspace ids to render: 1..N, where N is at least minWorkspaces and
    // extends to cover the highest-numbered workspace that currently exists.
    readonly property var workspaceIds: {
        let ids = [];
        for (let id = 1; id <= wsRoot.maxWorkspaceId; id++)
            ids.push(id);
        return ids;
    }

    // A set of live Hyprland workspace ids (Hyprland only tracks workspaces that
    // hold windows or are focused).
    readonly property var occupiedWorkspaces: {
        const list = Hyprland.workspaces.values;
        let s = new Set();
        for (let i = 0; i < list.length; i++)
            s.add(list[i].id);
        return s;
    }

    // Queries occipiedWorkspaces to determine if a id is occupied.
    function isOccupied(id: int): bool {
        return wsRoot.occupiedWorkspaces.has(id);
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.primary
        radius: 14
    }

    // Background of occupied workspaces
    Repeater {
        model: Math.max(0, wsRoot.workspaceIds.length)
        delegate: Rectangle {
            required property int index
            readonly property int leftId: wsRoot.workspaceIds[index]
            readonly property int rightId: index + 1 < wsRoot.workspaceIds.length ? wsRoot.workspaceIds[index + 1] : -1
            readonly property bool leftOccupied: wsRoot.isOccupied(leftId)
            readonly property bool rightOccupied: wsRoot.isOccupied(rightId)

            visible: leftOccupied
            color: Theme.secondary
            radius: 14
            implicitWidth: (leftOccupied && rightOccupied) ? (Theme.dotSize * 2 + rowLayout.spacing) : Theme.dotSize
            implicitHeight: leftOccupied ? Theme.dotSize : 0

            // Map leftItem's origin from rowLayout's coordinate space into wsRoot's
            x: rowLayout.x + index * (Theme.dotSize + rowLayout.spacing)
            y: rowLayout.y
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 2

        Repeater {
            id: rep
            model: wsRoot.workspaceIds

            onItemAdded: {
                wsRoot.rebuildNavButtons();
            }
            onItemRemoved: {
                wsRoot.rebuildNavButtons();
            }

            delegate: Rectangle {
                id: ws
                implicitWidth: Theme.dotSize
                implicitHeight: Theme.dotSize
                // radius: 16
                // color: occupied ? Theme.secondary : Theme.primary
                color: "transparent"

                // The workspace id
                required property var modelData

                // Set by statusbar
                property bool focused: false
                // Does this workspace have windows in it
                readonly property bool occupied: wsRoot.isOccupied(ws.modelData)
                // Is this the currently focused workspace
                readonly property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === ws.modelData

                //Active workspace inner small dot
                Rectangle {
                    anchors.centerIn: parent
                    visible: ws.isActive
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.selected
                }

                Text {
                    anchors.centerIn: parent
                    text: ws.modelData
                    font.family: Theme.fontFamily
                    color: ws.occupied ? Theme.font : Theme.font_inactive
                    visible: !ws.isActive
                }

                // Run this workspace's action (mouse click or keyboard Return).
                // Hyprland with Lua dispatchers ignores the plain "workspace N"
                // string, so branch on usingLua the same way the overview does.
                function activate(): void {
                    if (Hyprland.usingLua)
                        Hyprland.dispatch("hl.dsp.focus({workspace = '" + ws.modelData + "'})");
                    else
                        Hyprland.dispatch("workspace " + ws.modelData);
                }

                MouseArea {
                    id: wsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ws.activate()
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: "transparent"
                    border.color: Theme.secondary_hover
                    border.width: 2
                    opacity: wsMouse.containsMouse ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}
