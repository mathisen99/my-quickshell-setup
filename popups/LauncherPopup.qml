import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../theme"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    
    function toggle() { 
        isOpen = !isOpen
        if (isOpen) {
            searchInput.text = ""
            loadApps()
        }
    }
    
    function loadApps() {
        appsProc.running = true
    }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true }
    margins.top: 100
    
    // Enable keyboard input
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    // Center horizontally
    exclusionMode: ExclusionMode.Ignore
    
    implicitWidth: 500
    implicitHeight: 480
    color: "transparent"
    
    // Click outside to close
    mask: Region { item: popupContent }
    
    // Focus input when opened
    onIsOpenChanged: {
        if (isOpen) {
            searchInput.forceActiveFocus()
        }
    }
    
    ListModel {
        id: appsModel
    }
    
    ListModel {
        id: filteredModel
    }
    
    Process {
        id: appsProc
        command: ["sh", "-c", "find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | while read f; do name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2); exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2 | sed 's/ %[a-zA-Z]//g'); icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2); nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2); if [ \"$nodisplay\" != \"true\" ] && [ -n \"$name\" ] && [ -n \"$exec\" ]; then echo \"$name|$exec|$icon\"; fi; done | sort -u"]
        running: false
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                appsModel.clear()
                filteredModel.clear()
                let lines = data.trim().split("\n")
                for (let line of lines) {
                    let parts = line.split("|")
                    if (parts.length >= 2) {
                        let app = {
                            name: parts[0],
                            exec: parts[1],
                            icon: parts[2] || ""
                        }
                        appsModel.append(app)
                        filteredModel.append(app)
                    }
                }
            }
        }
    }
    
    Process {
        id: launchProc
        property string cmd: ""
        command: ["sh", "-c", cmd]
    }
    
    function filterApps(query) {
        filteredModel.clear()
        let q = query.toLowerCase()
        for (let i = 0; i < appsModel.count; i++) {
            let app = appsModel.get(i)
            if (app.name.toLowerCase().includes(q)) {
                filteredModel.append(app)
            }
        }
    }
    
    function launchApp(exec) {
        launchProc.command = ["sh", "-c", "nohup " + exec + " >/dev/null 2>&1 &"]
        launchProc.running = true
        popup.isOpen = false
    }
    
    Rectangle {
        id: popupContent
        anchors.centerIn: parent
        width: 500
        height: 480
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
            anchors.margins: 16
            spacing: 12
            
            // Search bar
            Rectangle {
                width: parent.width
                height: 50
                radius: 14
                color: theme.bgSurface
                
                Row {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12
                    
                    Text {
                        text: "󰍉"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 20
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    TextInput {
                        id: searchInput
                        width: parent.width - 40
                        anchors.verticalCenter: parent.verticalCenter
                        color: theme.text
                        font.family: theme.fontFamily
                        font.pixelSize: 16
                        clip: true
                        
                        property string placeholderText: "Search apps..."
                        
                        Text {
                            anchors.fill: parent
                            text: searchInput.placeholderText
                            color: theme.textDim
                            font: searchInput.font
                            visible: !searchInput.text && !searchInput.activeFocus
                        }
                        
                        onTextChanged: popup.filterApps(text)
                        
                        Keys.onReturnPressed: {
                            if (filteredModel.count > 0) {
                                popup.launchApp(filteredModel.get(0).exec)
                            }
                        }
                        
                        Keys.onEscapePressed: popup.isOpen = false
                        
                        Keys.onDownPressed: appsList.incrementCurrentIndex()
                        Keys.onUpPressed: appsList.decrementCurrentIndex()
                    }
                }
            }
            
            // Apps list
            Rectangle {
                width: parent.width
                height: parent.height - 74
                radius: 14
                color: theme.bgSurface
                clip: true
                
                ListView {
                    id: appsList
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4
                    clip: true
                    
                    model: filteredModel
                    currentIndex: 0
                    
                    delegate: Rectangle {
                        id: appItem
                        width: appsList.width
                        height: 48
                        radius: 10
                        color: appsList.currentIndex === index ? theme.accent : (appHover.containsMouse ? theme.bgHover : "transparent")
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        
                        Row {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12
                            
                            // App icon placeholder
                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: appsList.currentIndex === index ? Qt.rgba(0,0,0,0.2) : theme.bgElevated
                                anchors.verticalCenter: parent.verticalCenter
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: model.name.charAt(0).toUpperCase()
                                    color: appsList.currentIndex === index ? theme.bg : theme.accent
                                    font.family: theme.fontFamily
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                }
                            }
                            
                            Text {
                                text: model.name
                                color: appsList.currentIndex === index ? theme.bg : theme.text
                                font.family: theme.fontFamily
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                                elide: Text.ElideRight
                                width: parent.width - 50
                            }
                        }
                        
                        MouseArea {
                            id: appHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popup.launchApp(model.exec)
                            onEntered: appsList.currentIndex = index
                        }
                    }
                    
                    // Empty state
                    Text {
                        anchors.centerIn: parent
                        text: filteredModel.count === 0 ? "No apps found" : ""
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 14
                        visible: filteredModel.count === 0
                    }
                }
            }
        }
    }
    
    // Close when clicking outside
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: popup.isOpen = false
    }
}
