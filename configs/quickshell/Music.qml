import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: musicRoot
    implicitWidth: musicRow.implicitWidth
    implicitHeight: musicRow.implicitHeight

    // ── LÓGICA DE TIEMPO REAL ──
    property double localPosition: 0 
    property bool isDraggingProgress: false
    
    Timer {
        id: smoothTimer
        interval: 500
        repeat: true
        running: player?.playbackState === MprisPlaybackState.Playing && !isDraggingProgress
        onTriggered: {
            musicRoot.localPosition += 500000;
            if (player && musicRoot.localPosition > player.length) {
                musicRoot.localPosition = player.length;
            }
        }
    }

    Connections {
        target: player
        function onPositionChanged() {
            if (!isDraggingProgress) musicRoot.localPosition = player.position;
        }
        function onTrackTitleChanged() {
            musicRoot.localPosition = 0;
        }
    }

    function formatTime(ms) {
        if (!ms || ms < 0) return "0:00";
        let totalSeconds = Math.floor(ms / 1000000);
        let minutes = Math.floor(totalSeconds / 60);
        let seconds = totalSeconds % 60;
        return minutes + ":" + (seconds < 10 ? "0" + seconds : seconds);
    }

    readonly property var spotifyPlayer: {
        let players = Mpris.players.values;
        let sp = players.find(p => p.dbusName.includes("spotify"));
        if (sp) return sp;
        return players.length > 0 ? players[0] : null;
    }

    property var player: spotifyPlayer
    property bool isSpotify: player ? player.dbusName.includes("spotify") : false

    Process { id: spotifyLaunch; command: ["spotify"] }

    property bool barHovered: musicHover.containsMouse
    property bool popupHovered: false
    property bool anyHovered: barHovered || popupHovered
    property bool popupVisible: false

    onAnyHoveredChanged: {
        if (anyHovered) { popupHideTimer.stop(); popupShowTimer.start() } 
        else { popupShowTimer.stop(); popupHideTimer.start() }
    }

    Timer { id: popupShowTimer; interval: 200; onTriggered: musicRoot.popupVisible = true }
    Timer { id: popupHideTimer; interval: 600; onTriggered: { if (!musicRoot.anyHovered) musicRoot.popupVisible = false } }

    RowLayout {
        id: musicRow; spacing: 6
        Rectangle { width: 1; height: 24; color: "#45475a"; Layout.alignment: Qt.AlignVCenter }
        Loader { id: contentLoader; Layout.alignment: Qt.AlignVCenter; sourceComponent: player ? playingComponent : idleComponent }
    }

    Component {
        id: playingComponent
        RowLayout {
            spacing: 6
            Text { text: musicRoot.isSpotify ? "🎵" : "♫"; color: musicRoot.isSpotify ? "#1db954" : "#a6e3a1"; font.pixelSize: 15 }
            Text { text: player?.trackTitle ?? ""; color: "#cdd6f4"; font.pixelSize: 12; font.bold: true; elide: Text.ElideRight; Layout.maximumWidth: 120 }
            Row {
                spacing: 2
                MusicIconBtn { text: "⏮"; onClicked: player?.previous() }
                MusicIconBtn { 
                    text: player?.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"
                    iconColor: musicRoot.isSpotify ? "#1db954" : "#cdd6f4"
                    onClicked: player?.togglePlaying() 
                }
                MusicIconBtn { text: "⏭"; onClicked: player?.next() }
            }
        }
    }

    Component {
        id: idleComponent
        RowLayout {
            spacing: 8
            Rectangle {
                width: 130; height: 26; radius: 13
                color: launchArea.containsMouse ? "#313244" : "transparent"
                border.color: launchArea.containsMouse ? "#45475a" : "transparent"
                Text { anchors.centerIn: parent; text: "🎵 Iniciar Spotify"; color: launchArea.containsMouse ? "#1db954" : "#6c7086"; font.pixelSize: 11; font.bold: true }
                MouseArea { id: launchArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: spotifyLaunch.running = true }
            }
        }
    }

    MouseArea { id: musicHover; anchors.fill: musicRow; hoverEnabled: true; acceptedButtons: Qt.NoButton; propagateComposedEvents: true }

    component MusicIconBtn: Rectangle {
        property string text: ""; property string iconColor: "#cdd6f4"; signal clicked()
        width: 20; height: 20; radius: 10
        color: mArea.containsMouse ? "#45475a" : "transparent"
        Text { anchors.centerIn: parent; text: parent.text; color: parent.iconColor; font.pixelSize: 10 }
        MouseArea { id: mArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }

    PopupWindow {
        id: musicPopup; anchor.item: musicRoot; anchor.edges: Edges.Bottom; anchor.gravity: Edges.Bottom; anchor.adjustment: PopupAdjustment.Slide
        implicitWidth: 320; implicitHeight: 330; visible: musicRoot.popupVisible && player !== null; color: "transparent"

        Rectangle {
            id: popupBg; anchors.fill: parent; color: "#1e1e2e"; radius: 24; border.color: "#45475a"
            opacity: musicRoot.popupVisible ? 1.0 : 0.0; scale: musicRoot.popupVisible ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200 } }; Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            MouseArea { anchors.fill: parent; hoverEnabled: true; onContainsMouseChanged: musicRoot.popupHovered = containsMouse }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 12

                RowLayout {
                    spacing: 8
                    Text { text: musicRoot.isSpotify ? "🎵 Spotify" : ("♫ " + (player?.identity ?? "Media")); color: musicRoot.isSpotify ? "#1db954" : "#a6e3a1"; font.pixelSize: 14; font.bold: true }
                    Item { Layout.fillWidth: true }
                    Text { text: player?.playbackState === MprisPlaybackState.Playing ? "Reproduciendo" : "Pausado"; color: "#6c7086"; font.pixelSize: 10; font.bold: true }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                Column {
                    Layout.fillWidth: true; spacing: 4
                    Text { text: player?.trackTitle ?? "Sin título"; color: "#cdd6f4"; font.pixelSize: 18; font.bold: true; elide: Text.ElideRight; width: parent.width }
                    Text {
                        text: {
                            if (!player) return "";
                            let artists = player.trackArtists;
                            if (!artists) return "";
                            if (typeof artists === "object" && artists.length !== undefined) return Array.from(artists).join(", ");
                            return String(artists);
                        }
                        color: "#bac2de"; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width
                    }
                    Text { text: player?.trackAlbum ?? ""; color: "#6c7086"; font.pixelSize: 11; font.italic: true; visible: text !== ""; elide: Text.ElideRight; width: parent.width }
                }

                // Barra de Progreso DESLIZABLE
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 4
                    Rectangle {
                        id: progressBar; Layout.fillWidth: true; height: 6; radius: 3; color: "#313244"
                        Rectangle {
                            height: parent.height; radius: 3
                            width: parent.width * (Math.min(musicRoot.localPosition, player?.length || 1) / (player?.length || 1))
                            color: musicRoot.isSpotify ? "#1db954" : "#cba6f7"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            
                            function updatePos(mouseX) {
                                if (player && player.length > 0) {
                                    let ratio = Math.max(0, Math.min(1, mouseX / width));
                                    musicRoot.localPosition = ratio * player.length;
                                }
                            }

                            onPressed: (mouse) => { musicRoot.isDraggingProgress = true; updatePos(mouse.x) }
                            onPositionChanged: (mouse) => { if (pressed) updatePos(mouse.x) }
                            onReleased: {
                                if (player) player.position = musicRoot.localPosition;
                                musicRoot.isDraggingProgress = false;
                            }
                        }
                    }
                    RowLayout {
                        Text { text: formatTime(musicRoot.localPosition); color: "#6c7086"; font.pixelSize: 10 }
                        Item { Layout.fillWidth: true }
                        Text { text: formatTime(player?.length); color: "#6c7086"; font.pixelSize: 10 }
                    }
                }

                // CONTROL DE VOLUMEN DESLIZABLE
                RowLayout {
                    spacing: 10; Layout.fillWidth: true
                    Text { text: "󰕾"; color: "#6c7086"; font.pixelSize: 14 }
                    Rectangle {
                        id: volBar; Layout.fillWidth: true; height: 4; radius: 2; color: "#313244"
                        Rectangle {
                            height: parent.height; radius: 2
                            width: parent.width * (player?.volume || 0)
                            color: "#bac2de"
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            function updateVol(mouseX) {
                                if (player) {
                                    let ratio = Math.max(0, Math.min(1, mouseX / width));
                                    player.volume = ratio;
                                }
                            }
                            onPressed: (mouse) => updateVol(mouse.x)
                            onPositionChanged: (mouse) => { if (pressed) updateVol(mouse.x) }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter; spacing: 20
                    ControlBtn { text: "⏮"; size: 40; onClicked: player?.previous() }
                    ControlBtn { text: player?.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"; size: 50; accent: true; onClicked: player?.togglePlaying() }
                    ControlBtn { text: "⏭"; size: 40; onClicked: player?.next() }
                }
            }
        }
    }

    component ControlBtn: Rectangle {
        property string text: ""; property int size: 40; property bool accent: false; signal clicked()
        width: size; height: size; radius: size/2
        color: btnM.containsMouse ? (accent ? (musicRoot.isSpotify ? "#1db954" : "#cba6f7") : "#45475a") : "#313244"
        scale: btnM.pressed ? 0.9 : (btnM.containsMouse ? 1.1 : 1.0)
        Behavior on scale { NumberAnimation { duration: 100 } }
        Text { anchors.centerIn: parent; text: parent.text; font.pixelSize: parent.size * 0.45; color: parent.accent && btnM.containsMouse ? "#1e1e2e" : "#cdd6f4" }
        MouseArea { id: btnM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
    }
}
