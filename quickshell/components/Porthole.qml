import QtQuick
import "root:/config"

// The house mark: a porthole with a planet low in it — the wallpaper's one
// composition, drawn in a hairline ring and a disc. The bar's sigil and the
// lock screen both draw it, so the two are the same mark at two sizes.
Item {
    id: root

    property real size: 18
    property bool lit: false

    implicitWidth: root.size
    implicitHeight: root.size

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.width: Math.max(1, Math.round(root.size / 18))
        border.color: root.lit ? Theme.accent : Theme.primaryDim

        Behavior on border.color {
            ColorAnimation { duration: Theme.durFast }
        }
    }

    // The planet's limb, sitting on the ring's lower edge. Always the planet
    // white; `lit` only lets it rise a little.
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.size / 6
        width: root.size * (root.lit ? 0.44 : 0.34)
        height: width
        radius: width / 2
        color: Theme.accent

        Behavior on width {
            NumberAnimation { duration: Theme.durBase; easing.type: Easing.OutCubic }
        }
    }
}
