import QtQuick
import QtQuick.Window
import "root:/config"

// Horizontally scrolling text that only moves when it actually overflows, and
// pauses at each end so titles stay readable.
Item {
    id: root

    property string text: ""
    property int pixelSize: Theme.fsSmall
    property string family: Theme.fontDisplay
    property int weight: Theme.weightBody
    property bool italic: false
    property color color: Theme.text
    property real speed: 26          // px per second
    property int pause: 1400         // ms held at each end
    property bool running: true

    readonly property bool overflowing: label.implicitWidth > width + 1

    // An Item inside an unmapped PopupWindow still reports itself visible, so a
    // marquee in a closed popout would keep its infinite animation alive. That
    // animation writes QML properties on every frame — at 240 Hz, three closed
    // popout marquees are enough to keep the whole animation driver spinning and
    // burn a fifth of a core with nothing on screen. Follow the window instead.
    readonly property bool onScreen: Window.window?.visible ?? true

    clip: true
    implicitHeight: label.implicitHeight
    implicitWidth: label.implicitWidth

    Text {
        id: label
        y: 0
        height: root.height
        text: root.text
        color: root.color
        verticalAlignment: Text.AlignVCenter
        font.family: root.family
        font.pixelSize: root.pixelSize
        font.weight: root.weight
        font.italic: root.italic
        renderType: Text.NativeRendering
    }

    SequentialAnimation {
        id: scroll
        running: root.running && root.overflowing && root.visible && root.onScreen
        loops: Animation.Infinite

        PauseAnimation { duration: root.pause }
        NumberAnimation {
            target: label; property: "x"
            from: 0; to: Math.min(0, root.width - label.implicitWidth)
            duration: Math.max(1, Math.abs(root.width - label.implicitWidth) / root.speed * 1000)
            easing.type: Easing.Linear
        }
        PauseAnimation { duration: root.pause }
        NumberAnimation {
            target: label; property: "x"
            to: 0
            duration: Theme.durSlow
            easing.type: Easing.OutExpo
        }
    }

    onOverflowingChanged: if (!overflowing) label.x = 0
    onTextChanged: { label.x = 0; scroll.restart(); }
}
