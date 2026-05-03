import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: sidebarRoot

    property bool open: false
    signal closeRequested()

    // ── Datos del clima ──
    property string condition:  "—"
    property string tempC:      "—"
    property string feelsLike:  "—"
    property string humidity:   "—"
    property string windKmh:    "—"
    property string location:   "Cargando..."
    property var forecast:      []
    property bool loading:      true

    function conditionEmoji(desc) {
        let d = (desc || "").toLowerCase();
        if (d.includes("thunder"))              return "⛈";
        if (d.includes("snow") || d.includes("blizzard")) return "❄️";
        if (d.includes("rain") || d.includes("drizzle")) return "🌧";
        if (d.includes("fog") || d.includes("mist"))     return "🌫";
        if (d.includes("overcast"))             return "☁️";
        if (d.includes("cloud") || d.includes("partly")) return "⛅";
        if (d.includes("sun") || d.includes("clear"))    return "☀️";
        if (d.includes("wind"))                 return "💨";
        return "🌤";
    }

    Process {
        id: weatherProc
        command: ["bash", "-c", "curl -sf --max-time 8 'wttr.in/?format=j1' 2>/dev/null"]
        stdout: StdioCollector { id: weatherOut }
        onExited: {
            sidebarRoot.loading = false;
            try {
                let data = JSON.parse(weatherOut.text.trim());
                let cur  = data.current_condition[0];
                let area = data.nearest_area[0];

                sidebarRoot.tempC     = cur.temp_C + "°C";
                sidebarRoot.feelsLike = cur.FeelsLikeC + "°C";
                sidebarRoot.humidity  = cur.humidity + "%";
                sidebarRoot.windKmh   = cur.windspeedKmph + " km/h";
                sidebarRoot.condition = cur.weatherDesc[0].value;
                sidebarRoot.location  = area.areaName[0].value
                                        + ", " + area.country[0].value;

                let fc = [];
                for (let i = 0; i < Math.min(3, data.weather.length); i++) {
                    let w = data.weather[i];
                    fc.push({
                        date: w.date,
                        maxC: w.maxtempC,
                        minC: w.mintempC,
                        desc: w.hourly[4]?.weatherDesc[0]?.value ?? ""
                    });
                }
                sidebarRoot.forecast = fc;
            } catch(e) {
                sidebarRoot.condition = "Sin conexión";
                sidebarRoot.location  = "";
            }
        }
    }

    Timer {
        interval: 600000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: { sidebarRoot.loading = true; weatherProc.running = true; }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Header
            RowLayout {
                spacing: 8
                Text {
                    text: "🌡 Clima"
                    color: "#8b4a3f"
                    font.pixelSize: 14; font.bold: true
                }
                Item { Layout.fillWidth: true }
                // Cerrar
                Rectangle {
                    width: 24; height: 24; radius: 12
                    color: closeBtn.containsMouse ? "#cc6e28" : "#efe4d4"
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Text { anchors.centerIn: parent; text: "✕"; font.pixelSize: 10; color: "#1f1b16" }
                    MouseArea {
                        id: closeBtn; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: sidebarRoot.closeRequested()
                    }
                }
            }

            Text {
                text: "📍 " + sidebarRoot.location
                color: "#9e8438"; font.pixelSize: 9
                elide: Text.ElideRight; Layout.fillWidth: true
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

            // Temp Principal
            Rectangle {
                Layout.fillWidth: true
                height: 90; radius: 14
                color: "#efe4d4"
                border.color: "#8b7355"; border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent; spacing: 2

                    Text {
                        text: sidebarRoot.conditionEmoji(sidebarRoot.condition)
                        font.pixelSize: 32; Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: sidebarRoot.tempC
                        color: "#8b4a3f"; font.pixelSize: 28; font.bold: true; Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: sidebarRoot.condition
                        color: "#5c5248"; font.pixelSize: 10; Layout.alignment: Qt.AlignHCenter
                        elide: Text.ElideRight; width: 200
                    }
                }
            }

            // Detalles
            GridLayout {
                columns: 2; columnSpacing: 6; rowSpacing: 6
                Layout.fillWidth: true

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: "#efe4d4"; border.color: "#e8dccb"; border.width: 1
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 1
                        Text { text: "🌡 Sensación"; color: "#9e8438"; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
                        Text { text: sidebarRoot.feelsLike; color: "#1f1b16"; font.pixelSize: 12; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; height: 40; radius: 8
                    color: "#efe4d4"; border.color: "#e8dccb"; border.width: 1
                    ColumnLayout {
                        anchors.centerIn: parent; spacing: 1
                        Text { text: "💧 Humedad"; color: "#9e8438"; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
                        Text { text: sidebarRoot.humidity; color: "#1f1b16"; font.pixelSize: 12; font.bold: true; Layout.alignment: Qt.AlignHCenter }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

            // Pronóstico
            Text {
                text: "Próximos días"
                color: "#9e8438"; font.pixelSize: 9; font.bold: true
            }

            Repeater {
                model: sidebarRoot.forecast.length
                Rectangle {
                    required property int index
                    property var day: sidebarRoot.forecast[index]
                    Layout.fillWidth: true; height: 38; radius: 8
                    color: "#efe4d4"; border.color: "#e8dccb"; border.width: 1
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 8; spacing: 6
                        Text { text: sidebarRoot.conditionEmoji(day.desc); font.pixelSize: 16 }
                        Column {
                            spacing: 0
                            Text { text: Qt.formatDate(new Date(day.date), "ddd d MMM"); color: "#1f1b16"; font.pixelSize: 10; font.bold: true }
                            Text { text: day.desc; color: "#9e8438"; font.pixelSize: 8; elide: Text.ElideRight; width: 100 }
                        }
                        Item { Layout.fillWidth: true }
                        Text { text: day.maxC + "°"; color: "#8b4a3f"; font.pixelSize: 12; font.bold: true }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
