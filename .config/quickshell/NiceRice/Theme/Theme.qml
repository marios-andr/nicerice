pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: theme

    // /usr/share/icons/breeze-dark/
    // TODO: Toggle between local icons and theme icons

    readonly property int dotSize: 24
    readonly property int moduleHeight: 28

    readonly property int fontSize: 16
    readonly property string fontFamily: "Fira Sans Semibold"

    readonly property color font: '#dfdfdf'
    readonly property color font_dark: '#191919'
    readonly property color font_secondary: '#bcbcbc'
    readonly property color font_inactive: '#5f5f5f'
    
    readonly property color background: '#161514'
    readonly property color background_hover: '#1f1b1b'
    readonly property color primary: '#2e2e2e'
    readonly property color primary_hover: secondary
    readonly property color secondary: '#473a39'
    readonly property color secondary_hover: '#604e4d'
    readonly property color secondary_border: '#7c6564'
    readonly property color tertiary: secondary_hover
    readonly property color selected: '#e90000'

    readonly property color icon_default: "#e3e3e3"
    readonly property color connect: "#22cc23"
}
