import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

RowLayout {
    spacing: 6

    Repeater {
        model: 10

        Rectangle {
            required property int index
            property int wsId: index + 1

            // Buscar si existe este workspace en Hyprland
            readonly property var wsObject: {
                let all = Hyprland.workspaces.values;
                if (!all) return null;
                for (let i = 0; i < all.length; i++) {
                    if (all[i].id === wsId) return all[i];
                }
                return null;
            }

            // Determina si es el workspace activo
            readonly property bool isFocused: {
                if (!Hyprland.focusedMonitor) return false;
                if (!Hyprland.focusedMonitor.activeWorkspace) return false;
                return Hyprland.focusedMonitor.activeWorkspace.id === wsId;
            }

            // Determina si tiene ventanas abiertas
            readonly property bool hasWindows: wsObject !== null

            // 3 estados visuales: activo (mauve), ocupado (lavender), vacío (surface1)
            Layout.alignment: Qt.AlignVCenter
            width: isFocused ? 28 : (hasWindows ? 16 : 10)
            height: 10
            radius: 5
            color: isFocused ? "#cba6f7" : (hasWindows ? "#b4befe" : "#45475a")
            opacity: isFocused ? 1.0 : (hasWindows ? 0.85 : 0.45)

            // Animaciones fluidas
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack } }
            Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.OutSine } }
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutSine } }

            // Efecto hover
            scale: wsHover.containsMouse ? 1.3 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            MouseArea {
                id: wsHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // Sintaxis correcta: un solo string
                    Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
}
