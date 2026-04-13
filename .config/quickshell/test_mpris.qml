import QtQuick
import Quickshell
import Quickshell.Services.Mpris

ShellRoot {
    Component.onCompleted: {
        console.log("Players map type:", typeof MprisController.players);
        console.log("Players keys:", Object.keys(MprisController.players));
        for (var key in MprisController.players) {
            console.log("Key:", key, "Identity:", MprisController.players[key].identity);
        }
        Qt.quit()
    }
}
