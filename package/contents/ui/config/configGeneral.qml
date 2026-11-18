import ".." as ARP
import Qt.labs.platform as Labs
/*
* SPDX-FileCopyrightText: 2022-2023 Yuri Saurov <dr@i-glu4it.ru>
* SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
*
* SPDX-License-Identifier: LGPL-2.0-or-later
*/
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.plasmoid

KCM.ScrollViewKCM {
    id: root

    property string cfg_servers: plasmoid.configuration.servers
    property int dialogMode: -1

    function fileUtils(fileUrl, text, mode) {
        // mode is type of work - open/save
        var file = fileUrl.toString().replace("file:///", "/");
        if (mode === 1) {
            var escapedText = text.replace(/'/g, "'\\''");
            executable.exec("echo '" + escapedText + "' > " + file + " && cat " + file);
        } else {
            executable.exec("cat " + file);
        }
    }

    function showMessage(positive, text) {
        importexportmessage.positive = positive;
        importexportmessage.text = text;
        importexportmessage.visible = true;
        closetimer.restart();
    }

    function getServersArray() {
        var serversArray = [];
        for (var i = 0; i < stationsModel.count; i++) {
            serversArray.push(stationsModel.get(i));
        }
        return serversArray;
    }

    function addServer() {
        dialogMode = -1;
        serverName.text = "";
        serverHostname.text = "";
        serverActive.checked = true;
        serverDialog.visible = true;
    }

    function editServer() {
        dialogMode = mainList.currentIndex;
        serverName.text = stationsModel.get(dialogMode).name;
        serverHostname.text = stationsModel.get(dialogMode).hostname;
        serverActive.checked = stationsModel.get(dialogMode).active;
        serverDialog.visible = true;
    }

    Component.onCompleted: {
        stationsModel.clear();
        var servers = JSON.parse(cfg_servers);
        for (const server of servers) {
            stationsModel.append(server);
        }
    }

    Component {
        id: delegateComponent

        Item {
            id: listItem

            required property int index
            required property var model
            required property bool active
            required property string name

            width: mainList.width
            height: swipeListItem.height

            Kirigami.SwipeListItem {
                id: swipeListItem

                down: false
                alternatingBackground: true
                Kirigami.Theme.inherit: true
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                hoverEnabled: true
                separatorVisible: true
                actions: [
                    Kirigami.Action {
                        icon.name: "edit-entry"
                        text: i18n("Edit")
                        onTriggered: {
                            listItem.ListView.view.currentIndex = listItem.index;
                            editServer();
                        }
                    },
                    Kirigami.Action {
                        icon.name: checked ? "view-visible" : "view-hidden"
                        text: checked ? i18n("Hide") : i18n("Show")
                        checked: listItem.active
                        checkable: true
                        onTriggered: {
                            listItem.model.active = checked;
                            cfg_servers = JSON.stringify(getServersArray());
                        }
                    },
                    Kirigami.Action {
                        icon.name: "delete"
                        text: i18n("Remove")
                        onTriggered: {
                            stationsModel.remove(listItem.index);
                            cfg_servers = JSON.stringify(getServersArray());
                        }
                    }
                ]

                contentItem: RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        Layout.preferredWidth: listCounterMetrics.advanceWidth
                        horizontalAlignment: Text.AlignHCenter
                        LayoutMirroring.enabled: false
                        text: listItem.index + 1
                        color: swipeListItem.textColor
                        Component.onCompleted: {
                            listCounterMetrics.font = font;
                        }
                    }

                    Kirigami.ListItemDragHandle {
                        listItem: swipeListItem
                        listView: listItem.ListView.view
                        onMoveRequested: {
                            stationsModel.move(oldIndex, newIndex, 1);
                            cfg_servers = JSON.stringify(getServersArray());
                        }
                    }

                    Item {
                        id: trackRect

                        clip: true
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        QQC2.Label {
                            id: trackName

                            anchors.verticalCenter: parent.verticalCenter
                            text: listItem.name
                            color: swipeListItem.textColor

                            XAnimator {
                                target: trackName
                                from: 0
                                to: -trackName.paintedWidth
                                duration: Math.round(Math.abs(to - from) / Kirigami.Units.gridUnit * 300 * plasmoid.configuration.speedfactor)
                                running: swipeListItem.containsMouse && trackName.width > trackRect.width
                                loops: 1
                                onFinished: {
                                    from = trackRect.width;
                                    if (listItem.containsMouse)
                                        start();

                                }
                                onStopped: {
                                    from = 0;
                                    trackName.x = 0;
                                }
                            }

                        }

                    }

                }

            }

        }

    }

    ARP.StationsModel {
        id: stationsModel
    }

    TextMetrics {
        id: listCounterMetrics

        text: ''.padStart(Math.max(0, mainList.count - 1).toString().length, '9')
    }

    Kirigami.Dialog {
        id: serverDialog

        title: dialogMode === -1 ? i18n("Add Station") : i18n("Edit station")
        padding: Kirigami.Units.largeSpacing
        standardButtons: QQC2.Dialog.Ok | QQC2.Dialog.Cancel
        onOpened: serverName.forceActiveFocus(Qt.MouseFocusReason)
        onAccepted: {
            const itemObject = {
                "name": serverName.text,
                "hostname": serverHostname.text,
                "active": serverActive.checked
            };
            if (dialogMode === -1)
                stationsModel.append(itemObject);
            else
                stationsModel.set(dialogMode, itemObject);
            cfg_servers = JSON.stringify(getServersArray());
        }

        ColumnLayout {
            Kirigami.FormLayout {
                QQC2.TextField {
                    id: serverName

                    Kirigami.FormData.label: i18n("Name:")
                }

                QQC2.TextField {
                    id: serverHostname

                    Kirigami.FormData.label: i18n("URL:")
                }

                QQC2.CheckBox {
                    id: serverActive

                    checked: true
                    text: i18n("Active")
                }

            }

        }

    }

    Labs.FileDialog {
        id: openFileDialog

        nameFilters: ["ARP Stations Backup (*.arp)"]
        fileMode: Labs.FileDialog.OpenFile
        folder: Labs.StandardPaths.writableLocation(Labs.StandardPaths.HomeLocation)
        onAccepted: {
            fileUtils(currentFile, cfg_servers, 0);
        }
    }

    Labs.FileDialog {
        id: saveFileDialog

        nameFilters: ["ARP Stations Backup (*.arp)"]
        folder: Labs.StandardPaths.writableLocation(Labs.StandardPaths.HomeLocation)
        fileMode: Labs.FileDialog.SaveFile
        onVisibleChanged: {
            if (visible) {
                const home = Labs.StandardPaths.writableLocation(Labs.StandardPaths.HomeLocation);
                currentFile = "file: ///" + home + "/stations.arp";
            }
        }
        onAccepted: fileUtils(currentFile, cfg_servers, 1)
    }

    P5Support.DataSource {
        id: executable

        signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)

        function exec(cmd) {
            if (cmd)
                connectSource(cmd);

        }

        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            var exitCode = data["exit code"];
            var exitStatus = data["exit status"];
            var stdout = data["stdout"];
            var stderr = data["stderr"];
            exited(sourceName, exitCode, exitStatus, stdout, stderr);
            disconnectSource(sourceName);
        }
    }

    Connections {
        //   }

        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            var formattedText = stdout.trim();
            if (cmd.startsWith("cat")) {
                //   if (formattedText != cfg_servers) {
                try {
                    const servers = JSON.parse(formattedText);
                    stationsModel.clear();
                    for (const srv of servers) {
                        stationsModel.append(srv);
                    }
                    cfg_servers = JSON.stringify(getServersArray());
                    showMessage(true, i18n("Сonfiguration has been loaded. Click 'Apply' to save changes."));
                } catch (e) {
                    showMessage(false, i18n("Error loading configuration. Try choosing a different file."));
                }
            } else {
                if (formattedText === cfg_servers)
                    showMessage(true, i18n("You сonfiguration saved successfully."));
                else
                    showMessage(false, i18n("Error, make sure the selected directory is writable!"));
            }
            importexportmessage.visible = true;
            closetimer.restart();
        }

        target: executable
    }

    view: ListView {
        id: mainList

        focus: true
        model: stationsModel
        reuseItems: true
        delegate: delegateComponent

        moveDisplaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

        }

    }

    footer: ColumnLayout {
        Kirigami.InlineMessage {
            id: importexportmessage

            property bool positive

            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing
            Layout.topMargin: Kirigami.Units.largeSpacing
            visible: false
            showCloseButton: true
            type: positive ? Kirigami.MessageType.Positive : Kirigami.MessageType.Error
        }

        Timer {
            id: closetimer

            running: false
            repeat: false
            interval: 10000
            onTriggered: {
                importexportmessage.visible = false;
            }
        }

        RowLayout {
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                text: i18n("Add…")
                icon.name: "list-add"
                onClicked: addServer()
            }

            Item {
                Layout.fillWidth: true
            }

            QQC2.Button {
                text: i18n("Import…")
                icon.name: "document-import"
                onClicked: openFileDialog.open()
            }

            QQC2.Button {
                text: i18n("Export…")
                icon.name: "document-export"
                onClicked: saveFileDialog.open()
            }

        }

    }

}
