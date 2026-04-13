import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: musicRoot
    implicitWidth: musicRow.implicitWidth
    implicitHeight: musicRow.implicitHeight

    // Prioriza Spotify; si no existe, toma cualquier otro reproductor activo
    readonly property var spotifyPlayer: {
        let players = Mpris.players.values;
        let sp = players.find(p => p.dbusName.includes("spotify"));
        if (sp) return sp;
        return players.length > 0 ? players[0] : null;
    }

    property var player: spotifyPlayer
    property bool isSpotify: player ? player.dbusName.includes("spotify") : false

    // Control de visibilidad robusto del popup
    property bool barHovered: musicHover.containsMouse
    property bool popupHovered: false  // Lo controla el MouseArea del popup
    property bool anyHovered: barHovered || popupHovered
    property bool popupVisible: false

    onAnyHoveredChanged: {
        if (anyHovered) {
            popupHideTimer.stop()
            popupShowTimer.start()
        } else {
            popupShowTimer.stop()
            popupHideTimer.start()
        }
    }

    Timer {
        id: popupShowTimer
        interval: 200
        onTriggered: musicRoot.popupVisible = true
    }
    Timer {
        id: popupHideTimer
        interval: 350
        onTriggered: {
            // Doble-check: solo cerrar si realmente ya no estamos hovering
            if (!musicRoot.anyHovered) {
                musicRoot.popupVisible = false
            }
        }
    }

    visible: player !== null

    // ── Barra compacta (inline en el panel) ──
    RowLayout {
        id: musicRow
        spacing: 6

        // Separador
        Rectangle {
            width: 1; height: 24; color: "#45475a"
            Layout.alignment: Qt.AlignVCenter
        }

        // Ícono
        Text {
            text: musicRoot.isSpotify ? "🎵" : "♫"
            color: musicRoot.isSpotify ? "#1db954" : "#a6e3a1"
            font.pixelSize: 15
            Layout.alignment: Qt.AlignVCenter
        }

        // Título recortado
        Text {
            text: player?.trackTitle ?? "Sin reproducción"
            color: "#cdd6f4"
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
            Layout.maximumWidth: 120
            Layout.alignment: Qt.AlignVCenter
        }

        // Controles compactos
        Rectangle {
            width: 20; height: 20; radius: 10
            color: prevArea.containsMouse ? "#45475a" : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
            Layout.alignment: Qt.AlignVCenter
            Text { anchors.centerIn: parent; text: "⏮"; color: "#cdd6f4"; font.pixelSize: 10 }
            MouseArea {
                id: prevArea; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: player?.previous()
            }
        }
        Rectangle {
            width: 20; height: 20; radius: 10
            color: playArea.containsMouse ? "#45475a" : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
            Layout.alignment: Qt.AlignVCenter
            Text {
                anchors.centerIn: parent
                text: player?.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"
                color: musicRoot.isSpotify ? "#1db954" : "#cdd6f4"
                font.pixelSize: 10
            }
            MouseArea {
                id: playArea; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: player?.togglePlaying()
            }
        }
        Rectangle {
            width: 20; height: 20; radius: 10
            color: nextArea.containsMouse ? "#45475a" : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }
            Layout.alignment: Qt.AlignVCenter
            Text { anchors.centerIn: parent; text: "⏭"; color: "#cdd6f4"; font.pixelSize: 10 }
            MouseArea {
                id: nextArea; anchors.fill: parent; hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: player?.next()
            }
        }
    }

    // Zona de hover sobre toda la barra compacta
    MouseArea {
        id: musicHover
        anchors.fill: musicRow
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // No roba clics a los botones internos
        propagateComposedEvents: true
    }



    // ── Popup expandido (aparece arriba del módulo al hacer hover) ──
    PopupWindow {
        id: musicPopup
        anchor.item: musicRoot
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.Slide
        implicitWidth: 300
        implicitHeight: 200
        visible: musicRoot.popupVisible
        color: "transparent"

        // Fondo del popup
        Rectangle {
            id: popupBg
            anchors.fill: parent
            color: "#1e1e2e"
            radius: 16
            border.color: "#45475a"
            border.width: 1

            // Animación de entrada
            opacity: musicRoot.popupVisible ? 1.0 : 0.0
            scale: musicRoot.popupVisible ? 1.0 : 0.95
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutSine } }
            Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

            MouseArea {
                id: popupMouseArea
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onContainsMouseChanged: {
                    musicRoot.popupHovered = containsMouse
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // Header: Spotify / Player badge
                RowLayout {
                    spacing: 8
                    Text {
                        text: musicRoot.isSpotify ? "🎵 Spotify" : ("♫ " + (player?.identity ?? "Media"))
                        color: musicRoot.isSpotify ? "#1db954" : "#a6e3a1"
                        font.pixelSize: 14
                        font.bold: true
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        width: statusLabel.implicitWidth + 12
                        height: 18; radius: 9
                        color: player?.playbackState === MprisPlaybackState.Playing ? "#1db95430" : "#45475a"
                        Text {
                            id: statusLabel
                            anchors.centerIn: parent
                            text: player?.playbackState === MprisPlaybackState.Playing ? "Reproduciendo" : "Pausado"
                            color: player?.playbackState === MprisPlaybackState.Playing ? "#a6e3a1" : "#6c7086"
                            font.pixelSize: 9
                            font.bold: true
                        }
                    }
                }

                // Separador
                Rectangle { Layout.fillWidth: true; height: 1; color: "#313244" }

                // Título de la canción
                Text {
                    text: player?.trackTitle ?? "Sin reproducción"
                    color: "#cdd6f4"
                    font.pixelSize: 16
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Artista
                Text {
                    text: {
                        if (!player) return "";
                        let artists = player.trackArtists;
                        if (artists && artists.length > 0) return Array.from(artists).join(", ");
                        return "";
                    }
                    color: "#bac2de" // Subtext 1
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                // Álbum
                Text {
                    text: player?.trackAlbum ?? ""
                    color: "#6c7086" // Overlay 0
                    font.pixelSize: 11
                    font.italic: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    visible: (player?.trackAlbum ?? "") !== ""
                }

                Item { Layout.fillHeight: true }

                // Controles grandes
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    // Anterior
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: prevBig.containsMouse ? "#45475a" : "#313244"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: prevBig.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                        Text { anchors.centerIn: parent; text: "⏮"; font.pixelSize: 16; color: "#cdd6f4" }
                        MouseArea { id: prevBig; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: player?.previous() }
                    }

                    // Play/Pause (grande, acento)
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: playBig.containsMouse ? (musicRoot.isSpotify ? "#1db954" : "#cba6f7") : "#313244"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: playBig.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                        Text {
                            anchors.centerIn: parent
                            text: player?.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"
                            font.pixelSize: 20
                            color: playBig.containsMouse ? "#1e1e2e" : "#cdd6f4"
                        }
                        MouseArea { id: playBig; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: player?.togglePlaying() }
                    }

                    // Siguiente
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: nextBig.containsMouse ? "#45475a" : "#313244"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        scale: nextBig.containsMouse ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
                        Text { anchors.centerIn: parent; text: "⏭"; font.pixelSize: 16; color: "#cdd6f4" }
                        MouseArea { id: nextBig; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: player?.next() }
                    }
                }
            }
        }
    }
}