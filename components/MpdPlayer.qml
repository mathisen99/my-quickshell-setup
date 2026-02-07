import QtQuick
import Quickshell.Io
import "../theme"

Rectangle {
    id: root
    
    Theme { id: theme }
    
    width: parent.width
    height: 160
    radius: 16
    color: theme.bgSurface
    
    property string title: "No media playing"
    property string artist: "Play something!"
    property bool isPlaying: false
    property bool shuffle: false
    property bool repeat: false
    property int elapsed: 0
    property int duration: 0
    property int volume: 100
    
    Column {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        Row {
            width: parent.width
            spacing: 12
            
            // Album art placeholder
            Rectangle {
                width: 50
                height: 50
                radius: 10
                color: theme.bgElevated
                
                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "󰎆" : "󰎈"
                    color: root.isPlaying ? theme.accent : theme.textDim
                    font.family: theme.iconFont
                    font.pixelSize: 22
                }
            }
            
            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2
                width: parent.width - 62
                
                Text {
                    text: root.title
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    width: parent.width
                }
                
                Text {
                    text: root.artist
                    color: theme.textDim
                    font.family: theme.fontFamily
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    width: parent.width
                }
            }
        }
        
        // Progress bar
        Rectangle {
            width: parent.width
            height: 4
            radius: 2
            color: theme.bgElevated
            visible: root.duration > 0
            
            Rectangle {
                width: root.duration > 0 ? parent.width * (root.elapsed / root.duration) : 0
                height: parent.height
                radius: parent.radius
                color: theme.accent
                
                Behavior on width { NumberAnimation { duration: 200 } }
            }
        }
        
        // Controls
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8
            
            // Shuffle
            MediaButton { 
                icon: "󰒟"
                highlighted: root.shuffle
                onClicked: shuffleProc.running = true
            }
            
            // Previous
            MediaButton { 
                icon: "󰒮"
                onClicked: prevProc.running = true
            }
            
            // Play/Pause
            MediaButton { 
                icon: root.isPlaying ? "󰏤" : "󰐊"
                highlighted: true
                onClicked: toggleProc.running = true
            }
            
            // Next
            MediaButton { 
                icon: "󰒭"
                onClicked: nextProc.running = true
            }
            
            // Repeat
            MediaButton { 
                icon: "󰑖"
                highlighted: root.repeat
                onClicked: repeatProc.running = true
            }
        }
        
        // Volume slider
        Row {
            width: parent.width
            spacing: 8
            
            Text {
                text: root.volume > 66 ? "󰕾" : root.volume > 33 ? "󰖀" : root.volume > 0 ? "󰕿" : "󰖁"
                color: theme.textDim
                font.family: theme.iconFont
                font.pixelSize: 14
                anchors.verticalCenter: parent.verticalCenter
            }
            
            Rectangle {
                width: parent.width - 50
                height: 6
                radius: 3
                color: theme.bgElevated
                anchors.verticalCenter: parent.verticalCenter
                
                Rectangle {
                    width: parent.width * (root.volume / 100)
                    height: parent.height
                    radius: parent.radius
                    color: theme.accent
                }
                
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    onClicked: mouse => {
                        let newVol = Math.round((mouse.x / parent.width) * 100)
                        newVol = Math.max(0, Math.min(100, newVol))
                        volumeProc.command = ["mpc", "volume", newVol.toString()]
                        volumeProc.running = true
                    }
                    onPositionChanged: mouse => {
                        if (pressed) {
                            let newVol = Math.round((mouse.x / parent.width) * 100)
                            newVol = Math.max(0, Math.min(100, newVol))
                            volumeProc.command = ["mpc", "volume", newVol.toString()]
                            volumeProc.running = true
                        }
                    }
                }
            }
            
            Text {
                text: root.volume + "%"
                color: theme.textDim
                font.family: theme.fontFamily
                font.pixelSize: 10
                anchors.verticalCenter: parent.verticalCenter
                width: 28
            }
        }
    }
    
    // MPD status polling
    Process {
        id: statusProc
        command: ["mpc", "status", "-f", "%title%\n%artist%"]
        running: true
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                let lines = data.trim().split("\n")
                if (lines.length >= 1 && lines[0] !== "") {
                    root.title = lines[0] || "Unknown"
                    root.artist = lines[1] || "Unknown artist"
                    
                    for (let i = 0; i < lines.length; i++) {
                        if (lines[i].startsWith("[playing]")) {
                            root.isPlaying = true
                            let timeMatch = lines[i].match(/(\d+):(\d+)\/(\d+):(\d+)/)
                            if (timeMatch) {
                                root.elapsed = parseInt(timeMatch[1]) * 60 + parseInt(timeMatch[2])
                                root.duration = parseInt(timeMatch[3]) * 60 + parseInt(timeMatch[4])
                            }
                        } else if (lines[i].startsWith("[paused]")) {
                            root.isPlaying = false
                            let timeMatch = lines[i].match(/(\d+):(\d+)\/(\d+):(\d+)/)
                            if (timeMatch) {
                                root.elapsed = parseInt(timeMatch[1]) * 60 + parseInt(timeMatch[2])
                                root.duration = parseInt(timeMatch[3]) * 60 + parseInt(timeMatch[4])
                            }
                        }
                        
                        // Check for repeat/random status
                        if (lines[i].includes("repeat: on")) root.repeat = true
                        else if (lines[i].includes("repeat: off")) root.repeat = false
                        if (lines[i].includes("random: on")) root.shuffle = true
                        else if (lines[i].includes("random: off")) root.shuffle = false
                        
                        // Check for volume
                        let volMatch = lines[i].match(/volume:\s*(\d+)%/)
                        if (volMatch) {
                            root.volume = parseInt(volMatch[1])
                        }
                    }
                } else {
                    root.title = "No media playing"
                    root.artist = "Play something!"
                    root.isPlaying = false
                    root.elapsed = 0
                    root.duration = 0
                }
            }
        }
    }
    
    // Control processes
    Process {
        id: toggleProc
        command: ["mpc", "toggle"]
        onExited: statusProc.running = true
    }
    
    Process {
        id: nextProc
        command: ["mpc", "next"]
        onExited: statusProc.running = true
    }
    
    Process {
        id: prevProc
        command: ["mpc", "prev"]
        onExited: statusProc.running = true
    }
    
    Process {
        id: shuffleProc
        command: ["mpc", "random"]
        onExited: statusProc.running = true
    }
    
    Process {
        id: repeatProc
        command: ["mpc", "repeat"]
        onExited: statusProc.running = true
    }
    
    Process {
        id: volumeProc
        command: ["mpc", "volume", "100"]
        onExited: statusProc.running = true
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: statusProc.running = true
    }
}
