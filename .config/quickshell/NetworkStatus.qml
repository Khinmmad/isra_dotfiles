import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: netRoot
    implicitWidth: netRow.implicitWidth
    implicitHeight: netRow.implicitHeight

    // Estado de conexión
    property string currentSSID: ""
    property string connectionStatus: "Escaneando..."
    property bool isConnected: currentSSID !== ""

    // Control de visibilidad robusto del popup
    property bool barHovered: netHover.containsMouse
    property bool popupHovered: false  // Lo controla el MouseArea del popup
    property bool anyHovered: barHovered || popupHovered
    property bool popupVisible: false

    onAnyHoveredChanged: {
        if (anyHovered) {
            netPopupHideTimer.stop()
            netPopupShowTimer.start()
        } else {
            netPopupShowTimer.stop()
            netPopupHideTimer.start()
        }
    }

    Timer {
        id: netPopupShowTimer
        interval: 200
        onTriggered: {
            netRoot.popupVisible = true
            scanProc.running = true
        }
    }
    Timer {
        id: netPopupHideTimer
        interval: 600
        onTriggered: {
            if (!netRoot.anyHovered) {
                netRoot.popupVisible = false
            }
        }
    }

    // ── Modelo de redes WiFi ──
    property var wifiNetworks: []
    property string connectingSSID: ""

    // Proceso: obtener SSID actual
    Process {
        id: currentProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"]
        stdout: StdioCollector { id: currentOut }
        onExited: {
            let ssid = currentOut.text.trim();
            netRoot.currentSSID = ssid;
            netRoot.connectionStatus = ssid !== "" ? ("Conectado a " + ssid) : "Sin conexión";
        }
    }

    // Proceso: escanear redes WiFi
    Process {
        id: scanProc
        command: ["bash", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null | head -20"]
        stdout: StdioCollector { id: scanOut }
        onExited: {
            let lines = scanOut.text.trim().split("\n");
            let nets = [];
            for (let i = 0; i < lines.length; i++) {
                let parts = lines[i].split(":");
                if (parts.length >= 3 && parts[0] !== "") {
                    // Evitar duplicados
                    let exists = false;
                    for (let j = 0; j < nets.length; j++) {
                        if (nets[j].ssid === parts[0]) { exists = true; break; }
                    }
                    if (!exists) {
                        nets.push({
                            ssid: parts[0],
                            signal: parseInt(parts[1]) || 0,
                            security: parts[2] || "",
                            inUse: parts[3] === "*"
                        });
                    }
                }
            }
            // Ordenar por señal descendente
            nets.sort(function(a, b) { return b.signal - a.signal; });
            netRoot.wifiNetworks = nets;
        }
    }

    // Proceso: conectar a red
    Process {
        id: connectProc
        command: ["bash", "-c", "echo placeholder"]
        stdout: StdioCollector { id: connectOut }
        onExited: {
            netRoot.connectingSSID = "";
            currentProc.running = true; // Refrescar estado
            scanProc.running = true;
        }
    }

    // Timer para obtener el SSID actual periódicamente
    Timer {
        interval: 5000
        running: true; repeat: true; triggeredOnStart: true
        onTriggered: currentProc.running = true
    }

    // ── Indicador compacto en la barra ──
    RowLayout {
        id: netRow
        spacing: 6

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            height: 32; width: netLabel.implicitWidth + 40
            radius: 16
            color: netHover.containsMouse ? "#45475a" : "#313244"
            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text {
                    text: netRoot.isConnected ? "📶" : "📡"
                    font.pixelSize: 14
                }
                Text {
                    id: netLabel
                    text: netRoot.isConnected ? netRoot.currentSSID : "WiFi"
                    color: netRoot.isConnected ? "#a6e3a1" : "#6c7086"
                    font.pixelSize: 12
                    font.bold: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    MouseArea {
        id: netHover
        anchors.fill: netRow
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton
    }

    // ── Popup de redes WiFi ──
    PopupWindow {
        id: netPopup
        anchor.item: netRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        implicitWidth: 300
        implicitHeight: 380
        visible: netRoot.popupVisible
        color: "transparent"

        Rectangle {
            id: netPopupBg
            anchors.fill: parent
            color: "#1e1e2e"
            radius: 24
            border.color: "#45475a"
            border.width: 1

            opacity: netRoot.popupVisible ? 1.0 : 0.0
            scale: netRoot.popupVisible ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutSine } }
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            MouseArea {
                id: netPopupMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onContainsMouseChanged: {
                    netRoot.popupHovered = containsMouse
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                // Header
                RowLayout {
                    spacing: 8
                    Text {
                        text: "📶 Redes WiFi"
                        color: "#cdd6f4"
                        font.pixelSize: 15
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    // Botón de rescan
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: rescanArea.containsMouse ? "#45475a" : "#313244"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        scale: rescanArea.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                        Text {
                            anchors.centerIn: parent; text: "🔄"; font.pixelSize: 13
                            RotationAnimation on rotation {
                                id: spinAnim
                                from: 0; to: 360; duration: 800
                                running: false
                            }
                        }
                        MouseArea {
                            id: rescanArea; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                spinAnim.running = true;
                                scanProc.running = true;
                            }
                        }
                    }
                }

                // Estado actual
                Rectangle {
                    Layout.fillWidth: true; height: 32; radius: 10
                    color: "#313244"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 6
                        Text {
                            text: netRoot.isConnected ? "✅" : "❌"
                            font.pixelSize: 12
                        }
                        Text {
                            text: netRoot.connectionStatus
                            color: netRoot.isConnected ? "#a6e3a1" : "#f38ba8"
                            font.pixelSize: 11; font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }

                // Separador
                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // Lista de redes
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: netListCol.implicitHeight
                    clip: true

                    Column {
                        id: netListCol
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: netRoot.wifiNetworks.length

                            Rectangle {
                                required property int index
                                property var net: netRoot.wifiNetworks[index]
                                property bool isCurrentNet: net.ssid === netRoot.currentSSID
                                property bool isConnecting: net.ssid === netRoot.connectingSSID

                                width: netListCol.width
                                height: 44
                                radius: 10
                                color: netItemArea.containsMouse ? "#45475a" : (isCurrentNet ? "#31324480" : "transparent")
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    // Icono de señal
                                    Text {
                                        text: {
                                            let s = net.signal;
                                            if (s >= 75) return "📶";
                                            if (s >= 50) return "📶";
                                            if (s >= 25) return "📡";
                                            return "📡";
                                        }
                                        font.pixelSize: 14
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // Info columna
                                    Column {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        spacing: 1
                                        Text {
                                            text: net.ssid
                                            color: isCurrentNet ? "#a6e3a1" : "#cdd6f4"
                                            font.pixelSize: 12
                                            font.bold: true
                                            elide: Text.ElideRight
                                            width: parent.width
                                        }
                                        Text {
                                            text: {
                                                let parts = [];
                                                parts.push(net.signal + "%");
                                                if (net.security !== "" && net.security !== "--") parts.push("🔒");
                                                if (isCurrentNet) parts.push("Conectado");
                                                if (isConnecting) parts.push("Conectando...");
                                                return parts.join("  ");
                                            }
                                            color: "#6c7086"
                                            font.pixelSize: 9
                                        }
                                    }

                                    // Barra de señal visual
                                    Row {
                                        spacing: 2
                                        Layout.alignment: Qt.AlignVCenter
                                        Repeater {
                                            model: 4
                                            Rectangle {
                                                required property int index
                                                width: 3
                                                height: 6 + index * 4
                                                radius: 1
                                                color: {
                                                    let threshold = (index + 1) * 25;
                                                    return net.signal >= threshold ?
                                                        (isCurrentNet ? "#a6e3a1" : "#cba6f7") : "#45475a";
                                                }
                                                anchors.bottom: parent.bottom
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: netItemArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!isCurrentNet) {
                                            netRoot.connectingSSID = net.ssid;
                                            connectProc.command = ["bash", "-c",
                                                "nmcli device wifi connect " + JSON.stringify(net.ssid)];
                                            connectProc.running = true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
