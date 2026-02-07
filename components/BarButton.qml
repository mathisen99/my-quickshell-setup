import QtQuick
import "../theme"

Rectangle {
    id: root
    
    property string icon: ""
    property color iconColor: theme.text
    property color bgColor: mouseArea.containsMouse ? theme.bgHover : theme.bgSurface
    property string tooltip: ""
    
    signal clicked()
    
    Theme { id: theme }
    
    width: 36
    height: 36
    radius: theme.radiusSmall
    color: bgColor
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.iconColor
        font.family: theme.iconFont
        font.pixelSize: 18
        
        Behavior on color { ColorAnimation { duration: theme.animDuration } }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
