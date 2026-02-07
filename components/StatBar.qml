import QtQuick
import "../theme"

Item {
    id: root
    
    property string label: ""
    property string icon: ""
    property int value: 0
    property color color: theme.accent
    
    Theme { id: theme }
    
    width: parent.width
    height: 28
    
    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        width: parent.width
        
        Text {
            text: root.icon
            color: root.color
            font.family: theme.iconFont
            font.pixelSize: 16
            width: 20
        }
        
        Text {
            text: root.label
            color: theme.text
            font.family: theme.fontFamily
            font.pixelSize: 12
            width: 40
        }
        
        Rectangle {
            width: parent.width - 120
            height: 6
            radius: 3
            color: theme.bgElevated
            anchors.verticalCenter: parent.verticalCenter
            
            Rectangle {
                width: parent.width * (root.value / 100)
                height: parent.height
                radius: parent.radius
                color: root.color
                
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
        
        Text {
            text: root.value + "%"
            color: theme.textDim
            font.family: theme.monoFont
            font.pixelSize: 11
            width: 35
            horizontalAlignment: Text.AlignRight
        }
    }
}
