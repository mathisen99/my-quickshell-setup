import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray
import "../theme"
import "../components"

Row {
    id: tray
    spacing: 4
    Layout.alignment: Qt.AlignVCenter
    
    Theme { id: theme }
    
    Repeater {
        model: SystemTray.items
        
        Rectangle {
            id: trayItem
            required property SystemTrayItem modelData
            
            width: 32
            height: 32
            radius: 8
            color: trayHover.containsMouse ? theme.bgHover : "transparent"
            
            Behavior on color { ColorAnimation { duration: theme.animDuration } }
            
            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: modelData.icon
                sourceSize.width: 18
                sourceSize.height: 18
            }
            
            MouseArea {
                id: trayHover
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: mouse => {
                    let window = trayItem.QsWindow.window
                    let pos = trayItem.mapToItem(null, 0, trayItem.height)
                    
                    if (mouse.button === Qt.LeftButton) {
                        if (modelData.onlyMenu || modelData.hasMenu) {
                            modelData.display(window, pos.x, pos.y)
                        } else {
                            modelData.activate()
                        }
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu) {
                            modelData.display(window, pos.x, pos.y)
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate()
                    }
                }
                
                onWheel: wheel => {
                    modelData.scroll(wheel.angleDelta.y / 120, false)
                }
            }
            
            ToolTip {
                visible: trayHover.containsMouse && modelData.title !== ""
                text: modelData.title
            }
        }
    }
    
    // Volume button (keep this separate)
    BarButton {
        id: volButton
        icon: volumeLevel > 50 ? "󰕾" : volumeLevel > 0 ? "󰖀" : "󰝟"
        iconColor: theme.secondary
        
        property int volumeLevel: 0
        
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            
            onWheel: wheel => {
                let delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
                volChangeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", delta > 0 ? "5%+" : "5%-"]
                volChangeProc.running = true
            }
            
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    muteProc.running = true
                }
            }
        }
        
        Process {
            id: volProc
            command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
            running: true
            stdout: SplitParser {
                onRead: data => volButton.volumeLevel = parseInt(data) || 0
            }
        }
        
        Process {
            id: volChangeProc
            onExited: volProc.running = true
        }
        
        Process {
            id: muteProc
            command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            onExited: volProc.running = true
        }
        
        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: volProc.running = true
        }
    }
    
    // Simple tooltip component
    component ToolTip: Rectangle {
        property string text: ""
        
        visible: false
        width: tooltipText.width + 16
        height: tooltipText.height + 8
        radius: 6
        color: theme.bgElevated
        border.color: theme.border
        border.width: 1
        z: 100
        
        y: -height - 4
        x: -width / 2 + parent.width / 2
        
        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: parent.text
            color: theme.text
            font.family: theme.fontFamily
            font.pixelSize: 11
        }
    }
}
