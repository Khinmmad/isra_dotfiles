import QtQuick
import QtQuick.Layouts
import Quickshell

RowLayout {
    SystemClock { id: clock; precision: SystemClock.Seconds }

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.rightMargin: 4
        height: 32
        width: 80
        radius: 12
        color: "#313244"

        Column {
            anchors.centerIn: parent
            spacing: 1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: clock.time ? Qt.formatTime(clock.time, "HH:mm") : "--:--"
                color: "#cdd6f4"
                font.pixelSize: 14
                font.bold: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: clock.time ? Qt.formatDate(clock.time, "ddd d") : "---"
                color: "#6c7086"
                font.pixelSize: 9
            }
        }
    }
}