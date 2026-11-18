import QtMultimedia
/*
 *  SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

MouseArea {
    id: panelIconWidget

    property int wheelDelta: 0

    function setToolTip() {
        tooltip.mainText = Plasmoid.title;
        tooltip.subText = Plasmoid.metaData.description;
        tooltip.icon = "";
    }

    function setVolumeIcon(volume) {
        let suffix;
        if (volume <= 0)
            suffix = "-muted";
        else if (volume <= 0.25)
            suffix = "-low";
        else if (volume <= 0.75)
            suffix = "-medium";
        else
            suffix = "-high";
        return "audio-volume" + suffix;
    }

    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
    hoverEnabled: true
    onClicked: (mouse) => {
        if (mouse.button === Qt.MiddleButton) {
            if (Plasmoid.configuration.lastplay)
                refreshServer(lastPlay);

        } else {
            root.expanded = !root.expanded;
        }
    }
    onWheel: (wheel) => {
        volumeTimer.restart();
        const delta = wheel.angleDelta.y || wheel.angleDelta.x;
        wheelDelta += delta;
        while (wheelDelta >= 120) {
            wheelDelta -= 120;
            if (playMusicOutput.volume < 1)
                playMusicOutput.volume += 0.05;

        }
        while (wheelDelta <= -120) {
            wheelDelta += 120;
            if (playMusicOutput.volume > 0)
                playMusicOutput.volume -= 0.05;

        }
        tooltip.mainText = playMusicOutput.volume === 0 ? i18n("Audio") : i18n("Volume");
        tooltip.subText = playMusicOutput.volume === 0 ? i18n("Muted") : Math.round(playMusicOutput.volume * 100) + "%";
        tooltip.icon = setVolumeIcon(playMusicOutput.volume);
    }
    onEntered: {
        tooltip.showToolTip();
    }

    Kirigami.Icon {
        source: Plasmoid.configuration.icon
        fallback: Plasmoid.configuration.iconFallback
        anchors.fill: parent
        isMask: true
        color: isPlaying() ? Kirigami.Theme.positiveTextColor : Kirigami.Theme.textColor
    }

    PlasmaCore.ToolTipArea {
        id: tooltip

        anchors.horizontalCenter: parent.horizontalCenter
        onAboutToShow: {
            setToolTip();
        }
    }

    Timer {
        id: volumeTimer

        running: false
        repeat: false
        interval: Kirigami.Units.humanMoment
        onTriggered: {
            setToolTip();
        }
    }

}
