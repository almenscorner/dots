import qs.modules.common
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool vertical: false
    property real padding: 10
    implicitWidth: vertical ? Appearance.sizes.baseVerticalBarWidth : (gridLayout.implicitWidth + padding * 2)
    implicitHeight: vertical ? (gridLayout.implicitHeight + padding * 2) : Appearance.sizes.baseBarHeight
    default property alias items: gridLayout.children

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: root.vertical ? 0 : 4
            bottomMargin: root.vertical ? 0 : 4
            leftMargin: root.vertical ? 4 : 0
            rightMargin: root.vertical ? 4 : 0
        }
        color: Config.options?.bar.borderless ? "transparent" : (Config.options?.bar.showBackground ? Appearance.colors.colLayer2 : Appearance.colors.colLayer0)
        border.width: Config.options?.bar.borderless ? 0 : 1
        border.color: Appearance.colors.colOutlineVariant
        radius: Appearance.rounding.small
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        anchors {
            verticalCenter: root.vertical ? undefined : background.verticalCenter
            horizontalCenter: root.vertical ? background.horizontalCenter : undefined
            left: root.vertical ? undefined : background.left
            right: root.vertical ? undefined : background.right
            top: root.vertical ? background.top : undefined
            bottom: root.vertical ? background.bottom : undefined
            leftMargin: root.padding
            rightMargin: root.padding
            topMargin: root.vertical ? root.padding : 0
            bottomMargin: root.vertical ? root.padding : 0
        }
        columnSpacing: 4
        rowSpacing: 12
    }
}