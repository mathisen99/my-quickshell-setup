import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    
    Layout.fillWidth: true
    Layout.preferredHeight: 32
    Layout.alignment: Qt.AlignVCenter
    
    Theme { id: theme }
    
    radius: theme.radiusSmall
    color: hover.containsMouse ? theme.bgHover : theme.bgSurface
    clip: true
    
    property string windowTitle: "Desktop"
    property string windowClass: ""
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Row {
        anchors.centerIn: parent
        spacing: 8
        width: Math.min(implicitWidth, parent.width - 24)
        
        Text {
            text: "󰖯"
            color: theme.secondary
            font.family: theme.iconFont
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: root.windowTitle
            color: theme.text
            font.family: theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 300)
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
    }
    
    // Poll active window via hyprctl
    Process {
        id: activeWinProc
        command: ["hyprctl", "activewindow", "-j"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    let json = JSON.parse(data)
                    root.windowTitle = json.title || "Desktop"
                    root.windowClass = json.class || ""
                } catch (e) {
                    root.windowTitle = "Desktop"
                }
            }
        }
    }
    
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: activeWinProc.running = true
    }
}
