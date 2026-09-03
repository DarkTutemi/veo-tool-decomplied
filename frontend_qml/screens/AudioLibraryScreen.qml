import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Kho Audio & Series — one place that stores, per account:
//  • SERIES (1 Gemini chat = 1 series): the roadmap of episodes; each episode is
//    produced by a chat follow-up in that same conversation (fresh news, robust).
//  • AUDIO: every produced audio, with push-to-A2V + "đã ra video chưa".
// All fed off-thread from persistent stores → survives app restarts.
Item {
    id: screen
    objectName: "audioLibraryScreen"

    Component.onCompleted: {
        researchController.refreshSeries()
        researchController.refreshAudios()
    }

    // ── formatters / status helpers ─────────────────────────────────────────
    function fmtDur(sec) {
        var s = Math.max(0, Math.round(Number(sec) || 0))
        var m = Math.floor(s / 60)
        var r = s % 60
        return m + ":" + (r < 10 ? "0" + r : r)
    }
    function fmtDate(iso) {
        var s = String(iso || "")
        if (s.length < 16) return s
        return s.slice(0, 10) + " " + s.slice(11, 16)
    }
    function vStatusLabel(s) {
        if (s === "complete") return "✅ Đã có video"
        if (s === "processing") return "⏳ Đang dựng video…"
        if (s === "pushed") return "→ Đã đẩy · chờ dựng"
        if (s === "failed") return "❌ Dựng lỗi"
        return "• Chưa đẩy"
    }
    function vFill(s) {
        if (s === "complete") return VfTheme.greenFill
        if (s === "processing") return VfTheme.amberFill
        if (s === "pushed") return VfTheme.blueFill
        if (s === "failed") return VfTheme.redFill
        return VfTheme.surfaceSoft
    }
    function vText(s) {
        if (s === "complete") return VfTheme.greenText
        if (s === "processing") return VfTheme.amberText
        if (s === "pushed") return VfTheme.blueText
        if (s === "failed") return VfTheme.redText
        return VfTheme.textSubtle
    }
    function epFill(s) {
        if (s === "done") return VfTheme.greenFill
        if (s === "running") return VfTheme.amberFill
        return VfTheme.surfaceSoft
    }
    function epText(s) {
        if (s === "done") return VfTheme.greenText
        if (s === "running") return VfTheme.amberText
        return VfTheme.textSubtle
    }
    function epLabel(s) {
        if (s === "done") return "✅ xong"
        if (s === "running") return "⏳ đang chạy"
        return "• chờ"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(12)

        // ── Header ──────────────────────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(10)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)
                Text {
                    text: "🎧  Kho Audio & Series"
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontTitle
                    font.weight: VfTheme.weightTitle
                }
                Text {
                    text: researchController.seriesCount + " series · " + researchController.audioCount
                        + " audio · tài khoản " + (String(researchController.currentAccount || "").length > 0
                            ? researchController.currentAccount : "(hiện tại)")
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            VfButton {
                text: "↻ Làm mới"
                tone: "neutral"
                onClicked: { researchController.refreshSeries(); researchController.refreshAudios() }
            }
        }

        // ── SERIES section ──────────────────────────────────────────────────
        Text {
            visible: researchController.seriesCount > 0
            text: "📚 Series (mỗi tập tự lấy tin mới nhất trong cùng phiên chat)"
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightStrong
        }

        VfListView {
            id: seriesList
            visible: researchController.seriesCount > 0
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, screen.height * 0.42)
            model: researchController.seriesModel
            spacing: VfTheme.dp(8)

            delegate: Rectangle {
                id: seriesCard
                width: ListView.view ? ListView.view.width : 0
                implicitHeight: seriesCol.implicitHeight + VfTheme.dp(20)
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.violetBorder
                border.width: 1
                readonly property string sid: String((modelData && modelData.series_id) || "")

                ColumnLayout {
                    id: seriesCol
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(6)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(1)
                            Text {
                                Layout.fillWidth: true
                                text: "📺 " + String((modelData && modelData.seed_topic) || "(series)")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSection
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Text {
                                text: (modelData && modelData.done_count || 0) + "/" + (modelData && modelData.episode_count || 0) + " tập đã làm"
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                        VfButton {
                            text: "▶ Chạy tập kế"
                            tone: "success"
                            compact: true
                            tooltip: "Chạy tập chưa làm tiếp theo (chat tiếp lấy tin mới → audio)"
                            onClicked: researchController.runSeriesEpisode(seriesCard.sid, 0)
                        }
                    }

                    // episodes
                    Repeater {
                        model: (modelData && modelData.plan) || []
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)
                            Text {
                                Layout.fillWidth: true
                                text: "Tập " + (modelData.episode_no || "?") + ": " + String(modelData.title || "")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Rectangle {
                                implicitWidth: epPill.implicitWidth + VfTheme.dp(12)
                                implicitHeight: VfTheme.dp(20)
                                radius: VfTheme.dp(10)
                                color: screen.epFill(String(modelData.status || "pending"))
                                Text {
                                    id: epPill
                                    anchors.centerIn: parent
                                    text: screen.epLabel(String(modelData.status || "pending"))
                                    color: screen.epText(String(modelData.status || "pending"))
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                }
                            }
                            VfButton {
                                text: "▶ Chạy"
                                tone: "primary"
                                compact: true
                                visible: String(modelData.status || "pending") === "pending"
                                onClicked: researchController.runSeriesEpisode(seriesCard.sid, modelData.episode_no || 0)
                            }
                        }
                    }
                }
            }
        }

        // ── AUDIO section ───────────────────────────────────────────────────
        Text {
            visible: researchController.audioCount > 0
            text: "🎧 Audio đã tạo"
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontTiny
            font.weight: VfTheme.weightStrong
        }

        VfListView {
            id: audioList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: researchController.audioCount > 0
            model: researchController.audioLibraryModel
            spacing: VfTheme.dp(8)

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width : 0
                implicitHeight: cardCol.implicitHeight + VfTheme.dp(20)
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                border.width: 1

                ColumnLayout {
                    id: cardCol
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(6)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            spacing: VfTheme.dp(3)
                            Text {
                                Layout.fillWidth: true
                                text: String((modelData && modelData.topic) || "(không tên)")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSection
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Text {
                                Layout.fillWidth: true
                                text: screen.fmtDate(modelData && modelData.created_at)
                                    + "  ·  " + screen.fmtDur(modelData && modelData.duration_sec)
                                    + "  ·  " + (String((modelData && modelData.script_format) || "monologue") === "dialogue" ? "Hội thoại" : "Đơn thoại")
                                    + ((modelData && Number(modelData.episode_no) > 1) ? ("  ·  Tập " + modelData.episode_no) : "")
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                            Text {
                                visible: !(modelData && modelData.audio_exists)
                                text: "⚠ File audio không còn trên đĩa"
                                color: VfTheme.redText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                        Rectangle {
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: statusPill.implicitWidth + VfTheme.dp(16)
                            implicitHeight: VfTheme.dp(24)
                            radius: VfTheme.dp(12)
                            color: screen.vFill(String((modelData && modelData.video_status) || "none"))
                            border.width: 1
                            border.color: screen.vText(String((modelData && modelData.video_status) || "none"))
                            Text {
                                id: statusPill
                                anchors.centerIn: parent
                                text: screen.vStatusLabel(String((modelData && modelData.video_status) || "none"))
                                color: screen.vText(String((modelData && modelData.video_status) || "none"))
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightStrong
                            }
                        }
                    }

                    Flow {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        VfButton {
                            text: "▶ Nghe"
                            tone: "neutral"
                            compact: true
                            enabled: Boolean(modelData && modelData.audio_exists)
                            onClicked: researchController.openAudioPath(String((modelData && modelData.audio_path) || ""))
                        }
                        VfButton {
                            text: String((modelData && modelData.video_status) || "none") === "failed" ? "⟳ Dựng lại" : "🎬 Đẩy sang Video"
                            tone: "primary"
                            compact: true
                            visible: {
                                var s = String((modelData && modelData.video_status) || "none")
                                return s === "none" || s === "failed"
                            }
                            enabled: Boolean(modelData && modelData.audio_exists)
                            tooltip: "Đẩy audio + báo cáo + SRT sang hàng chờ Audio-to-Video"
                            onClicked: researchController.sendAudioToVideo(String((modelData && modelData.job_id) || ""))
                        }
                        VfButton {
                            text: "🎞 Mở video"
                            tone: "success"
                            compact: true
                            visible: String((modelData && modelData.video_status) || "none") === "complete"
                                && String((modelData && modelData.video_path) || "").length > 0
                            onClicked: researchController.openAudioPath(String((modelData && modelData.video_path) || ""))
                        }
                        VfButton {
                            text: "🗑 Xoá"
                            tone: "danger"
                            compact: true
                            tooltip: "Xoá khỏi kho (không xoá file trên đĩa)"
                            onClicked: researchController.deleteAudio(String((modelData && modelData.job_id) || ""))
                        }
                    }
                }
            }
        }

        // ── Empty state ─────────────────────────────────────────────────────
        Text {
            visible: researchController.audioCount === 0 && researchController.seriesCount === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            text: "Chưa có gì ở đây.\nVào Research Labs → nghiên cứu 1 chủ đề → bấm \"Tạo series\" để có một series dài khai thác dần."
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontBody
        }
    }
}
