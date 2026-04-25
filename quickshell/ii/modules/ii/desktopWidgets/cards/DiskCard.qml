pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 14 * 2
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    property var topDirs: []
    property string diskUsed: ""
    property string diskFree: ""
    property string diskTotal: ""
    property string diskUsedPercentLabel: ""
    property real diskUsageRatio: 0
    property real diskTotalBytes: 0

    function usageColor(ratio) {
        if (ratio >= 0.9) return Appearance.colors.colError
        if (ratio >= 0.75) return "#ffb300"
        return Appearance.colors.colPrimary
    }

    function rankColor(index) {
        const palette = [
            "#66e3ff",
            "#4fc3f7",
            "#64b5f6",
            "#81c784",
            "#ffb74d",
        ]
        return palette[Math.min(index, palette.length - 1)]
    }

    function humanSizeToBytes(value) {
        if (!value || value.length === 0) return 0
        const normalized = value.replace(",", ".").trim()
        const match = normalized.match(/^([0-9]+(?:\.[0-9]+)?)([KMGTPE]?)(i?B?)$/i)
        if (!match) return parseFloat(normalized) || 0
        const number = parseFloat(match[1])
        const unit = match[2].toUpperCase()
        const factors = {
            "": 1,
            K: 1024,
            M: 1024 * 1024,
            G: 1024 * 1024 * 1024,
            T: 1024 * 1024 * 1024 * 1024,
            P: 1024 * 1024 * 1024 * 1024 * 1024,
            E: 1024 * 1024 * 1024 * 1024 * 1024 * 1024,
        }
        return number * (factors[unit] ?? 1)
    }

    function formatPercent(value) {
        return (value * 100).toFixed(1) + "%"
    }

    Process {
        id: dfDetail
        command: ["df", "-h", "--output=used,avail,size,pcent", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length >= 2) {
                    const parts = lines[1].trim().split(/\s+/)
                    if (parts.length >= 4) {
                        root.diskUsed = parts[0]
                        root.diskFree = parts[1]
                        root.diskTotal = parts[2]
                        root.diskUsedPercentLabel = parts[3]
                        const used = parseFloat(parts[0])
                        const total = parseFloat(parts[2])
                        if (!isNaN(used) && !isNaN(total) && total > 0) {
                            root.diskUsageRatio = used / total
                        }
                        root.diskTotalBytes = root.humanSizeToBytes(parts[2])
                    }
                }
            }
        }
    }

    Process {
        id: duProc
        command: ["bash", "-c",
            "du -sh /home/* /var /usr /opt 2>/dev/null | sort -rh | head -5"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.topDirs = text.trim().split("\n")
                    .filter(l => l.length > 0)
                    .map(l => {
                        const parts = l.split("\t")
                        const size = parts[0] ?? ""
                        const path = parts[1] ?? ""
                        const name = path.split("/").pop()
                        const bytes = root.humanSizeToBytes(size)
                        const ratio = root.diskTotalBytes > 0 ? bytes / root.diskTotalBytes : 0
                        return { size, name, path, bytes, ratio }
                    })
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            dfDetail.running = false; dfDetail.running = true
            duProc.running = false; duProc.running = true
        }
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        // Header
        RowLayout {
            spacing: 8
            MaterialSymbol {
                text: "storage"
                iconSize: Appearance.font.pixelSize.larger
                color: root.usageColor(root.diskUsageRatio)
                fill: 1
            }
            StyledText {
                text: "Disk"
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer1
            }
            Item { Layout.fillWidth: true }
            StyledText {
                text: root.diskUsed + " / " + root.diskTotal
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: root.usageColor(root.diskUsageRatio)
                font.weight: Font.Medium
            }
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            StyledText {
                text: `Used ${root.diskUsedPercentLabel}`
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: root.usageColor(root.diskUsageRatio)
                font.weight: Font.Medium
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: `Free ${root.diskFree}`
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Appearance.colors.colOutlineVariant; opacity: 0.5 }

        // Top directories
        Repeater {
            model: root.topDirs
            delegate: ColumnLayout {
                required property var modelData
                required property int index
                readonly property color rowColor: root.rankColor(index)
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: modelData.size
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: rowColor
                        font.weight: Font.Medium
                        Layout.preferredWidth: 42
                    }
                    MaterialSymbol {
                        text: "folder"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Qt.rgba(rowColor.r, rowColor.g, rowColor.b, 0.85)
                    }
                    StyledText {
                        text: modelData.name
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: Qt.rgba(rowColor.r, rowColor.g, rowColor.b, 0.9)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    StyledText {
                        text: root.formatPercent(modelData.ratio)
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colOnSurfaceVariant
                        font.weight: Font.Medium
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignRight
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 50
                    Layout.rightMargin: 2
                    implicitHeight: 3
                    radius: 2
                    color: Qt.rgba(rowColor.r, rowColor.g, rowColor.b, 0.18)

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(1, modelData.ratio))
                        height: parent.height
                        radius: parent.radius
                        color: rowColor
                    }
                }
            }
        }
    }
}
