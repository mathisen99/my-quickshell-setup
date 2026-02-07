import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../theme"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    function toggle() { 
        isOpen = !isOpen
        if (isOpen) loadWallpapers()
    }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true }
    margins.top: 80
    
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    implicitWidth: 700
    implicitHeight: 550
    color: "transparent"
    
    mask: Region { item: content }
    
    property string wallpaperDir: "/home/mathisen/Mathisen/images/darkwibes"
    property var monitors: ["DP-1", "DP-2", "HDMI-A-1"]
    property string selectedMonitor: "DP-2"
    
    ListModel { id: wallpaperModel }
    
    function loadWallpapers() {
        wallpaperModel.clear()
        loadProc.running = true
    }
    
    Process {
        id: loadProc
        command: ["sh", "-c", "find '" + popup.wallpaperDir + "' -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                let files = data.trim().split("\n")
                for (let f of files) {
                    if (f) wallpaperModel.append({ path: f, name: f.split("/").pop() })
                }
            }
        }
    }
    
    function setWallpaper(path) {
        setWallProc.command = ["hyprctl", "hyprpaper", "wallpaper", popup.selectedMonitor + "," + path]
        setWallProc.running = true
    }
    
    Process {
        id: setWallProc
        onExited: {
            // Also preload for hyprpaper
            preloadProc.command = ["hyprctl", "hyprpaper", "preload", setWallProc.command[3].split(",")[1]]
            preloadProc.running = true
        }
    }
    
    Process { id: preloadProc }
    
    Rectangle {
        id: content
        anchors.centerIn: parent
        width: 700
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
                    text: "󰸉"
                    color: theme.accent
                    font.family: theme.iconFont
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Text {
                    text: "Wallpaper"
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    anchors.verticalCenter: parent.verticalCenter
                }
                
                Item { width: 20; height: 1 }
                
                // Monitor selector
                Row {
                    spacing: 8
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Text {
                        text: "Monitor:"
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    Repeater {
                        model: popup.monitors
                        
                        Rectangle {
                            width: monitorText.width + 16
                            height: 28
                            radius: 8
                            color: popup.selectedMonitor === modelData ? theme.accent : (monitorHover.containsMouse ? theme.bgHover : theme.bgSurface)
                            
                            Text {
                                id: monitorText
                                anchors.centerIn: parent
                                text: modelData
                                color: popup.selectedMonitor === modelData ? theme.bg : theme.text
                                font.family: theme.monoFont
                                font.pixelSize: 10
                            }
                            
                            MouseArea {
                                id: monitorHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popup.selectedMonitor = modelData
                            }
                        }
                    }
                }
                
                Item { width: parent.width - 480; height: 1 }
                
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
            
            // Wallpaper grid
            Rectangle {
                width: parent.width
                height: parent.height - 60
                radius: 16
                color: theme.bgSurface
                clip: true
                
                GridView {
                    id: wallpaperGrid
                    anchors.fill: parent
                    anchors.margins: 12
                    cellWidth: (width - 12) / 4
                    cellHeight: 120
                    clip: true
                    cacheBuffer: 1000
                    
                    model: wallpaperModel
                    
                    // Smooth scrolling
                    flickDeceleration: 3000
                    maximumFlickVelocity: 4000
                    
                    delegate: Item {
                        width: wallpaperGrid.cellWidth
                        height: wallpaperGrid.cellHeight
                        
                        Rectangle {
                            id: wallpaperItem
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 12
                            color: theme.bgElevated
                            clip: true
                            
                            // Image preview
                            Image {
                                id: wallImg
                                anchors.fill: parent
                                anchors.margins: 3
                                source: model.path ? "file://" + model.path : ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                sourceSize.width: 200
                                sourceSize.height: 140
                                
                                // Loading indicator
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: theme.bgSurface
                                    visible: wallImg.status === Image.Loading
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰦖"
                                        color: theme.textDim
                                        font.family: theme.iconFont
                                        font.pixelSize: 16
                                    }
                                }
                            }
                            
                            // Border on hover
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: "transparent"
                                border.color: wallHover.containsMouse ? theme.accent : "transparent"
                                border.width: 2
                            }
                            
                            // Filename tooltip on hover
                            Rectangle {
                                visible: wallHover.containsMouse
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.margins: 3
                                height: 22
                                radius: 6
                                color: Qt.rgba(0, 0, 0, 0.75)
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: model.name
                                    color: theme.text
                                    font.family: theme.fontFamily
                                    font.pixelSize: 9
                                    elide: Text.ElideMiddle
                                    width: parent.width - 8
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                            
                            MouseArea {
                                id: wallHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: popup.setWallpaper(model.path)
                            }
                        }
                    }
                    
                    ScrollBar.vertical: ScrollBar {
                        active: true
                        policy: ScrollBar.AsNeeded
                    }
                }
                
                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: wallpaperModel.count === 0
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰸉"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 48
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "No wallpapers found"
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 13
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: popup.wallpaperDir
                        color: theme.textDim
                        font.family: theme.monoFont
                        font.pixelSize: 10
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
}
