import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: clientInfoResolver

    property string appId: ""

    property string appName: ""

    property string appBin: ""

    // The client ID to query (set this from node.properties["client.id"])
    property string clientId: ""

    // property bool running: false

    onClientIdChanged: {
        if (clientId !== "") {
            pwProcess.running = false;
            Qt.callLater(() => {
                pwProcess.running = true;
            });
        }
    }

    property Process pwProcess: Process {
        id: pwProcess
        // pw-cli info outputs the properties of a specific object ID
        command: ["pw-cli", "i", clientInfoResolver.clientId]
        running: false

        stderr: StdioCollector {
            onStreamFinished: {
                //console.log(JSON.stringify(pwProcess.command) + " STDERR:", text);
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                //console.log("COMMAND WAS:", pwProcess.command);
                //console.log("RAW OUTPUT:", JSON.stringify(text));

                let output = text.trim();

                // Extract the flatpak app_id
                let appIdMatch = output.match(/pipewire\.access\.portal\.app_id = "(.*?)"/);
                if (appIdMatch && appIdMatch[1]) {
                    clientInfoResolver.appId = appIdMatch[1];
                }

                // Extract the application.name
                let appNameMatch = output.match(/application\.name = "(.*?)"/);
                if (appNameMatch && appNameMatch[1]) {
                    clientInfoResolver.appName = appNameMatch[1];
                }

                let appBinMatch = output.match(/application\.process\.binary = "(.*?)"/);
                if (appBinMatch && appBinMatch[1]) {
                    clientInfoResolver.appBin = appBinMatch[1];
                }
            }
        }
    }
}
