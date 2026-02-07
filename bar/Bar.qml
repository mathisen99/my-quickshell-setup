import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

PanelWindow {
    id: bar
    
    Theme { id: theme }
    
    anchors {
        top: true
        left: true
        right: true
    }
    
    implicitHeight: theme.barHeight
    color: "transparent"
    
    Rectangle {
        id: barBg
        anchors.fill: parent
        anchors.margins: theme.barMargin
        anchors.bottomMargin: 0
        radius: theme.radius
        color: theme.bg
        
        // Border
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: theme.border
            border.width: 1
            z: -1
        }
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4
            
            // Logo - opens launcher
            BarButton {
                icon: "󰣇"
                iconColor: theme.accent
                onClicked: shell.launcherPopup.toggle()
            }
            
            // Dashboard
            BarButton {
                icon: "󰕮"
                iconColor: theme.secondary
                onClicked: shell.dashboardPopup.toggle()
            }
            
            // Wallpaper
            BarButton {
                icon: "󰸉"
                iconColor: theme.tertiary
                onClicked: shell.wallpaperPopup.toggle()
            }
            
            BarSeparator {}
            
            // Workspaces
            Workspaces {}
            
            BarSeparator {}
            
            // Active Window
            ActiveWindow {}
            
            BarSeparator {}
            
            // System Tray
            SystemTray {}
            
            BarSeparator {}
            
            // Clock
            Clock {}
            
            BarSeparator {}
            
            // Status
            StatusIcons {}
            
            // Power
            BarButton {
                id: powerBtn
                icon: "󰐥"
                iconColor: powerHover.containsMouse ? theme.bg : theme.error
                bgColor: powerHover.containsMouse ? theme.error : theme.bgSurface
                
                MouseArea {
                    id: powerHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: shell.sessionPopup.toggle()
                }
            }
        }
    }
}
