import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "root:/config"
import "root:/components"

// One level of a StatusNotifier menu, drawn in the shell's own language.
//
// Submenus expand inline rather than opening a second window: a tray menu is
// two or three items deep at most, and a stack of leaning slabs chasing each
// other across the screen would read as clutter. The type nests itself for
// child levels, so this file is the whole menu.
Column {
    id: root

    // A QsMenuHandle — either the item's root menu or a submenu entry.
    required property var menuHandle

    // Raised by any level when an entry is actually invoked, so the window can
    // close itself.
    signal activated()

    // What the window should size itself to. Deliberately NOT `implicitWidth`.
    //
    // A Column takes its implicit width from how wide its children ended up, and
    // the rows are stretched to the Column's own width so a hover block can span
    // the entry. Sizing the window off that closes the loop — window width feeds
    // row width feeds Column implicit width feeds window width — and it does not
    // settle: each pass adds a float epsilon, so the shell spins at 100% CPU
    // forever. Slack's menu was the first to hit it and it took the whole bar
    // down with it, past the reach of anything but SIGKILL. Measuring the
    // strings against the font instead keeps sizing entirely out of the layout.
    readonly property real menuWidth: {
        let w = 0;
        for (const e of (opener.children?.values ?? [])) {
            if (e.isSeparator) continue;
            let ew = fm.advanceWidth(root.clean(e.text)) + Theme.padM * 2 + Theme.padS * 2;
            if (e.buttonType !== QsMenuButtonType.None || e.icon !== "")
                ew += 16 + Theme.padS;
            if (e.hasChildren) ew += 18;
            w = Math.max(w, ew);
        }
        return w;
    }

    // DBus menus carry Qt's mnemonic underscores; nothing here handles
    // accelerators, so they would just be stray marks.
    function clean(s: string): string {
        return String(s ?? "").replace(/_([^_])/g, "$1");
    }

    spacing: 0

    FontMetrics {
        id: fm
        font.family: Theme.fontMono
        font.pixelSize: Theme.fsSmall
        font.weight: Theme.weightBody
    }

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    Repeater {
        model: opener.children

        Item {
            id: row

            required property var modelData
            readonly property var entry: modelData
            readonly property bool interactive: entry.enabled && !entry.isSeparator
            readonly property bool hovered: rowHover.hovered && interactive

            // Submenus stay collapsed until asked for.
            property bool expanded: false

            // Height only. Width is the Column's business — see `menuWidth`.
            implicitHeight: entry.isSeparator ? 9 : 26 + sub.height

            width: root.width

            // ------------------------------------------------------ separator
            //
            // A horizontal rule slants by a fraction of its own width, so at
            // menu width the house lean turns a hairline into a 30px diagonal
            // gash straight across the entries above and below it. The rise is
            // pinned in pixels instead, matching the rail's dividers.
            Skew {
                anchors.verticalCenter: parent.verticalCenter
                visible: row.entry.isSeparator
                width: parent.width - Theme.padM * 2
                x: Theme.padM
                height: 1
                vertical: true
                lean: width > 0 ? 5 / width : 0
                color: Theme.alpha(Theme.outline, 0.9)
            }

            // ----------------------------------------------------------- item
            Item {
                id: line
                width: parent.width
                height: row.entry.isSeparator ? 0 : 26
                visible: !row.entry.isSeparator

                // Hover is a solid crimson block, the same statement the
                // workspace ticks and the rail icons make.
                Skew {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.padS
                    anchors.rightMargin: Theme.padS
                    color: row.hovered ? Theme.accent : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.durFast }
                    }
                }

                // Check mark / radio dot, or the entry's own icon. Both occupy
                // the same slot so the labels line up either way.
                Item {
                    id: leading
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.padM
                    anchors.verticalCenter: parent.verticalCenter
                    width: row.entry.buttonType !== QsMenuButtonType.None
                        || row.entry.icon !== "" ? 16 : 0
                    height: 12

                    Skew {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: row.entry.buttonType !== QsMenuButtonType.None
                        width: 10
                        height: 10
                        borderWidth: 1
                        borderColor: row.hovered ? Theme.ink : Theme.alpha(Theme.text, 0.6)
                        color: row.entry.checkState === Qt.Checked
                            ? (row.hovered ? Theme.ink : Theme.accent)
                            : "transparent"
                    }

                    IconImage {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: row.entry.buttonType === QsMenuButtonType.None
                            && row.entry.icon !== ""
                        width: 14
                        height: 14
                        source: row.entry.icon
                        asynchronous: true

                        // Same flattening the tray icons get — brand colour in
                        // a two-hue palette is the one thing that breaks it.
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: row.hovered ? Theme.ink : Theme.text
                        }
                    }
                }

                Text {
                    id: label
                    anchors.left: leading.right
                    anchors.leftMargin: leading.width > 0 ? Theme.padS : Theme.padM
                    anchors.right: arrow.left
                    anchors.rightMargin: Theme.padS
                    anchors.verticalCenter: parent.verticalCenter

                    text: root.clean(row.entry.text)
                    elide: Text.ElideRight
                    color: !row.entry.enabled
                        ? Theme.muted
                        : (row.hovered ? Theme.ink : Theme.text)
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    font.weight: Theme.weightBody
                    renderType: Text.NativeRendering
                }

                Text {
                    id: arrow
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.padM
                    anchors.verticalCenter: parent.verticalCenter
                    width: row.entry.hasChildren ? 18 : 0
                    visible: row.entry.hasChildren
                    text: row.expanded ? "" : ""
                    color: row.hovered ? Theme.ink : Theme.subtext
                    font.family: Theme.fontIcon
                    font.pixelSize: Theme.fsMicro
                }

                HoverHandler {
                    id: rowHover
                    enabled: row.interactive
                    cursorShape: Qt.PointingHandCursor
                }

                TapHandler {
                    enabled: row.interactive
                    onTapped: {
                        if (row.entry.hasChildren) {
                            row.expanded = !row.expanded;
                        } else {
                            row.entry.triggered();
                            root.activated();
                        }
                    }
                }
            }

            // ------------------------------------------------------- submenu
            Item {
                id: sub
                anchors.top: line.bottom
                width: parent.width
                height: subLoader.item ? subLoader.item.implicitHeight : 0
                clip: true
                visible: height > 0

                Behavior on height {
                    NumberAnimation { duration: Theme.durFast; easing.type: Easing.OutExpo }
                }

                // The guide rule down the side of an expanded submenu.
                //
                // Same trap the separators hit, from the other direction: the
                // house lean is a fraction of *height*, and this rule is as tall
                // as the submenu. A Wi-Fi list of thirty networks made it 600px
                // tall, which sheared a 1px hairline into a 150px crimson wedge
                // lying across every entry in the list. The rise is pinned in
                // pixels, and it is declared before the entries so it can never
                // paint over them again.
                Skew {
                    x: Theme.padS
                    width: 1
                    height: parent.height
                    lean: height > 0 ? 5 / height : 0
                    visible: row.expanded
                    color: Theme.alpha(Theme.accent, 0.8)
                }

                // Loaded by URL rather than as an inline component: QML rejects
                // a type that instantiates itself, even lazily, and a menu tree
                // is the one place recursion is the natural shape.
                Loader {
                    id: subLoader
                    x: Theme.padM
                    width: parent.width - Theme.padM

                    onLoaded: item.activated.connect(root.activated)
                }

                Connections {
                    target: row

                    function onExpandedChanged() {
                        if (row.expanded)
                            subLoader.setSource(Qt.resolvedUrl("TrayMenuList.qml"),
                                                { menuHandle: row.entry });
                        else
                            subLoader.source = "";
                    }
                }

            }
        }
    }
}
