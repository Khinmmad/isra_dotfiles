import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland

ShellRoot {
    readonly property int fw: 10
    readonly property int fr: 24
    readonly property color bg: "#f5ede4"

    PanelWindow {
        id: root
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        property int leftWidth: 64 + (appMenu.active || weatherSidebar.open || clockModule.drawerOpen ? 320 : 0)

        mask: [
            Region { x: 0; y: 0; width: root.width; height: fw },
            Region { x: 0; y: root.height - fw; width: root.width; height: fw },
            Region { x: root.width - fw; y: 0; width: fw; height: root.height },
            Region { x: 0; y: 0; width: root.leftWidth; height: root.height }
        ]

        Item {
            id: frameLayer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.7
                blurMax: 40
                shadowOpacity: 0.6
                shadowColor: "#000000"
            }

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: fw
                color: bg
                bottomRightRadius: fr
            }

            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: fw
                color: bg
                topRightRadius: fr
            }

            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: fw
                color: bg
                topLeftRadius: fw
                bottomLeftRadius: fw
            }

            Rectangle {
                id: leftFrame
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: root.leftWidth
                color: bg
                topRightRadius: fr
                bottomRightRadius: fr

                Behavior on width {
                    SpringAnimation { spring: 4; damping: 0.8; epsilon: 0.5 }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 64
                        anchors.topMargin: 20
                        anchors.bottomMargin: 20
                        spacing: 16

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
                                onClicked: { weatherSidebar.open = false; appMenu.active = !appMenu.active }
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
                                onClicked: { appMenu.active = false; weatherSidebar.open = !weatherSidebar.open }
                            }
                        }

                        BarClock {
                            id: clockModule
                            Layout.alignment: Qt.AlignHCenter
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: { appMenu.active = false; weatherSidebar.open = false; clockModule.drawerOpen = !clockModule.drawerOpen }
                            }
                        }
                    }

                    Item {
                        id: expansionArea
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        clip: true

                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top; anchors.bottom: parent.bottom
                            anchors.topMargin: 20; anchors.bottomMargin: 20
                            width: 1; color: "#8b7355"
                            opacity: root.leftWidth > 64 ? 0.1 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 300 } }
                        }

                        Item {
                            anchors.fill: parent; anchors.margins: 10
                            opacity: root.leftWidth > 350 ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Launcher { id: appMenu; visible: active; anchors.fill: parent }
                            WeatherSidebar { id: weatherSidebar; visible: open; anchors.fill: parent; onCloseRequested: open = false }
                            BarClock { id: clockExpanded; drawerOpen: true; visible: clockModule.drawerOpen; anchors.fill: parent }
                        }
                    }
                }
            }
        }
    }
}
