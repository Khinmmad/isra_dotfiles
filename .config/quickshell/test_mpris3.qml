import QtQuick
import Quickshell
import Quickshell.Services.Mpris

ShellRoot {
    Component.onCompleted: {
        console.log("Mpris props:", Object.keys(Mpris));
        Qt.quit()
    }
}
