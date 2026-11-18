/*
 *  SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    property alias cfg_lastplay: middleLastPlay.checked
    property alias cfg_speedfactor: slider.speedFactor

Kirigami.FormLayout {

    Item {
        Kirigami.FormData.label: i18n("Behavior")
        Kirigami.FormData.isSection: true
    }

    ColumnLayout {
        Kirigami.FormData.label: i18n("Animation speed:")
        Kirigami.FormData.buddyFor: slider

        QQC2.Slider {
            id: slider
            property double speedFactor
            Layout.fillWidth: true
            from: -1.5
            to: 1.5
            stepSize: 0.25
            snapMode: QQC2.Slider.SnapAlways
            value: -(Math.log(speedFactor) / Math.log(2))
            onMoved: {
                speedFactor = 1.0 / Math.pow(2, value)
            }
        }

        RowLayout {
            QQC2.Label {
                text: i18n("Slower")
            }
            Item {
                Layout.fillWidth: true
            }
            QQC2.Label {
                text: i18n("Faster")
            }
        }
    }

    Kirigami.Separator {
        Kirigami.FormData.isSection: true
    }

    Item {
        Kirigami.FormData.label: i18n("Panel settings")
        Kirigami.FormData.isSection: true
    }

    Item {
        Kirigami.FormData.isSection: true
    }

    // KIconThemes.IconDialog {
    //     id: iconDialog

    //     property var iconObj
    //     property QQC2.Button button

    //     iconSize: Kirigami.Units.iconSizes.smallMedium //Must specify the size directly - alias don't work
    //     onIconNameChanged: iconObj.name = iconName
    // }

    // RowLayout {
    //     Kirigami.FormData.label: i18n("Plasmoid Icon:")

    //     visible: !panelview.checked
    //     enabled: plasmoid.formFactor !== PlasmaCore.Types.Planar

    //     QQC2.Button {
    //         id: mainIconName

    //         QQC2.ToolTip.visible: hovered
    //         QQC2.ToolTip.text: i18n("Select Icon…")

    //         icon.width: iconSize
    //         icon.height: iconSize

    //         onClicked: {
    //             iconDialog.button = mainIconName
    //             iconDialog.open()
    //             iconDialog.iconObj = iconDialog.button.icon
    //         }
    //     }

    //     QQC2.Button {
    //         QQC2.ToolTip.visible: hovered
    //         QQC2.ToolTip.text: i18n("Set Default")

    //         icon.name: "edit-clear"
    //         icon.width: iconSize
    //         icon.height: iconSize

    //         onClicked: mainIconName.icon.name = "audio-radio"
    //     }
    // }

    // RowLayout {
    //     Kirigami.FormData.label: i18n("Indicator Icon:")

    //     visible: !panelview.checked
    //     enabled: plasmoid.formFactor !== PlasmaCore.Types.Planar

    //     QQC2.Button {
    //         id: indicatorIconName

    //         QQC2.ToolTip.visible: hovered
    //         QQC2.ToolTip.text: i18n("Select Icon…")

    //         icon.width: iconSize
    //         icon.height: iconSize
    //         visible: !panelview.checked

    //         onClicked: {
    //             iconDialog.button = indicatorIconName
    //             iconDialog.open()
    //             iconDialog.iconObj = iconDialog.button.icon
    //         }
    //     }

    //     QQC2.Button {
    //         QQC2.ToolTip.visible: hovered
    //         QQC2.ToolTip.text: i18n("Set Default")

    //         icon.name: "edit-clear"
    //         icon.width: iconSize
    //         icon.height: iconSize

    //         onClicked: indicatorIconName.icon.name = "media-default-track"
    //     }
    // }

    // function openDialog(button) {
    //     iconDialog.open()
    //     iconDialog.iconObj = button.icon
    // }

    // QQC2.Button {
    //     id: indicator

    //     Kirigami.FormData.label: i18n("Indicator Position:")

    //     visible: !panelview.checked
    //     enabled: plasmoid.formFactor !== PlasmaCore.Types.Planar

    //     icon.width: iconSize
    //     icon.height: iconSize
    //     icon.name: "snap-bounding-box-corners"

    //     transform: Rotation {
    //         angle: cfg_indicatorIndex * 90
    //         origin.x: indicator.width / 2
    //         origin.y: indicator.height / 2
    //     }
    //     onClicked: {
    //         if (cfg_indicatorIndex === 3) {
    //             cfg_indicatorIndex = 0
    //         } else {
    //             cfg_indicatorIndex += 1
    //         }
    //     }
    // }

    // Item {
    //     Kirigami.FormData.isSection: true
    // }

    QQC2.CheckBox {
        id: middleLastPlay

        text: i18n("Use middle button")
        enabled: plasmoid.formFactor !== PlasmaCore.Types.Planar

        QQC2.ToolTip.visible: hovered
        QQC2.ToolTip.text: i18n("Use middle click for play last playing station")
    }
}
}
