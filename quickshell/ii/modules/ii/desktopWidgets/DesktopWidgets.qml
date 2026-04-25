import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules.common
import qs.modules.ii.desktopWidgets.cards

Scope {
    PanelWindow {
        id: win

        visible: false  // delay so compositor registers us after the wallpaper
        Timer {
            interval: 800
            running: true
            onTriggered: win.visible = true
        }

        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:desktopWidgets"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            right: true
        }

        implicitWidth: 720
        implicitHeight: layout.implicitHeight + topPad + 20

        property int topPad: Appearance.sizes.baseBarHeight + Appearance.rounding.screenRounding + 12
        readonly property int columnsGap: 8
        readonly property int leftColumnWidth: 320
        readonly property int rightColumnWidth: layout.width - leftColumnWidth - columnsGap

        ColumnLayout {
            id: layout
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: win.topPad
            width: 700
            spacing: 8

            AppLauncher {}

            RowLayout {
                spacing: win.columnsGap
                Layout.fillWidth: true

                // Left column
                ColumnLayout {
                    spacing: 8
                    Layout.preferredWidth: win.leftColumnWidth
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignTop

                    ClockCard {}
                    MediaCard {}
                    VolumeCard {}
                    QuoteCard {}
                    Item { Layout.fillHeight: true }
                }

                // Right column
                ColumnLayout {
                    spacing: 8
                    Layout.preferredWidth: win.rightColumnWidth
                    Layout.fillWidth: false
                    Layout.alignment: Qt.AlignTop

                    WeatherCard {}
                    CalendarCard {}
                    SysInfoCard {}
                    DiskCard {}
                }
            }
        }
    }
}
