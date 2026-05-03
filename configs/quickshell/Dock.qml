import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: dockRoot

    readonly property int collapsedH: 10
    readonly property int expandedH: 52
    property bool hovered: false

    implicitWidth: parent ? parent.width : 0
    implicitHeight: hovered ? expandedH : collapsedH

    Behavior on implicitHeight {
        SpringAnimation { spring: 3; damping: 0.7; epsilon: 0.5 }
    }

    Rectangle {
        anchors.fill: parent
        color: "#f5ede4"

        MouseArea {
            id: dockArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: dockRoot.hovered = true
            onExited: dockRoot.hovered = false
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 24
            opacity: dockRoot.hovered ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250 } }

            DockApp {
                icon: "💻"; label: "Terminal"
                cmd: "kitty"; accent: "#cc6e28"
            }
            DockApp {
                icon: "🌐"; label: "Web"
                cmd: "firefox"; accent: "#d4b440"
            }
            DockApp {
                icon: "📁"; label: "Archivos"
                cmd: "thunar"; accent: "#e09838"
            }
            DockApp {
                icon: "📝"; label: "Editor"
                cmd: "code"; accent: "#96c836"
            }
            DockApp {
                icon: "🎵"; label: "Música"
                cmd: "spotify"; accent: "#1db954"
            }
            DockApp {
                icon: "⚙️"; label: "Ajustes"
                cmd: "nwg-look"; accent: "#a0c840"
            }
        }
    }

    component DockApp: Item {
        property string icon: ""
        property string label: ""
        property string cmd: ""
        property string accent: "#8b4a3f"

        width: col.width; height: col.height

        Column {
            id: col
            spacing: 4

            Rectangle {
                id: iconBg
                anchors.horizontalCenter: parent.horizontalCenter
                width: 36; height: 36; radius: 12
                color: appMa.containsMouse ? accent : "#efe4d4"
                border.color: appMa.containsMouse ? accent : "transparent"
                border.width: 2

                scale: appMa.containsMouse ? 1.15 : 1.0
                Behavior on scale   { SpringAnimation { spring: 3; damping: 0.6; epsilon: 0.3 } }
                Behavior on color   { ColorAnimation { duration: 180 } }
                Behavior on border.color { ColorAnimation { duration: 180 } }

                Text {
                    anchors.centerIn: parent
                    text: icon; font.pixelSize: 18
                }

                MouseArea {
                    id: appMa
                    anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        proc.command = [cmd]; proc.running = true
                    }
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: label
                color: appMa.containsMouse ? accent : "#5c5248"
                font.pixelSize: 9; font.bold: appMa.containsMouse
                Behavior on color { ColorAnimation { duration: 180 } }
            }
        }
    }

    Process { id: proc }
}
