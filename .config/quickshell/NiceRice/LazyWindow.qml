pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root
    property string ipcTarget
    default property Component content

    signal activation(active: bool)

    IpcHandler {
        target: root.ipcTarget

        function open(): void {
            loader.active = true;
        }

        function toggle(): void {
            loader.active = !loader.active;
        }

        function close(): void {
            loader.active = false;
        }
    }

    LazyLoader {
        id: loader
        active: false
        component: root.content

        onActiveChanged: {
            root.activation(active);

            if (active && loader.item) {
                loader.item.closed.connect(function () {
                    loader.active = false
                })
            }
        }
    }
}
