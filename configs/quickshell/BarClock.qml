import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: clockRoot
    implicitWidth: 42
    implicitHeight: 42

    property date currentTime: new Date()
    property bool drawerOpen: false // Usado ahora para controlar la expansión desde fuera si fuera necesario

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: currentTime = new Date()
    }

    // ─── Vista de la Barra (Compacta) ───
    ColumnLayout {
        anchors.centerIn: parent
        spacing: -2
        visible: !drawerOpen // Solo se muestra si NO está expandido (opcional, dependiendo de shell.qml)

        Text {
            text: Qt.formatTime(clockRoot.currentTime, "hh")
            color: "#1f1b16"; font.pixelSize: 13; font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: Qt.formatTime(clockRoot.currentTime, "mm")
            color: "#8b4a3f"; font.pixelSize: 13; font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // ─── Vista Expandida (Contenido del Panel) ───
    // Este contenido se mostrará dentro del expansionArea de shell.qml
    // Para que shell.qml pueda mostrarlo, lo envolvemos en un componente o item visible según el estado
    Rectangle {
        id: expandedView
        anchors.fill: parent
        color: "transparent"
        visible: drawerOpen // Esto lo controlará shell.qml igualando drawerOpen a su estado de expansión

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "🕐 Ciudad de México"
                color: "#8b4a3f"
                font.pixelSize: 14; font.bold: true
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0
                Text {
                    text: Qt.formatTime(clockRoot.currentTime, "h:mm")
                    color: "#1f1b16"
                    font.pixelSize: 48; font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: Qt.formatTime(clockRoot.currentTime, "ap").toUpperCase()
                    color: "#8b4a3f"
                    font.pixelSize: 14; font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2
                Text {
                    text: Qt.formatDate(clockRoot.currentTime, "dddd").charAt(0).toUpperCase() + Qt.formatDate(clockRoot.currentTime, "dddd").slice(1)
                    color: "#1f1b16"
                    font.pixelSize: 18; font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Text {
                    text: Qt.formatDate(clockRoot.currentTime, "d 'de' MMMM, yyyy")
                    color: "#5c5248"
                    font.pixelSize: 13
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            Item { Layout.fillHeight: true }
            
            // Un pequeño mensaje decorativo
            Text {
                text: "Que tengas un gran día"
                color: "#9e8438"; font.pixelSize: 11; font.italic: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
