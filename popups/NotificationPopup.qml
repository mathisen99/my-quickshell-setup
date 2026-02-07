import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import "../theme"

PanelWindow {
    id: popup
    
    Theme { id: theme }
    
    property bool dndEnabled: false
    
    anchors { top: true; right: true }
    margins.top: 54
    margins.right: 12
    
    implicitWidth: 380
    implicitHeight: Math.min(notifColumn.height + 16, 400)
    color: "transparent"
    
    visible: notifServer.trackedNotifications.values.length > 0 && !dndEnabled
    
    NotificationServer {
        id: notifServer
        
        onNotification: notif => {
            notif.tracked = true
            
            // Add to history
            historyModel.insert(0, {
                appName: notif.appName || "Notification",
                summary: notif.summary || "",
                body: notif.body || "",
                time: new Date()
            })
            
            // Keep history limited to 50
            if (historyModel.count > 50) {
                historyModel.remove(historyModel.count - 1)
            }
            
            // Auto-dismiss popup after timeout (default 5 seconds)
            let timeout = notif.expireTimeout > 0 ? notif.expireTimeout : 5000
            dismissTimer.createObject(notif, { 
                target: notif, 
                interval: timeout 
            })
        }
    }
    
    // Timer component for auto-dismiss
    Component {
        id: dismissTimer
        Timer {
            property Notification target
            running: true
            onTriggered: target.dismiss()
        }
    }
    
    // History model for sidebar
    ListModel {
        id: historyModel
    }
    
    // Expose for other components
    property alias server: notifServer
    property alias history: historyModel
    
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        
        Column {
            id: notifColumn
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            spacing: 8
            
            Repeater {
                model: notifServer.trackedNotifications
                
                Rectangle {
                    id: notifCard
                    required property Notification modelData
                    
                    width: parent.width
                    height: cardContent.height + 24
                    radius: 16
                    color: theme.bg
                    border.color: theme.border
                    border.width: 1
                    
                    // Entry animation
                    opacity: 0
                    x: 50
                    
                    Component.onCompleted: {
                        opacity = 1
                        x = 0
                    }
                    
                    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    
                    Column {
                        id: cardContent
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 12
                        spacing: 6
                        
                        // Header
                        Row {
                            width: parent.width
                            spacing: 8
                            
                            Text {
                                text: "󰍡"
                                color: theme.accent
                                font.family: theme.iconFont
                                font.pixelSize: 16
                            }
                            
                            Text {
                                text: notifCard.modelData.appName || "Notification"
                                color: theme.textDim
                                font.family: theme.fontFamily
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                width: parent.width - 70
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            
                            Text {
                                text: "󰅖"
                                color: closeHover.containsMouse ? theme.error : theme.textDim
                                font.family: theme.iconFont
                                font.pixelSize: 14
                                
                                Behavior on color { ColorAnimation { duration: 100 } }
                                
                                MouseArea {
                                    id: closeHover
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifCard.modelData.dismiss()
                                }
                            }
                        }
                        
                        // Summary
                        Text {
                            text: notifCard.modelData.summary || ""
                            color: theme.text
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            wrapMode: Text.WordWrap
                            width: parent.width
                            visible: text !== ""
                        }
                        
                        // Body
                        Text {
                            text: notifCard.modelData.body || ""
                            color: theme.textDim
                            font.family: theme.fontFamily
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                            width: parent.width
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            visible: text !== ""
                        }
                    }
                    
                    // Click to dismiss
                    MouseArea {
                        anchors.fill: parent
                        z: -1
                        onClicked: notifCard.modelData.dismiss()
                    }
                }
            }
        }
    }
}
