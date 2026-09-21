import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../Theme"
import "../Util"
import "../AudioApp"

Loader {
    active: Pipewire.ready
    sourceComponent: Item {
        id: root
        implicitWidth: rowLayout.implicitWidth + 10
        implicitHeight: Theme.moduleHeight//rowLayout.implicitHeight + 8

        readonly property real volume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
        function iconSource(): string {
            if (Pipewire.defaultAudioSink?.audio?.muted)
                return Quickshell.iconPath("audio-volume-muted");
            if (volume < 1.0 / 3)
                return Quickshell.iconPath("audio-volume-low");
            if (volume < 2.0 / 3)
                return  Quickshell.iconPath("audio-volume-medium");
            return  Quickshell.iconPath("audio-volume-high");
        }

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Rectangle {
            anchors.fill: parent
            color: app.buttonHovered ? Theme.secondary : Theme.primary
            radius: 14

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

            Image {
                Layout.alignment: Qt.AlignVCenter
                source: root.iconSource()
                sourceSize.width: 20
                sourceSize.height: 20
                width: 20
                height: 20
                fillMode: Image.PreserveAspectFit
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: Theme.dotSize + 16
                implicitHeight: Theme.dotSize - 2
                radius: 10
                color: app.buttonHovered ? Theme.secondary_hover : Theme.secondary

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: (root.volume * 100).toFixed(0) + "%"
                    font.pixelSize: Theme.fontSize - 1
                    font.family: Theme.fontFamily
                    color: Theme.font_secondary
                }
            }
        }

        StatusbarApp {
            id: app
            anchorItem: root
            yOffset: 6
            onClicked: app.toggleExpanded()
            onExited: app.syncVisibility()
            appContent: AudioApp {}
        }
    }
}
