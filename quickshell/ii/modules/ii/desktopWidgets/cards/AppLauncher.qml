pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: row.implicitHeight + 10 * 2
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    readonly property var apps: [
        { name: "Spotify",  icon: "spotify",   cmd: "spotify"  },
        { name: "Discord",  icon: "discord",   cmd: "discord"  },
        { name: "Steam",    icon: "steam",     cmd: "steam"    },
        { name: "Firefox",  icon: "firefox",   cmd: "firefox"  },
        { name: "Kitty",    icon: "kitty",     cmd: "kitty"    },
        { name: "Dolphin",  icon: "org.kde.dolphin",   cmd: "dolphin"  },
        { name: "VSCodium", icon: "vscodium",  cmd: "codium"   },
    ]

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.apps
            delegate: RippleButton {
                required property var modelData

                implicitWidth: 48
                implicitHeight: 48
                buttonRadius: Appearance.rounding.small
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2
                colRipple: Appearance.colors.colLayer2Active

                onPressed: Quickshell.execDetached(["bash", "-c", modelData.cmd])

                contentItem: IconImage {
                    anchors.centerIn: parent
                    implicitSize: 38
                    source: `image://icon/${modelData.icon}`
                }
            }
        }
    }
}
