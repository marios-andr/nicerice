import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../Theme"
import "../Util"

Item {
    id: usgRoot
    implicitWidth: rowLayout.implicitWidth + 6
    implicitHeight: Theme.moduleHeight//rowLayout.implicitHeight + 8

    // ----------------------------
    // -- Compute CPU/RAM usages --
    // ----------------------------

    readonly property real cpuUsage: _cpuUsage   // 0.0 - 1.0
    readonly property real memUsedFraction: _memUsed   // 0.0 - 1.0
    readonly property real memUsedKb: _memUsedKb
    readonly property real memTotalKb: _memTotalKb

    property real _cpuUsage: 0
    property real _memUsed: 0
    property real _memUsedKb: 0
    property real _memTotalKb: 0

    // Previous /proc/stat sample, for computing a delta
    property var _prevIdle: 0
    property var _prevTotal: 0

    FileView {
        id: statFile
        path: "/proc/stat"
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            statFile.reload();
            memFile.reload();
        }
    }

    Connections {
        target: statFile
        function onLoaded() {
            // First line: cpu  user nice system idle iowait irq softirq steal guest guest_nice
            const line = statFile.text().split("\n")[0];
            const parts = line.trim().split(/\s+/).slice(1).map(Number);
            const idle = parts[3] + parts[4];               // idle + iowait
            const total = parts.reduce((a, b) => a + b, 0);

            const idleDelta = idle - usgRoot._prevIdle;
            const totalDelta = total - usgRoot._prevTotal;

            if (usgRoot._prevTotal !== 0 && totalDelta > 0)
                usgRoot._cpuUsage = 1 - (idleDelta / totalDelta);

            usgRoot._prevIdle = idle;
            usgRoot._prevTotal = total;
        }
    }

    Connections {
        target: memFile
        function onLoaded() {
            const text = memFile.text();
            const total = Number(text.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = Number(text.match(/MemAvailable:\s+(\d+)/)[1]);
            usgRoot._memTotalKb = total;
            usgRoot._memUsedKb = total - avail;
            usgRoot._memUsed = (total - avail) / total;
        }
    }

    // ----------------------
    // -- Show Percentages --
    // ----------------------

    property bool showPercentageText: false
    property int percentageTextWidth: usgRoot.showPercentageText ? Theme.dotSize + 20 : 0

    Rectangle {
        anchors.fill: parent
        color: usgMouse.containsMouse ? Theme.primary_hover : Theme.primary
        radius: 12

        Behavior on color {
            ColorAnimation {
                duration: 100
            }
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 2

        Rectangle {
            implicitWidth: usgRoot.percentageTextWidth
            implicitHeight: Theme.dotSize
            radius: 10
            color: usgMouse.containsMouse ? Theme.secondary_hover : Theme.secondary

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                visible: usgRoot.showPercentageText
                anchors.centerIn: parent
                text: Math.round(usgRoot.cpuUsage * 100) + "%"
                font.family: Theme.fontFamily
                color: Theme.font_secondary
            }
        }

        PercentageRing {
            percentage: usgRoot.cpuUsage
            iconSource: "../icons/cpu.svg"
        }

        Rectangle {
            implicitWidth: usgRoot.percentageTextWidth
            implicitHeight: Theme.dotSize
            radius: 10
            color: usgMouse.containsMouse ? Theme.secondary_hover : Theme.secondary

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            Text {
                visible: usgRoot.showPercentageText
                anchors.centerIn: parent
                text: Math.round(usgRoot.memUsedFraction * 100) + "%"
                font.family: Theme.fontFamily
                color: Theme.font_secondary
            }
        }

        PercentageRing {
            percentage: usgRoot.memUsedFraction
            iconSource: "../icons/ram.svg"
        }
    }

    function activate(): void {
        showPercentageText = !showPercentageText;
    }

    MouseArea {
        id: usgMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: usgRoot.activate()
    }
}
