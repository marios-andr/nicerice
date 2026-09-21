import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    property string input
    property var providers: [help, cmd, dir, apps]

    readonly property var active: providers.find(p => p.prefix !== "" && input.startsWith(p.prefix)) ?? apps
    readonly property string query: active.prefix === "" ? input : input.slice(active.prefix.length).trim()
    readonly property var results: active.results

    onQueryChanged: active.update(query)
    // onActiveChanged: active.update(query)

    function launchSelected(selected) {
        if (selected instanceof DesktopEntry) {
            selected.execute();
            freq.bump(selected.id);
        }
    }

    AppsProvider {
        id: apps
        frequencies: freq.counts
    }

    CommandsProvider {
        id: cmd
    }

    DirectoryProvider {
        id: dir
    }

    HelpProvider {
        id: help
        providers: root.providers
    }

    QtObject {
        id: freq
        property var counts: ({})

        property FileView file: FileView {
            path: Quickshell.statePath("launcher/frequency.json")
            atomicWrites: true          // avoids a corrupt file if you crash mid-write
            onLoaded: {
                try {
                    freq.counts = JSON.parse(text());
                    console.debug(text());
                } catch (e) {
                    freq.counts = {};
                }
            }
            onLoadFailed: freq.counts = {}   // first run: file doesn't exist yet
        }

        function bump(id) {
            const c = Object.assign({}, counts);   // new object so bindings update
            c[id] = (c[id] ?? 0) + 1;
            counts = c;
            file.setText(JSON.stringify(c));
        }
    }
}
