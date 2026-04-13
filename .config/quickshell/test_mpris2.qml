import QtQuick
import Quickshell
import Quickshell.Services.Mpris

ShellRoot {
    Component.onCompleted: {
        console.log("Players map type:", typeof Mpris.players);
        console.log("Players keys:", Object.keys(Mpris.players));
        for (var i = 0; i < Mpris.players.values.length; i++) {
            console.log("Player bus:", Mpris.players.values[i].busName);
        }
        Qt.quit()
    }
}
