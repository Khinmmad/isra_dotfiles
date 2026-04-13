import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: bottomPanel
        anchors {
            top: true
            bottom: false
            left: true
            right: true
        }
        
        // En Quickshell los márgenes de la ventana (para el protocolo LayerShell) suelen declararse así:
        margins {
            top: 12
            left: 12
            right: 12
        }
        
        implicitHeight: 48 // Un poco más alto para verse más premium
        color: "transparent" // La ventana real es transparente, la caja de color va adentro
        
        Rectangle {
            id: panelRect
            anchors.fill: parent
            color: "#1e1e2e" // Catppuccin Mocha Base (sólido)
            radius: 16
            border.color: "#45475a" // Catppuccin Surface 1
            border.width: 1
            
            // Animación de entrada al cargar el panel
            scale: 0.95
            opacity: 0.0
            Component.onCompleted: {
                panelRect.scale = 1.0
                panelRect.opacity = 1.0
            }
            
            Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutSine } }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 15
                
                // Módulo izquierdo (ej. logo o menú)
                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 4
                    width: 32; height: 32
                    radius: 16
                    color: "#313244" // Catppuccin Surface 0
                    Text {
                        anchors.centerIn: parent
                        text: "🐻" // Placeholder de ícono
                        font.pixelSize: 16
                    }
                }
                
                // Espaciador para empujar el texto al centro si quisieras:
                // Item { Layout.fillWidth: true }
                
                Workspaces {
                    Layout.alignment: Qt.AlignVCenter
                }
                
                Item { Layout.fillWidth: true } // Esto empuja lo siguiente a la derecha
                
                // Módulos derechos (estado de red, sistema y reloj)
                NetworkStatus {
                    Layout.alignment: Qt.AlignVCenter
                }

                SystemInfo {
                    Layout.alignment: Qt.AlignVCenter
                }

                Music {
                    Layout.alignment: Qt.AlignVCenter
                }

                Clock {
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }
    }
}