/*
 *  SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami

RowLayout {
    spacing: infoButton.visible || backButton.visible ? Kirigami.Units.smallSpacing : 0
    clip: true
    PlasmaComponents3.ToolButton {
        id: backButton
        display: PlasmaComponents3.AbstractButton.IconOnly
        Kirigami.Theme.inherit: Plasmoid.userBackgroundHints === PlasmaCore.Types.ShadowBackground ? false : true
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        implicitWidth: visible ? Kirigami.Units.iconSizes.medium : 0
        flat: true
        icon.name: "arrow-left"
        visible: root.view == 1
        onClicked: root.view = 0
    }

    Rectangle {

        Layout.preferredWidth: Plasmoid.configuration.panel && Plasmoid.formFactor !== PlasmaCore.Types.Planar
        ? textMetrics.boundingRect.width + Kirigami.Units.smallSpacing * 2
        : infoButton.visible  || backButton.visible ? fullRepresentation.width - infoButton.width - backButton.width - Kirigami.Units.smallSpacing : fullRepresentation.width

        implicitHeight: Plasmoid.configuration.panel && Plasmoid.formFactor !== PlasmaCore.Types.Planar
        ? parent.height : backButton.height

        color: "transparent"
        border.color: Plasmoid.configuration.border
        && Plasmoid.configuration.panel
        && Plasmoid.formFactor !== PlasmaCore.Types.Planar
        ? PlasmaCore.ColorScope.textColor : "transparent"

        radius: Kirigami.Units.smallSpacing
        clip: true

        onWidthChanged: {
            if (isPlaying() && root.title !== Plasmoid.title) {
                calculateAnimation()
            } else {
                anim.stop()
                heading.x = -heading.width / 2 + width / 2
            }
        }

        onHeightChanged: {
            if (Plasmoid.configuration.panel && Plasmoid.formFactor !== PlasmaCore.Types.Planar) {
                if (textMetrics.boundingRect.height >= height - Kirigami.Units.smallSpacing * 2) {
                    if (heading.level < 5) {
                        heading.level += 1
                    }
                } else {
                    if (heading.level > 1) {
                        heading.level -= 1
                    }
                }
                heading.x = -heading.width / 2 + width / 2
            }
        }

        TextMetrics {
            id: textMetrics
            font.family: Kirigami.Theme.defaultFont.family
            font.pointSize: heading.font.pointSize
            text: Plasmoid.title
        }

       /* PlasmaExtras.Heading {
            id: heading
            color: Plasmoid.userBackgroundHints === PlasmaCore.Types.ShadowBackground
            ? PlasmaCore.ColorScope.highlightedTextColor
            : PlasmaCore.ColorScope.textColor
            anchors.verticalCenter: parent.verticalCenter
            text: root.title
            level: 1
            maximumLineCount: 1
            onTextChanged: {
                if (isPlaying()) {
                    calculateAnimation()
                } else {
                    anim.stop()
                    heading.x = -heading.width / 2 + parent.width / 2
                }
            }

            Component.onCompleted: {
                x = -heading.width / 2 + parent.width / 2
            }
        }*/
        Kirigami.Heading {
            id: heading
            color: Plasmoid.userBackgroundHints === PlasmaCore.Types.ShadowBackground ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.title
            level: 1
            maximumLineCount: 1

            onTextChanged: {
                //console.log("TRY TO ANIMATE")
                if (isPlaying() && root.title !== Plasmoid.title) {
                    calculateAnimation()
                } else {
                    anim.stop()
                    heading.x = -heading.width / 2 + parent.width / 2
                }
            }

            Component.onCompleted: {
                x = -heading.width / 2 + parent.width / 2
            }
        }
    }
    PlasmaComponents3.ToolButton {
        id: infoButton
        implicitWidth: visible ? Kirigami.Units.iconSizes.medium : 0
        flat: true
        display: PlasmaComponents3.AbstractButton.IconOnly
        Kirigami.Theme.inherit: Plasmoid.userBackgroundHints === PlasmaCore.Types.ShadowBackground ? false : true
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        icon.name: "view-media-lyrics"
        visible: root.title !== Plasmoid.title && root.view === 0
        onClicked: root.view = 1
    }

    XAnimator {
        id: anim
        target: heading
        easing.type: Easing.Linear
        duration: Math.round(Math.abs(to - from) / Kirigami.Units.gridUnit
        * 300 * Plasmoid.configuration.speedfactor)
    }

    function calculateAnimation() {
        anim.from = width - infoButton.width - backButton.width
        anim.to = -heading.width
        anim.loops = Animation.Infinite
        anim.restart()
    }

    Connections {
        target: Plasmoid.configuration

        function onSpeedfactorChanged() {
            if (isPlaying()) {
                calculateAnimation()
            }
        }
    }
}
