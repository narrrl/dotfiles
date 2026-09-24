import QtQuick
import Quickshell
import "root:/config"
import "root:/components"
import "root:/popouts"

// Centre-stage clock. Hovering drops the calendar.
BarPill {
    id: root

    required property var screenRef

    accent: Theme.accent
    slash: true
    padding: Theme.padS
    implicitWidth: layout.implicitWidth + contentPad * 2

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    onClicked: calendar.pinned = !calendar.pinned

    Row {
        id: layout
        anchors.centerIn: parent
        spacing: Theme.padM

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: -1

            Text {
                text: Qt.formatDateTime(clock.date, "ddd").toUpperCase()
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.weight: Font.Bold
                font.letterSpacing: 3
                renderType: Text.NativeRendering
            }

            Text {
                text: Qt.formatDateTime(clock.date, "dd MMM").toUpperCase()
                color: Theme.subtext
                font.family: Theme.fontMono
                font.pixelSize: Theme.fsMicro
                font.letterSpacing: 1
                renderType: Text.NativeRendering
            }
        }

        // Declared with room for its own lean, so the slash sits inside the box
        // the Row gave it instead of hanging several px into the date column.
        Skew {
            anchors.verticalCenter: parent.verticalCenter
            width: 22 * Theme.skew + 3
            height: 22
            color: Theme.alpha(Theme.accent, 0.6)
        }

        // Archivo Black's digits are not all the same width, so a clock sized to
        // its own text changed width as the minutes rolled over — 11:11 is
        // several px narrower than 08:48 — and shoved the rest of the bar
        // around. Reserve the widest possible reading and centre inside it.
        TextMetrics {
            id: timeMetrics
            text: "88:88"
            font.family: Theme.fontDisplay
            font.pixelSize: Theme.fsTitle
            font.weight: Theme.weightDisplay
            font.italic: true
            font.letterSpacing: 0.5
        }

        // Archivo Black reserves descender room the time never uses — "12:04"
        // is all cap height — so centring the line box left the digits sitting
        // above everything beside them. Centre the ink instead.
        // `tightBoundingRect` is measured from the baseline, so the ink's top
        // inside the line box is `ascent + ink.y`.
        readonly property real timeInkOffset: {
            const ink = timeMetrics.tightBoundingRect;
            if (ink.height <= 0) return 0;
            const inkCentre = timeFont.ascent + ink.y + ink.height / 2;
            return Math.round(timeMetrics.boundingRect.height / 2 - inkCentre);
        }

        FontMetrics {
            id: timeFont
            font: timeMetrics.font
        }

        SplitText {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: layout.timeInkOffset
            width: timeMetrics.advanceWidth
            text: Qt.formatDateTime(clock.date, "HH:mm")
            pixelSize: Theme.fsTitle
            horizontalAlignment: Text.AlignHCenter
        }

    }

    // Glitch the time on the hour, because it should feel like something happened.
    property int lastHour: -1
    Connections {
        target: clock
        function onDateChanged() {
            const h = clock.date.getHours();
            if (root.lastHour !== -1 && h !== root.lastHour) timeText.glitch();
            root.lastHour = h;
        }
    }

    CalendarPopout {
        id: calendar
        anchorItem: root
        triggerHovered: root.hovered
        clockDate: clock.date
    }
}
