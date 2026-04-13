import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: clockRoot
    implicitWidth: 120
    implicitHeight: 32
    
    property date currentTime: new Date()

    // Lógica de hover sincronizada
    property bool barHovered: clockHover.containsMouse
    property bool popupHovered: false
    property bool anyHovered: barHovered || popupHovered
    property bool popupVisible: false

    onAnyHoveredChanged: {
        if (anyHovered) {
            hideTimer.stop()
            showTimer.start()
        } else {
            showTimer.stop()
            hideTimer.start()
        }
    }

    Timer { id: showTimer; interval: 200; onTriggered: clockRoot.popupVisible = true }
    Timer { id: hideTimer; interval: 500; onTriggered: if (!clockRoot.anyHovered) clockRoot.popupVisible = false }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentTime = new Date()
    }

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: "#313244"
        border.color: "#45475a"
        border.width: 1

        Column {
            anchors.centerIn: parent
            spacing: 0

            Text {
                id: hourText
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatTime(currentTime, "h:mm ap")
                color: "#cdd6f4"
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                id: dateText
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDate(currentTime, "ddd d 'de' MMM")
                color: "#6c7086"
                font.pixelSize: 9
                font.bold: false
            }
        }
        
        MouseArea {
            id: clockHover
            anchors.fill: parent
            hoverEnabled: true
        }
    }

    // ── Popup de Fecha Detallada ──
    PopupWindow {
        id: datePopup
        anchor.item: clockRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        implicitWidth: 220
        implicitHeight: 90
        visible: clockRoot.popupVisible
        color: "transparent"

        Rectangle {
            width: 220
            height: 90
            color: "#1e1e2e"
            radius: 24
            border.color: "#45475a"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: clockRoot.popupHovered = containsMouse
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                Text {
                    text: "Calendario y Fecha"
                    color: "#cba6f7" // Mauve
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                Text {
                    text: Qt.formatDate(currentTime, "dddd")
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    transform: [ Translate { y: -2 } ]
                }

                Text {
                    text: Qt.formatDate(currentTime, "d 'de' MMMM, yyyy")
                    color: "#bac2de"
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}