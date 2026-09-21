import QtQuick
import Quickshell

AppsProvider {
    prefix: ">"
    icon: "text-x-script"
    name: "Commands"

    function update(query) {
        results = [];
    }
}