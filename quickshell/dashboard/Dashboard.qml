import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "root:/config"
import "root:/components"
import "root:/services"

// The dashboard: a drawer that slides down out of the underside of the bar.
//
// The idea is caelestia's — the drawer is not a floating card but more of the
// hull, so it is painted in the hull colour and joins the bar through two
// concave fillets, and the porthole's rim runs round it without a break. Read
// against the wallpaper it is a panel lowered from the ceiling of the ship.
//
// Four columns divided by hairlines: who and when, the month, the machine,
// and what is playing. The clock in the bar toggles it, as does
// `qs ipc call shell dashboard`; Escape or a click anywhere else puts it away.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool open: Actions.dashboardOpen
        && Actions.dashboardScreen === modelData.name

    // 0 = tucked under the bar, 1 = fully down.
    property real reveal: root.open ? 1 : 0
    Behavior on reveal {
        NumberAnimation {
            duration: Theme.durSlow
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    visible: root.open || root.reveal > 0

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "takemi-dashboard"
    WlrLayershell.keyboardFocus: root.open
        ? WlrKeyboardFocus.OnDemand
        : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // One pixel up, so the drawer covers the rim the hull draws along the
    // underside of the bar instead of sitting below it.
    anchors.top: true
    margins.top: Theme.barHeight - 1

    // The fillets are the same radius as the porthole's corners, so the drawer
    // meets the bar the way the opening meets the frame.
    readonly property real fillet: Theme.frameRadius
    readonly property real radius: Theme.frameRadius
    readonly property real pad: Theme.padL

    readonly property real bodyWidth: columns.implicitWidth + root.pad * 2
    readonly property real bodyHeight: columns.implicitHeight + toggles.implicitHeight
        + Theme.padL + 1 + root.pad * 3

    implicitWidth: root.bodyWidth + root.fillet * 2
    implicitHeight: root.bodyHeight + 1
    color: "transparent"

    // A Region follows its item's own geometry, not its parents', so masking
    // to the body, which rides on the sliding sheet, would freeze the mask
    // wherever the sheet was when it was built — above the window, letting
    // every click through to whatever is below and dropping the focus grab.
    mask: Region { item: hitbox }

    Item {
        id: hitbox
        x: root.fillet
        width: root.bodyWidth
        height: parent.height
    }

    HyprlandFocusGrab {
        active: root.open
        windows: [root]
        onCleared: Actions.closeDashboard()
    }

    // Who is at the console. Read once; it does not change under a session.
    readonly property string user: Quickshell.env("USER") ?? ""
    FileView {
        id: hostFile
        path: "/etc/hostname"
    }
    readonly property string host: hostFile.text().trim()

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // Everything below slides as one sheet, clipped to the window so it
    // appears to come out from behind the bar rather than fading in over it.
    Item {
        anchors.fill: parent
        clip: true

        Item {
            id: sheet
            width: parent.width
            height: parent.height
            y: -height * (1 - root.reveal)

            // ------------------------------------------------------ silhouette
            Shape {
                id: silhouette
                anchors.fill: parent
                preferredRendererType: Shape.CurveRenderer

                readonly property real w: width
                readonly property real h: height
                readonly property real f: root.fillet
                readonly property real r: root.radius

                // Down the left fillet, round the bottom, up the right fillet.
                readonly property string edge:
                    `M 0 0 A ${f} ${f} 0 0 1 ${f} ${f}`
                    + ` V ${h - r} A ${r} ${r} 0 0 0 ${f + r} ${h}`
                    + ` H ${w - f - r} A ${r} ${r} 0 0 0 ${w - f} ${h - r}`
                    + ` V ${f} A ${f} ${f} 0 0 1 ${w} 0`

                ShapePath {
                    fillColor: Theme.hull
                    strokeColor: "transparent"
                    PathSvg { path: silhouette.edge + " Z" }
                }

                // The rim, carried on round the drawer from the opening.
                ShapePath {
                    fillColor: "transparent"
                    strokeColor: Theme.rim
                    strokeWidth: 1
                    PathSvg { path: silhouette.edge }
                }
            }

            // ---------------------------------------------------------- body
            FocusScope {
                id: body
                x: root.fillet
                width: root.bodyWidth
                height: parent.height
                focus: root.open

                Keys.onEscapePressed: Actions.closeDashboard()

                Row {
                    id: columns
                    x: root.pad
                    y: root.pad
                    spacing: 0

                    // Who and when: the house mark, the operator, a large clock.
                    Item {
                        implicitWidth: 230
                        implicitHeight: root.columnHeight

                        Row {
                            id: who
                            spacing: Theme.padM

                            Porthole {
                                anchors.verticalCenter: parent.verticalCenter
                                size: 30
                                lit: true
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1

                                Text {
                                    text: root.user.toUpperCase()
                                    color: Theme.text
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: Theme.fsBody
                                    font.weight: Theme.weightDisplay
                                    font.letterSpacing: Theme.tracking
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    text: root.host !== "" ? "@ " + root.host : ""
                                    color: Theme.muted
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fsMicro
                                    font.letterSpacing: 1
                                    renderType: Text.NativeRendering
                                }
                            }
                        }

                        Row {
                            id: time
                            anchors.top: who.bottom
                            anchors.topMargin: Theme.padL
                            spacing: Theme.padS

                            SplitText {
                                id: hhmm
                                text: Qt.formatDateTime(clock.date, "HH:mm")
                                pixelSize: 54
                                weight: Font.Light
                                letterSpacing: 2
                                color: Theme.accent
                            }

                            Text {
                                anchors.baseline: hhmm.bottom
                                anchors.baselineOffset: -12
                                text: Qt.formatDateTime(clock.date, "ss")
                                color: Theme.muted
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fsBody
                                renderType: Text.NativeRendering
                            }
                        }

                        Text {
                            anchors.top: time.bottom
                            anchors.topMargin: Theme.padS
                            text: Qt.formatDateTime(clock.date, "dddd  ·  dd MMMM").toUpperCase()
                            color: Theme.subtext
                            font.family: Theme.fontMono
                            font.pixelSize: Theme.fsMicro
                            font.letterSpacing: 2
                            renderType: Text.NativeRendering
                        }

                        Column {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: Theme.padS

                            Fact { label: "UPTIME"; value: Sys.uptime || "—" }
                            Fact {
                                visible: Battery.available
                                label: "POWER"
                                value: Math.round(Battery.percent) + "%"
                                    + (Battery.timeLabel !== "" ? "  ·  " + Battery.timeLabel : "")
                            }
                            Fact { label: "NOTICES"; value: Notifs.count > 0 ? Notifs.count + " held" : "none" }
                        }
                    }

                    Rule { height: root.columnHeight }

                    // The month, Monday first. Today is the NieR cursor: an inverted disc.
                    Item {
                        id: month
                        implicitWidth: 238
                        implicitHeight: root.columnHeight

                        // Keyed by the day, not the clock: the clock ticks every
                        // second, and rebuilding 42 cells that often is waste.
                        readonly property string dayKey: Qt.formatDateTime(clock.date, "yyyy-MM-dd")
                        readonly property var cells: {
                            const now = new Date(month.dayKey + "T12:00:00");
                            const y = now.getFullYear(), m = now.getMonth();
                            const lead = (new Date(y, m, 1).getDay() + 6) % 7;
                            const out = [];
                            for (let i = 0; i < 42; i++) {
                                const d = new Date(y, m, 1 - lead + i);
                                out.push({
                                    day: d.getDate(),
                                    inMonth: d.getMonth() === m,
                                    today: d.toDateString() === now.toDateString()
                                });
                            }
                            return out;
                        }

                        SectionRule {
                            id: monthHead
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: Qt.formatDateTime(clock.date, "MMMM yyyy")
                        }

                        Row {
                            id: weekdays
                            anchors.top: monthHead.bottom
                            anchors.topMargin: Theme.padS

                            Repeater {
                                model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]

                                Text {
                                    required property var modelData
                                    required property int index
                                    width: month.width / 7
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData
                                    color: index >= 5 ? Theme.subtext : Theme.muted
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fsMicro
                                    renderType: Text.NativeRendering
                                }
                            }
                        }

                        Grid {
                            anchors.top: weekdays.bottom
                            anchors.topMargin: Theme.padS
                            columns: 7

                            Repeater {
                                model: month.cells

                                Item {
                                    required property var modelData
                                    width: month.width / 7
                                    height: 26

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 22
                                        height: 22
                                        radius: 11
                                        visible: parent.modelData.today
                                        color: Theme.treatmentSelectedFill
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: parent.modelData.day
                                        color: parent.modelData.today ? Theme.treatmentSelectedText
                                             : parent.modelData.inMonth ? Theme.text
                                             : Theme.alpha(Theme.muted, 0.5)
                                        font.family: Theme.fontMono
                                        font.pixelSize: Theme.fsSmall
                                        font.weight: parent.modelData.today ? Font.Bold : Font.Normal
                                        renderType: Text.NativeRendering
                                    }
                                }
                            }
                        }
                    }

                    Rule { height: root.columnHeight }

                    // The machine: the same meters the bar's readout opens onto.
                    Item {
                        implicitWidth: 238
                        implicitHeight: root.columnHeight

                        SectionRule {
                            id: sysHead
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: "System"
                        }

                        Column {
                            anchors.top: sysHead.bottom
                            anchors.topMargin: Theme.padM
                            anchors.left: parent.left
                            anchors.right: parent.right
                            spacing: Theme.padM

                            MetricRow {
                                width: parent.width
                                value: Sys.cpuUsage
                                label: "CPU"
                                sub: Math.round(Sys.cpuTemp) + "°C"
                            }

                            MetricRow {
                                width: parent.width
                                value: Sys.memPercent
                                label: "MEM"
                                sub: Sys.gb(Sys.memUsed) + " / " + Sys.gb(Sys.memTotal)
                            }

                            MetricRow {
                                width: parent.width
                                visible: Sys.gpuAvailable
                                value: Sys.gpuUsage
                                label: "GPU"
                                sub: Math.round(Sys.gpuTemp) + "°C"
                            }

                            MetricRow {
                                width: parent.width
                                value: Sys.diskPercent
                                label: "DISK"
                                sub: Sys.diskFree + " free"
                            }
                        }
                    }

                    Rule { height: root.columnHeight }

                    // What is playing. With no player it says so, in the voice NieR's
                    // interface uses for an empty channel.
                    Item {
                        implicitWidth: 280
                        implicitHeight: root.columnHeight

                        SectionRule {
                            id: playHead
                            anchors.left: parent.left
                            anchors.right: parent.right
                            text: Media.hasPlayer ? Media.identity : "Audio"
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !Media.hasPlayer
                            text: "NO SIGNAL"
                            color: Theme.muted
                            font.family: Theme.fontDisplay
                            font.pixelSize: Theme.fsBody
                            font.letterSpacing: Theme.tracking * 2
                            renderType: Text.NativeRendering
                        }

                        Item {
                            anchors.top: playHead.bottom
                            anchors.topMargin: Theme.padM
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            visible: Media.hasPlayer

                            ClippingRectangle {
                                id: artFrame
                                width: 96
                                height: 96
                                radius: Theme.radiusL
                                color: Theme.surface
                                border.width: 1
                                border.color: Theme.overlay

                                Image {
                                    id: art
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: Media.artUrl
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    sourceSize.width: 192
                                    sourceSize.height: 192
                                }

                                Icon {
                                    anchors.centerIn: parent
                                    visible: art.status !== Image.Ready
                                    text: "󰝚"
                                    color: Theme.muted
                                    font.pixelSize: Theme.fsHuge
                                }
                            }

                            Column {
                                anchors.left: artFrame.right
                                anchors.leftMargin: Theme.padM
                                anchors.right: parent.right
                                anchors.verticalCenter: artFrame.verticalCenter
                                spacing: 3

                                Text {
                                    width: parent.width
                                    text: Media.title || "Untitled"
                                    elide: Text.ElideRight
                                    maximumLineCount: 2
                                    wrapMode: Text.Wrap
                                    color: Theme.accent
                                    font.family: Theme.fontDisplay
                                    font.pixelSize: Theme.fsLarge
                                    font.weight: Theme.weightDisplay
                                    renderType: Text.NativeRendering
                                }

                                Text {
                                    width: parent.width
                                    text: Media.artist
                                    elide: Text.ElideRight
                                    color: Theme.subtext
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fsSmall
                                    renderType: Text.NativeRendering
                                }
                            }

                            // Position: a hairline with a square riding it.
                            Item {
                                id: timeline
                                anchors.top: artFrame.bottom
                                anchors.topMargin: Theme.padM
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: Theme.marker
                                visible: Media.hasTimeline

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 1
                                    color: Theme.overlay
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * Media.progress
                                    height: 1
                                    color: Theme.accent
                                }

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: parent.width * Media.progress - width / 2
                                    width: Theme.marker
                                    height: Theme.marker
                                    radius: width / 2
                                    color: Theme.accent
                                }
                            }

                            Row {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                spacing: Theme.padS

                                Transport {
                                    glyph: "󰒮"
                                    enabled: Media.canGoPrevious
                                    onClicked: Media.previous()
                                }
                                Transport {
                                    glyph: Media.playing ? "󰏤" : "󰐊"
                                    onClicked: Media.playPause()
                                }
                                Transport {
                                    glyph: "󰒭"
                                    enabled: Media.canGoNext
                                    onClicked: Media.next()
                                }
                            }

                            Text {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 8
                                anchors.right: parent.right
                                visible: Media.hasTimeline
                                text: Media.timeString(Media.position) + " / " + Media.timeString(Media.length)
                                color: Theme.muted
                                font.family: Theme.fontMono
                                font.pixelSize: Theme.fsMicro
                                renderType: Text.NativeRendering
                            }
                        }
                    }
                }

                // A hairline, then the switches you reach for most.
                Rectangle {
                    id: togglesRule
                    x: root.pad
                    y: columns.y + columns.implicitHeight + Theme.padL
                    width: root.bodyWidth - root.pad * 2
                    height: 1
                    color: Theme.alpha(Theme.outline, 0.5)
                }

                Row {
                    id: toggles
                    x: root.pad
                    y: togglesRule.y + 1 + root.pad
                    spacing: Theme.padS

                    readonly property int count: nightLight.available ? 5 : 4
                    readonly property real chipWidth:
                        (root.bodyWidth - root.pad * 2 - toggles.spacing * (toggles.count - 1)) / toggles.count

                    Toggle {
                        width: toggles.chipWidth
                        glyph: Net.wifiEnabled ? "󰖩" : "󰖪"
                        label: "Wi-Fi"
                        on: Net.wifiEnabled
                        onClicked: Net.toggleWifi()
                    }
                    Toggle {
                        width: toggles.chipWidth
                        enabled: Bt.available
                        glyph: Bt.enabled ? "󰂯" : "󰂲"
                        label: "Bluetooth"
                        on: Bt.enabled
                        onClicked: Bt.toggle()
                    }
                    Toggle {
                        width: toggles.chipWidth
                        glyph: Notifs.dnd ? "󰂛" : "󰂚"
                        label: "Do not disturb"
                        on: Notifs.dnd
                        onClicked: Notifs.toggleDnd()
                    }
                    Toggle {
                        width: toggles.chipWidth
                        glyph: "󰅶"
                        label: "Stay awake"
                        on: Idle.stayAwake
                        onClicked: Idle.toggleStayAwake()
                    }
                    Toggle {
                        width: toggles.chipWidth
                        visible: nightLight.available
                        glyph: "󰖔"
                        label: "Night light"
                        on: nightLight.running
                        onClicked: nightLight.running = !nightLight.running
                    }
                }
            }
        }
    }

    // ------------------------------------------------------------ columns
    // A vertical hairline between columns, the same rule the bar divides its
    // modules with, at the drawer's scale.
    component Rule: Item {
        implicitWidth: Theme.padL * 2 + 1

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: Theme.padS
            anchors.bottomMargin: Theme.padS
            width: 1
            color: Theme.alpha(Theme.outline, 0.5)
        }
    }

    readonly property real columnHeight: 214

    // A warm screen for the evening, through hyprsunset if it is installed.
    // It runs for as long as night light is on; stopping it restores the
    // screen. The chip only appears when the binary exists.
    Process {
        id: nightLight
        property bool available: false
        command: ["hyprsunset", "--temperature", "4200"]
    }

    Process {
        running: true
        command: ["sh", "-c", "command -v hyprsunset"]
        onExited: code => nightLight.available = code === 0
    }

    // A switch: a pill with a glyph and a name. On is the light slab with ink
    // type, the same as a selection everywhere else; off is a hairline.
    component Toggle: Item {
        id: tg
        property string glyph: ""
        property string label: ""
        property bool on: false
        signal clicked()

        height: 38
        opacity: tg.enabled ? 1 : 0.35

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: tg.on ? Theme.accentSoft : (tgHover.hovered ? Theme.treatmentHoverFill : "transparent")
            border.width: tg.on ? 0 : 1
            border.color: tgHover.hovered ? Theme.treatmentHoverMark : Theme.overlay

            Behavior on color { ColorAnimation { duration: Theme.durBase } }
        }

        Row {
            anchors.centerIn: parent
            spacing: Theme.padS

            Icon {
                anchors.verticalCenter: parent.verticalCenter
                text: tg.glyph
                font.pixelSize: Theme.fsLarge
                color: tg.on ? Theme.ink : (tgHover.hovered ? Theme.accent : Theme.text)
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: tg.label.toUpperCase()
                color: tg.on ? Theme.ink : Theme.subtext
                font.family: Theme.fontDisplay
                font.pixelSize: Theme.fsMicro
                font.weight: Font.DemiBold
                font.letterSpacing: Theme.tracking
                renderType: Text.NativeRendering
            }
        }

        HoverHandler {
            id: tgHover
            enabled: tg.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: tg.enabled
            onTapped: tg.clicked()
        }
    }

    // A label and its reading on one line, label left, reading right.
    component Fact: Item {
        property string label: ""
        property string value: ""

        width: parent.width
        implicitHeight: 14

        Text {
            anchors.left: parent.left
            text: parent.label
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            font.letterSpacing: 2
            renderType: Text.NativeRendering
        }

        Text {
            anchors.right: parent.right
            text: parent.value
            color: Theme.text
            font.family: Theme.fontMono
            font.pixelSize: Theme.fsMicro
            renderType: Text.NativeRendering
        }
    }

    // A round hairline button. Hover lifts it; nothing here inverts, since
    // inversion is reserved for the keyboard's cursor.
    component Transport: Item {
        id: tb
        property string glyph: ""
        signal clicked()

        width: 30
        height: 30
        opacity: tb.enabled ? 1 : 0.35

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: tbHover.hovered ? Theme.treatmentHoverFill : "transparent"
            border.width: 1
            border.color: tbHover.hovered ? Theme.treatmentHoverMark : Theme.overlay

            Behavior on color { ColorAnimation { duration: Theme.durFast } }
        }

        Icon {
            anchors.centerIn: parent
            text: tb.glyph
            color: tbHover.hovered ? Theme.accent : Theme.text
        }

        HoverHandler {
            id: tbHover
            enabled: tb.enabled
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            enabled: tb.enabled
            onTapped: tb.clicked()
        }
    }
}
