import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    id: root
    
    Layout.preferredWidth: clockRow.width + 20
    Layout.preferredHeight: 32
    Layout.alignment: Qt.AlignVCenter
    
    Theme { id: theme }
    
    radius: theme.radiusSmall
    color: hover.containsMouse ? theme.bgHover : theme.bgSurface
    
    Behavior on color { ColorAnimation { duration: theme.animDuration } }
    
    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8
        
        Text {
            text: "󰥔"
            color: theme.accent
            font.family: theme.iconFont
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), "HH:mm")
            color: theme.text
            font.family: theme.monoFont
            font.pixelSize: 13
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "ddd d")
            color: theme.textDim
            font.family: theme.fontFamily
            font.pixelSize: 11
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            let now = new Date()
            timeText.text = Qt.formatDateTime(now, "HH:mm")
            dateText.text = Qt.formatDateTime(now, "ddd d")
        }
    }
    
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: shell.sidebarPopup.toggle()
    }
}
