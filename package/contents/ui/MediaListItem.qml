/*
 *  SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtMultimedia
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid

PlasmaComponents3.ItemDelegate {
    id: listItem

    property bool isTry: false

    width: parent ? parent.width : 0
    clip: true

    background: KSvg.FrameSvgItem {
        imagePath: "widgets/viewitem"
        prefix: (stationView.currentIndex === model.index && isPlaying() || listItem.hovered ? "hover" : "normal")
        anchors.fill: parent
        opacity: stationView.currentIndex === model.index && isPlaying() && playMusic.status === MediaPlayer.Buffered ? 1 : 0.5
    }

    contentItem: RowLayout {
        id: listItemLayout

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignLeft
        implicitHeight: Kirigami.Units.gridUnit + Kirigami.Units.smallSpacing
        clip: true

        Kirigami.Icon {
            id: listIcon

            // colorGroup: PlasmaCore.ColorScope.colorGroup
            source: stationView.currentIndex === model.index && listItem.hovered && isPlaying() ? "media-playback-stop" : "media-playback-start"
            implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
            implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
            visible: !tryToPlayIndicator.visible && listItem.hovered || stationView.currentIndex === model.index && playMusic.bufferProgress === 1
        }

        PlasmaComponents3.Label {
            Layout.minimumWidth: Kirigami.Units.iconSizes.sizeForLabels
            Layout.preferredHeight: Kirigami.Units.iconSizes.sizeForLabels
            width: height
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: model.index + 1
            visible: !listIcon.visible && !tryToPlayIndicator.visible
        }

        PlasmaComponents3.BusyIndicator {
            id: tryToPlayIndicator

            running: visible
            visible: isPlaying() && stationView.currentIndex === model.index && playMusic.mediaStatus != MediaPlayer.BufferedMedia
            implicitWidth: Kirigami.Units.iconSizes.sizeForLabels
            implicitHeight: Kirigami.Units.iconSizes.sizeForLabels
        }

        Rectangle {
            id: trackRect

            Layout.fillWidth: true
            height: parent.height
            clip: true
            color: "transparent"

            PlasmaComponents3.Label {
                id: trackName

                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                anchors.verticalCenter: parent.verticalCenter
                text: model.name
                font.weight: stationView.currentIndex === model.index && isPlaying() && playMusic.status === MediaPlayer.BufferedMedia ? Font.Bold : Font.Normal
                maximumLineCount: 1
                elide: Text.ElideRight

                XAnimator {
                    target: trackName
                    from: 0
                    to: -trackName.width
                    duration: Math.round(Math.abs(to - from) / Kirigami.Units.gridUnit * 300 * Plasmoid.configuration.speedfactor)
                    running: listItem.hovered && trackName.width > trackRect.width
                    loops: 1
                    onFinished: {
                        from = trackRect.width;
                        if (listItem.hovered)
                            start();

                    }
                    onStopped: {
                        from = 0;
                        trackName.x = 0;
                    }
                }

            }

        }

        TapHandler {
            target: listItemLayout
            onTapped: {
                isError = false;
                errorTimer.stop();
                stationView.currentIndex = model.index;
                refreshServer(model.index);
                lastPlay = model.index;
            }
        }

    }

}
