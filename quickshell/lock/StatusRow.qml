import QtQuick
import "root:/config"
import "root:/components"

// One line of the lock screen's status log, laid out like the dashboard's
// facts: a dot in the line's tone, the label tracked in caps, a hairline
// running out to the detail at the far end.
Item {
    id: row

    property string label: ""
    property string detail: ""
    property color tone: Theme.primaryDim
    // The lock face's size factor. The row is laid out at that size rather
    // than scaled, so its native text stays sharp.
    property real uiScale: 1

    implicitHeight: visible ? Math.round(26 * row.uiScale) : 0

    Rectangle {
        id: dot
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.round(Theme.marker * row.uiScale)
        height: width
        radius: width / 2
        color: row.tone
    }

    Text {
        id: name
        anchors.left: dot.right
        anchors.leftMargin: Math.round(Theme.padS * row.uiScale)
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, row.width * 0.55)
        text: row.label.toUpperCase()
        color: Theme.text
        elide: Text.ElideRight
        font.family: Theme.fontDisplay
        font.pixelSize: Math.round(Theme.fsSmall * row.uiScale)
        font.weight: Theme.weightDisplay
        font.letterSpacing: Theme.tracking * row.uiScale
        renderType: Text.NativeRendering
    }

    Rectangle {
        anchors.left: name.right
        anchors.leftMargin: Math.round(Theme.padS * row.uiScale)
        anchors.right: value.left
        anchors.rightMargin: Math.round(Theme.padS * row.uiScale)
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: Theme.alpha(Theme.outline, 0.4)
    }

    Text {
        id: value
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(implicitWidth, row.width * 0.4)
        text: row.detail
        color: Theme.muted
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        font.family: Theme.fontMono
        font.pixelSize: Math.round(Theme.fsMicro * row.uiScale)
        renderType: Text.NativeRendering
    }
}
