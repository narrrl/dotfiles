import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/services"

// Month grid with the current day slashed in the accent, plus uptime and a couple
// of world clocks.
Popout {
    id: root

    property date clockDate: new Date()

    contentWidth: 320
    contentHeight: 352

    // Month currently on display, as an offset from the real one.
    property int monthOffset: 0

    onShownChanged: if (!shown) monthOffset = 0

    readonly property date viewDate: {
        const d = new Date(root.clockDate);
        d.setDate(1);
        d.setMonth(d.getMonth() + root.monthOffset);
        return d;
    }

    readonly property int viewYear: viewDate.getFullYear()
    readonly property int viewMonth: viewDate.getMonth()

    // Monday-first grid, 6 rows of 7.
    readonly property var cells: {
        const first = new Date(root.viewYear, root.viewMonth, 1);
        const lead = (first.getDay() + 6) % 7;
        const start = new Date(root.viewYear, root.viewMonth, 1 - lead);
        const out = [];
        for (let i = 0; i < 42; i++) {
            const d = new Date(start);
            d.setDate(start.getDate() + i);
            out.push({
                day: d.getDate(),
                inMonth: d.getMonth() === root.viewMonth,
                today: d.toDateString() === root.clockDate.toDateString()
            });
        }
        return out;
    }

    PopoutSurface {
        anchors.fill: parent
        tone: Theme.accent

        PopoutHeader {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            title: Qt.formatDateTime(root.viewDate, "MMMM")
            icon: "󰃭"
            accent: Theme.accent
            subtitle: Qt.formatDateTime(root.viewDate, "yyyy")
        }

        // Month stepper.
        Row {
            anchors.top: header.bottom
            anchors.topMargin: Theme.padS
            anchors.right: parent.right
            spacing: Theme.padS
            z: 2

            StepButton {
                glyph: "󰅁"
                onClicked: root.monthOffset--
            }

            StepButton {
                glyph: "󰅂"
                onClicked: root.monthOffset++
            }
        }

        // Weekday header, clear of the month stepper above it.
        Row {
            id: dayNames
            anchors.top: header.bottom
            anchors.topMargin: 36
            anchors.left: parent.left
            anchors.right: parent.right

            Repeater {
                model: ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]

                Text {
                    required property var modelData
                    required property int index

                    width: dayNames.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    color: index >= 5 ? Theme.subtext : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1
                    renderType: Text.NativeRendering
                }
            }
        }

        Grid {
            id: grid
            anchors.top: dayNames.bottom
            anchors.topMargin: Theme.padS
            anchors.left: parent.left
            anchors.right: parent.right
            columns: 7

            Repeater {
                model: root.cells

                Item {
                    id: cell
                    required property var modelData

                    width: grid.width / 7
                    height: 30

                    // Today gets a leaning accent slab, inked like every selected slab.
                    Skew {
                        anchors.centerIn: parent
                        width: 26
                        height: 26
                        radius: 13
                        visible: cell.modelData.today
                        color: Theme.accent
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.modelData.day
                        color: {
                            if (cell.modelData.today) return Theme.treatmentSelectedText;
                            if (!cell.modelData.inMonth) return Theme.alpha(Theme.muted, 0.45);
                            return Theme.subtext;
                        }
                        font.family: Theme.fontDisplay
                        font.pixelSize: Theme.fsSmall
                        font.weight: cell.modelData.today ? Font.DemiBold : Font.Medium
                        renderType: Text.NativeRendering
                    }
                }
            }
        }

        // Footer: uptime and a second time zone.
        Row {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right

            Column {
                width: parent.width / 2
                spacing: -2

                Text {
                    text: "UPTIME"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1.5
                    renderType: Text.NativeRendering
                }

                Text {
                    text: Sys.uptime
                    color: Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }
            }

            Column {
                width: parent.width / 2
                spacing: -2

                Text {
                    anchors.right: parent.right
                    text: "TOKYO"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsMicro
                    font.letterSpacing: 1.5
                    renderType: Text.NativeRendering
                }

                Text {
                    anchors.right: parent.right
                    text: {
                        // Tokyo is UTC+9 year-round.
                        const utc = root.clockDate.getTime()
                            + root.clockDate.getTimezoneOffset() * 60000;
                        const tokyo = new Date(utc + 9 * 3600000);
                        return Qt.formatDateTime(tokyo, "HH:mm");
                    }
                    color: Theme.primary
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fsSmall
                    font.weight: Font.DemiBold
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    component StepButton: Item {
        id: step

        property string glyph: ""
        signal clicked()

        implicitWidth: 22
        implicitHeight: 22

        Skew {
            anchors.fill: parent
            color: stepHover.hovered ? Theme.treatmentHoverFill : "transparent"
            borderWidth: 1
            borderColor: stepHover.hovered ? Theme.treatmentHoverMark : Theme.alpha(Theme.outline, 0.7)
        }

        Icon {
            anchors.centerIn: parent
            text: step.glyph
            color: stepHover.hovered ? Theme.text : Theme.subtext
            font.pixelSize: Theme.fsBody
        }

        HoverHandler {
            id: stepHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: step.clicked()
        }
    }
}
