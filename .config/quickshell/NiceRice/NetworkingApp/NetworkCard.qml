import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import "../Theme"
import "../Util"

Rectangle {
    id: card
    property Network network
    readonly property bool isWifi: network instanceof WifiNetwork
    readonly property bool needsPassword: isWifi && (network.security === WifiSecurityType.WpaPsk || network.security === WifiSecurityType.Wpa2Psk || network.security === WifiSecurityType.Sae)
    readonly property bool needsUser: isWifi && (network.security === WifiSecurityType.WpaEap || network.security === WifiSecurityType.Wpa2Eap)
    readonly property bool needsCredentials: needsPassword || needsUser

    property bool passwordVisible: false
    property bool showWrongPassword: false

    signal cardClicked

    signal connectionFailed(reason: string)

    signal networkStateChanged

    function submitForm() {
        if (card.needsUser && userField.text.length > 0 && passwordField.text.length > 0) {
            let s = network.nmSettings;
            
        } else if (card.needsPassword && passwordField.text.length > 0) {
            network.connectWithPsk(passwordField.text);
            
        }
    }

    // Component.onCompleted: {
    //     console.debug(`nmSettings count for ${network.name}: ${network.nmSettings.length}`);

    //     for (let i = 0; i < network.nmSettings.length; i++) {
    //         let setting = network.nmSettings[i];
    //         console.debug(`[Setting ${i}] Name/Path:`, setting, JSON.stringify(setting), JSON.stringify(setting.read()));
    //     }
    // }

    implicitHeight: layout.implicitHeight
    radius: 12
    color: netMouse.containsMouse ? Theme.secondary : Theme.primary

    Connections {
        target: card.network
        function onConnectionFailed(reason) {
            card.connectionFailed(reason);
        }

        function onStateChanged() {
            card.networkStateChanged();
        }
    }

    onPasswordVisibleChanged: {
        if (!passwordVisible) {
            passwordField.text = "";
            showWrongPassword = false;
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }

    MouseArea {
        id: netMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            // card.cardClicked = true;
            card.cardClicked();
            if (card.network.stateChanging)
                return;
            if (card.network.connected)
                card.network.disconnect();
            else if (card.network.known || !card.needsCredentials)
                card.network.connect();
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent

        RowLayout {

            Image {
                Layout.preferredHeight: 36
                Layout.preferredWidth: 36
                Layout.alignment: Qt.AlignTop
                fillMode: Image.PreserveAspectFit
                visible: source.toString() !== ""
                sourceSize.width: 36
                sourceSize.height: 36
                source: {
                    let icon = Networks.networkIcon(card.network);
                    if (card.needsCredentials)
                        icon += "-locked";
                    return Quickshell.iconPath(icon);
                }
            }

            ColumnLayout {
                Layout.fillWidth: true

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: card.network.name
                    color: Theme.font
                    font.family: Theme.fontFamily
                    elide: Text.ElideRight
                }

                // TODO: Traffic monitoring?
                // Text {
                //     Layout.alignment: Qt.AlignVCenter
                //     text: network.modelData.address
                //     color: Theme.font_inactive
                //     font.family: Theme.fontFamily
                //     font.pixelSize: Theme.fontSize - 4
                //     elide: Text.ElideRight
                // }
            }

            Spinner {
                sizeUnit: 0.7
                visible: card.network.stateChanging
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                color: "transparent"
                implicitWidth: 26
                implicitHeight: 26

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: "../icons/unplug.svg"
                    opacity: card.network.connected || netMouse.containsMouse ? 1 : 0
                    sourceSize.width: 26
                    sourceSize.height: 26
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: card.network.connected ? Theme.font : Theme.connect
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                Image {
                    Layout.alignment: Qt.AlignVCenter
                    source: "../icons/circle_off.svg"
                    opacity: netMouse.containsMouse && card.network.connected ? 1 : 0
                    sourceSize.width: 26
                    sourceSize.height: 26
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    fillMode: Image.PreserveAspectFit
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: Theme.selected
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }

        // --------------
        // -- Password --
        // --------------
        ColumnLayout {
            Layout.fillWidth: true
            visible: card.needsCredentials && card.passwordVisible
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Item {
                    Layout.preferredWidth: 32
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    color: userField.hovered ? Theme.secondary_hover : Theme.secondary
                    border.width: 1
                    border.color: card.showWrongPassword ? "#e06c75" : Theme.secondary_border

                    TextField {
                        id: userField
                        anchors.fill: parent
                        anchors.margins: 4
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Normal
                        color: Theme.font
                        font.family: Theme.fontFamily
                        placeholderText: "User"
                        placeholderTextColor: Theme.font_inactive
                        selectByMouse: true
                        background: Item {}
                        hoverEnabled: true
                        onTextChanged: card.showWrongPassword = false
                    }
                }

                Item {
                    Layout.preferredWidth: 64
                }
            }

            RowLayout {
                Layout.fillWidth: true
                
                spacing: 0

                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    color: revealMouse.containsMouse ? Theme.secondary : "transparent"

                    Image {
                        property int size: revealMouse.containsPress ? 24 : 26

                        width: size
                        height: size
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        visible: source.toString() !== ""
                        sourceSize.width: size
                        sourceSize.height: size
                        source: Quickshell.iconPath(revealMouse.containsPress ? "password-show-on" : "password-show-off")
                    }

                    MouseArea {
                        id: revealMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 32
                    color: passwordField.hovered ? Theme.secondary_hover : Theme.secondary
                    border.width: 1
                    border.color: card.showWrongPassword ? "#e06c75" : Theme.secondary_border

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 4
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: revealMouse.containsPress ? TextInput.Normal : TextInput.Password
                        color: Theme.font
                        font.family: Theme.fontFamily
                        placeholderText: "Password"
                        placeholderTextColor: Theme.font_inactive
                        selectByMouse: true
                        background: Item {}
                        hoverEnabled: true
                        onTextChanged: card.showWrongPassword = false
                        Keys.onReturnPressed: card.submitForm()
                        Keys.onEnterPressed: card.submitForm()
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 32
                    color: confirmMouse.containsMouse ? Theme.secondary_hover : Theme.secondary
                    border.width: 1
                    border.color: Theme.secondary_border

                    Image {
                        property int size: confirmMouse.containsPress ? 24 : 30
                        width: size
                        height: size
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        visible: source.toString() !== ""
                        sourceSize.width: size
                        sourceSize.height: size
                        source: Quickshell.iconPath("arrow-right")
                    }

                    MouseArea {
                        id: confirmMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.submitForm()
                    }
                }

                Item {
                    Layout.preferredWidth: 32
                }
            }
        }
    }
}
