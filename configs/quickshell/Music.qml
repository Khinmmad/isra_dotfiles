import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: musicRoot
    implicitWidth: 36
    implicitHeight: 36

    property bool drawerOpen: false
    property double localPosition: 0
    property bool isDraggingProgress: false

    readonly property var spotifyPlayer: {
        let players = Mpris.players.values;
        let sp = players.find(p => p.dbusName.includes("spotify"));
        return sp ?? (players.length > 0 ? players[0] : null);
    }
    property var player: spotifyPlayer
    onPlayerChanged: { if (player) localPosition = player.position ?? 0 }
    property bool isSpotify: player ? player.dbusName.includes("spotify") : false
    property bool isPlaying: player?.playbackState === MprisPlaybackState.Playing

    Process { id: spotifyLaunch; command: ["spotify"] }

    Timer {
        interval: 500; repeat: true
        running: musicRoot.isPlaying && !musicRoot.isDraggingProgress
        onTriggered: {
            musicRoot.localPosition += 500;
            if (player && player.length > 0 && musicRoot.localPosition > player.length)
                musicRoot.localPosition = player.length;
        }
    }

    Connections {
        target: musicRoot.player ?? null
        function onPositionChanged() {
            if (!musicRoot.isDraggingProgress) musicRoot.localPosition = musicRoot.player.position;
        }
        function onTrackTitleChanged() { musicRoot.localPosition = 0; }
    }

    function formatTime(ms) {
        if (!ms || ms < 0) return "0:00";
        let s = Math.floor(ms / 1000);
        return Math.floor(s / 60) + ":" + (s % 60 < 10 ? "0" : "") + (s % 60);
    }

    // ─── Icono en la barra ───
    Rectangle {
        anchors.fill: parent
        radius: 18
        color: musicArea.containsMouse
            ? "#8b7355"
            : (musicRoot.drawerOpen ? "#e8dccb"
                : (musicRoot.isPlaying ? "#efe4d4" : "#efe4d4"))
        Behavior on color { ColorAnimation { duration: 150 } }
        scale: musicArea.pressed ? 0.9 : (musicArea.containsMouse ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack } }

        Text {
            anchors.centerIn: parent
            text: musicRoot.isSpotify ? "🎵" : "♫"
            font.pixelSize: 16
        }

        // Indicador de playing
        Rectangle {
            visible: musicRoot.isPlaying
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: -2
            width: 4; height: 4; radius: 2
            color: "#1db954"
        }

        MouseArea {
            id: musicArea; anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (musicRoot.player) {
                    musicRoot.drawerOpen = !musicRoot.drawerOpen;
                } else {
                    spotifyLaunch.running = true;
                }
            }
        }
    }

    // ─── Drawer ───
    PopupWindow {
        id: drawer
        anchor.item: musicRoot
        anchor.edges: Edges.Right
        anchor.gravity: Edges.Right
        anchor.adjustment: PopupAdjustment.SlideY
        implicitWidth: 340; implicitHeight: 320
        visible: musicRoot.drawerOpen && musicRoot.player !== null
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#f5ede4"; radius: 24
            border.color: "#8b7355"; border.width: 1

            opacity: musicRoot.drawerOpen ? 1.0 : 0.0
            scale:   musicRoot.drawerOpen ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200 } }
            Behavior on scale   { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 18; spacing: 10

                RowLayout {
                    Text {
                        text: musicRoot.isSpotify ? "🎵 Spotify"
                            : ("♫ " + (musicRoot.player?.identity ?? "Media"))
                        color: "#8b4a3f"
                        font.pixelSize: 14; font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: musicRoot.isPlaying ? "▶ Reproduciendo" : "⏸ Pausado"
                        color: "#5c5248"; font.pixelSize: 10
                    }
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: closeBtn.containsMouse ? "#cc6e28" : "#efe4d4"
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "✕"
                            font.pixelSize: 10; color: "#1f1b16" }
                        MouseArea { id: closeBtn; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: musicRoot.drawerOpen = false
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#e8dccb" }

                Column {
                    Layout.fillWidth: true; spacing: 4
                    Text {
                        text: musicRoot.player?.trackTitle ?? "Sin título"
                        color: "#1f1b16"
                        font.pixelSize: 18; font.bold: true
                        elide: Text.ElideRight; width: parent.width
                    }
                    Text {
                        text: {
                            if (!musicRoot.player) return "";
                            let a = musicRoot.player.trackArtists;
                            if (!a) return "";
                            if (typeof a === "object" && a.length !== undefined)
                                return Array.from(a).join(", ");
                            return String(a);
                        }
                        color: "#5c5248"
                        font.pixelSize: 13
                        elide: Text.ElideRight; width: parent.width
                    }
                    Text {
                        text: musicRoot.player?.trackAlbum ?? ""
                        color: "#8b7355"
                        font.pixelSize: 11; font.italic: true
                        visible: text !== ""
                        elide: Text.ElideRight; width: parent.width
                    }
                }

                // Progreso
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Rectangle {
                        Layout.fillWidth: true; height: 6; radius: 3; color: "#e8dccb"
                        Rectangle {
                            height: parent.height; radius: 3
                            width: parent.width * (Math.min(musicRoot.localPosition,
                                musicRoot.player?.length || 1)
                                / (musicRoot.player?.length || 1))
                            color: musicRoot.isSpotify ? "#1db954" : "#8b4a3f"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            function updatePos(mx) {
                                if (musicRoot.player && musicRoot.player.length > 0)
                                    musicRoot.localPosition = Math.max(0, Math.min(1,
                                        mx / width)) * musicRoot.player.length;
                            }
                            onPressed: (m) => { musicRoot.isDraggingProgress = true;
                                updatePos(m.x) }
                            onPositionChanged: (m) => { if (pressed) updatePos(m.x) }
                            onReleased: {
                                if (musicRoot.player)
                                    musicRoot.player.position = musicRoot.localPosition;
                                musicRoot.isDraggingProgress = false;
                            }
                        }
                    }
                    RowLayout {
                        Text { text: musicRoot.formatTime(musicRoot.localPosition)
                            color: "#5c5248"; font.pixelSize: 10 }
                        Item { Layout.fillWidth: true }
                        Text { text: musicRoot.formatTime(musicRoot.player?.length)
                            color: "#5c5248"; font.pixelSize: 10 }
                    }
                }

                Item { Layout.fillHeight: true }

                // Controles principales
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 16
                    ControlBtn { text: "⏮"; size: 38; onClicked: musicRoot.player?.previous() }
                    ControlBtn {
                        text: musicRoot.isPlaying ? "⏸" : "▶"
                        size: 48; accent: true
                        onClicked: musicRoot.player?.togglePlaying()
                    }
                    ControlBtn { text: "⏭"; size: 38; onClicked: musicRoot.player?.next() }
                }
            }
        }
    }

    component ControlBtn: Rectangle {
        property string text: ""
        property int size: 40
        property bool accent: false
        signal clicked()
        width: size; height: size; radius: size / 2
        color: btnM.containsMouse
            ? (accent ? (musicRoot.isSpotify ? "#1db954" : "#8b4a3f") : "#8b7355")
            : "#efe4d4"
        scale: btnM.pressed ? 0.9 : (btnM.containsMouse ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 150 } }
        Text {
            anchors.centerIn: parent; text: parent.text
            font.pixelSize: parent.size * 0.45
            color: btnM.containsMouse ? "#f5ede4" : "#1f1b16"
        }
        MouseArea { id: btnM; anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
