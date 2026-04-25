import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 14 * 2
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        // Volume
        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            RippleButton {
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: Appearance.rounding.full
                toggled: Audio.sink?.audio?.muted ?? false
                colBackground: "transparent"
                colBackgroundHover: Appearance.colors.colLayer2
                colRipple: Appearance.colors.colLayer2Active
                colBackgroundToggled: Appearance.colors.colSecondaryContainer
                onPressed: if (Audio.sink) Audio.sink.audio.muted = !Audio.sink.audio.muted

                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: (Audio.sink?.audio?.muted ?? false) ? "volume_off"
                        : (Audio.sink?.audio?.volume ?? 0) > 0.5 ? "volume_up"
                        : (Audio.sink?.audio?.volume ?? 0) > 0 ? "volume_down"
                        : "volume_mute"
                    iconSize: Appearance.font.pixelSize.larger
                    color: (Audio.sink?.audio?.muted ?? false)
                        ? Appearance.m3colors.m3onSecondaryContainer
                        : Appearance.colors.colPrimary
                }
            }

            StyledSlider {
                id: volumeSlider
                Layout.fillWidth: true
                from: 0; to: 1
                value: Audio.sink?.audio?.volume ?? 0
                onMoved: {
                    if (Audio.sink) Audio.sink.audio.volume = value
                }
            }

            StyledText {
                text: Math.round((Audio.sink?.audio?.volume ?? 0) * 100) + "%"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Appearance.colors.colOutlineVariant; opacity: 0.5 }

        // Network
        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            MaterialSymbol {
                text: Network.materialSymbol
                iconSize: Appearance.font.pixelSize.larger
                color: Appearance.colors.colPrimary
                fill: 1
            }

            StyledText {
                text: Network.networkName.length > 0 ? Network.networkName : "Disconnected"
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            StyledText {
                visible: Network.wifi
                text: (Network.active?.strength ?? 0) + "%"
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
            }
        }
    }
}
