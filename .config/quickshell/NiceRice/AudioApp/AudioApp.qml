pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import "../Theme"

/*
Pipewire:
- links: PwLink[] (use PwNodeLinkTracker instead)
- linkGroups: PwLinkGroup[]
+ nodes: PwNode[]
    PwNode.isStream - if the node is an application or hardware device.
    PwNode.isSink - if the node is a sink or source.
    PwNode.audio - if non null the node is an audio node.
+ defaultAudioSink: PwNode (readonly)
+ preferredDefaultAudioSink: PwNode
- defaultAudioSource: PwNode (readonly)
- preferredDefaultAudioSource

PwNode:
+ name
- audio: PwNodeAudio
+ isSink
+ properties
+ description
- ready
+ isStream
- type

PwNodeAudio:
+ muted
+ volume
- volumes
- channels


*/
ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: 4

    readonly property int windowWidth: 450
    readonly property int maxWindowHeight: 485

    property bool category

    ScriptModel {
        id: inputDevices
        values: [...Pipewire.nodes.values].filter(n => !n.isStream && !n.isSink && n.audio)
    }

    ScriptModel {
        id: outputDevices
        values: [...Pipewire.nodes.values].filter(n => !n.isStream && n.isSink && n.audio)
    }

    ScriptModel {
        id: inputStreams
        values: [...Pipewire.nodes.values].filter(n => n.isStream && !n.isSink && n.audio)
    }

    ScriptModel {
        id: outputStreams
        values: [...Pipewire.nodes.values].filter(n => n.isStream && n.isSink && n.audio)
    }

    PwObjectTracker {
        objects: [...inputDevices.values, ...outputDevices.values, ...inputStreams.values, ...outputStreams.values]
    }

    // ----------------------------
    // -- Applications - Devices --
    // ----------------------------
    RowLayout {
        Layout.fillWidth: true

        Item {
            Layout.preferredWidth: root.windowWidth / 2
            Layout.preferredHeight: 25

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 25
                    color: appsMouse.containsMouse || !root.category ? Theme.background_hover : "transparent"
                    topLeftRadius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Applications"
                        color: !root.category ? Theme.font : (appsMouse.containsMouse ? Theme.font_secondary : Theme.font_inactive)
                        font.family: Theme.fontFamily
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 3
                    Layout.preferredWidth: !root.category || appsMouse.containsMouse ? root.windowWidth / 2 : 0
                    color: Theme.selected

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 110
                        }
                    }
                }
            }
            MouseArea {
                id: appsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.category = false
            }
        }

        Item {
            Layout.preferredWidth: root.windowWidth / 2
            Layout.preferredHeight: 25

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.preferredHeight: 25
                    color: devsMouse.containsMouse || root.category ? Theme.background_hover : "transparent"
                    topRightRadius: 8

                    Text {
                        anchors.centerIn: parent
                        text: "Devices"
                        color: root.category ? Theme.font : (devsMouse.containsMouse ? Theme.font_secondary : Theme.font_inactive)
                        font.family: Theme.fontFamily
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredHeight: 3
                    Layout.preferredWidth: root.category || devsMouse.containsMouse ? root.windowWidth / 2 : 0
                    color: Theme.selected

                    Behavior on Layout.preferredWidth {
                        NumberAnimation {
                            duration: 110
                        }
                    }
                }
            }
            MouseArea {
                id: devsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.category = true
            }
        }
    }

    // -----------------------
    // -- Devices - Streams --
    // -----------------------
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: plz.implicitHeight + 20
        Layout.maximumHeight: root.maxWindowHeight
        color: Theme.primary
        bottomLeftRadius: 8
        bottomRightRadius: 8

        ScrollView {
            anchors.fill: parent
            anchors.margins: 10
            clip: true
            padding: 0
            contentWidth: availableWidth

            ColumnLayout {
                id: plz
                width: parent.width
                spacing: 11

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Output " + (!root.category ? "Streams " : "Devices ")
                        color: Theme.font_secondary
                        font.family: Theme.fontFamily
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.font_secondary
                    }
                }

                // ------------
                // -- Output --
                // ------------

                Repeater {
                    model: !root.category ? outputStreams : outputDevices
                    delegate: AudioCard {
                        Layout.fillWidth: true

                        required property PwNode modelData
                        node: modelData
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Input " + (!root.category ? "Streams " : "Devices ")
                        color: Theme.font_secondary
                        font.family: Theme.fontFamily
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Theme.font_secondary
                    }
                }

                // -----------
                // -- Input --
                // -----------

                Repeater {
                    model: !root.category ? inputStreams : inputDevices
                    delegate: AudioCard {
                        Layout.fillWidth: true

                        required property PwNode modelData
                        node: modelData
                    }
                }
            }
        }
    }
}
