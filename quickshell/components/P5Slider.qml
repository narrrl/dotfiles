import QtQuick
import "root:/config"

// Leaning slider with a chopped handle. Drag or click anywhere on the rail.
Item {
    id: root

    property real value: 0        // 0..1
    property color accent: Theme.primary
    property bool enabledControl: true

    signal moved(real value)

    implicitHeight: 18
    implicitWidth: 200

    readonly property real _lean: Theme.skew * height

    // Rail
    Rectangle {
        id: rail
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        color: Theme.alpha(Theme.outline, 0.7)

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -Theme.skew, 0, 6 * Theme.skew,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        }
    }

    // Fill
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: Math.max(0, Math.min(1, root.value)) * root.width
        height: 6
        color: root.enabledControl ? root.accent : Theme.muted

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -Theme.skew, 0, 6 * Theme.skew,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        }

        Behavior on width {
            enabled: !drag.active
            NumberAnimation { duration: Theme.durFast }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.durBase }
        }
    }

    // Handle
    Rectangle {
        id: handle
        width: 6
        height: hover.hovered || drag.active ? 18 : 14
        color: root.enabledControl ? Theme.text : Theme.muted
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, root.value)) * root.width - width / 2

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -Theme.skew, 0, height * Theme.skew,
                                 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        }

        Behavior on height {
            NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutBack }
        }
        Behavior on x {
            enabled: !drag.active
            NumberAnimation { duration: Theme.durFast }
        }
    }

    HoverHandler {
        id: hover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        onTapped: event => root.moved(Math.max(0, Math.min(1, event.position.x / root.width)))
    }

    DragHandler {
        id: drag
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onCentroidChanged: {
            if (!active) return;
            root.moved(Math.max(0, Math.min(1, centroid.position.x / root.width)));
        }
    }
}
