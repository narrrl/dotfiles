import QtQuick
import "root:/config"

// NieR menu button: a hairline box with a square marker that lights when the
// button is pointed at or chosen. One activation path for pointer and keyboard.
FocusScope {
    id: root

    property string text: ""
    property string icon: ""
    property color accent: Theme.primary
    property bool destructive: false
    property bool selected: false
    property real lean: Theme.skew
    // Sideways nudge on hover. Zero: NieR buttons do not move, the marker
    // and the inversion carry the state.
    property real lunge: 0
    property bool wide: false

    signal clicked()

    readonly property bool hovered: root.enabled && hover.hovered
    readonly property bool pressed: tap.pressed
    readonly property bool focusedOrSelected: root.activeFocus || root.selected
    readonly property bool highlighted: root.hovered || root.focusedOrSelected

    // Keyboard focus and roving selection invert the slab to solid accent.
    // Pointer hover stays a keyline change, so the two never look alike and a
    // mouse user never sees the "selected" treatment by accident. Destructive
    // buttons keep their own red inversion for both.
    readonly property bool inverted: root.enabled && !root.destructive && root.focusedOrSelected

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

    Panel {
        id: panel
        anchors.fill: parent
        lean: root.lean
        padding: Theme.padS
        fill: {
            if (!root.enabled) return Theme.treatmentDisabledFill;
            if (root.destructive)
                return root.highlighted ? Theme.treatmentDestructiveActiveFill
                                        : Theme.treatmentDestructiveFill;
            if (root.inverted) return Theme.treatmentFocusFill;
            if (root.highlighted) return Theme.treatmentHoverFill;
            return Theme.treatmentRestFill;
        }
        fillOpacity: root.enabled ? 1.0 : 0.72
        border: {
            if (!root.enabled) return Theme.treatmentDisabledMark;
            if (root.destructive)
                return root.highlighted ? Theme.treatmentDestructiveActiveMark
                                        : Theme.treatmentDestructiveMark;
            if (root.inverted) return Theme.treatmentFocusMark;
            if (root.highlighted) return Theme.treatmentHoverMark;
            return Theme.alpha(root.accent, 0.55);
        }
        borderWidth: Theme.stroke

        Behavior on fillOpacity {
            NumberAnimation { duration: Theme.durFast }
        }

        Row {
            id: row
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            spacing: Theme.padM

            // The marker. Dim at rest, full strength under the pointer or the
            // cursor, in whatever colour the label is wearing.
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.marker
                height: Theme.marker
                radius: width / 2
                color: label.color
                opacity: root.highlighted ? 1.0 : 0.35

                Behavior on opacity {
                    NumberAnimation { duration: Theme.durFast }
                }
            }

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
                    if (root.inverted) return Theme.treatmentFocusText;
                    if (root.highlighted) return Theme.treatmentHoverText;
                    return root.accent;
                }
            }

            Text {
                id: label
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                color: {
                    if (!root.enabled) return Theme.treatmentDisabledText;
                    if (root.destructive)
                        return root.highlighted ? Theme.treatmentDestructiveActiveText
                                                : Theme.treatmentDestructiveText;
                    if (root.inverted) return Theme.treatmentFocusText;
                    if (root.highlighted) return Theme.treatmentHoverText;
                    return Theme.treatmentRestText;
                }
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsBody
                font.weight: Theme.weightDisplay
                font.letterSpacing: Theme.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation { duration: Theme.durFast }
                }
            }
        }
    }

    // A press sinks the button one whole pixel instead of shrinking it, so
    // its label stays on the pixel grid.
    transform: Translate {
        x: root.pressed ? 0 : (root.highlighted ? root.lunge : 0)
        y: root.pressed ? 1 : 0

        Behavior on x {
            NumberAnimation {
                duration: Theme.durBase
                easing.type: Easing.OutCubic
            }
        }
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
