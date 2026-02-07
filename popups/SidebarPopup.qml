import Quickshell
import QtQuick
import "../theme"

PanelWindow {
    id: popup
    
    property bool isOpen: false
    property var notifHistory: null
    
    function toggle() { isOpen = !isOpen }
    
    Theme { id: theme }
    
    visible: isOpen
    anchors { top: true; right: true }
    margins.top: 54
    margins.right: 12
    
    implicitWidth: 360
    implicitHeight: 500
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
            
            // Big Clock
            Rectangle {
                width: parent.width
                height: 110
                radius: 16
                color: theme.bgSurface
                
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    
                    Text {
                        id: bigClock
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        color: theme.text
                        font.family: theme.monoFont
                        font.pixelSize: 44
                        font.weight: Font.Light
                    }
                    
                    Text {
                        id: dateText
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                    }
                    
                    Timer {
                        interval: 1000
                        running: popup.isOpen
                        repeat: true
                        onTriggered: {
                            bigClock.text = Qt.formatDateTime(new Date(), "HH:mm")
                            dateText.text = Qt.formatDateTime(new Date(), "dddd, MMMM d, yyyy")
                        }
                    }
                }
            }
            
            // Notifications Header
            Row {
                width: parent.width
                height: 24
                
                Text {
                    text: "Notifications"
                    color: theme.text
                    font.family: theme.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
                
                Text {
                    visible: notifHistory && notifHistory.count > 0
                    text: notifHistory ? " (" + notifHistory.count + ")" : ""
                    color: theme.textDim
                    font.family: theme.fontFamily
                    font.pixelSize: 14
                }
                
                Item { width: parent.width - 180; height: 1 }
                
                Text {
                    text: "Clear all"
                    color: theme.accent
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                    visible: notifHistory && notifHistory.count > 0
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (notifHistory) notifHistory.clear()
                        }
                    }
                }
            }
            
            // Notifications list or empty state
            Rectangle {
                width: parent.width
                height: parent.height - 160
                radius: 16
                color: theme.bgSurface
                clip: true
                
                // Empty state
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !notifHistory || notifHistory.count === 0
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰂚"
                        color: theme.textDim
                        font.family: theme.iconFont
                        font.pixelSize: 48
                    }
                    
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "All caught up!"
                        color: theme.textDim
                        font.family: theme.fontFamily
                        font.pixelSize: 13
                    }
                }
                
                // Notifications list
                ListView {
                    id: notifList
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    clip: true
                    visible: notifHistory && notifHistory.count > 0
                    
                    model: notifHistory
                    
                    delegate: Rectangle {
                        id: historyItem
                        
                        width: notifList.width
                        height: notifContent.height + 16
                        radius: 10
                        color: notifHover.containsMouse ? theme.bgHover : theme.bgElevated
                        
                        Behavior on color { ColorAnimation { duration: 100 } }
                        
                        Column {
                            id: notifContent
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 8
                            spacing: 4
                            
                            Row {
                                width: parent.width
                                spacing: 8
                                
                                Text {
                                    text: "󰍡"
                                    color: theme.accent
                                    font.family: theme.iconFont
                                    font.pixelSize: 14
                                }
                                
                                Text {
                                    text: model.appName
                                    color: theme.text
                                    font.family: theme.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    width: parent.width - 60
                                }
                                
                                Text {
                                    text: "󰅖"
                                    color: theme.textDim
                                    font.family: theme.iconFont
                                    font.pixelSize: 12
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: notifHistory.remove(index)
                                    }
                                }
                            }
                            
                            Text {
                                text: model.summary
                                color: theme.text
                                font.family: theme.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Medium
                                wrapMode: Text.WordWrap
                                width: parent.width
                                visible: text !== ""
                            }
                            
                            Text {
                                text: model.body
                                color: theme.textDim
                                font.family: theme.fontFamily
                                font.pixelSize: 11
                                wrapMode: Text.WordWrap
                                width: parent.width
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }
                        }
                        
                        MouseArea {
                            id: notifHover
                            anchors.fill: parent
                            hoverEnabled: true
                            z: -1
                        }
                    }
                }
            }
        }
    }
}
