import QtQuick
import Quickshell
import Quickshell.Hyprland
import "root:/config"
import "root:/components"

// Focused window title. Rapid application title churn is settled before it is
// painted, then the stable caption lands like a misregistered print layer.
Item {
    id: root

    required property var screenRef

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screenRef)
    readonly property HyprlandToplevel toplevel: Hyprland.activeToplevel

    // Only speak for the monitor this bar lives on.
    readonly property bool mine: toplevel !== null
        && (root.monitor === null || toplevel.monitor === null
            || toplevel.monitor.id === root.monitor.id)

    readonly property string incomingTitle: mine && toplevel.title ? toplevel.title : "—"
    property string displayedTitle: "—"

    // The bar shrinks this when the three clusters would otherwise collide.
    property real maxWidth: 240

    implicitWidth: Math.min(maxWidth, Math.max(70, label.implicitWidth + 4))
    implicitHeight: 20

    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.durSlow; easing.type: Easing.OutExpo }
    }

    Item {
        id: titleStage
        anchors.fill: parent
        clip: true

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            text: root.displayedTitle
            color: root.mine ? Theme.subtext : Theme.muted
            elide: Text.ElideRight
            font.pixelSize: Theme.fsSmall
            font.family: Theme.fontDisplay
            font.italic: true
            font.weight: Font.DemiBold
            renderType: Text.NativeRendering
        }

        // Crimson duplicate: visible only during the landing transition. The
        // small opposing offset gives the title Persona's rough print snap
        // without leaving permanent motion in the bar.
        Text {
            id: ghost
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            text: root.displayedTitle
            color: Theme.accent
            opacity: 0
            elide: Text.ElideRight
            font: label.font
            renderType: Text.NativeRendering
        }
    }

    function commitTitle(): void {
        if (root.displayedTitle === root.incomingTitle)
            return;
        root.displayedTitle = root.incomingTitle;
        titleLanding.restart();
    }

    // Browser tabs, terminals and editors can update titles several times in a
    // frame. Keep the old caption steady until the stream settles instead of
    // restarting an animation for every intermediate value.
    Timer {
        id: titleSettle
        interval: 120
        repeat: false
        onTriggered: root.commitTitle()
    }

    onIncomingTitleChanged: titleSettle.restart()
    Component.onCompleted: displayedTitle = incomingTitle

    // A quick crimson wipe under the title on focus change.
    Rectangle {
        id: wipe
        anchors.bottom: parent.bottom
        height: 2
        width: 0
        color: Theme.accent
        opacity: 0
    }

    SequentialAnimation {
        id: titleLanding
        ParallelAnimation {
            NumberAnimation {
                target: wipe; property: "width"
                from: 0; to: root.width
                duration: Theme.durBase; easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: wipe; property: "opacity"
                from: 0; to: 1; duration: Theme.durFast
            }
            NumberAnimation {
                target: label; property: "x"
                from: -10; to: 0
                duration: Theme.durBase; easing.type: Easing.OutBack
            }
            NumberAnimation {
                target: label; property: "opacity"
                from: 0.35; to: 1; duration: Theme.durFast
            }
            NumberAnimation {
                target: ghost; property: "x"
                from: 9; to: -3
                duration: Theme.durBase; easing.type: Easing.OutExpo
            }
            NumberAnimation {
                target: ghost; property: "opacity"
                from: 0.8; to: 0; duration: Theme.durBase
            }
        }
        NumberAnimation {
            target: wipe; property: "opacity"
            to: 0; duration: Theme.durSlow
        }
    }
}
