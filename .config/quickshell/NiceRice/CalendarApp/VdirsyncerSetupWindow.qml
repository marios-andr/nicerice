import QtQml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../Theme"
import "../Util"

/*
Stage 0: Just text
Stage 1:
- Create vdirsyncer config, and set status_path
- Accept name, client id, client secret from user (TODO: Must check name for duplicate calendars)
Stage 2:
- Append to the vdirsyncer config the google remote/local pair
- vdirsyncer discover google_calendar
- vdirsyncer sync
- Append calendars to khal config
Stage 3:
- Done!
*/
FloatingWindow {
    id: root
    title: "VDirSycner Google Setup Wizard"
    color: Theme.primary
    implicitWidth: 600
    implicitHeight: 500

    readonly property string homePath: Quickshell.env("HOME") || ""
    readonly property string defaultCalendarsPath: homePath + "/.calendars"
    readonly property string vdirsyncerStatusPath: homePath + "/.local/share/vdirsyncer/status"
    readonly property string vdirsyncerConfigPath: homePath + "/.config/vdirsyncer"
    readonly property string khalConfigPath: homePath + "/.config/khal/config"

    property int stage: 0

    property bool invalidName: false
    property bool invalidPath: false
    property bool invalidId: false
    property bool invalidSecret: false

    property bool failed: false

    signal done

    function isAlphanumericUnderscore(str) {
        return /^[a-zA-Z0-9_]+$/.test(str);
    }

    // Initialize vdirsyncer config file
    Process {
        id: vdirsyncerSetup
        running: root.stage === 1
        command: ["sh", "-c", `
        set -e
        mkdir -p ${root.vdirsyncerStatusPath}
        mkdir -p ${root.vdirsyncerConfigPath}

        if [ ! -f ${root.vdirsyncerConfigPath}/config ]; then
            cat > ${root.vdirsyncerConfigPath}/config << 'EOF'
[general]
status_path = "${root.vdirsyncerStatusPath}"
EOF
        fi
    `]

        stdout: SplitParser {
            onRead: line => console.log("vdirsyncer-setup:", line)
        }
        stderr: SplitParser {
            onRead: line => console.warn("vdirsyncer-setup error:", line)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("vdirsyncer-setup failed with code", exitCode);
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            // Layout.margins: 6
            Layout.preferredHeight: 35
            color: Theme.background_hover

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 25
                text: "VDirSyncer Google Setup Wizard"
                color: Theme.font
                font.family: Theme.fontFamily
            }
        }

        // -------------
        // -- Stage 0 --
        // -------------

        Text {
            visible: root.stage === 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            text: `
Google doesn't let third-party tools use a shared client ID/secret, you need your own. This is a one-time setup - blame google:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/) and create a new project (any name).
2. In the sidebar, go to **APIs & Services -> Library**, search for and enable:
   - **CalDAV API**
   - **CardDAV API** (only needed if you'll sync contacts too)
   - Do **not** enable "Google Calendar API" — that's a different, incompatible API.
3. Go to **APIs & Services -> OAuth consent screen**.
4. Go to **APIs & Services -> Credentials -> Create Credentials -> OAuth Client ID**.
   - Application type: **Desktop app**.
5. Save the resulting **Client ID** and **Client Secret** — you'll paste these into the vdirsyncer config next.
6. In **APIs & Services -> OAuth consent screen -> Audience** add yourself as a test user (Authentication tokens last only 7 days) OR publish your product 

When ready press the button below
`
            textFormat: TextEdit.MarkdownText
            wrapMode: Text.Wrap
            color: Theme.font
            font.family: Theme.fontFamily

            onLinkActivated: link => Qt.openUrlExternally(link)
        }

        // -------------
        // -- Stage 1 --
        // -------------
        ColumnLayout {
            visible: root.stage === 1
            Layout.fillWidth: true
            Layout.leftMargin: 40
            Layout.rightMargin: 50

            Text {
                text: "Calendar Name - Can contain alphanumeric characters and the underscore"
                color: Theme.font
                font.family: Theme.fontFamily
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: nameField.hovered ? Theme.secondary_hover : Theme.secondary
                border.width: 1
                border.color: root.invalidName ? "#e06c75" : Theme.secondary_border

                TextField {
                    id: nameField
                    anchors.fill: parent
                    anchors.margins: 4
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Normal
                    color: Theme.font
                    font.family: Theme.fontFamily
                    selectByMouse: true
                    background: Item {}
                    hoverEnabled: true
                    onTextChanged: root.invalidName = false
                    Keys.onTabPressed: pathField.focus = true
                }
            }

            Text {
                text: "Calendar Path"
                color: Theme.font
                font.family: Theme.fontFamily
                wrapMode: Text.Wrap
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: pathField.hovered ? Theme.secondary_hover : Theme.secondary
                border.width: 1
                border.color: root.invalidPath ? "#e06c75" : Theme.secondary_border

                TextField {
                    id: pathField
                    anchors.fill: parent
                    anchors.margins: 4
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Normal
                    placeholderText: root.defaultCalendarsPath
                    placeholderTextColor: Theme.font_inactive
                    color: Theme.font
                    font.family: Theme.fontFamily
                    selectByMouse: true
                    background: Item {}
                    hoverEnabled: true
                    onTextChanged: root.invalidPath = false
                    Keys.onTabPressed: idField.focus = true
                }
            }

            Text {
                text: "Google Client ID"
                color: Theme.font
                font.family: Theme.fontFamily
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: idField.hovered ? Theme.secondary_hover : Theme.secondary
                border.width: 1
                border.color: root.invalidId ? "#e06c75" : Theme.secondary_border

                TextField {
                    id: idField
                    anchors.fill: parent
                    anchors.margins: 4
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Normal
                    color: Theme.font
                    font.family: Theme.fontFamily
                    // placeholderText: "Calendar name"
                    // placeholderTextColor: Theme.font_inactive
                    selectByMouse: true
                    background: Item {}
                    hoverEnabled: true
                    onTextChanged: root.invalidId = false
                    Keys.onTabPressed: secretField.focus = true
                }
            }

            Text {
                text: "Google Client Secret"
                color: Theme.font
                font.family: Theme.fontFamily
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 32
                color: secretField.hovered ? Theme.secondary_hover : Theme.secondary
                border.width: 1
                border.color: root.invalidSecret ? "#e06c75" : Theme.secondary_border

                TextField {
                    id: secretField
                    anchors.fill: parent
                    anchors.margins: 4
                    verticalAlignment: TextInput.AlignVCenter
                    echoMode: TextInput.Normal
                    color: Theme.font
                    font.family: Theme.fontFamily
                    // placeholderText: "Calendar name"
                    // placeholderTextColor: Theme.font_inactive
                    selectByMouse: true
                    background: Item {}
                    hoverEnabled: true
                    onTextChanged: root.invalidSecret = false
                }
            }
        }

        // ---------------
        // -- Stage 2/3 --
        // ---------------
        ColumnLayout {
            visible: root.stage === 2 || root.stage === 3
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter

            Text {
                id: progressText
                Layout.alignment: Qt.AlignVCenter
                text: "Configuring vdirsyncer config.."
                color: Theme.font
                font.family: Theme.fontFamily
                wrapMode: Text.Wrap
            }

            Spinner {
                Layout.alignment: Qt.AlignVCenter
                sizeUnit: 1
                visible: !root.failed && root.stage !== 3
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: 100
            implicitHeight: 30
            color: continueMouse.containsMouse ? Theme.secondary_hover : Theme.secondary
            radius: 8
            border.width: 2
            border.color: Theme.secondary_border

            Text {
                anchors.centerIn: parent
                text: root.stage === 3 ? "Done" : "Continue"
                color: Theme.font
                font.family: Theme.fontFamily
            }

            MouseArea {
                id: continueMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.stage === 0)
                        root.stage++;
                    if (root.stage === 1) { // TODO: ASk to retry on duplicate name
                        if (!root.isAlphanumericUnderscore(nameField.text))
                            root.invalidName = true;
                        else if (idField.text === "")
                            root.invalidId = true;
                        else if (secretField.text === "")
                            root.invalidSecret = true;
                        else {
                            root.name = nameField.text;
                            root.path = pathField.text || pathField.placeholderText;
                            root.clientId = idField.text;
                            root.clientSecret = secretField.text;
                            root.stage++;
                        }
                    } else if (root.stage === 3) {
                        root.done();
                    }
                }
            }
        }
    }

    property string name
    property string path // TODO: check if path exists
    property string clientId
    property string clientSecret

    Process {
        id: googleCalendarPairSetup
        running: root.stage === 2
        environment: ({
                CLIENT_ID: clientId,
                CLIENT_SECRET: clientSecret
            })

        command: ["bash", "-c", `
        set -e
        mkdir -p ${root.path}
        CONFIG="${root.vdirsyncerConfigPath}/config"

        if grep -q '\\[pair ${root.name}\\]' "$CONFIG"; then
            echo "${root.name} pair already present, skipping"
            exit 0
        fi

        cat >> "$CONFIG" << EOF

[pair ${root.name}]
a = "${root.name}_local"
b = "${root.name}_remote"
collections = ["from b"]
metadata = ["color", "displayname"]

[storage ${root.name}_local]
type = "filesystem"
path = "${root.path}/${root.name}"
fileext = ".ics"

[storage ${root.name}_remote]
type = "google_calendar"
token_file = "${root.vdirsyncerConfigPath}/google_token"
client_id = "$CLIENT_ID"
client_secret = "$CLIENT_SECRET"
EOF
    `]

        stdout: SplitParser {
            onRead: line => console.log("google-calendar-setup:", line)
        }
        stderr: SplitParser {
            onRead: line => console.warn("google-calendar-setup error:", line)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("google-calendar-setup failed with code", exitCode);
                progressText.text += "\n Process failed exceptionally."
                root.stage = 3;
            } else {
                console.log("google-calendar-setup success");
                progressText.text += "success! \n Waiting for browser login..";
                vdirsyncerRun.running = true;
            }
        }
    }

    Process {
        id: vdirsyncerRun
        running: false
        command: ["bash", "-c", `
        set -e
        yes | vdirsyncer discover ${root.name}
        vdirsyncer sync
    `]

        stdout: SplitParser {
            onRead: line => console.log("vdirsyncer:", line)
        }
        stderr: SplitParser {
            onRead: line => console.warn("vdirsyncer error:", line)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("vdirsyncer discover/sync failed with code", exitCode);
                progressText.text += "\n Process failed exceptionally."
                root.stage = 3;
            } else {
                console.log("vdirsyncer discover/sync completed successfully");
                progressText.text += "success! \n Configuring khal..";
                khalCalendarSetup.running = true;
            }
        }
    }

    Process {
        id: khalCalendarSetup
        running: false
        command: ["bash", "-c", `
        set -e
CONFIG="${root.khalConfigPath}"
BASE="${root.path}/${root.name}"

shopt -s nullglob
ENTRIES=""
for dir in "$BASE"/*/; do
    name="$(basename "$dir")"
    ENTRIES="\${ENTRIES}
[[\${name}]]
path = \${BASE}/\${name}
type = calendar
"
done
shopt -u nullglob

awk -v entries="$ENTRIES" '
    { print }
    index($0, "[calendars]") == 1 && !inserted {
        print entries
        inserted = 1
    }
' "\${CONFIG}" > "\${CONFIG}.tmp" && mv "\${CONFIG}.tmp" "\${CONFIG}"
    `]

        stdout: SplitParser {
            onRead: line => console.log("khal-setup:", line)
        }
        stderr: SplitParser {
            onRead: line => console.warn("khal-setup error:", line)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                console.warn("khal calendar setup failed with code", exitCode);
                progressText.text += "\n Process failed exceptionally."
                root.stage = 3;
            } else {
                progressText.text += "success!";
                root.stage++;
            }
        }
    }
}
