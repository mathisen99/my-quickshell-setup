import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../theme"

Row {
    spacing: 4
    Layout.alignment: Qt.AlignVCenter
    
    Theme { id: theme }
    
    Repeater {
        model: 6
        
        Rectangle {
            id: wsItem
            
            property bool isActive: Hyprland.focusedMonitor?.activeWorkspace?.id === (index + 1)
            property bool isOccupied: {
                for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                    if (Hyprland.workspaces.values[i].id === (index + 1)) return true
                }
                return false
            }
            
            width: isActive ? 32 : 12
            height: 32
            radius: isActive ? theme.radiusSmall : 6
            color: isActive ? theme.accent : (wsHover.containsMouse ? theme.bgHover : theme.bgSurface)
            
            Behavior on width { NumberAnimation { duration: theme.animDuration; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: theme.animDuration } }
            Behavior on radius { NumberAnimation { duration: theme.animDuration } }
            
            // Occupied dot
            Rectangle {
                visible: !wsItem.isActive && wsItem.isOccupied
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: theme.textDim
            }
            
            // Active number
            Text {
                visible: wsItem.isActive
                anchors.centerIn: parent
                text: index + 1
                color: theme.bg
                font.pixelSize: 12
                font.family: theme.monoFont
                font.weight: Font.Bold
            }
            
            MouseArea {
                id: wsHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}
