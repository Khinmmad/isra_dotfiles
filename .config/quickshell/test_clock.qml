import QtQuick
import Quickshell

ShellRoot {
    SystemClock { id: c }
    Component.onCompleted: {
        console.log("Clock props:", Object.keys(c));
        Qt.quit()
    }
}
