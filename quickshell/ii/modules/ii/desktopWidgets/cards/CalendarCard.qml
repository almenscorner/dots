pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "swedish_holidays.js" as Holidays

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 14 * 2
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    property int monthOffset: 0
    property var viewDate: {
        const d = new Date()
        d.setDate(1)
        d.setMonth(d.getMonth() + root.monthOffset)
        return d
    }
    property var today: new Date()
    property var holidayMap: Holidays.getHolidayMap(root.viewDate.getFullYear())

    onViewDateChanged: {
        root.holidayMap = Holidays.getHolidayMap(root.viewDate.getFullYear())
        root.grid = calendarGrid()
    }

    function calendarGrid() {
        const year = root.viewDate.getFullYear()
        const month = root.viewDate.getMonth()
        const firstDay = new Date(year, month, 1)
        // Mon=0 ... Sun=6
        let startDow = (firstDay.getDay() + 6) % 7
        const daysInMonth = new Date(year, month + 1, 0).getDate()
        const daysInPrev = new Date(year, month, 0).getDate()

        let cells = []
        // Previous month fill
        for (let i = startDow - 1; i >= 0; i--) {
            cells.push({ day: daysInPrev - i, thisMonth: false, isToday: false, holidayName: "" })
        }
        // Current month
        for (let d = 1; d <= daysInMonth; d++) {
            const isToday = (root.monthOffset === 0 &&
                d === root.today.getDate() &&
                month === root.today.getMonth() &&
                year === root.today.getFullYear())
            cells.push({
                day: d,
                thisMonth: true,
                isToday: isToday,
                holidayName: Holidays.getHolidayName(root.holidayMap, month, d)
            })
        }
        // Next month fill to complete 6 rows × 7 cols = 42
        let next = 1
        while (cells.length < 42) cells.push({ day: next++, thisMonth: false, isToday: false, holidayName: "" })
        return cells
    }

    property var grid: calendarGrid()
    onMonthOffsetChanged: root.grid = calendarGrid()
    onTodayChanged: root.grid = calendarGrid()

    // Refresh 'today' at midnight
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.today = new Date()
    }

    MouseArea {
        anchors.fill: parent
        onWheel: (event) => {
            root.monthOffset += event.angleDelta.y < 0 ? 1 : -1
        }
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 6

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            RippleButton {
                implicitWidth: 28; implicitHeight: 28
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2
                colRipple: Appearance.colors.colLayer2Active
                onPressed: root.monthOffset--
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "chevron_left"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }
            }

            StyledText {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.viewDate.toLocaleDateString(Qt.locale(), "MMMM yyyy") +
                      (root.monthOffset !== 0 ? " ●" : "")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer1
            }

            RippleButton {
                implicitWidth: 28; implicitHeight: 28
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2
                colRipple: Appearance.colors.colLayer2Active
                onPressed: root.monthOffset++
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "chevron_right"
                    iconSize: Appearance.font.pixelSize.larger
                    color: Appearance.colors.colOnLayer1
                }
            }

            RippleButton {
                visible: root.monthOffset !== 0
                implicitWidth: 28; implicitHeight: 28
                buttonRadius: Appearance.rounding.full
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2
                colRipple: Appearance.colors.colLayer2Active
                onPressed: root.monthOffset = 0
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "today"
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colPrimary
                }
            }
        }

        // Day-of-week header
        RowLayout {
            Layout.fillWidth: true
            spacing: 0
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                delegate: StyledText {
                    required property string modelData
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
        }

        // Calendar grid: 6 rows × 7 cols
        GridLayout {
            Layout.fillWidth: true
            columns: 7
            columnSpacing: 0
            rowSpacing: 0

            Repeater {
                model: root.grid
                delegate: Item {
                    required property var modelData
                    required property int index
                    Layout.fillWidth: true
                    implicitWidth: 38
                    implicitHeight: 34

                    Rectangle {
                        id: dayCell
                        anchors.centerIn: parent
                        width: 32; height: 32
                        radius: Appearance.rounding.small
                        color: modelData.isToday
                            ? Appearance.colors.colPrimary
                            : "transparent"

                        StyledText {
                            anchors.centerIn: parent
                            text: modelData.day
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: modelData.isToday ? Font.DemiBold : Font.Normal
                            color: modelData.isToday ? Appearance.m3colors.m3onPrimary
                                 : !modelData.thisMonth ? Appearance.colors.colOutlineVariant
                                 : modelData.holidayName.length > 0 ? Appearance.colors.colPrimary
                                 : Appearance.colors.colOnLayer1
                        }

                        // Holiday dot
                        Rectangle {
                            visible: modelData.holidayName.length > 0 && !modelData.isToday
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 4; height: 4; radius: 2
                            color: Appearance.colors.colPrimary
                        }

                        HoverHandler { id: hoverHandler }

                        ToolTip {
                            visible: hoverHandler.hovered && modelData.holidayName.length > 0
                            text: modelData.holidayName
                            delay: 400
                        }
                    }
                }
            }
        }
    }
}
