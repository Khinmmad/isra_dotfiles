import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: bar
        anchors { left: true; top: true; bottom: true }
        
        // El ancho se expande dinámicamente
        property int baseWidth: 64
        property int expansionWidth: (appMenu.active || weatherSidebar.open || clockModule.drawerOpen) ? 320 : 0
        
        implicitWidth: baseWidth + expansionWidth
        
        // Animación suave estilo "Spring" para la expansión
        Behavior on implicitWidth {
            SpringAnimation {
                spring: 4
                damping: 0.8
                epsilon: 0.5
            }
        }

        exclusionMode: ExclusionMode.Auto
        color: "transparent"

        Rectangle {
            id: barContainer
            anchors.fill: parent
            color: "#f5ede4"
            topRightRadius: 24
            bottomRightRadius: 24
            
            // Sombra suave para dar profundidad
            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.1
                radius: parent.radius
                z: -1
                anchors.margins: -2
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // ─── Columna de Iconos (Barra Estática) ───
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: bar.baseWidth
                    anchors.topMargin: 20
                    anchors.bottomMargin: 20
                    spacing: 16

                    // Logo / Launcher
                    Rectangle {
                        id: logoContainer
                        Layout.alignment: Qt.AlignHCenter
                        width: 42; height: 42; radius: 21
                        color: appMenu.active ? "#8b7355" : (logoArea.containsMouse ? "#e8dccb" : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        
                        Text { anchors.centerIn: parent; text: "🐻"; font.pixelSize: 22 }
                        MouseArea {
                            id: logoArea; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                weatherSidebar.open = false;
                                appMenu.active = !appMenu.active;
                            }
                        }
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 24; height: 1; color: "#8b7355"; opacity: 0.2
                    }

                    Workspaces { Layout.alignment: Qt.AlignHCenter }

                    Item { Layout.fillHeight: true }

                    NetworkStatus { Layout.alignment: Qt.AlignHCenter }
                    Music         { Layout.alignment: Qt.AlignHCenter }
                    SystemInfo    { Layout.alignment: Qt.AlignHCenter }

                    // Botón Clima
                    Rectangle {
                        id: weatherBtnContainer
                        Layout.alignment: Qt.AlignHCenter
                        width: 42; height: 42; radius: 21
                        color: weatherSidebar.open ? "#8b7355" : (weatherBtn.containsMouse ? "#e8dccb" : "transparent")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        
                        Text { anchors.centerIn: parent; text: "🌤"; font.pixelSize: 20 }
                        MouseArea {
                            id: weatherBtn; anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appMenu.active = false;
                                weatherSidebar.open = !weatherSidebar.open;
                            }
                        }
                    }

                    BarClock {
                        id: clockModule
                        Layout.alignment: Qt.AlignHCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appMenu.active = false;
                                weatherSidebar.open = false;
                                clockModule.drawerOpen = !clockModule.drawerOpen;
                            }
                        }
                    }
                }

                // ─── Área de Contenido Expansible ───
                Item {
                    id: expansionArea
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    clip: true // Importante para ocultar el contenido mientras se expande
                    
                    // Separador vertical sutil
                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        anchors.topMargin: 20
                        anchors.bottomMargin: 20
                        width: 1
                        color: "#8b7355"
                        opacity: expansionWidth > 0 ? 0.1 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    // Cargador de Módulos
                    Item {
                        anchors.fill: parent
                        anchors.margins: 10
                        opacity: expansionWidth > 300 ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 200 } }

                        Launcher {
                            id: appMenu
                            visible: active
                            anchors.fill: parent
                        }

                        WeatherSidebar {
                            id: weatherSidebar
                            visible: open
                            anchors.fill: parent
                            onCloseRequested: open = false
                        }

                        BarClock {
                            id: clockExpanded
                            drawerOpen: true
                            visible: clockModule.drawerOpen
                            anchors.fill: parent
                        }
                    }
                }
            }
        }
    }
}
