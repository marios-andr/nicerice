import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property string pendingConName

    // Fired when nmcli finishes
    signal setupFinished(bool success, string output)

    Process {
        id: nmcliProcess
        running: false

        stdout: StdioCollector {
            id: stdoutCollector
        }
        stderr: StdioCollector {
            id: stderrCollector
        }

        onExited: (regularExit, exitCode) => {
            const success = regularExit && exitCode === 0
            const output = success ? stdoutCollector.text : stderrCollector.text

            Quickshell.execDetached(["nmcli", "connection", "up", root.pendingConName]);

            root.setupFinished(success, output)
            if (!success) {
                console.warn("nmcli setup failed:", output)
            } else {
                console.log("nmcli setup succeeded:", output)
            }
        }
    }

    // Sets up (or updates) a WPA/WPA2-Enterprise wifi connection profile.
    //
    // ssid          - network SSID (required)
    // username      - 802.1x identity (required)
    // password      - 802.1x password (required)
    // conName       - connection profile name (defaults to ssid)
    // eap           - EAP method: "peap" (default), "ttls", or "tls"
    // phase2Auth    - phase2 auth method, used for peap/ttls (default "mschapv2")
    // caCertPath    - optional path to a CA cert file to validate the server
    // ifname        - network interface to bind to (default "*" = any wifi device)
    function setupEnterpriseWifi(ssid, username, password, conName, eap, phase2Auth, caCertPath, ifname) {
        conName = conName || ssid
        eap = eap || "peap"
        phase2Auth = phase2Auth || "mschapv2"
        ifname = ifname || "*"

        let args = [
            "connection", "add",
            "type", "wifi",
            "ifname", ifname,
            "con-name", conName,
            "ssid", ssid,
            "802-11-wireless-security.key-mgmt", "wpa-eap",
            "802-1x.eap", eap,
            "802-1x.identity", username,
            "802-1x.password", password
        ]

        // phase2-auth only applies to peap/ttls, not tls
        if (eap !== "tls") {
            args.push("802-1x.phase2-auth", phase2Auth)
        }

        if (caCertPath) {
            args.push("802-1x.ca-cert", caCertPath)
        }

        pendingConName = conName;
        nmcliProcess.command = ["nmcli"].concat(args)
        nmcliProcess.running = true
    }
}