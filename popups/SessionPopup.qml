import Quickshell
import QtQuick
import "../theme"
import "../components"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    function toggle() { isOpen = !isOpen }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true; right: true }
    margins.top: 54
    margins.right: 12
    
    implicitWidth: 200
    implicitHeight: 220
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        radius: 16
        color: theme.bg
        border.color: theme.border
        border.width: 1
        
        scale: popup.isOpen ? 1 : 0.95
        opacity: popup.isOpen ? 1 : 0
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        
        Column {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4
            
            SessionButton { icon: "󰌾"; label: "Lock"; cmd: "loginctl lock-session" }
            SessionButton { icon: "󰍃"; label: "Logout"; cmd: "hyprctl dispatch exit"; danger: true }
            SessionButton { icon: "󰤄"; label: "Suspend"; cmd: "systemctl suspend" }
            SessionButton { icon: "󰜉"; label: "Reboot"; cmd: "systemctl reboot"; danger: true }
            SessionButton { icon: "󰐥"; label: "Shutdown"; cmd: "systemctl poweroff"; danger: true }
        }
    }
}
