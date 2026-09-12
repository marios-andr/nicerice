pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string homePath: Quickshell.env("HOME") || ""

    // Whether khal and the config exists
    property bool initialized: false
    // Whether vdirsyncer is installed
    property bool vdirsyncerInstalled: false
    // Unload unnecessary event data when not needed
    property bool should_load_events: false
    // Unload unnecessary calendar data when not needed
    // property bool should_load_calendars: false
    // The events container
    property alias events: eventsLoader.item
    // The calendars container
    property alias calendars: calsLoader.item

    function reload() {
        if (root.initialized) {
            calendars.reload()
        }
    }

    // Check if khal is installed.
    Process {
        id: khalCheck
        command: ["which", "khal"]
        running: true

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                khalInit.running = true;
                vdirsyncerCheck.running = true;
            }
        }
    }

    Process {
        id: vdirsyncerCheck
        command: ["which", "vdirsyncer"]

        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.vdirsyncerInstalled = true;
            }
        }
    }

    // If no khal config exists, create it and a local calendar.
    Process {
        id: khalInit
        command: ["sh", "-c", `
        mkdir -p ~/.local/share/khal/calendars/personal
        mkdir -p ~/.config/khal
        if [ ! -f ~/.config/khal/config ]; then
            cat > ~/.config/khal/config << 'EOF'
            [calendars]
[[personal]]
path = ~/.local/share/khal/calendars/personal
color = dark blue
type = calendar

[default]
default_calendar = personal

[locale]
dateformat= %x
longdateformat= '%A, %-d %B %Y'
timeformat= %H:%M
datetimeformat= %c
longdatetimeformat= '%A, %d %B %Y %H:%M'
EOF
        fi
    `]
        onExited: (exitCode, exitStatus) => {
            root.initialized = true;
        }
    }

    Loader {
        id: eventsLoader
        active: root.initialized && root.should_load_events
        sourceComponent: Scope {
            id: config

            property var lookup: ({})
            property date calendarDate
            readonly property string monthStartDate: {
                let a = new Date(calendarDate.getFullYear(), calendarDate.getMonth() - 1, 1);
                return Qt.formatDateTime(a, "yyyy-MM-dd");
            }
            readonly property string monthEndDate: {
                let a = new Date(calendarDate.getFullYear(), calendarDate.getMonth() + 2, 0);
                return Qt.formatDateTime(a, "yyyy-MM-dd");
            }

            Component.onCompleted: {
                if (root.vdirsyncerInstalled) {
                    Quickshell.execDetached(["vdirsyncer", "sync"]);
                    Quickshell.execDetached(["vdirsyncer", "metasync"]);
                }
            }

            onMonthStartDateChanged: {
                if (!calendarDate)
                    return;
                eventsProc.running = false;

                Qt.callLater(() => {
                    eventsProc.running = true;
                });
            }

            Process {
                id: eventsProc

                command: [root.homePath + "/.config/nicerice/bin/khal-helper", "list", "--start-date", config.monthStartDate, "--end-date", config.monthEndDate]

                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            let days = JSON.parse(text);
                            let merged = Object.assign({}, config.lookup);
                            for (const day of days)
                                merged[day.date] = day.events;
                            config.lookup = merged;
                        } catch (e) {
                            console.log("khal: failed to parse JSON output:", e);
                        }
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.trim().length > 0)
                            console.log("khal-helper list stderr:", text.trim());
                    }
                }
            }
        }
    }

    Loader {
        id: calsLoader
        active: root.initialized
        sourceComponent: Scope {
            id: cals

            property var calendars: ({})
            property string default_calendar: ""
            
            function reload() {
                calsProc.running = false
                calsProc.running = true
            }

            Process {
                id: calsProc
                running: true
                command: [root.homePath + "/.config/nicerice/bin/khal-helper", "calendars"]

                stdout: StdioCollector {
                    onStreamFinished: {
                        try {
                            // console.debug("loaded calendars")
                            cals.calendars = JSON.parse(text);
                        } catch (e) {
                            console.log("khal: failed to parse JSON output:", e);
                        }
                    }
                }

                stderr: StdioCollector {
                    onStreamFinished: {
                        if (text.trim().length > 0)
                            console.log("khal-helper calendars stderr:", text.trim());
                    }
                }
            }
        }
    }
}

// readonly property string configPath: homePath + "/.config/khal/config"
// readonly property string scriptPath: homePath + "/.config/nicerice/scripts/"

// readonly property var calendars: get("calendars", {})
// readonly property string defaultCalendar: get("default.default_calendar", "")
// readonly property string dateformat: get("locale.dateformat", "")

// // Generic dotted-path getter, e.g. get("default.default_calendar")
// function get(path, fallback) {
//     const parts = path.split(".");
//     let node = data;
//     for (const p of parts) {
//         if (node === undefined || node === null)
//             return fallback;
//         node = node[p];
//     }
//     return node === undefined ? fallback : node;
// }

// // Generic dotted-path setter, e.g. set("default.default_calendar", "work")
// function set(path, value) {
//     const parts = path.split(".");
//     const patch = {};
//     let node = patch;
//     for (let i = 0; i < parts.length - 1; i++) {
//         node[parts[i]] = {};
//         node = node[parts[i]];
//     }
//     node[parts[parts.length - 1]] = value;
//     writeProc.patch = patch;
//     writeProc.running = true;
// }

// function reload() {
//     readProc.running = true;
// }

// Component.onCompleted: reload()

// Process {
//     id: readProc
//     command: ["python3", config.scriptPath + "read-khalconf.py", config.configPath]
//     stdout: StdioCollector {
//         onStreamFinished: {
//             try {
//                 config.data = JSON.parse(this.text);
//                 config.loaded = true;
//             } catch (e) {
//                 console.warn("KhalConfig: failed to parse khal config:", e);
//             }
//         }
//     }
// }

// Process {
//     id: writeProc
//     property var patch: ({})
//     command: ["python3", config.scriptPath + "write-khalconf.py", config.configPath]
//     stdinEnabled: true
//     onRunningChanged: if (running)
//         write(JSON.stringify(patch))
//     onExited: config.reload()
// }
