import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    
    property string icon: ""
    property string label: ""
    property string cmd: ""
    property bool danger: false
    
    Theme { id: theme }
    
    width: parent.width
    height: 40
    radius: 10
    color: mouseArea.containsMouse ? (danger ? Qt.rgba(theme.error.r, theme.error.g, theme.error.b, 0.2) : theme.bgHover) : "transparent"
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: 12
        spacing: 12
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: danger ? theme.error : theme.text
            font.family: theme.iconFont
            font.pixelSize: 18
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.label
            color: danger ? theme.error : theme.text
            font.family: theme.fontFamily
            font.pixelSize: 13
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: proc.running = true
    }
    
    Process {
        id: proc
        command: ["sh", "-c", root.cmd]
    }
}
