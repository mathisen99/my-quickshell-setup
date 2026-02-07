import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    
    property string icon: ""
    property string label: ""
    property bool active: false
    property color accentColor: theme.accent
    property string onCommand: ""
    property string offCommand: ""
    
    signal clicked()
    
    Theme { id: theme }
    
    width: 72
    height: 56
    radius: 12
    color: active ? accentColor : (mouseArea.containsMouse ? theme.bgHover : theme.bgElevated)
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Column {
        anchors.centerIn: parent
        spacing: 4
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.icon
            color: active ? theme.bg : theme.text
            font.family: theme.iconFont
            font.pixelSize: 20
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: active ? theme.bg : theme.textDim
            font.family: theme.fontFamily
            font.pixelSize: 10
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.active = !root.active
            root.clicked()
            if (root.onCommand !== "" && root.active) {
                toggleProc.command = ["sh", "-c", root.onCommand]
                toggleProc.running = true
            } else if (root.offCommand !== "" && !root.active) {
                toggleProc.command = ["sh", "-c", root.offCommand]
                toggleProc.running = true
            }
        }
    }
    
    Process {
        id: toggleProc
    }
}
