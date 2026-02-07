import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../theme"

Row {
    spacing: 8
    Layout.alignment: Qt.AlignVCenter
    
    Theme { id: theme }
    
    // CPU
    Rectangle {
        id: cpuBox
        width: cpuRow.width + 12
        height: 24
        radius: 6
        color: cpuHover.containsMouse ? theme.bgHover : theme.bgSurface
        
        property bool expanded: false
        
        Row {
            id: cpuRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: "󰻠"
                color: theme.accent
                font.family: theme.iconFont
                font.pixelSize: 14
            }
            
            Text {
                id: cpuText
                text: "0%"
                color: theme.text
                font.family: theme.monoFont
                font.pixelSize: 10
            }
        }
        
        MouseArea {
            id: cpuHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: cpuPopup.visible = !cpuPopup.visible
        }
    }
    
    // RAM
    Rectangle {
        width: ramRow.width + 12
        height: 24
        radius: 6
        color: theme.bgSurface
        
        Row {
            id: ramRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: "󰍛"
                color: theme.secondary
                font.family: theme.iconFont
                font.pixelSize: 14
            }
            
            Text {
                id: ramText
                text: "0 / 0 GB"
                color: theme.text
                font.family: theme.monoFont
                font.pixelSize: 10
            }
        }
    }
    
    // GPU
    Rectangle {
        id: gpuBox
        width: gpuRow.width + 12
        height: 24
        radius: 6
        color: gpuHover.containsMouse ? theme.bgHover : theme.bgSurface
        
        Row {
            id: gpuRow
            anchors.centerIn: parent
            spacing: 4
            
            Text {
                text: "󰢮"
                color: theme.tertiary
                font.family: theme.iconFont
                font.pixelSize: 14
            }
            
            Text {
                id: gpuText
                text: "0%"
                color: theme.text
                font.family: theme.monoFont
                font.pixelSize: 10
            }
            
            Text {
                text: "·"
                color: theme.textDim
                font.pixelSize: 10
            }
            
            Text {
                id: gpuTempText
                text: "0°C"
                color: theme.text
                font.family: theme.monoFont
                font.pixelSize: 10
            }
        }
        
        MouseArea {
            id: gpuHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: gpuPopup.visible = !gpuPopup.visible
        }
    }
    
    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'"]
        running: true
        stdout: SplitParser {
            onRead: data => cpuText.text = data.trim() + "%"
        }
    }
    
    // RAM usage - shows used/total in GB
    Process {
        id: ramProc
        command: ["sh", "-c", "free -b | awk '/^Mem:/ {used=$3/1073741824; total=$2/1073741824; printf \"%.1f / %.0f GB\", used, total}'"]
        running: true
        stdout: SplitParser {
            onRead: data => ramText.text = data.trim()
        }
    }
    
    // GPU usage and temp (nvidia-smi)
    Process {
        id: gpuProc
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits | head -1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(",")
                if (parts.length >= 2) {
                    gpuText.text = parts[0].trim() + "%"
                    gpuTempText.text = parts[1].trim() + "°C"
                }
            }
        }
    }
    
    // Per-core CPU usage
    Process {
        id: coresProc
        command: ["sh", "-c", "cat /proc/stat | awk '/^cpu[0-9]/ {usage=100-($5*100/($2+$3+$4+$5+$6+$7+$8)); printf \"%.0f\\n\", usage}'"]
        running: cpuPopup.visible
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                let lines = data.trim().split("\n")
                // Only update if we have valid data
                if (lines.length > 0 && lines[0] !== "") {
                    coresModel.clear()
                    for (let i = 0; i < lines.length; i++) {
                        let usage = parseInt(lines[i]) || 0
                        if (!isNaN(usage)) {
                            coresModel.append({ core: i, usage: usage })
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            ramProc.running = true
            gpuProc.running = true
            if (cpuPopup.visible) coresProc.running = true
            if (gpuPopup.visible) gpuDetailProc.running = true
        }
    }
    
    // CPU Cores Popup
    PanelWindow {
        id: cpuPopup
        visible: false
        
        anchors { top: true; right: true }
        margins.top: 54
        margins.right: 80
        
        implicitWidth: 220
        implicitHeight: 520
        color: "transparent"
        
        ListModel { id: coresModel }
        
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: theme.bg
            border.color: theme.border
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8
                
                Row {
                    width: parent.width
                    
                    Text {
                        text: "CPU Cores"
                        color: theme.text
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }
                    
                    Item { width: parent.width - 80; height: 1 }
                    
                    Text {
                        text: "󰅖"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 14
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cpuPopup.visible = false
                        }
                    }
                }
                
                ListView {
                    width: parent.width
                    height: parent.height - 30
                    model: coresModel
                    clip: true
                    spacing: 4
                    
                    delegate: Row {
                        width: parent ? parent.width : 0
                        spacing: 8
                        
                        Text {
                            text: "C" + model.core
                            color: theme.textDim
                            font.family: theme.monoFont
                            font.pixelSize: 10
                            width: 28
                        }
                        
                        Rectangle {
                            width: parent.width - 75
                            height: 6
                            radius: 3
                            color: theme.bgElevated
                            anchors.verticalCenter: parent.verticalCenter
                            
                            Rectangle {
                                width: parent.width * (model.usage / 100)
                                height: parent.height
                                radius: parent.radius
                                color: model.usage > 80 ? theme.error : model.usage > 50 ? theme.warning : theme.accent
                            }
                        }
                        
                        Text {
                            text: model.usage + "%"
                            color: theme.text
                            font.family: theme.monoFont
                            font.pixelSize: 10
                            width: 32
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }
    }
    
    // GPU Details Popup
    PanelWindow {
        id: gpuPopup
        visible: false
        
        anchors { top: true; right: true }
        margins.top: 54
        margins.right: 12
        
        implicitWidth: 300
        implicitHeight: 340
        color: "transparent"
        
        mask: Region { item: gpuContent }
        
        property string gpuName: "NVIDIA GPU"
        property int gpuUsage: 0
        property int gpuTemp: 0
        property int gpuMemUsed: 0
        property int gpuMemTotal: 0
        property int gpuPower: 0
        property int gpuFanSpeed: 0
        property int gpuMemClock: 0
        property int gpuCoreClock: 0
        
        Rectangle {
            id: gpuContent
            anchors.fill: parent
            radius: 16
            color: theme.bg
            border.color: theme.border
            border.width: 1
            
            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12
                
                // Header
                RowLayout {
                    width: parent.width
                    spacing: 8
                    
                    Text {
                        text: "󰢮"
                        color: theme.tertiary
                        font.family: theme.iconFont
                        font.pixelSize: 18
                    }
                    
                    Column {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "GPU"
                            color: theme.text
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Medium
                        }
                        Text {
                            text: gpuPopup.gpuName
                            color: theme.textDim
                            font.family: theme.fontFamily
                            font.pixelSize: 10
                            elide: Text.ElideRight
                            width: parent.width
                        }
                    }
                    
                    Text {
                        text: "󰅖"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 14
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: gpuPopup.visible = false
                        }
                    }
                }
                
                // Stats grid
                Rectangle {
                    width: parent.width
                    height: 240
                    radius: 12
                    color: theme.bgSurface
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10
                        
                        // Usage
                        Column {
                            width: parent.width
                            spacing: 4
                            
                            RowLayout {
                                width: parent.width
                                Text {
                                    text: "Usage"
                                    color: theme.textDim
                                    font.family: theme.fontFamily
                                    font.pixelSize: 11
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: gpuPopup.gpuUsage + "%"
                                    color: theme.text
                                    font.family: theme.monoFont
                                    font.pixelSize: 11
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: theme.bgElevated
                                Rectangle {
                                    width: parent.width * (gpuPopup.gpuUsage / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: theme.tertiary
                                }
                            }
                        }
                        
                        // VRAM
                        Column {
                            width: parent.width
                            spacing: 4
                            
                            RowLayout {
                                width: parent.width
                                Text {
                                    text: "VRAM"
                                    color: theme.textDim
                                    font.family: theme.fontFamily
                                    font.pixelSize: 11
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: gpuPopup.gpuMemUsed + " / " + gpuPopup.gpuMemTotal + " MB"
                                    color: theme.text
                                    font.family: theme.monoFont
                                    font.pixelSize: 11
                                }
                            }
                            Rectangle {
                                width: parent.width
                                height: 6
                                radius: 3
                                color: theme.bgElevated
                                Rectangle {
                                    width: gpuPopup.gpuMemTotal > 0 ? parent.width * (gpuPopup.gpuMemUsed / gpuPopup.gpuMemTotal) : 0
                                    height: parent.height
                                    radius: parent.radius
                                    color: theme.secondary
                                }
                            }
                        }
                        
                        // Temperature and Fan
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 50
                                radius: 8
                                color: theme.bgElevated
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰔏"
                                        color: gpuPopup.gpuTemp > 80 ? theme.error : gpuPopup.gpuTemp > 60 ? theme.warning : theme.tertiary
                                        font.family: theme.iconFont
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gpuPopup.gpuTemp + "°C"
                                        color: theme.text
                                        font.family: theme.monoFont
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 50
                                radius: 8
                                color: theme.bgElevated
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰈐"
                                        color: theme.accent
                                        font.family: theme.iconFont
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gpuPopup.gpuFanSpeed + "%"
                                        color: theme.text
                                        font.family: theme.monoFont
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                        }
                        
                        // Power and clocks
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 50
                                radius: 8
                                color: theme.bgElevated
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󱐋"
                                        color: theme.warning
                                        font.family: theme.iconFont
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gpuPopup.gpuPower + "W"
                                        color: theme.text
                                        font.family: theme.monoFont
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                            
                            Rectangle {
                                width: (parent.width - 8) / 2
                                height: 50
                                radius: 8
                                color: theme.bgElevated
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "󰓅"
                                        color: theme.accent
                                        font.family: theme.iconFont
                                        font.pixelSize: 16
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: gpuPopup.gpuCoreClock + " MHz"
                                        color: theme.text
                                        font.family: theme.monoFont
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // GPU detailed stats
    Process {
        id: gpuDetailProc
        command: ["sh", "-c", "nvidia-smi --query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total,power.draw,fan.speed,clocks.gr --format=csv,noheader,nounits | head -1"]
        running: gpuPopup.visible
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split(",")
                if (parts.length >= 8) {
                    gpuPopup.gpuName = parts[0].trim()
                    gpuPopup.gpuUsage = parseInt(parts[1]) || 0
                    gpuPopup.gpuTemp = parseInt(parts[2]) || 0
                    gpuPopup.gpuMemUsed = parseInt(parts[3]) || 0
                    gpuPopup.gpuMemTotal = parseInt(parts[4]) || 0
                    gpuPopup.gpuPower = parseInt(parts[5]) || 0
                    gpuPopup.gpuFanSpeed = parseInt(parts[6]) || 0
                    gpuPopup.gpuCoreClock = parseInt(parts[7]) || 0
                }
            }
        }
    }
}
