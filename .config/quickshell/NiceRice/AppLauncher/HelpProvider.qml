import QtQuick
import Quickshell

AppsProvider {
    prefix: "?"
    icon: "help-hint"
    name: "Help"

    property var providers

    function update(query) {
        const a = [];
        for (const p of providers) {
            a.push({
                name: p.prefix + " " + p.name,
                icon: p.icon
            });
        }
        results = a;
    }
}
