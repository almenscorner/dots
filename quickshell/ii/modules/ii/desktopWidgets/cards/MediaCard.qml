pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 140
    radius: Appearance.rounding.normal
    color: Qt.rgba(Appearance.colors.colLayer1Base.r, Appearance.colors.colLayer1Base.g, Appearance.colors.colLayer1Base.b, 0.86)
    border.width: 1
    border.color: Qt.rgba(Appearance.colors.colOutlineVariant.r, Appearance.colors.colOutlineVariant.g, Appearance.colors.colOutlineVariant.b, 0.88)
    clip: true
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }

    readonly property MprisPlayer activePlayer: MprisController.activePlayer
    readonly property bool playing: activePlayer?.playbackState == MprisPlaybackState.Playing
    readonly property string title: StringUtils.cleanMusicTitle(activePlayer?.trackTitle) || "No media"
    readonly property string artist: activePlayer?.trackArtist ?? ""

    // Album art download
    property string artUrl: activePlayer?.trackArtUrl ?? ""
    property string artFilePath: artUrl.length > 0 ? `${Directories.coverArt}/${Qt.md5(artUrl)}` : ""
    property bool artDownloaded: false
    property string displayedArt: artDownloaded && artFilePath.length > 0 ? Qt.resolvedUrl(artFilePath) : ""

    onArtFilePathChanged: {
        if (artUrl.length === 0) { artDownloaded = false; return }
        artDownloaded = false
        artDownloader.targetUrl = artUrl
        artDownloader.targetPath = artFilePath
        artDownloader.running = true
    }

    Process {
        id: artDownloader
        property string targetUrl: ""
        property string targetPath: ""
        command: ["bash", "-c", `[ -f '${targetPath}' ] || curl -4 -sSL '${targetUrl}' -o '${targetPath}'`]
        onExited: root.artDownloaded = true
    }

    // Cava visualizer
    property list<real> cavaPoints: []

    Process {
        id: cavaProc
        running: root.playing
        onRunningChanged: if (!running) root.cavaPoints = []
        command: ["cava", "-p", `${FileUtils.trimFileProtocol(Directories.scriptPath)}/cava/raw_output_config.txt`]
        stdout: SplitParser {
            onRead: data => {
                root.cavaPoints = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p))
            }
        }
    }

    Timer {
        running: root.playing
        interval: Config.options.resources.updateInterval
        repeat: true
        onTriggered: root.activePlayer?.positionChanged()
    }

    // Blurred art background
    Image {
        id: bgArt
        anchors.fill: parent
        source: root.displayedArt
        fillMode: Image.PreserveAspectCrop
        visible: false
        cache: false
    }
    GaussianBlur {
        id: bgBlur
        anchors.fill: parent
        source: bgArt
        radius: 24
        samples: 49
        visible: root.displayedArt.length > 0
        opacity: 0.25
    }

    // Cava wave
    Canvas {
        id: cavaCanvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            const pts = root.cavaPoints
            if (pts.length < 2 || !root.playing) return
            ctx.beginPath()
            ctx.moveTo(0, height)
            for (let i = 0; i < pts.length; i++) {
                ctx.lineTo(i * width / (pts.length - 1), height - (pts[i] / 1000) * height * 0.6)
            }
            ctx.lineTo(width, height)
            ctx.closePath()
            ctx.fillStyle = Qt.rgba(
                Appearance.colors.colPrimary.r,
                Appearance.colors.colPrimary.g,
                Appearance.colors.colPrimary.b, 0.25)
            ctx.fill()
        }
        Connections {
            target: root
            function onCavaPointsChanged() { cavaCanvas.requestPaint() }
        }
    }

    // Content
    RowLayout {
        anchors {
            fill: parent
            margins: 12
        }
        spacing: 12

        // Album art
        Rectangle {
            implicitWidth: 110
            implicitHeight: 110
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer2
            clip: true

            Image {
                anchors.fill: parent
                source: root.displayedArt
                fillMode: Image.PreserveAspectCrop
                cache: false
            }

            MaterialSymbol {
                visible: root.displayedArt.length === 0
                anchors.centerIn: parent
                text: "music_note"
                iconSize: 40
                color: Appearance.colors.colOnSurfaceVariant
            }
        }

        // Info + controls
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 4

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: Appearance.colors.colOnLayer1
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.artist.length > 0
                text: root.artist
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colOnSurfaceVariant
                elide: Text.ElideRight
            }

            Item { Layout.fillHeight: true }

            // Progress bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: Qt.rgba(Appearance.colors.colPrimary.r,
                               Appearance.colors.colPrimary.g,
                               Appearance.colors.colPrimary.b, 0.2)
                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1,
                        (root.activePlayer?.position ?? 0) / Math.max(1, root.activePlayer?.length ?? 1)))
                    height: parent.height
                    radius: parent.radius
                    color: Appearance.colors.colPrimary
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }

            // Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                component CtrlButton: RippleButton {
                    property string iconName
                    implicitWidth: 32; implicitHeight: 32
                    buttonRadius: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: Appearance.colors.colLayer2
                    colRipple: Appearance.colors.colLayer2Active
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: iconName
                        iconSize: Appearance.font.pixelSize.larger
                        fill: 1
                        color: Appearance.colors.colOnLayer1
                    }
                }

                Item { Layout.fillWidth: true }
                CtrlButton {
                    iconName: "skip_previous"
                    onPressed: root.activePlayer?.previous()
                }
                CtrlButton {
                    iconName: root.playing ? "pause" : "play_arrow"
                    onPressed: root.activePlayer?.togglePlaying()
                }
                CtrlButton {
                    iconName: "skip_next"
                    onPressed: root.activePlayer?.next()
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
