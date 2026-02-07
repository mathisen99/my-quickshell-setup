import QtQuick
import QtQuick.Layouts
import "../theme"

Rectangle {
    Theme { id: theme }
    
    Layout.preferredWidth: 1
    Layout.preferredHeight: 20
    Layout.alignment: Qt.AlignVCenter
    color: theme.border
    opacity: 0.5
}
