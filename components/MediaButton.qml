import QtQuick
import "../theme"

Rectangle {
    id: root
    
    property string icon: ""
    property bool highlighted: false
    
    signal clicked()
    
    Theme { id: theme }
    
    width: highlighted ? 36 : 28
    height: highlighted ? 36 : 28
    radius: width / 2
    color: highlighted ? theme.accent : (mouseArea.containsMouse ? theme.bgHover : theme.bgElevated)
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Text {
        anchors.centerIn: parent
        text: root.icon
        color: highlighted ? theme.bg : theme.text
        font.family: theme.iconFont
        font.pixelSize: highlighted ? 18 : 14
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
