import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    readonly property int fw: 10
    readonly property int fr: 24
    readonly property color bg: "#f5ede4"
    readonly property int leftBase: 64

    property int expansionW: (appMenu.active || weatherSidebar.open || clockModule.drawerOpen) ? 320 : 0

    // ─── TOP ───
    PanelWindow {
        anchors { top: true; left: true; right: true }
        implicitHeight: fw
        exclusionMode: ExclusionMode.Auto
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            color: bg
            bottomRightRadius: fr
            Rectangle {
                anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
                height: 1; color: Qt.darker(bg, 1.08)
            }
        }
    }

    // ─── BOTTOM (Dock) ───
    PanelWindow {
        id: bottomPanel
        anchors { bottom: true; left: true; right: true }

        implicitHeight: dock.hovered ? dock.expandedH : fw

        Behavior on implicitHeight {
            SpringAnimation { spring: 3; damping: 0.7; epsilon: 0.5 }
        }

        exclusionMode: ExclusionMode.Auto
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: bg
            topRightRadius: fr
            clip: true

            Rectangle {
                anchors { top: parent.top; left: parent.left; right: parent.right }
                height: 1; color: Qt.darker(bg, 1.08)
            }

            Dock {
                id: dock
                anchors.fill: parent
            }
        }
    }

    // ─── RIGHT ───
    PanelWindow {
        anchors { right: true; top: true; bottom: true }
        implicitWidth: fw
        exclusionMode: ExclusionMode.Auto
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            color: bg
            topLeftRadius: fw
            bottomLeftRadius: fw
            Rectangle {
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: 1; color: Qt.darker(bg, 1.08)
            }
        }
    }

    // ─── LEFT (main bar) ───
    PanelWindow {
        id: bar
        anchors { left: true; top: true; bottom: true }

        implicitWidth: leftBase + expansionW

        Behavior on implicitWidth {
            SpringAnimation { spring: 4; damping: 0.8; epsilon: 0.5 }
        }

        exclusionMode: ExclusionMode.Auto
        color: "transparent"

        Rectangle {
            id: barContainer
            anchors.fill: parent
            color: bg
            topRightRadius: fr
            bottomRightRadius: fr

            Rectangle {
                anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
                width: 2; color: Qt.darker(bg, 1.06)
            }

            RowLayout {
                anchors.fill: parent
                spacing: 0

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: leftBase
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
                        opacity: expansionW > 0 ? 0.1 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                    }

                    Item {
                        anchors.fill: parent; anchors.margins: 10
                        opacity: expansionW > 300 ? 1.0 : 0.0
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
