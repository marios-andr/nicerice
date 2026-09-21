import QtQuick
import Quickshell
import "../resources/js/search.js" as Search

QtObject {
    property string prefix: ""
    property string icon: ""
    property string name: "Apps"
    property var results: [] //[{ name, icon, desc, execute: function }]
    property var prepared: Search.prepare(DesktopEntries.applications.values)

    property var frequencies: []

    property string lastQuery: ""
    onPreparedChanged: update(lastQuery)
    onFrequenciesChanged: update(lastQuery)

    function update(query: string) {
        results = Search.search(query, prepared, frequencies);
        lastQuery = query
    }
}
