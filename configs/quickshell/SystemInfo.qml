import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: sysRoot
    implicitWidth: 36
    implicitHeight: 36

    property bool drawerOpen: false
    property string cpuPct: "0"
    property string ramPct: "0"

    Rectangle {
        anchors.fill: parent
        radius: 18
        color: sysArea.containsMouse
            ? "#8b7355"
            : (sysRoot.drawerOpen ? "#e8dccb" : "#efe4d4")
        Behavior on color { ColorAnimation { duration: 150 } }
        scale: sysArea.pressed ? 0.9 : (sysArea.containsMouse ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

        Text { anchors.centerIn: parent; text: "💻"; font.pixelSize: 16 }

        MouseArea {
            id: sysArea; anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: sysRoot.drawerOpen = !sysRoot.drawerOpen
        }
    }

    PopupWindow {
        id: drawer
        anchor.item: sysRoot
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.adjustment: PopupAdjustment.SlideY
        implicitWidth: 260; implicitHeight: 180
        visible: sysRoot.drawerOpen
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f5ede4"; radius: 20
            border.color: "#8b7355"; border.width: 1

            opacity: sysRoot.drawerOpen ? 1.0 : 0.0
            scale:   sysRoot.drawerOpen ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale   { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12

                RowLayout {
                    Text { text: "💻 Sistema"; color: "#8b4a3f"
                        font.pixelSize: 14; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: closeArea.containsMouse ? "#cc6e28" : "#efe4d4"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✕"
                            font.pixelSize: 10; color: "#1f1b16" }
                        MouseArea {
                            id: closeArea; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: sysRoot.drawerOpen = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

                // CPU
                ColumnLayout {
                    spacing: 4
                    RowLayout {
                        Text { text: "⚙️ CPU"; color: "#cc6e28"
                            font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: sysRoot.cpuPct + "%"; color: "#1f1b16"
                            font.pixelSize: 12; font.bold: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: "#e8dccb"
                        Rectangle {
                            height: parent.height; radius: 4
                            width: parent.width * (parseFloat(sysRoot.cpuPct) / 100)
                            color: "#cc6e28"
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                }

                // RAM
                ColumnLayout {
                    spacing: 4
                    RowLayout {
                        Text { text: "🧠 Memoria"; color: "#96c836"
                            font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: sysRoot.ramPct + "%"; color: "#1f1b16"
                            font.pixelSize: 12; font.bold: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 8; radius: 4; color: "#e8dccb"
                        Rectangle {
                            height: parent.height; radius: 4
                            width: parent.width * (parseFloat(sysRoot.ramPct) / 100)
                            color: "#96c836"
                            Behavior on width { NumberAnimation { duration: 500 } }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }
    }

    Process {
        id: ramProc
        command: ["bash", "-c", "free -m | awk '/^Mem/ {printf \"%.0f\", $3/$2 * 100}'"]
        stdout: StdioCollector { id: ramOut }
        onExited: sysRoot.ramPct = ramOut.text.trim()
    }

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep \"Cpu(s)\" | sed \"s/.*, *\\([0-9.]*\\)%* id.*/\\1/\" | awk '{printf \"%.0f\", 100 - $1}'"]
        stdout: StdioCollector { id: cpuOut }
        onExited: sysRoot.cpuPct = cpuOut.text.trim()
    }

    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { ramProc.running = true; cpuProc.running = true }
    }
}
