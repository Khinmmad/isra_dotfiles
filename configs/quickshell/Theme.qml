pragma Singleton
import QtQuick

QtObject {
    // Superficies
    readonly property color background:       "#f5ede4"
    readonly property color surface:          "#e8dccb"
    readonly property color surfaceDim:       "#efe4d4"
    readonly property color surfaceHigh:      "#ddd0bd"

    // Texto
    readonly property color text:             "#1f1b16"
    readonly property color textMuted:        "#5c5248"

    // Acentos y bordes
    readonly property color outline:          "#8b7355"
    readonly property color primary:          "#8b4a3f"
    readonly property color primaryContainer: "#ffdbd1"

    // Animaciones
    readonly property int animFast:   100
    readonly property int animNormal: 150
}
