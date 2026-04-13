import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: launcherRoot
    property bool active: false
    property var anchorItem: null

    function toggle() {
        active = !active
    }

    PopupWindow {
        id: launcherPopup
        anchor.item: launcherRoot.anchorItem
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        implicitWidth: 320
        implicitHeight: 480
        visible: launcherRoot.active
        color: "transparent"

        // Fondo del launcher
        Rectangle {
            width: 320
            height: 480
            color: "#1e1e2e" // Mocha Base
            radius: 24
            border.color: "#45475a"
            border.width: 1

            // Animación
            opacity: launcherRoot.active ? 1.0 : 0.0
            scale: launcherRoot.active ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                // Header
                RowLayout {
                    spacing: 12
                    Rectangle {
                        width: 48; height: 48; radius: 24
                        color: "#313244"
                        Text { anchors.centerIn: parent; text: "🐻"; font.pixelSize: 24 }
                    }
                    Column {
                        Text { text: "Bienvenido"; color: "#6c7086"; font.pixelSize: 12 }
                        Text { text: "Quickshell Menu"; color: "#cdd6f4"; font.pixelSize: 16; font.bold: true }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // App Grid
                GridLayout {
                    columns: 3
                    rowSpacing: 20
                    columnSpacing: 20
                    Layout.fillWidth: true

                    AppButton { icon: "💻"; label: "Terminal"; cmd: "kitty"; color: "#f38ba8" }
                    AppButton { icon: "🌐"; label: "Web"; cmd: "firefox"; color: "#89b4fa" }
                    AppButton { icon: "📁"; label: "Archivos"; cmd: "thunar"; color: "#fab387" }
                    AppButton { icon: "📝"; label: "Editor"; cmd: "code"; color: "#a6e3a1" }
                    AppButton { icon: "🎵"; label: "Música"; cmd: "spotify"; color: "#1db954" }
                    AppButton { icon: "⚙️"; label: "Ajustes"; cmd: "nwg-look"; color: "#94e2d5" }
                }

                Item { Layout.fillHeight: true }

                // Power Menu
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    PowerButton { icon: "󰐥"; label: "Apagar"; cmd: "shutdown now"; accentColor: "#f38ba8" }
                    PowerButton { icon: "󰜉"; label: "Reiniciar"; cmd: "reboot"; accentColor: "#fab387" }
                    PowerButton { icon: "󰍃"; label: "Salir"; cmd: "hyprctl dispatch exit"; accentColor: "#f9e2af" }
                }
            }
        }
    }

    // Componente interno para botones de apps
    component AppButton: Column {
        property string icon: ""
        property string label: ""
        property string cmd: ""
        property string color: "#cba6f7"
        
        spacing: 8
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
            id: btnRect
            width: 64; height: 64; radius: 16
            color: mouseArea.containsMouse ? "#313244" : "#181825"
            border.color: mouseArea.containsMouse ? color : "transparent"
            border.width: 2
            
            Behavior on color { ColorAnimation { duration: 150 } }
            
            Text {
                anchors.centerIn: parent
                text: icon
                font.pixelSize: 32
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    proc.command = [cmd]
                    proc.running = true
                    launcherRoot.active = false
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: label
            color: "#cdd6f4"
            font.pixelSize: 11
            font.bold: true
        }
    }

    // Componente interno para botones de poder
    component PowerButton: Rectangle {
        property string icon: ""
        property string label: ""
        property string cmd: ""
        property string accentColor: ""

        Layout.fillWidth: true
        height: 44
        radius: 12
        color: pArea.containsMouse ? accentColor : "#313244"
        
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.centerIn: parent
            spacing: 8
            Text { text: icon; font.pixelSize: 16; color: pArea.containsMouse ? "#1e1e2e" : accentColor }
            Text { text: label; font.pixelSize: 12; font.bold: true; color: pArea.containsMouse ? "#1e1e2e" : "#cdd6f4" }
        }

        MouseArea {
            id: pArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                proc.command = ["bash", "-c", cmd]
                proc.running = true
                launcherRoot.active = false
            }
        }
    }

    Process { id: proc }
}
