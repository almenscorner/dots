import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 16 * 2
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    property var now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: 2

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatTime(root.now, "HH:mm:ss")
            font.pixelSize: 48
            font.weight: Font.Light
            color: Appearance.colors.colPrimary
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDate(root.now, "dddd, MMMM d")
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}
