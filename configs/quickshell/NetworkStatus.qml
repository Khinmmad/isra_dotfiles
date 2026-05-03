import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: netRoot
    implicitWidth: 36
    implicitHeight: 36

    property bool drawerOpen: false
    property string currentSSID: ""
    property string connectionStatus: "Escaneando..."
    property bool isConnected: currentSSID !== ""
    property var wifiNetworks: []
    property string connectingSSID: ""

    Process {
        id: currentProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2"]
        stdout: StdioCollector { id: currentOut }
        onExited: {
            let ssid = currentOut.text.trim();
            netRoot.currentSSID = ssid;
            netRoot.connectionStatus = ssid !== ""
                ? ("Conectado a " + ssid) : "Sin conexión";
        }
    }

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
            nets.sort(function(a, b) { return b.signal - a.signal; });
            netRoot.wifiNetworks = nets;
        }
    }

    Process {
        id: connectProc
        command: ["bash", "-c", "echo placeholder"]
        stdout: StdioCollector {}
        onExited: {
            netRoot.connectingSSID = "";
            currentProc.running = true;
            scanProc.running = true;
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: currentProc.running = true
    }

    // ─── Icono en la barra ───
    Rectangle {
        anchors.fill: parent
        radius: 18
        color: netArea.containsMouse
            ? "#8b7355"
            : (netRoot.drawerOpen ? "#e8dccb" : "#efe4d4")
        Behavior on color { ColorAnimation { duration: 150 } }
        scale: netArea.pressed ? 0.9 : (netArea.containsMouse ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

        Text {
            anchors.centerIn: parent
            text: netRoot.isConnected ? "📶" : "📡"
            font.pixelSize: 16
        }

        MouseArea {
            id: netArea; anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
                netRoot.drawerOpen = !netRoot.drawerOpen;
                if (netRoot.drawerOpen) scanProc.running = true;
            }
        }
    }

    // ─── Drawer ───
    PopupWindow {
        id: drawer
        anchor.item: netRoot
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.adjustment: PopupAdjustment.SlideY
        implicitWidth: 320; implicitHeight: 420
        visible: netRoot.drawerOpen
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f5ede4"; radius: 24
            border.color: "#8b7355"; border.width: 1

            opacity: netRoot.drawerOpen ? 1.0 : 0.0
            scale:   netRoot.drawerOpen ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale   { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 8

                RowLayout {
                    spacing: 8
                    Text { text: "📶 Redes WiFi"; color: "#8b4a3f"
                        font.pixelSize: 14; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: 26; height: 26; radius: 13
                        color: rescanArea.containsMouse ? "#8b7355" : "#efe4d4"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent; text: "🔄"; font.pixelSize: 12
                            RotationAnimation on rotation {
                                id: spinAnim; from: 0; to: 360; duration: 800; running: false
                            }
                        }
                        MouseArea { id: rescanArea; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: { spinAnim.running = true; scanProc.running = true; }
                        }
                    }
                    Rectangle {
                        width: 26; height: 26; radius: 13
                        color: closeArea.containsMouse ? "#cc6e28" : "#efe4d4"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✕"
                            font.pixelSize: 10; color: "#1f1b16" }
                        MouseArea { id: closeArea; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: netRoot.drawerOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 32; radius: 10; color: "#efe4d4"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 6
                        Text { text: netRoot.isConnected ? "✅" : "❌"; font.pixelSize: 12 }
                        Text {
                            text: netRoot.connectionStatus
                            color: netRoot.isConnected ? "#96c836" : "#cc6e28"
                            font.pixelSize: 11; font.bold: true
                            elide: Text.ElideRight; Layout.fillWidth: true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

                Flickable {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    contentHeight: netListCol.implicitHeight; clip: true

                    Column {
                        id: netListCol; width: parent.width; spacing: 4

                        Repeater {
                            model: netRoot.wifiNetworks.length

                            Rectangle {
                                required property int index
                                property var net: netRoot.wifiNetworks[index]
                                property bool isCurrentNet: net.ssid === netRoot.currentSSID
                                property bool isConnecting: net.ssid === netRoot.connectingSSID

                                width: netListCol.width; height: 44; radius: 10
                                color: netItemArea.containsMouse
                                    ? "#e8dccb"
                                    : (isCurrentNet ? "#efe4d4" : "transparent")
                                Behavior on color { ColorAnimation { duration: 120 } }

                                RowLayout {
                                    anchors.fill: parent; anchors.margins: 8; spacing: 8

                                    Text {
                                        text: net.signal >= 50 ? "📶" : "📡"
                                        font.pixelSize: 14
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Column {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter; spacing: 1
                                        Text {
                                            text: net.ssid
                                            color: isCurrentNet ? "#96c836" : "#1f1b16"
                                            font.pixelSize: 12; font.bold: true
                                            elide: Text.ElideRight; width: parent.width
                                        }
                                        Text {
                                            text: {
                                                let p = [net.signal + "%"];
                                                if (net.security !== "" && net.security !== "--")
                                                    p.push("🔒");
                                                if (isCurrentNet) p.push("Conectado");
                                                if (isConnecting) p.push("Conectando...");
                                                return p.join("  ");
                                            }
                                            color: "#5c5248"; font.pixelSize: 9
                                        }
                                    }

                                    Row {
                                        spacing: 2; Layout.alignment: Qt.AlignVCenter
                                        Repeater {
                                            model: 4
                                            Rectangle {
                                                required property int index
                                                width: 3; height: 6 + index * 4; radius: 1
                                                color: net.signal >= (index + 1) * 25
                                                    ? (isCurrentNet ? "#96c836" : "#8b4a3f")
                                                    : "#8b7355"
                                                anchors.bottom: parent.bottom
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: netItemArea; anchors.fill: parent
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!isCurrentNet && !isConnecting) {
                                            netRoot.connectingSSID = net.ssid;
                                            connectProc.command = ["bash", "-c",
                                                "nmcli device wifi connect "
                                                + JSON.stringify(net.ssid)];
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
