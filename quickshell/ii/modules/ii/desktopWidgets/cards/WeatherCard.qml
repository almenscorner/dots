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

    component MetricRow: RowLayout {
        property string symbol
        property string label
        property string value
        spacing: 6

        MaterialSymbol {
            text: symbol
            iconSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colPrimary
            fill: 1
        }
        StyledText {
            text: label
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnSurfaceVariant
        }
        Item { Layout.fillWidth: true }
        StyledText {
            text: value
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colOnLayer1
            font.weight: Font.Medium
        }
    }

    ColumnLayout {
        id: content
        anchors {
            fill: parent
            margins: 14
        }
        spacing: 10

        // Header: icon + temp + city
        RowLayout {
            spacing: 10

            Text {
                text: Icons.getWeatherEmoji(Weather.data.wCode) ?? "🌡"
                font.pixelSize: 40
            }

            ColumnLayout {
                spacing: 2
                StyledText {
                    text: Weather.data.temp ?? "--°"
                    font.pixelSize: 32
                    font.weight: Font.Light
                    color: Appearance.colors.colPrimary
                }
                StyledText {
                    text: Weather.data.city ?? ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }

            Item { Layout.fillWidth: true }

            ColumnLayout {
                spacing: 2
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike ?? "--")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnSurfaceVariant
                }
                StyledText {
                    Layout.alignment: Qt.AlignRight
                    text: Weather.data.desc ?? ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnLayer1
                }
            }
        }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Appearance.colors.colOutlineVariant; opacity: 0.5 }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 6

            MetricRow { symbol: "wb_sunny";        label: "UV";    value: Weather.data.uv ?? "--"       }
            MetricRow { symbol: "air";             label: "Wind";  value: `(${Weather.data.windDir ?? "-"}) ${Weather.data.wind ?? "--"}` }
            MetricRow { symbol: "rainy_light";     label: "Rain";  value: Weather.data.precip ?? "--"   }
            MetricRow { symbol: "humidity_low";    label: "Humidity"; value: Weather.data.humidity ?? "--" }
            MetricRow { symbol: "wb_twilight";     label: "Sunrise"; value: Weather.data.sunrise ?? "--" }
            MetricRow { symbol: "bedtime";         label: "Sunset";  value: Weather.data.sunset ?? "--"  }
        }
    }
}
