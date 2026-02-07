import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../theme"
import "../components"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    function toggle() { isOpen = !isOpen }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true }
    margins.top: 80
    
    exclusionMode: ExclusionMode.Ignore
    
    implicitWidth: 500
    implicitHeight: 550
    color: "transparent"
    
    mask: Region { item: content }
    
    Rectangle {
        id: content
        anchors.centerIn: parent
        width: 500
        height: 550
        radius: 24
        color: theme.bg
        border.color: theme.border
        border.width: 1
        
        scale: popup.isOpen ? 1 : 0.95
        opacity: popup.isOpen ? 1 : 0
        
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            
            // Header
            Row {
                width: parent.width
                spacing: 12
                
                Text {
                    text: "󰒓"
                    color: theme.accent
                    font.family: theme.iconFont
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "Settings"
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: parent.width - 200; height: 1 }
                
                Rectangle {
                    width: 32
                    height: 32
                    radius: 8
                    color: closeHover.containsMouse ? theme.bgHover : "transparent"
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 16
                    }
                    
                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: popup.isOpen = false
                    }
                }
            }
            
            // Scrollable content
            Flickable {
                width: parent.width
                height: parent.height - 50
                contentHeight: settingsColumn.height
                clip: true
                
                Column {
                    id: settingsColumn
                    width: parent.width
                    spacing: 12
                    
                    // Audio Section
                    SettingsSection {
                        title: "Audio"
                        icon: "󰕾"
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            SettingsSlider {
                                label: "Volume"
                                icon: "󰕾"
                                value: volValue
                                property int volValue: 0
                                onValueChanged: {
                                    volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", (value / 100).toString()]
                                    volSetProc.running = true
                                }
                                
                                Process {
                                    id: volGetProc
                                    command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'"]
                                    running: popup.isOpen
                                    stdout: SplitParser {
                                        onRead: data => parent.volValue = parseInt(data) || 0
                                    }
                                }
                                
                                Process { id: volSetProc }
                                
                                Timer {
                                    interval: 2000
                                    running: popup.isOpen
                                    repeat: true
                                    onTriggered: volGetProc.running = true
                                }
                            }
                            
                            SettingsToggle {
                                id: muteToggle
                                label: "Mute Audio"
                                icon: "󰝟"
                                checked: muteState2.muted
                                onToggled: {
                                    muteState2.muted = !muteState2.muted
                                    muteSetProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", muteState2.muted ? "1" : "0"]
                                    muteSetProc.running = true
                                }
                                
                                QtObject {
                                    id: muteState2
                                    property bool muted: false
                                }
                                
                                Process {
                                    id: muteCheckProc
                                    command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 1 || echo 0"]
                                    running: popup.isOpen
                                    stdout: SplitParser {
                                        onRead: data => muteState2.muted = data.trim() === "1"
                                    }
                                }
                                
                                Process {
                                    id: muteSetProc
                                    onExited: muteCheckProc.running = true
                                }
                                
                                Timer {
                                    interval: 1000
                                    running: popup.isOpen
                                    repeat: true
                                    onTriggered: muteCheckProc.running = true
                                }
                            }
                        }
                    }
                    
                    // Display Section
                    SettingsSection {
                        title: "Display"
                        icon: "󰍹"
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            SettingsToggle {
                                label: "Night Light"
                                icon: "󰖔"
                                checked: nightEnabled
                                property bool nightEnabled: false
                                onToggled: {
                                    nightEnabled = checked
                                    nightProc.command = ["hyprctl", "keyword", "decoration:screen_shader", 
                                        checked ? "~/.config/hypr/shaders/nightlight.glsl" : "[[EMPTY]]"]
                                    nightProc.running = true
                                }
                                
                                Process { id: nightProc }
                            }
                            
                            SettingsSlider {
                                label: "Gaps"
                                icon: "󰘞"
                                value: gapsValue
                                minValue: 0
                                maxValue: 30
                                property int gapsValue: 10
                                onValueChanged: {
                                    gapsProc.command = ["hyprctl", "keyword", "general:gaps_out", value.toString()]
                                    gapsProc.running = true
                                }
                                
                                Process { id: gapsProc }
                            }
                            
                            SettingsSlider {
                                label: "Border Radius"
                                icon: "󰢡"
                                value: radiusValue
                                minValue: 0
                                maxValue: 20
                                property int radiusValue: 5
                                onValueChanged: {
                                    radiusProc.command = ["hyprctl", "keyword", "decoration:rounding", value.toString()]
                                    radiusProc.running = true
                                }
                                
                                Process { id: radiusProc }
                            }
                        }
                    }
                    
                    // Notifications Section
                    SettingsSection {
                        title: "Notifications"
                        icon: "󰂚"
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            SettingsToggle {
                                label: "Do Not Disturb"
                                icon: "󰍶"
                                checked: shell.dndEnabled
                                onToggled: shell.dndEnabled = checked
                            }
                        }
                    }
                    
                    // System Section
                    SettingsSection {
                        title: "System"
                        icon: "󰒓"
                        
                        Column {
                            width: parent.width
                            spacing: 10
                            
                            SettingsButton {
                                label: "Reload Hyprland"
                                icon: "󰑓"
                                onClicked: reloadProc.running = true
                                
                                Process {
                                    id: reloadProc
                                    command: ["hyprctl", "reload"]
                                }
                            }
                            
                            SettingsButton {
                                label: "Open Terminal"
                                icon: "󰆍"
                                onClicked: termProc.running = true
                                
                                Process {
                                    id: termProc
                                    command: ["kitty"]
                                }
                            }
                            
                            SettingsButton {
                                label: "Open File Manager"
                                icon: "󰉋"
                                onClicked: fmProc.running = true
                                
                                Process {
                                    id: fmProc
                                    command: ["thunar"]
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: popup.isOpen = false
    }
    
    // Components
    component SettingsSection: Rectangle {
        property string title: ""
        property string icon: ""
        default property alias content: sectionContent.data
        
        width: parent.width
        implicitHeight: sectionColumn.implicitHeight + 24
        radius: 16
        color: theme.bgSurface
        
        Column {
            id: sectionColumn
            width: parent.width - 24
            anchors.centerIn: parent
            spacing: 12
            
            Row {
                spacing: 8
                
                Text {
                    text: icon
                    color: theme.accent
                    font.family: theme.iconFont
                    font.pixelSize: 16
                }
                
                Text {
                    text: title
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Medium
                }
            }
            
            Column {
                id: sectionContent
                width: parent.width
                spacing: 8
            }
        }
    }
    
    component SettingsToggle: Rectangle {
        property string label: ""
        property string icon: ""
        property bool checked: false
        signal toggled()
        
        width: parent.width
        height: 40
        radius: 10
        color: toggleHover.containsMouse ? theme.bgHover : theme.bgElevated
        
        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Text {
                text: icon
                color: theme.textDim
                font.family: theme.iconFont
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: label
                color: theme.text
                font.family: theme.fontFamily
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Item { width: parent.width - 180; height: 1 }
            
            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: checked ? theme.accent : theme.border
                anchors.verticalCenter: parent.verticalCenter
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: theme.text
                    x: checked ? parent.width - width - 3 : 3
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }
            }
        }
        
        MouseArea {
            id: toggleHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: toggled()
        }
    }
    
    component SettingsSlider: Rectangle {
        property string label: ""
        property string icon: ""
        property int value: 50
        property int minValue: 0
        property int maxValue: 100
        
        width: parent.width
        height: 50
        radius: 10
        color: theme.bgElevated
        
        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            
            Row {
                width: parent.width
                spacing: 10
                
                Text {
                    text: icon
                    color: theme.textDim
                    font.family: theme.iconFont
                    font.pixelSize: 16
                }
                
                Text {
                    text: label
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                }
                
                Item { width: parent.width - 120; height: 1 }
                
                Text {
                    text: value
                    color: theme.textDim
                    font.family: theme.monoFont
                    font.pixelSize: 11
                }
            }
            
            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: theme.border
                
                Rectangle {
                    width: parent.width * ((value - minValue) / (maxValue - minValue))
                    height: parent.height
                    radius: parent.radius
                    color: theme.accent
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: mouse => {
                        value = Math.round(minValue + (mouse.x / width) * (maxValue - minValue))
                    }
                    onPositionChanged: mouse => {
                        if (pressed) {
                            value = Math.round(minValue + (mouse.x / width) * (maxValue - minValue))
                            value = Math.max(minValue, Math.min(maxValue, value))
                        }
                    }
                }
            }
        }
    }
    
    component SettingsButton: Rectangle {
        property string label: ""
        property string icon: ""
        signal clicked()
        
        width: parent.width
        height: 40
        radius: 10
        color: btnHover.containsMouse ? theme.bgHover : theme.bgElevated
        
        Behavior on color { ColorAnimation { duration: 150 } }
        
        Row {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Text {
                text: icon
                color: theme.accent
                font.family: theme.iconFont
                font.pixelSize: 16
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Text {
                text: label
                color: theme.text
                font.family: theme.fontFamily
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        
        MouseArea {
            id: btnHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
