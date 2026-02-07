import Quickshell
import Quickshell.Io
import QtQuick
import "../theme"
import "../components"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    function toggle() { isOpen = !isOpen }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true; left: true }
    margins.top: 54
    margins.left: 12
    
    implicitWidth: 380
    implicitHeight: 570
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        radius: 20
        color: theme.bg
        border.color: theme.border
        border.width: 1
        
        scale: popup.isOpen ? 1 : 0.95
        opacity: popup.isOpen ? 1 : 0
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        
        Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            // User Profile
            Rectangle {
                width: parent.width
                height: 90
                radius: 16
                color: theme.bgSurface
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14
                    
                    Rectangle {
                        width: 62
                        height: 62
                        radius: 31
                        color: theme.accent
                        clip: true
                        
                        Image {
                            anchors.fill: parent
                            source: "file://" + Qt.resolvedUrl("../cat.png").toString().replace("file://", "")
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(62, 62)
                        }
                    }
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        
                        Text {
                            text: "Welcome back!"
                            color: theme.textDim
                            font.family: theme.fontFamily
                            font.pixelSize: 11
                        }
                        
                        Text {
                            id: userText
                            text: "Mathisen"
                            color: theme.text
                            font.family: theme.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Medium
                        }
                        
                        Text {
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                            color: theme.textDim
                            font.family: theme.fontFamily
                            font.pixelSize: 10
                        }
                    }
                }
                
            }
            
            // Quick Toggles
            Rectangle {
                width: parent.width
                height: 70
                radius: 16
                color: theme.bgSurface
                
                Row {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    QuickToggle { 
                        id: dndToggle
                        icon: "󰍶"
                        label: "DND"
                        accentColor: theme.secondary
                        onClicked: shell.dndEnabled = active
                    }
                    QuickToggle { 
                        icon: "󰖔"
                        label: "Night"
                        accentColor: theme.warning
                        onCommand: "hyprctl keyword decoration:screen_shader ~/.config/hypr/shaders/nightlight.glsl"
                        offCommand: "hyprctl keyword decoration:screen_shader [[EMPTY]]"
                    }
                    QuickToggle { 
                        icon: "󰂜"
                        label: "Mute"
                        accentColor: theme.error
                        active: muteState.muted
                        onClicked: {
                            muteToggleProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", active ? "1" : "0"]
                            muteToggleProc.running = true
                        }
                        
                        QtObject {
                            id: muteState
                            property bool muted: false
                        }
                        
                        Process {
                            id: muteCheckProc2
                            command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 1 || echo 0"]
                            running: true
                            stdout: SplitParser {
                                onRead: data => muteState.muted = data.trim() === "1"
                            }
                        }
                        
                        Process {
                            id: muteToggleProc
                            onExited: muteCheckProc2.running = true
                        }
                        
                        Timer {
                            interval: 2000
                            running: popup.isOpen
                            repeat: true
                            onTriggered: muteCheckProc2.running = true
                        }
                    }
                    QuickToggle { 
                        icon: "󰒓"
                        label: "Settings"
                        accentColor: theme.accent
                        onClicked: {
                            popup.isOpen = false
                            shell.settingsPopup.toggle()
                        }
                    }
                }
            }
            
            // Volume Slider
            Rectangle {
                width: parent.width
                height: 60
                radius: 16
                color: theme.bgSurface
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12
                    
                    Text {
                        text: "󰕾"
                        color: theme.secondary
                        font.family: theme.iconFont
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6
                        width: parent.width - 50
                        
                        Row {
                            width: parent.width
                            Text {
                                text: "Volume"
                                color: theme.text
                                font.family: theme.fontFamily
                                font.pixelSize: 12
                            }
                            Item { width: parent.width - 80; height: 1 }
                            Text {
                                id: volText
                                text: "0%"
                                color: theme.textDim
                                font.family: theme.monoFont
                                font.pixelSize: 11
                            }
                        }
                        
                        // Volume bar
                        Rectangle {
                            width: parent.width
                            height: 8
                            radius: 4
                            color: theme.bgElevated
                            
                            Rectangle {
                                id: volBar
                                property int volume: 0
                                width: parent.width * (volume / 100)
                                height: parent.height
                                radius: parent.radius
                                color: theme.secondary
                                
                                Behavior on width { NumberAnimation { duration: 100 } }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: mouse => {
                                    let vol = Math.round((mouse.x / width) * 100)
                                    volProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", vol / 100 + ""]
                                    volProc.running = true
                                }
                            }
                        }
                    }
                }
                
                Process {
                    id: getVolProc
                    command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
                    running: popup.isOpen
                    stdout: SplitParser {
                        onRead: data => {
                            let v = parseInt(data) || 0
                            volBar.volume = v
                            volText.text = v + "%"
                        }
                    }
                }
                
                Process {
                    id: volProc
                    onExited: getVolProc.running = true
                }
                
                Timer {
                    interval: 1000
                    running: popup.isOpen
                    repeat: true
                    onTriggered: getVolProc.running = true
                }
            }
            
            // System Stats
            Rectangle {
                width: parent.width
                height: 100
                radius: 16
                color: theme.bgSurface
                
                Column {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10
                    
                    Text {
                        text: "System"
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.Medium
                    }
                    
                    StatBar { id: cpuBar; label: "CPU"; value: 0; color: theme.accent; icon: "󰻠" }
                    StatBar { id: ramBar; label: "RAM"; value: 0; color: theme.secondary; icon: "󰍛" }
                }
                
                Process {
                    id: cpuProc
                    command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'"]
                    running: popup.isOpen
                    stdout: SplitParser {
                        onRead: data => cpuBar.value = parseInt(data) || 0
                    }
                }
                
                Process {
                    id: ramProc
                    command: ["sh", "-c", "free | awk '/^Mem:/ {printf \"%.0f\", $3/$2 * 100}'"]
                    running: popup.isOpen
                    stdout: SplitParser {
                        onRead: data => ramBar.value = parseInt(data) || 0
                    }
                }
                
                Timer {
                    interval: 2000
                    running: popup.isOpen
                    repeat: true
                    onTriggered: {
                        cpuProc.running = true
                        ramProc.running = true
                    }
                }
            }
            
            // Media Player (MPD)
            MpdPlayer {
                width: parent.width
            }
        }
    }
}
