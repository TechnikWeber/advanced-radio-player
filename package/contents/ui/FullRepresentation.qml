import QtMultimedia
/*
 *  SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmaExtras.Representation {
    id: fullRepresentation

    readonly property var appletInterface: Plasmoid.self

    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 18
    Layout.maximumWidth: Kirigami.Units.gridUnit * 32
    Layout.maximumHeight: Kirigami.Units.gridUnit * 36
    Layout.preferredHeight: Layout.minimumHeight
    collapseMarginsHint: true

    PlasmaComponents3.SwipeView {
        id: swipeView

        currentIndex: root.view
        anchors.fill: parent
        clip: true

        PlasmaComponents3.ScrollView {
            //  contentWidth: availableWidth - contentItem.leftMargin - contentItem.rightMargin

            id: scrollView

            // anchors.fill: parent
            topPadding: Kirigami.Units.smallSpacing
            bottomPadding: Kirigami.Units.smallSpacing
            PlasmaComponents3.ScrollBar.horizontal.policy: PlasmaComponents3.ScrollBar.AlwaysOff
            PlasmaComponents3.ScrollBar.vertical.policy: Plasmoid.userBackgroundHints !== PlasmaCore.Types.ShadowBackground || Plasmoid.formFactor !== PlasmaCore.Types.Planar ? PlasmaComponents3.ScrollBar.AsNeeded : PlasmaComponents3.ScrollBar.AlwaysOff

            contentItem: ListView {
                id: stationView

                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
                model: stationsModel
                enabled: isConnected
                focus: true
                currentIndex: 0
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                Connections {
                    function onErrorOccurred() {
                        stationView.currentIndex = -1;
                    }

                    target: playMusic
                }

                delegate: MediaListItem {
                }

            }

        }

        ColumnLayout {
            Item {
                Layout.fillHeight: true
            }

            Kirigami.ShadowedImage {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                source: root.imageurl
                visible: status == Image.Ready
                width: Kirigami.Units.gridUnit * 10
                height: Kirigami.Units.gridUnit * 10
            }

            Kirigami.Heading {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: root.title.indexOf('-') > -1 ? root.title.split("-")[0].trim() : ""
            }

            Kirigami.Heading {
                Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                text: root.title.indexOf('-') > -1 ? root.title.split("-")[1].trim() : ""
            }

            Item {
                Layout.fillHeight: true
            }

        }

    }

    header: PlasmaExtras.PlasmoidHeading {
        id: header

        focus: true
        height: Kirigami.Units.gridUnit * 2
        // hide for shadow background on desktop
        background.visible: Plasmoid.userBackgroundHints !== PlasmaCore.Types.ShadowBackground

        Heading {
        }

    }

    footer: PlasmaExtras.PlasmoidHeading {
        background.visible: Plasmoid.userBackgroundHints !== PlasmaCore.Types.ShadowBackground

        RowLayout {
            Rectangle {
                implicitWidth: fullRepresentation.width
                width: fullRepresentation.width
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                Layout.preferredHeight: childrenRect.height
                color: "transparent"

                PlasmaComponents3.Label {
                    id: subtext

                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font: PlasmaCore.Theme.smallestFont
                    elide: Text.ElideRight
                    clip: true
                    color: {
                        if (isError || !isConnected)
                            return Kirigami.Theme.negativeTextColor;
                        else if (Plasmoid.userBackgroundHints === PlasmaCore.Types.ShadowBackground)
                            return Kirigami.Theme.highlightedTextColor;
                        else
                            return Kirigami.Theme.textColor;
                    }
                    text: {
                        if (!isConnected)
                            return i18n("Check internet connection…");
                        else if (root.isError)
                            return i18n("Error: ") + playMusic.errorString;
                        else if (isPlaying() && playMusic.mediaStatus === MediaPlayer.BufferedMedia)
                            return i18n("Bitrate: ") + Math.round(playMusic.metaData.value(MediaMetaData.AudioBitRate) / 1000) + 'Kb/s';
                        else if (playMusic.bufferProgress < 1 && playMusic.mediaStatus !== MediaPlayer.NoMedia && isPlaying())
                            return i18n("Buffering…") + ' ' + Math.round(playMusic.bufferProgress * 100) + "%";
                        else
                            return i18n("Choose station and enjoy…");
                    }
                }

            }

        }

    }

}
