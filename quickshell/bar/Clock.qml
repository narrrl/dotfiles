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
                font.letterSpacing: 2.5
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

        Skew {
            anchors.verticalCenter: parent.verticalCenter
            width: 2
            height: 22
            color: Theme.alpha(Theme.accent, 0.6)
        }

        SplitText {
            id: timeText
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            pixelSize: Theme.fsTitle
            split: 1.4
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
