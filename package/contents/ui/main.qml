import Qt.labs.platform as Labs
import QtMultimedia
import QtNetwork
import QtQuick
import org.kde.notification
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    property string title: Plasmoid.title
    property string imageurl: ""
    property string metadata: ""
    property bool isError: false
    property int lastPlay: 0
    property int view: 0
    property bool isConnected: NetworkInformation.reachability === NetworkInformation.Reachability.Online

    function isPlaying() {
        return playMusic.playbackState === MediaPlayer.PlayingState;
    }

    function reloadStationsModel() {
        playMusic.stop();
        stationsModel.clear();
        try {
            const servers = JSON.parse(Plasmoid.configuration.servers);
            for (const server of servers) {
                if (server.active)
                    stationsModel.append(server);

            }
        } catch (e) {
            console.log(e);
        }
    }

    function refreshServer(index) {
        if (isPlaying() && playMusic.source == stationsModel.get(index).hostname && lastPlay === index) {
            infoTimer.stop();
            root.title = Plasmoid.title;
            playMusic.stop();
        } else {
            root.title = Plasmoid.title;
            playMusic.stop();
            playMusic.source = stationsModel.get(index).hostname;
            playMusic.play();
            infoTimer.restart();
        }
    }

    function getStreamInfo(url, metadata) {
        var cmd = "python3  " + Qt.resolvedUrl("reader.py").toString().substring(7) + " '" + url + "' '" + metadata + "'";
        executable.exec(cmd);
    }

    onMetadataChanged: function() {
        if (metadata.length > 0) {
            root.title = metadata.split("::")[0];
            root.imageurl = metadata.split("::")[1];
        } else {
            root.title = Plasmoid.title;
            root.imageurl = "";
        }
    }
    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    Component.onCompleted: {
        reloadStationsModel();
    }

    StationsModel {
        id: stationsModel
    }

    Connections {
        function onServersChanged() {
            playMusic.stop();
            reloadStationsModel();
        }

        target: Plasmoid.configuration
    }

    Connections {
        function onPanelChanged() {
            playMusic.stop();
        }

        target: Plasmoid.configuration
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
        onNewData: function(sourceName, data) {
            const exitCode = data["exit code"];
            const exitStatus = data["exit status"];
            const stdout = data["stdout"];
            const stderr = data["stderr"];
            exited(sourceName, exitCode, exitStatus, stdout, stderr);
            disconnectSource(sourceName);
        }
    }

    Connections {
        function onExited(cmd, exitCode, exitStatus, stdout, stderr) {
            var formattedText = stdout.trim();
            if (isPlaying() && formattedText.length > 0) {
                root.metadata = formattedText;
            } else if (!isPlaying()) {
                root.metadata = "";
                root.title = Plasmoid.title;
            }
        }

        target: executable
    }

    // Follow the system default output (e.g. Bluetooth headphones connected later)
    MediaDevices {
        id: mediaDevices
    }

    MediaPlayer {
        id: playMusic

        onErrorOccurred: {
            isError = true;
            errorTimer.start();
        }
        onPlayingChanged: {
            if (!isPlaying()) {
                playMusic.stop();
                playMusic.source = "";
                root.metadata = "";
            }
        }

        audioOutput: AudioOutput {
            id: playMusicOutput

            device: mediaDevices.defaultAudioOutput
            volume: 0.75
        }

    }

    Timer {
        id: errorTimer

        running: false
        repeat: false
        interval: 5000
        onTriggered: {
            isError = false;
        }
    }

    Timer {
        id: infoTimer

        interval: 3000
        repeat: true
        triggeredOnStart: false
        onTriggered: getStreamInfo(playMusic.source, root.metadata)
    }

    compactRepresentation: CompactRepresentation {
    }

    fullRepresentation: FullRepresentation {
        id: dialogItem

        anchors.fill: parent
        focus: true
    }

}
