import qs.modules.common
import qs.modules.common.widgets
import qs.services
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

    property real gpuUsage: 0
    property real vramUsage: 0
    property real diskUsage: 0

    component InfoRow: RowLayout {
        property string symbol
        property string label
        property real value
        property color barColor: Appearance.colors.colPrimary
        spacing: 8
        Layout.fillWidth: true

        MaterialSymbol {
            text: symbol
            iconSize: Appearance.font.pixelSize.larger
            fill: 1
            color: barColor
        }

        StyledText {
            text: label
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnSurfaceVariant
            Layout.preferredWidth: 36
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: 3
            color: Qt.rgba(barColor.r, barColor.g, barColor.b, 0.2)
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, value))
                height: parent.height
                radius: parent.radius
                color: barColor
                Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            }
        }

        StyledText {
            text: Math.round(value * 100) + "%"
            font.pixelSize: Appearance.font.pixelSize.small
            color: barColor
            font.weight: Font.Medium
            Layout.preferredWidth: 36
            horizontalAlignment: Text.AlignRight
        }
    }

    Process {
        id: nvidiaSmi
        command: ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total",
                  "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",").map(s => parseFloat(s.trim()))
                if (parts.length >= 3) {
                    root.gpuUsage = parts[0] / 100
                    root.vramUsage = parts[1] / parts[2]
                }
            }
        }
    }

    Process {
        id: dfProc
        command: ["df", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length >= 2) {
                    const parts = lines[1].trim().split(/\s+/)
                    if (parts.length >= 2) root.diskUsage = parseInt(parts[0]) / parseInt(parts[1])
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            nvidiaSmi.running = false; nvidiaSmi.running = true
            dfProc.running = false; dfProc.running = true
        }
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        InfoRow {
            symbol: "bolt"
            label: "CPU"
            value: ResourceUsage.cpuUsage
            barColor: Appearance.colors.colPrimary
        }
        InfoRow {
            symbol: "memory_alt"
            label: "RAM"
            value: ResourceUsage.memoryUsedPercentage
            barColor: Appearance.m3colors.m3secondary
        }
        InfoRow {
            symbol: "sync"
            label: "Swap"
            value: ResourceUsage.swapUsedPercentage
            barColor: Appearance.colors.colTertiary
        }
        InfoRow {
            symbol: "developer_board"
            label: "GPU"
            value: root.gpuUsage
            barColor: "#4caf50"
        }
        InfoRow {
            symbol: "memory"
            label: "VRAM"
            value: root.vramUsage
            barColor: "#ff9800"
        }
        InfoRow {
            symbol: "storage"
            label: "Disk"
            value: root.diskUsage
            barColor: Appearance.colors.colOnSurfaceVariant
        }
    }
}
