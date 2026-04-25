import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight

    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property var prevRx: ({})
    property var prevTx: ({})
    property bool initialized: false

    function formatSpeed(bytesPerSec) {
        if (bytesPerSec >= 1024 * 1024)
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + "M"
        if (bytesPerSec >= 1024)
            return (bytesPerSec / 1024).toFixed(0) + "K"
        return "0K"
    }

    FileView {
        id: netDev
        path: "/proc/net/dev"
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            netDev.reload()
            const lines = netDev.text().trim().split('\n').slice(2)
            const newRx = {}, newTx = {}
            for (const line of lines) {
                const parts = line.trim().split(/\s+/)
                const iface = parts[0].replace(':', '')
                if (iface === 'lo') continue
                newRx[iface] = parseInt(parts[1])
                newTx[iface] = parseInt(parts[9])
            }
            if (root.initialized) {
                let rxDiff = 0, txDiff = 0
                for (const iface of Object.keys(newRx)) {
                    if (root.prevRx[iface] !== undefined)
                        rxDiff += newRx[iface] - root.prevRx[iface]
                }
                for (const iface of Object.keys(newTx)) {
                    if (root.prevTx[iface] !== undefined)
                        txDiff += newTx[iface] - root.prevTx[iface]
                }
                root.downloadSpeed = Math.max(0, rxDiff) / (interval / 1000)
                root.uploadSpeed = Math.max(0, txDiff) / (interval / 1000)
            }
            root.prevRx = newRx
            root.prevTx = newTx
            root.initialized = true
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 6

        RowLayout {
            spacing: 2
            MaterialSymbol {
                text: "arrow_downward"
                iconSize: Appearance.font.pixelSize.larger
                fill: 1
                font.weight: Font.DemiBold
                color: "#4caf50"
            }
            StyledText {
                text: root.formatSpeed(root.downloadSpeed)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
            }
        }

        RowLayout {
            spacing: 2
            MaterialSymbol {
                text: "arrow_upward"
                iconSize: Appearance.font.pixelSize.larger
                fill: 1
                font.weight: Font.DemiBold
                color: "#f44336"
            }
            StyledText {
                text: root.formatSpeed(root.uploadSpeed)
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
            }
        }
    }
}
