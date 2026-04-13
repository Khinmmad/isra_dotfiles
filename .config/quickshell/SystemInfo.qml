import QtQuick
import QtQuick.Layouts
import Quickshell.Io

RowLayout {
    spacing: 15

    // Textos que mostrarán el uso de CPU y RAM envueltos en cápsulas
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        height: 32; width: cpuText.implicitWidth + 16
        radius: 12
        color: "#313244" // Surface 0

        Text {
            id: cpuText
            anchors.centerIn: parent
            text: "⚙️ --%"
            color: "#f38ba8" // Catppuccin Red
            font.pixelSize: 14
            font.bold: true
            
            // Animación sutil de color cuando cambie el uso bruscamente
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: termProc.running = true
        }
    }

    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        height: 32; width: ramText.implicitWidth + 16
        radius: 12
        color: "#313244" // Surface 0

        Text {
            id: ramText
            anchors.centerIn: parent
            text: "🧠 --%"
            color: "#a6e3a1" // Catppuccin Green
            font.pixelSize: 14
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: termProc.running = true
        }
    }

    Process {
        id: termProc
        command: ["kitty", "-e", "top"] // Open top in kitty
    }

    // Proceso para medir RAM
    Process {
        id: ramProc
        command: ["bash", "-c", "free -m | awk '/^Mem/ {printf \\\"%.0f\\\", $3/$2 * 100}'"]
        stdout: StdioCollector {
            id: ramOut
        }
        onExited: {
            ramText.text = "🧠 " + ramOut.text.trim() + "%"
        }
    }

    // Proceso para medir CPU
    Process {
        id: cpuProc
        // El script toma una muestra con top en batch mode (muy ligero)
        command: ["bash", "-c", "top -bn1 | grep \\\"Cpu(s)\\\" | sed \\\"s/.*, *\\\\([0-9.]*\\\\)%* id.*/\\\\1/\\\" | awk '{printf \\\"%.0f\\\", 100 - $1}'"]
        stdout: StdioCollector {
            id: cpuOut
        }
        onExited: {
            cpuText.text = "⚙️ " + cpuOut.text.trim() + "%"
        }
    }

    // Temporizador que dispara las recolecciones cada 3 segundos
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            // Ejecutamos los procesos asignando true a 'running' 
            ramProc.running = true
            cpuProc.running = true
        }
    }
}
