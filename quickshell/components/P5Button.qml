import QtQuick
import "root:/config"

// Chopped, leaning button with one activation path for pointer and keyboard.
FocusScope {
    id: root

    property string text: ""
    property string icon: ""
    property color accent: Theme.primary
    property bool destructive: false
    property bool selected: false
    property real lean: Theme.skew
    property real lunge: 6
    property bool wide: false

    signal clicked()

    readonly property bool hovered: root.enabled && hover.hovered
    readonly property bool pressed: tap.pressed
    readonly property bool focusedOrSelected: root.activeFocus || root.selected
    readonly property bool highlighted: root.hovered || root.focusedOrSelected

    // Pointer activation must not turn a transient action into the black/white
    // keyboard-focus treatment. Tab still reaches it, and programmatic focus
    // (power-menu roving selection / pinned popouts) still works.
    focusPolicy: root.enabled ? Qt.TabFocus : Qt.NoFocus

    function activate(): void {
        if (root.enabled)
            root.clicked();
    }

    function activateFromKey(event): void {
        if (!event.isAutoRepeat)
            root.activate();
    }

    implicitWidth: wide ? 260 : (row.implicitWidth + panel.contentPad * 2)
    implicitHeight: 44

    P5Panel {
        id: panel
        anchors.fill: parent
        lean: root.lean
        padding: Theme.padS
        fill: {
            if (!root.enabled) return Theme.treatmentDisabledFill;
            if (root.destructive)
                return root.highlighted ? Theme.treatmentDestructiveActiveFill
                                        : Theme.treatmentDestructiveFill;
            if (root.highlighted) return Theme.treatmentHoverFill;
            return Theme.treatmentRestFill;
        }
        fillOpacity: root.enabled ? 1.0 : 0.72
        border: {
            if (!root.enabled) return Theme.treatmentDisabledMark;
            if (root.destructive)
                return root.highlighted ? Theme.treatmentDestructiveActiveMark
                                        : Theme.treatmentDestructiveMark;
            if (root.highlighted) return Theme.treatmentHoverMark;
            return Theme.alpha(root.accent, 0.55);
        }
        borderWidth: Theme.stroke
        slash: !root.highlighted
        slashColor: root.destructive ? Theme.alarm : root.accent
        halftone: root.enabled && root.highlighted
        halftoneColor: Theme.ink
        halftoneOpacity: 0.14

        Behavior on fillOpacity {
            NumberAnimation { duration: Theme.durFast }
        }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: Theme.padM

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.icon !== ""
                text: root.icon
                font.pixelSize: Theme.fsTitle
                color: {
                    if (!root.enabled) return Theme.treatmentDisabledText;
                    if (root.destructive)
                        return root.highlighted ? Theme.treatmentDestructiveActiveText
                                                : Theme.treatmentDestructiveText;
                    if (root.highlighted) return Theme.treatmentHoverText;
                    return root.accent;
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: {
                    if (!root.enabled) return Theme.treatmentDisabledText;
                    if (root.destructive)
                        return root.highlighted ? Theme.treatmentDestructiveActiveText
                                                : Theme.treatmentDestructiveText;
                    if (root.highlighted) return Theme.treatmentHoverText;
                    return Theme.treatmentRestText;
                }
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsBody
                font.weight: Theme.weightDisplay
                font.italic: true
                font.letterSpacing: 1.5
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation { duration: Theme.durFast }
                }
            }
        }
    }

    transform: Translate {
        x: root.pressed ? 0 : (root.highlighted ? root.lunge : 0)

        Behavior on x {
            NumberAnimation {
                duration: Theme.durBase
                easing.type: Easing.OutBack
            }
        }
    }

    scale: root.pressed ? 0.97 : 1.0
    Behavior on scale {
        NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutExpo }
    }

    HoverHandler {
        id: hover
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: tap
        enabled: root.enabled
        onTapped: root.activate()
    }

    Keys.onReturnPressed: event => root.activateFromKey(event)
    Keys.onEnterPressed: event => root.activateFromKey(event)
    Keys.onSpacePressed: event => root.activateFromKey(event)
}
