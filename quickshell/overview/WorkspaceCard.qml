import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "root:/config"
import "root:/services"

// One workspace in the overview: a small porthole at its monitor's aspect
// ratio, the wallpaper faint behind it, and its windows as live captures where
// they sit. Under it, the workspace's number in the bar's pill when it is the
// one on screen.
Item {
    id: card

    required property HyprlandWorkspace ws
    required property var windows
    required property real k            // logical px -> card px
    required property real logicalW
    required property real logicalH
    property bool current: false
    property string picked: ""

    signal pick(string address)
    signal activate(string address)
    signal activateWorkspace(int id)

    // ws goes null for a frame when its workspace is destroyed (the last
    // window on it closed) before the card is.
    readonly property bool special: (card.ws?.id ?? 0) < 0
    // The picked window, if it is one of the hidden members of a group here:
    // the group's slot shows it instead of the member that is in front.
    readonly property var pickedGroup: {
        for (const w of card.windows)
            if (w.address === card.picked && w.group.length > 1) return w.group;
        return [];
    }

    implicitWidth: Math.round(card.logicalW * card.k)
    implicitHeight: porthole.height + label.anchors.topMargin + label.height

    Rectangle {
        id: porthole
        width: card.implicitWidth
        height: Math.round(card.logicalH * card.k)
        radius: Theme.radiusM
        color: Theme.mantle
        border.width: 1
        border.color: card.current ? Theme.outline : Theme.rim
        clip: true

        Image {
            anchors.fill: parent
            anchors.margins: 1
            source: Wallpaper.source
            sourceSize: Qt.size(width, height)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: 0.35
        }

        // Click on bare wallpaper: go to the workspace itself.
        TapHandler {
            onTapped: if (!card.special) card.activateWorkspace(card.ws.id)
        }

        Repeater {
            model: card.windows

            Rectangle {
                id: tile
                required property var modelData
                readonly property bool isPicked: tile.modelData.address === card.picked
                // A group draws one member: the picked one if it is in this
                // group, otherwise whichever Hyprland has in front.
                visible: card.pickedGroup.length > 0 && card.pickedGroup.indexOf(tile.modelData.address) >= 0
                    ? tile.isPicked
                    : !tile.modelData.hidden

                x: Math.round(tile.modelData.x * card.k)
                y: Math.round(tile.modelData.y * card.k)
                width: Math.max(8, Math.round(tile.modelData.w * card.k))
                height: Math.max(8, Math.round(tile.modelData.h * card.k))
                z: tile.isPicked ? 2 : (tile.modelData.floating ? 1 : 0)
                radius: Theme.radiusS
                color: Theme.surface
                clip: true

                // The app's icon, under the capture, for the moment before the
                // first frame lands or for a window that cannot be captured.
                Image {
                    anchors.centerIn: parent
                    width: Math.min(32, parent.width * 0.4)
                    height: width
                    sourceSize: Qt.size(width, height)
                    source: {
                        const e = DesktopEntries.heuristicLookup(tile.modelData.appClass);
                        return e && e.icon ? Quickshell.iconPath(e.icon, true) : "";
                    }
                    visible: !capture.hasContent
                }

                ScreencopyView {
                    id: capture
                    anchors.fill: parent
                    captureSource: tile.modelData.toplevel.wayland
                    live: true
                    constraintSize: Qt.size(tile.width, tile.height)
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: tile.isPicked ? 2 : 1
                    border.color: tile.isPicked ? Theme.accent : Theme.alpha(Theme.ink, 0.6)

                    Behavior on border.color {
                        ColorAnimation { duration: Theme.durFast }
                    }
                }

                // Everything else sinks back a little.
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.ink
                    opacity: tile.isPicked ? 0 : 0.28

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.durFast }
                    }
                }

                // How many windows share this slot.
                Rectangle {
                    visible: tile.modelData.group.length > 1
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 4
                    width: groupText.implicitWidth + 8
                    height: groupText.implicitHeight + 2
                    radius: height / 2
                    color: Theme.alpha(Theme.ink, 0.75)

                    Text {
                        id: groupText
                        anchors.centerIn: parent
                        text: (tile.modelData.group.indexOf(tile.modelData.address) + 1)
                            + "/" + tile.modelData.group.length
                        color: Theme.subtext
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fsMicro
                        renderType: Text.NativeRendering
                    }
                }

                HoverHandler {
                    onHoveredChanged: if (hovered) card.pick(tile.modelData.address)
                    // Hovered from the start, then the pointer moves: still a pick.
                    onPointChanged: if (hovered) card.pick(tile.modelData.address)
                }

                TapHandler {
                    onTapped: card.activate(tile.modelData.address)
                }
            }
        }
    }

    // The workspace's name: the focused one wears it in the bar's light pill,
    // the rest in grey.
    Rectangle {
        id: label
        anchors.top: porthole.bottom
        anchors.topMargin: Theme.padS
        anchors.horizontalCenter: porthole.horizontalCenter
        width: Math.max(height * 1.6, labelText.implicitWidth + 14)
        height: labelText.implicitHeight + 4
        radius: height / 2
        color: card.current ? Theme.accent : "transparent"

        Text {
            id: labelText
            anchors.centerIn: parent
            text: !card.ws ? "" : card.special ? card.ws.name.replace(/^special:/, "") : String(card.ws.id)
            color: card.current ? Theme.ink : Theme.muted
            font.family: card.special ? Theme.fontMono : Theme.fontDisplay
            font.pixelSize: Theme.fsSmall
            font.weight: Theme.weightDisplay
            renderType: Text.NativeRendering
        }
    }
}
