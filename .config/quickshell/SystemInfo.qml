import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: sysRoot
    implicitWidth: sysRow.implicitWidth
    implicitHeight: sysRow.implicitHeight

    // Lógica de hover sincronizada
    property bool barHovered: sysHover.containsMouse
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

    Timer { id: showTimer; interval: 200; onTriggered: sysRoot.popupVisible = true }
    Timer { id: hideTimer; interval: 500; onTriggered: if (!sysRoot.anyHovered) sysRoot.popupVisible = false }

    RowLayout {
        id: sysRow
        spacing: 12

        // CPU Capsule
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            height: 32; width: cpuText.implicitWidth + 20
            radius: 16
            color: "#313244" // Surface 0
            border.color: "#45475a"
            border.width: 1

            Text {
                id: cpuText
                anchors.centerIn: parent
                text: "⚙️ --%"
                color: "#f38ba8" // Catppuccin Red
                font.pixelSize: 13
                font.bold: true
            }
        }

        // RAM Capsule
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            height: 32; width: ramText.implicitWidth + 20
            radius: 16
            color: "#313244" // Surface 0
            border.color: "#45475a"
            border.width: 1

            Text {
                id: ramText
                anchors.centerIn: parent
                text: "🧠 --%"
                color: "#a6e3a1" // Catppuccin Green
                font.pixelSize: 13
                font.bold: true
            }
        }
    }

    MouseArea {
        id: sysHover
        anchors.fill: sysRow
        hoverEnabled: true
    }

    // ── Popup de Información del Sistema ──
    PopupWindow {
        id: sysPopup
        anchor.item: sysRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        visible: sysRoot.popupVisible
        color: "transparent"

        Rectangle {
            width: 200
            height: 120
            color: "#1e1e2e"
            radius: 24
            border.color: "#45475a"
            border.width: 1

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onContainsMouseChanged: sysRoot.popupHovered = containsMouse
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Text {
                    text: "Estado del Sistema"
                    color: "#cdd6f4"
                    font.pixelSize: 14
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // CPU Detail
                ColumnLayout {
                    spacing: 4
                    RowLayout {
                        Text { text: "CPU"; color: "#f38ba8"; font.pixelSize: 11; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: cpuText.text.split(" ")[1]; color: "#bac2de"; font.pixelSize: 11 }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6; radius: 3
                        color: "#313244"
                        Rectangle {
                            height: parent.height; radius: 3
                            width: parent.width * (parseFloat(cpuText.text.split(" ")[1]) / 100)
                            color: "#f38ba8"
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                }

                // RAM Detail
                ColumnLayout {
                    spacing: 4
                    RowLayout {
                        Text { text: "Memoria"; color: "#a6e3a1"; font.pixelSize: 11; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: ramText.text.split(" ")[1]; color: "#bac2de"; font.pixelSize: 11 }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 6; radius: 3
                        color: "#313244"
                        Rectangle {
                            height: parent.height; radius: 3
                            width: parent.width * (parseFloat(ramText.text.split(" ")[1]) / 100)
                            color: "#a6e3a1"
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                }
            }
        }
    }

    // Datos (Procesos)
    Process {
        id: ramProc
        command: ["bash", "-c", "free -m | awk '/^Mem/ {printf \"%.0f\", $3/$2 * 100}'"]
        stdout: StdioCollector { id: ramOut }
        onExited: ramText.text = "🧠 " + ramOut.text.trim() + "%"
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\([0-9.]*\\)%* id.*/\\1/\" | awk '{printf \"%.0f\", 100 - $1}'"]
        stdout: StdioCollector { id: cpuOut }
        onExited: cpuText.text = "⚙️ " + cpuOut.text.trim() + "%"
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ramProc.running = true
            cpuProc.running = true
        }
    }
}
