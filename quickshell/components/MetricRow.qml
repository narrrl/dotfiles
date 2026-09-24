import QtQuick
import "root:/config"
import "root:/components"

// One metric in a popout: a label and its reading on a line, with a wide
// sheared segmented meter underneath.
//
// This replaces the radial Gauge. A 270° dial was the only curved thing in a
// shell whose whole geometry is sheared slabs and hard chamfers, so it read as
// though it had been imported from another design. The meter says the same
// thing in the language the bar and the OSD already speak, and it gets far more
// resolution across a popout's width than a 88px dial did.
Item {
    id: root

    property string label: ""
    property real value: 0            // 0..100
    property string readout: Math.round(root.value) + "%"
    property string sub: ""
    property color tone: Theme.heat(root.value)

    property int segments: 24
    property real segmentSpacing: 3

    implicitHeight: head.height + Theme.padS + meter.height

    Item {
        id: head
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(name.implicitHeight, figure.implicitHeight)

        Text {
            id: name
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.label.toUpperCase()
            color: Theme.subtext
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        // The secondary figure — temperature, used-of-total. Sits next to the
        // label rather than under the number so the right edge stays a single
        // clean column of readings.
        Text {
            anchors.left: name.right
            anchors.leftMargin: Theme.padM
            anchors.right: figure.left
            anchors.rightMargin: Theme.padM
            anchors.verticalCenter: parent.verticalCenter
            visible: root.sub !== ""
            text: root.sub
            color: Theme.muted
            elide: Text.ElideRight
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }

        SplitText {
            // Not `value` — an id by that name shadows the `value` property, and
            // the defaults above then round a Text item instead of a number.
            id: figure
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.readout
            pixelSize: Theme.fsBody
            color: Theme.text
        }
    }

    MeterBar {
        id: meter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 12
        segments: root.segments
        spacing: root.segmentSpacing
        // Fill the row exactly rather than leaving a ragged tail on the right.
        segmentWidth: (width - (root.segments - 1) * root.segmentSpacing) / root.segments
        value: root.value
        activeColor: root.tone
    }
}
