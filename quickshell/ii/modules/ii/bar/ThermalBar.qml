import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + 4 * 2
    implicitHeight: Appearance.sizes.barHeight

    property int cpuTemp: 0
    property int gpuTemp: 0

    function tempColor(t) {
        if (t >= 80) return Appearance.colors.colError
        if (t >= 60) return "#ffb300"
        return Appearance.colors.colPrimary
    }

    component TempMetric: RowLayout {
        required property string symbol
        required property int temperature
        readonly property color metricColor: root.tempColor(temperature)

        spacing: 2

        ClippedFilledCircularProgress {
            id: tempCirc
            Layout.alignment: Qt.AlignVCenter
            lineWidth: Appearance.rounding.unsharpen
            value: Math.max(0, Math.min(1, temperature / 100))
            implicitSize: 26
            colPrimary: metricColor
            accountForLightBleeding: true
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: tempCirc.implicitSize
                height: tempCirc.implicitSize

                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.DemiBold
                    fill: 1
                    text: symbol
                    iconSize: Appearance.font.pixelSize.normal
                    color: Appearance.m3colors.m3onPrimary
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: tempTextMetrics.width
            implicitHeight: tempText.implicitHeight

            TextMetrics {
                id: tempTextMetrics
                text: "100°"
                font.pixelSize: Appearance.font.pixelSize.small
            }

            StyledText {
                id: tempText
                anchors.centerIn: parent
                text: `${temperature}°`
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
            }
        }
    }

    FileView {
        id: cpuTempFile
        path: "/sys/class/hwmon/hwmon1/temp1_input"
    }

    Process {
        id: gpuTempProc
        command: ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: root.gpuTemp = parseInt(text.trim()) || 0
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuTempFile.reload()
            root.cpuTemp = Math.round(parseInt(cpuTempFile.text()) / 1000)
            gpuTempProc.running = false
            gpuTempProc.running = true
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 6

        TempMetric {
            symbol: "bolt"
            temperature: root.cpuTemp
        }

        TempMetric {
            symbol: "developer_board"
            temperature: root.gpuTemp
        }
    }
}
