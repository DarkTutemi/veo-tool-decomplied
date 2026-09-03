import QtQuick
import QtMultimedia

// One decoder. No app-level video cache. bindSource() always stops + detaches
// the previous file before opening the next; teardown() is the close path.
Item {
    id: root

    property bool muted: false
    signal failed()

    function teardown() {
        player.stop()
        player.source = ""
        player.videoOutput = null
    }

    function bindSource(url) {
        teardown()
        var next = url || ""
        if (String(next).length === 0)
            return
        player.videoOutput = videoOut
        player.source = next
        player.play()
    }

    MediaPlayer {
        id: player
        audioOutput: AudioOutput { muted: root.muted; volume: 1.0 }
        loops: MediaPlayer.Infinite
        onErrorOccurred: root.failed()
    }

    VideoOutput {
        id: videoOut
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit
    }

    Component.onDestruction: root.teardown()
}
