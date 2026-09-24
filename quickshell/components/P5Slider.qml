import QtQuick
import "root:/config"
import "root:/components"

// Leaning slider with a chopped handle. Drag or click anywhere on the rail.
Item {
    id: root

    property real value: 0        // 0..1
    property color accent: Theme.primary
    property real stepSize: 0.05

    signal moved(real value)

    implicitHeight: 18
    implicitWidth: 200
    focusPolicy: root.enabled ? Qt.StrongFocus : Qt.NoFocus

    readonly property real _lean: Theme.skew * height

    function commit(nextValue: real): void {
        if (!root.enabled)
            return;
        root.moved(Math.max(0, Math.min(1, nextValue)));
    }

    // Rail
    Skew {
        id: rail
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: root.activeFocus ? 10 : 6
        // Focus widens the rail and rings it in the accent rather than filling
        // it: the level fill is often the accent itself, and a solid accent
        // rail swallowed it.
        color: root.activeFocus
            ? Theme.surfaceAlt
            : Theme.alpha(root.enabled ? Theme.outline : Theme.treatmentDisabledMark, 0.7)
        borderColor: root.activeFocus ? Theme.accent : "transparent"
        borderWidth: root.activeFocus ? Theme.stroke : 0

        Behavior on height {
            NumberAnimation { duration: Theme.durFast }
        }
    }

    // Fill
    Skew {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width: Math.max(0, Math.min(1, root.value)) * root.width
        height: 6
        color: root.enabled ? root.accent : Theme.treatmentDisabledText

        Behavior on width {
            enabled: !drag.active
            NumberAnimation { duration: Theme.durFast }
        }

        Behavior on color {
            ColorAnimation { duration: Theme.durBase }
        }
    }

    // Handle
    Skew {
        id: handle
        width: 6
        height: root.activeFocus || hover.hovered || drag.active ? 18 : 14
        color: root.enabled ? Theme.text : Theme.treatmentDisabledText
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(1, root.value)) * root.width - width / 2

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
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.enabled
        onPressedChanged: if (pressed) root.forceActiveFocus(Qt.MouseFocusReason)
        onTapped: event => root.commit(event.position.x / root.width)
    }

    DragHandler {
        id: drag
        enabled: root.enabled
        target: null
        xAxis.enabled: true
        yAxis.enabled: false
        onCentroidChanged: {
            if (!active) return;
            root.forceActiveFocus(Qt.MouseFocusReason);
            root.commit(centroid.position.x / root.width);
        }
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Left:
            root.commit(root.value - root.stepSize);
            break;
        case Qt.Key_Right:
            root.commit(root.value + root.stepSize);
            break;
        case Qt.Key_Home:
            root.commit(0);
            break;
        case Qt.Key_End:
            root.commit(1);
            break;
        default:
            return;
        }
        event.accepted = true;
    }
}
