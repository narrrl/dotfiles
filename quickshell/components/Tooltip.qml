import QtQuick
import Quickshell
import "root:/config"

// Calm, informational hover label for permanent chrome. It never takes focus
// or participates in popup coordination; a delayed label should not dismiss or
// displace the detail panel attached to the same rail control.
PopupWindow {
    id: root

    required property Item anchorItem
    property bool triggerHovered: false
    property string title: ""
    property string status: ""
    property string hint: ""
    property int delay: 400
    property bool suppressed: false

    readonly property int pad: Theme.padS
    readonly property real textWidth: Math.max(titleText.implicitWidth,
        statusText.implicitWidth, hintText.implicitWidth)
    readonly property real contentWidth: Math.max(112, textWidth + pad * 4)
    readonly property real contentHeight: textColumn.implicitHeight + pad * 2

    anchor.item: anchorItem
    anchor.edges: Edges.Left
    anchor.gravity: Edges.Left
    anchor.adjustment: PopupAdjustment.Flip | PopupAdjustment.SlideY
    anchor.margins.left: Theme.popoutGap

    implicitWidth: contentWidth
    implicitHeight: contentHeight
    color: "transparent"
    visible: shown && title !== "" && !suppressed

    property bool shown: false

    onTriggerHoveredChanged: {
        if (triggerHovered && title !== "" && !suppressed) {
            hideTimer.stop();
            showTimer.restart();
        } else {
            showTimer.stop();
            hideTimer.restart();
        }
    }

    onSuppressedChanged: {
        if (suppressed) {
            showTimer.stop();
            shown = false;
        } else if (triggerHovered) {
            showTimer.restart();
        }
    }

    Timer {
        id: showTimer
        interval: root.delay
        onTriggered: root.shown = root.triggerHovered && !root.suppressed
    }

    Timer {
        id: hideTimer
        interval: 70
        onTriggered: root.shown = false
    }

    ChromeSurface {
        anchors.fill: parent
        padding: root.pad

        Column {
            id: textColumn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                id: titleText
                text: root.title.toUpperCase()
                color: Theme.text
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsSmall
                font.weight: Theme.weightDisplay
                renderType: Text.NativeRendering
            }

            Text {
                id: statusText
                visible: text !== ""
                text: root.status
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                renderType: Text.NativeRendering
            }

            Text {
                id: hintText
                visible: text !== ""
                text: root.hint.toUpperCase()
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                font.letterSpacing: 0.8
                renderType: Text.NativeRendering
            }
        }
    }
}
