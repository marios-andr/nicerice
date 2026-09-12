pragma Singleton

import QtQml
import QtQml.Models
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: root

    readonly property var notifications: server.trackedNotifications

    property var trackedMeta: ({})

    property bool dnd: false

    property alias history: history

    property int notificationCount: history.count

    // Convenience method for finding index from key
    function findGroupIndex(appKey) {
        for (let i = 0; i < history.count; i++) {
            let g = history.get(i);
            if (g.appName === appKey) {
                return i;
            }
        }
        return -1;
    }

    function findNotificationIndex(notifsModel, id) {
        for (let i = 0; i < notifsModel.count; i++) {
            if (notifsModel.get(i).id === id) {
                return i;
            }
        }
        return -1;
    }

    function deleteNotification(entry) {
        let groupKey = entry.desktopEntry || entry.appName;
        let groupIndex = findGroupIndex(groupKey);
        if (groupIndex === -1) {
            console.warn("deleteNotification: no group found for " + groupKey);
            return;
        }

        let notifsModel = history.get(groupIndex).notifications;
        let noteIndex = findNotificationIndex(notifsModel, entry.id);
        if (noteIndex === -1) {
            console.warn("deleteNotification: notification id " + entry.id + " not found in group " + groupKey);
            return;
        }

        notifsModel.remove(noteIndex);

        if (notifsModel.count === 0) {
            history.remove(groupIndex);
        }
    }

    function clearNotifications() {
        history.clear();
    }

    function appendNotification(n: Notification) {
        let entry = {
            id: n.id,
            urgency: n.urgency,
            appName: n.appName,
            image: n.image,
            appIcon: n.appIcon,
            summary: n.summary,
            body: n.body,
            desktopEntry: n.desktopEntry,
            receivedAt: Qt.formatDateTime(new Date(), "HH:mm")
        };

        // find existing group for this app
        let groupIndex = findGroupIndex(n.desktopEntry || n.appName);

        if (groupIndex === -1) {
            // no group yet, create one
            history.append({
                appName: n.desktopEntry || n.appName,
                appIcon: n.appIcon,
                notifications: [entry]
            });
        } else {
            // group exists, append into its nested list
            history.get(groupIndex).notifications.append(entry);
        }
    }

    ListModel {
        id: history
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        persistenceSupported: true
        // TODO: inlineReplySupported, bodyImagesSupported, bodyMarkupSupported,
        //       actionsSupported, bodyHypelinksSupported, actionIconsSupported

        onNotification: n => {
            n.tracked = true;
            n.closed.connect(reason => {
                if (reason === NotificationCloseReason.Expired && !n.transient) {
                    root.appendNotification(n);
                }
                delete root.trackedMeta[n.id];
            });

            root.trackedMeta[n.id] = {
                receivedAt: Qt.formatDateTime(new Date(), "HH:mm")
            };
        }
    }
}
