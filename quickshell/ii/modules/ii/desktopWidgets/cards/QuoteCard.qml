import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: Math.max(content.implicitHeight + 14 * 2, 128)
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    property string quoteText: "…"
    property string quoteAuthor: ""

    function fetchQuote() {
        fetchProc.running = false
        fetchProc.running = true
    }

    Process {
        id: fetchProc
        command: ["curl", "-sf", "--max-time", "8", "https://zenquotes.io/api/random"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim())
                    if (data && data[0]) {
                        root.quoteText = data[0].q
                        root.quoteAuthor = data[0].a
                    }
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 1800000  // 30 minutes
        running: true
        repeat: true
        onTriggered: root.fetchQuote()
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 6

        MaterialSymbol {
            text: "format_quote"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colPrimary
            opacity: 0.7
        }

        StyledText {
            Layout.fillWidth: true
            text: root.quoteText
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            wrapMode: Text.WordWrap
            font.italic: true
        }

        StyledText {
            visible: root.quoteAuthor.length > 0
            Layout.alignment: Qt.AlignRight
            text: "— " + root.quoteAuthor
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}
