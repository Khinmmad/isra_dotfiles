import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: launcherRoot
    property bool active: false

    Rectangle {
        anchors.fill: parent
        color: "transparent" // El fondo lo pone la barra

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 16

            // Header
            RowLayout {
                spacing: 10
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: "#efe4d4"
                    Text { anchors.centerIn: parent; text: "🐻"; font.pixelSize: 18 }
                }
                Column {
                    Text { text: "Bienvenido";     color: "#9e8438"; font.pixelSize: 10 }
                    Text { text: "Quickshell Menu"; color: "#1f1b16"; font.pixelSize: 13; font.bold: true }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

            // App Grid
            GridLayout {
                columns: 3; rowSpacing: 16; columnSpacing: 16
                Layout.fillWidth: true

                AppButton { icon: "💻"; label: "Terminal"; cmd: "kitty";    color: "#cc6e28" }
                AppButton { icon: "🌐"; label: "Web";      cmd: "firefox";  color: "#d4b440" }
                AppButton { icon: "📁"; label: "Archivos"; cmd: "thunar";   color: "#e09838" }
                AppButton { icon: "📝"; label: "Editor";   cmd: "code";     color: "#96c836" }
                AppButton { icon: "🎵"; label: "Música";   cmd: "spotify";  color: "#1db954" }
                AppButton { icon: "⚙️"; label: "Ajustes";  cmd: "nwg-look"; color: "#a0c840" }
            }

            Item { Layout.fillHeight: true }

            // Power Menu
            RowLayout {
                Layout.fillWidth: true; spacing: 8
                PowerButton { icon: "󰐥"; label: "Apagar";   cmd: "shutdown now";             accentColor: "#cc6e28" }
                PowerButton { icon: "󰜉"; label: "Reiniciar"; cmd: "reboot";                   accentColor: "#e09838" }
                PowerButton { icon: "󰍃"; label: "Salir";     cmd: "hyprctl dispatch exit";    accentColor: "#8b4a3f" }
            }
        }
    }

    component AppButton: Column {
        property string icon: ""
        property string label: ""
        property string cmd: ""
        property string color: "#8b4a3f"

        spacing: 6
        Layout.alignment: Qt.AlignHCenter

        Rectangle {
            id: btnRect
            width: 56; height: 56; radius: 14
            color: mouseArea.containsMouse ? "#efe4d4" : "#efe4d4"
            border.color: mouseArea.containsMouse ? color : "transparent"
            border.width: 2
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Text { anchors.centerIn: parent; text: icon; font.pixelSize: 28 }

            MouseArea {
                id: mouseArea; anchors.fill: parent
                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: {
                    proc.command = [cmd]; proc.running = true
                    launcherRoot.active = false
                }
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: label; color: "#1f1b16"; font.pixelSize: 10; font.bold: true
        }
    }

    component PowerButton: Rectangle {
        property string icon: ""
        property string label: ""
        property string cmd: ""
        property string accentColor: ""

        Layout.fillWidth: true; height: 38; radius: 10
        color: pArea.containsMouse ? accentColor : "#efe4d4"
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.centerIn: parent; spacing: 6
            Text { text: icon;  font.pixelSize: 14; color: pArea.containsMouse ? "#f5ede4" : accentColor }
            Text { text: label; font.pixelSize: 11; font.bold: true; color: pArea.containsMouse ? "#f5ede4" : "#1f1b16" }
        }

        MouseArea {
            id: pArea; anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
                proc.command = ["bash", "-c", cmd]; proc.running = true
                launcherRoot.active = false
            }
        }
    }

    Process { id: proc }
}
