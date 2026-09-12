import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../Theme"
import "../Util"

RowLayout {
    id: out

    property PwNode node

    readonly property var props: node.properties

    readonly property string name: (clientInfo.appName && !clientInfo.appName.includes("WirePlumber") && clientInfo.appName) || props["application.name"] || node.description || node.name

    function iconForId(id) {
        if (!id)
            return "";
        let entry = DesktopEntries.heuristicLookup(id);
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }

    readonly property string icon: iconForId(clientInfo.appId) || Quickshell.iconPath(props["application.icon-name"], true) || Quickshell.iconPath(props["application.icon"], true) || iconForId(props["pipewire.access.portal.app_id"]) || iconForId(clientInfo.appBin) || iconForId(props["application.process.binary"]) || Quickshell.iconPath("audio-x-generic", true)

    readonly property string mediaName: {
        if (!props["media.name"] || props["media.name"] === "Playback Stream" || props["media.name"].includes("announce&tr=dht") || props["media.name"] === name)
            return "";
        return props["media.name"];
    }

    readonly property string clientId: props["client.id"] || ""

    readonly property PwNodeAudio audio: node.audio

    ClientInfoResolver {
        id: clientInfo
        clientId: out.clientId
    }

    RadioButton {
        dotSize: Theme.dotSize - 4
        selected: out.node === (out.node.isSink ? Pipewire.defaultAudioSink : Pipewire.defaultAudioSource)
        visible: !out.node.isStream
        onClicked: {
            if (!selected) {
                if (out.node.isSink)
                    Pipewire.preferredDefaultAudioSink = out.node;
                else
                    Pipewire.preferredDefaultAudioSource = out.node;
            }
        }
    }

    Image {
        Layout.preferredHeight: 36
        Layout.preferredWidth: 36
        Layout.alignment: Qt.AlignTop
        fillMode: Image.PreserveAspectFit
        visible: out.node.isStream
        sourceSize.width: 36
        sourceSize.height: 36
        source: out.icon
    }

    ColumnLayout {

        RowLayout {
            Text {
                text: out.name + (out.node.isStream && out.mediaName !== "" ? " \u2022 " + out.mediaName : "")
                Layout.maximumWidth: out.implicitWidth - 36 - 10
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                wrapMode: Text.WordWrap
            }

            // TODO: more options?
        }

        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                Layout.preferredHeight: 18
                Layout.preferredWidth: 18
                Layout.alignment: Qt.AlignTop

                color: muteOutMouse.containsMouse ? Theme.secondary_hover : "transparent"
                radius: 8

                Image {
                    width: 18
                    height: 18
                    fillMode: Image.PreserveAspectFit
                    sourceSize.width: 18
                    sourceSize.height: 18
                    source: Quickshell.iconPath(out.audio.muted ? "audio-volume-muted" : "audio-volume-high")
                }

                MouseArea {
                    id: muteOutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        console.debug(out.node.id + " " + out.name + " " + out.icon + " " + out.mediaName);

                        out.audio.muted = !out.audio.muted;
                    }
                }
            }

            Slider {
                id: slider
                value: out.audio.volume
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                live: true

                onMoved: {
                    out.audio.volume = value;
                }
            }

            Text {
                Layout.minimumWidth: 39
                text: (slider.value * 100).toFixed(0) + "%"
                color: Theme.font
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
            }
        }
    }
}
