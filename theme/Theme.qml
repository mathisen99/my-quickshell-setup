import QtQuick

QtObject {
    // Background colors
    readonly property color bg: "#0d0f18"
    readonly property color bgSurface: "#151823"
    readonly property color bgElevated: "#1c1f2e"
    readonly property color bgHover: "#252a3d"
    
    // Accent colors
    readonly property color accent: "#89b4fa"
    readonly property color accentDim: Qt.rgba(accent.r, accent.g, accent.b, 0.3)
    readonly property color secondary: "#cba6f7"
    readonly property color tertiary: "#a6e3a1"
    readonly property color warning: "#f9e2af"
    readonly property color error: "#f38ba8"
    
    // Text colors
    readonly property color text: "#cdd6f4"
    readonly property color textDim: "#6c7086"
    readonly property color border: "#313244"
    
    // Animation
    readonly property int animDuration: 200
    
    // Fonts - using what you have installed
    readonly property string fontFamily: "sans-serif"
    readonly property string monoFont: "JetBrains Mono"
    readonly property string iconFont: "FiraCode Nerd Font"
    
    // Sizing
    readonly property int barHeight: 48
    readonly property int barMargin: 6
    readonly property int radius: 16
    readonly property int radiusSmall: 10
}
