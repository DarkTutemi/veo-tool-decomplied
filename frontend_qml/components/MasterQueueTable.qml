import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"
import "JobClock.js" as JobClock

Rectangle {
    id: root
    objectName: "queueTable"

    property var rows: []
    property var stats: ({})
    property string selectedRowId: ""
    property var techniqueOptions: []
    property var materialOptions: []
    property var durationOptions: []
    property var languageOptions: []
    property var aspectOptions: []
    property double elapsedClockMs: Date.now()
    signal previewRequested(var row)
    signal openFolderRequested(var row)
    signal openClipRequested(string path)
    signal removeRequested(var row)
    signal titleChanged(var row, string title)
    signal techniqueChanged(var row, string techniqueId)
    signal materialChanged(var row, string materialId)
    signal durationChanged(var row, int durationSeconds)
    signal languageChanged(var row, string languageCode)
    signal aspectChanged(var row, string aspectRatio)

    Layout.fillWidth: true
    Layout.fillHeight: true
    // Size to content so EVERY row is shown (no inner scroll). The outer page
    // ScrollView handles overflow when the queue is taller than the viewport.
    implicitHeight: VfTheme.dp(26) + Math.max(0, queueList.contentHeight)
    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.color: VfTheme.border
    clip: true

    function rowProgressValue(row) {
        return Number((row && (row.progress !== undefined ? row.progress : row.job_progress)) || 0)
    }

    function rowSceneCount(row) {
        return Number((row && row.scene_count) || 0)
    }

    function rowVideoCount(row) {
        return Number((row && row.video_count) || 0)
    }

    function rowId(row) {
        if (!row)
            return ""
        return String(row.row_id || row.id || row.batch_id || row.job_id || "")
    }

    function selectedRow() {
        var items = root.rows || []
        var selected = String(root.selectedRowId || "")
        if (selected.length > 0) {
            for (var i = 0; i < items.length; i++) {
                if (root.rowId(items[i]) === selected)
                    return items[i] || ({})
            }
        }
        return items.length > 0 ? (items[0] || ({})) : ({})
    }

    function syncSelectedRow() {
        var items = root.rows || []
        if (!items || items.length === 0) {
            root.selectedRowId = ""
            return
        }
        var selected = String(root.selectedRowId || "")
        if (selected.length === 0) {
            root.selectedRowId = root.rowId(items[0])
            return
        }
        for (var i = 0; i < items.length; i++) {
            if (root.rowId(items[i]) === selected)
                return
        }
        root.selectedRowId = root.rowId(items[0])
    }

    function rowOutputFolder(row) {
        if (!row)
            return ""
        return String(row.output_folder || row.session_folder || row.folder || "")
    }

    function rowMessage(row) {
        if (!row)
            return ""
        var errorText = String(row.job_error_message || row.error_message || row.error || "")
        if (errorText.length > 0)
            return errorText
        var summary = row.dispatcher_summary || ({})
        if (Number(summary.running || 0) > 0)
            return "Dispatcher running: " + String(summary.completed || 0) + "/" + String(summary.total || 0) + " scene(s) complete."
        if (Number(summary.failed || 0) > 0)
            return "Dispatcher reported failures."
        if (Number(summary.completed || 0) > 0)
            return "Dispatcher scenes completed."
        return ""
    }

    function rowMessageColor(row) {
        var text = String(row.job_error_message || row.error_message || row.error || "")
        if (text.length > 0)
            return "#DC2626"
        return VfTheme.textMuted
    }

    function rowBreakdownItems(row) {
        return (row && row.dispatcher_breakdown) ? row.dispatcher_breakdown : []
    }

    function optionValueForLabel(options, label) {
        var items = options || []
        var safeLabel = String(label || "")
        for (var i = 0; i < items.length; i++) {
            var item = items[i] || ({})
            if (String(item.label || "") === safeLabel)
                return String(item.value || "")
        }
        return ""
    }

    function techniqueValue(row) {
        var config = row && row.config ? row.config : ({})
        var direct = String(config.camera_id || "")
        if (direct.length > 0)
            return direct
        return root.optionValueForLabel(root.techniqueOptions, String(config.technique_name || config.camera || ""))
    }

    function materialValue(row) {
        var config = row && row.config ? row.config : ({})
        var direct = String(config.style_id || config.material_id || "")
        if (direct.length > 0)
            return direct
        return root.optionValueForLabel(root.materialOptions, String(config.material_name || config.style || ""))
    }

    function durationValue(row) {
        var config = row && row.config ? row.config : ({})
        var direct = Number(config.duration || 0)
        if (direct > 0)
            return direct
        return 0
    }

    function rowInputMode(row) {
        var c = row && row.config ? row.config : ({})
        return String((row && row.input_mode) || c.input_mode || "idea")
    }

    // Cột Duration: idea mode = tổng thời lượng ép sẵn ("Ns"/"Auto"). Script mode
    // KHÔNG có tổng — số cảnh do phân tích kịch bản quyết → "Theo KB" trước khi
    // phân tích, "N cảnh" sau khi gen (KHÔNG dùng "Auto" như idea).
    function durationCellText(row) {
        if (root.rowInputMode(row) === "script") {
            var n = Number((row && row.scene_count) || 0)
            return n > 0 ? (String(n) + " " + i18n.t("qml.master.queue_scenes_unit", "cảnh"))
                         : i18n.t("qml.master.queue_dur_by_script", "Theo KB")
        }
        var d = root.durationValue(row)
        return d > 0 ? (String(d) + "s") : i18n.t("master.duration_auto", "Auto")
    }

    function languageValue(row) {
        var config = row && row.config ? row.config : ({})
        var direct = String(config.voice_language || config.voice_id || "")
        if (direct.length > 0)
            return direct
        return root.optionValueForLabel(root.languageOptions, String(config.language || row.language || ""))
    }

    function aspectValue(row) {
        var config = row && row.config ? row.config : ({})
        var direct = String(config.aspect_ratio || "")
        if (direct.length > 0)
            return direct
        return String(row.aspect || "16:9")
    }

    function rowName(row) {
        var r = row || {}
        return String(r.name || r.idea || r.id || r.row_id || (void i18n.revision, i18n.t("qml.master.queue_row", "Queue row")))
    }

    function labelForValue(options, value) {
        var items = options || []
        var v = String(value || "")
        for (var i = 0; i < items.length; i++) {
            if (String((items[i] || {}).value || "") === v)
                return String((items[i] || {}).label || v)
        }
        return v
    }

    function rowCharacters(row) {
        var config = row && row.config ? row.config : ({})
        var info = config.multi_asset_info
        if (!info || typeof info !== "object")
            return []
        var assets = info.assets || []
        var out = []
        for (var i = 0; i < assets.length; i++) {
            var a = assets[i] || ({})
            var t = String(a.asset_type || a.type || "character")
            if (t !== "character")
                continue
            var nm = String(a.name || a.title || a.id || "").trim()
            if (nm.length > 0)
                out.push(nm)
        }
        return out
    }

    function rowClipItems(row) {
        var items = []
        var seen = ({})
        var breakdown = root.rowBreakdownItems(row)
        for (var i = 0; i < breakdown.length; i++) {
            var item = breakdown[i] || ({})
            var path = String(item.video_path || item.path || "")
            if (path.length === 0 || seen[path])
                continue
            seen[path] = true
            items.push({
                label: String(item.scene_id || item.job_id || ("Clip " + String(items.length + 1))),
                path: path
            })
        }
        return items
    }

    function progressText(row) {
        var status = root.statusText(row)
        var progress = root.rowProgressValue(row)
        var scenes = root.rowSceneCount(row)
        var videos = root.rowVideoCount(row)
        var text = status + " (" + String(progress) + "%)"
        if (scenes > 0)
            text += " - " + String(videos) + "/" + String(scenes) + " scenes"
        return text
    }

    function statusToken(row) {
        return String((row && (row.status_label || row.job_status || row.status || row.status_label)) || "").toLowerCase()
    }

    function statusText(row) {
        var token = root.statusToken(row)
        var message = String((row && row.progress_message) || "")
        if (row && row.needs_regeneration)
            return message.length > 0 ? message : (void i18n.revision, i18n.t("qml.master.needs_regeneration", "Needs regeneration"))
        if (token === "pending_script")
            return (void i18n.revision, i18n.t("master_prompt_tab.status_waiting_script", "Waiting Script"))
        if (token === "creating_script")
            return message.length > 0 ? message : (void i18n.revision, i18n.t("master_prompt_tab.status_creating_script", "Creating Script"))
        if (token === "complete")
            return (void i18n.revision, i18n.t("job_panel.status_completed", "Completed"))
        if (token === "failed")
            return (void i18n.revision, i18n.t("job_panel.status_failed", "Failed"))
        if (token === "generating" || token === "running" || token === "processing" || token === "polling" || token === "upscaling")
            return message.length > 0 ? message : (void i18n.revision, i18n.t("job_panel.status_generating", "Generating"))
        if (token === "cancelled")
            return (void i18n.revision, i18n.t("qml.master.cancelled", "Cancelled"))
        return String((row && (row.job_status || row.status || row.status_label)) || (void i18n.revision, i18n.t("common.pending", "Pending")))
    }

    function elapsedLabel(row) {
        void root.elapsedClockMs
        return JobClock.rowElapsedLabel(
            row,
            root.elapsedClockMs,
            root.statusToken(row)
        )
    }

    function progressColor(row) {
        var status = root.statusToken(row)
        if (row && row.needs_regeneration)
            return VfTheme.amberText
        if (status === "complete")
            return "#059669"
        if (status === "failed" || status === "cancelled")
            return "#DC2626"
        if (status === "pending_script")
            return VfTheme.amberText
        if (status === "running" || status === "generating" || status === "processing" || status === "polling" || status === "upscaling")
            return "#2563EB"
        return VfTheme.primaryPressed
    }

    // Shared column widths — used by BOTH header and row so they ALIGN. (Trước
    // đây header Actions=172 còn row=130 → cột Idea flex lệch 42px → toàn bộ lệch.)
    readonly property int colCamera: VfTheme.dp(94)
    readonly property int colStyle: VfTheme.dp(94)
    readonly property int colDuration: VfTheme.dp(54)
    readonly property int colLanguage: VfTheme.dp(74)
    readonly property int colAspect: VfTheme.dp(48)
    readonly property int colProgress: VfTheme.dp(152)
    readonly property int colActions: VfTheme.dp(116)

    // --- Locked-config value getters (đọc từ row.config = snapshot lúc add) ---
    function marketValue(row) { return String(((row && row.config) || {}).market || "global") }
    function modelValue(row) {
        var k = String(((row && row.config) || {}).model_key || ((row && row.config) || {}).video_model_key || "")
        return k.length > 0 ? k : "auto"
    }
    function qualityValue(row) { return String(((row && row.config) || {}).quality || "720p") }
    function charConsistencyText(row) {
        var c = (row && row.config) || {}
        if (!c.character_consistency)
            return (void i18n.revision, i18n.t("qml.master.queue_char_off", "Tắt"))
        var mode = String(c.char_mode || "full_ai")
        return (void i18n.revision, i18n.t("qml.master.queue_char_on", "Bật")) + " · " + mode
    }
    function voiceText(row) {
        var c = (row && row.config) || {}
        var lang = String(c.voice_language || c.voice_id || "none")
        var locked = Boolean(c.enable_flow_voice_lock)
        return lang + (locked ? " · 🔒" : "")
    }

    onRowsChanged: syncSelectedRow()

    component QueueCell: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        maximumLineCount: 1
    }

    // Chip "nhãn + giá trị" cho dải config đã khoá (market/model/quality/char/voice).
    component ConfigChip: Row {
        property string label: ""
        property string value: ""
        height: VfTheme.dp(24)
        spacing: VfTheme.dp(3)
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.label
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(9)
            font.weight: Font.DemiBold
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: parent.value
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header (responsive: idea flexes, meta fixed, actions fixed)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(26)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(8)
                anchors.rightMargin: VfTheme.dp(8)
                spacing: VfTheme.dp(6)

                QueueCell { Layout.fillWidth: true; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("master_prompt_tab.table_header_idea", "Idea")) }
                QueueCell { Layout.preferredWidth: root.colCamera; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("qml.master.queue_technique", "Camera")) }
                QueueCell { Layout.preferredWidth: root.colStyle; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("qml.master.queue_material", "Style")) }
                QueueCell { Layout.preferredWidth: root.colDuration; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("master_prompt_tab.table_header_duration", "Duration")) }
                QueueCell { Layout.preferredWidth: root.colLanguage; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("master_prompt_tab.table_header_language", "Language")) }
                QueueCell { Layout.preferredWidth: root.colAspect; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("qml.master.queue_aspect", "Aspect")) }
                QueueCell { Layout.preferredWidth: root.colProgress; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("master_prompt_tab.table_header_progress", "Progress")) }
                QueueCell { Layout.preferredWidth: root.colActions; horizontalAlignment: Text.AlignRight; color: VfTheme.textMuted; font.weight: Font.Bold; text: (void i18n.revision, i18n.t("qml.master.queue_actions", "Actions")) }
            }
        }

        ListView {
            id: queueList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            // KHÔNG reuseItems: view render-all + interactive:false nên pooling vô ích;
            // delegate lại stateful (selection + nút preview/delete ôm modelData) → reuse
            // sau khi xoá row bắn spurious clicked → tự bật Preview. (playbook.md:176)
            interactive: false
            model: root.rows
            spacing: VfTheme.dp(2)
            boundsBehavior: Flickable.StopAtBounds

            delegate: Column {
                width: queueList.width
                readonly property string currentRowId: root.rowId(modelData)
                readonly property bool isSelected: root.selectedRowId === currentRowId
                readonly property var rowChars: root.rowCharacters(modelData)

                // Main row - FROZEN (read-only). Change a queued row only by
                // deleting it and adding again.
                Rectangle {
                    width: parent.width
                    height: VfTheme.dp(36)
                    color: isSelected ? VfTheme.blueFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                    border.color: isSelected ? VfTheme.blueBorderSoft : VfTheme.surfaceSoft

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.selectedRowId = currentRowId
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(8)
                        anchors.rightMargin: VfTheme.dp(8)
                        spacing: VfTheme.dp(6)

                        QueueCell { Layout.fillWidth: true; font.weight: Font.DemiBold; text: root.rowName(modelData) }
                        QueueCell { Layout.preferredWidth: root.colCamera; color: VfTheme.textMuted; text: root.labelForValue(root.techniqueOptions, root.techniqueValue(modelData)) || "--" }
                        QueueCell { Layout.preferredWidth: root.colStyle; color: VfTheme.textMuted; text: root.labelForValue(root.materialOptions, root.materialValue(modelData)) || "--" }
                        QueueCell { Layout.preferredWidth: root.colDuration; color: VfTheme.textMuted; text: (void i18n.revision, root.durationCellText(modelData)) }
                        QueueCell { Layout.preferredWidth: root.colLanguage; color: VfTheme.textMuted; text: root.labelForValue(root.languageOptions, root.languageValue(modelData)) || "--" }
                        QueueCell { Layout.preferredWidth: root.colAspect; color: VfTheme.textMuted; text: root.aspectValue(modelData) }
                        Column {
                            Layout.preferredWidth: root.colProgress
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0
                            QueueCell {
                                width: root.colProgress
                                color: root.progressColor(modelData)
                                text: root.progressText(modelData)
                            }
                            Text {
                                width: root.colProgress
                                text: root.elapsedLabel(modelData)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                                elide: Text.ElideRight
                            }
                        }

                        Row {
                            Layout.preferredWidth: root.colActions
                            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            spacing: VfTheme.dp(4)

                            VfButton {
                                compact: true
                                minWidth: VfTheme.dp(30)
                                actionId: "master.queue.preview"
                                iconName: "framed-picture"
                                text: ""
                                tooltip: (void i18n.revision, i18n.t("qml.master.queue_preview", "Preview"))
                                onClicked: root.previewRequested(modelData)
                            }
                            VfButton {
                                compact: true
                                minWidth: VfTheme.dp(30)
                                actionId: "master.queue.open_folder"
                                iconName: "open-folder"
                                text: ""
                                tooltip: (void i18n.revision, i18n.t("master_prompt_tab.table_header_folder", "Folder"))
                                onClicked: root.openFolderRequested(modelData)
                            }
                            VfButton {
                                compact: true
                                minWidth: VfTheme.dp(30)
                                actionId: "master.queue.delete_row"
                                iconName: "cross-mark"
                                text: ""
                                tone: "danger"
                                tooltip: (void i18n.revision, i18n.t("common.delete", "Delete"))
                                onClicked: root.removeRequested(modelData)
                            }
                        }
                    }
                }

                // Locked-config strip — hiển thị FULL config đã khoá lúc thêm vào
                // hàng chờ (đổi config sau KHÔNG ảnh hưởng row này): thị trường,
                // model, chất lượng, điều khiển nhân vật, đồng bộ giọng nói.
                Rectangle {
                    width: parent.width
                    height: VfTheme.dp(24)
                    color: VfTheme.surfaceSoft
                    border.color: VfTheme.border
                    clip: true

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: VfTheme.dp(10)
                        anchors.rightMargin: VfTheme.dp(8)
                        spacing: VfTheme.dp(14)

                        ConfigChip {
                            label: "🌐 " + (void i18n.revision, i18n.t("qml.master.queue_market", "Thị trường:"))
                            value: root.marketValue(modelData)
                        }
                        ConfigChip {
                            label: "📺 " + (void i18n.revision, i18n.t("qml.master.queue_quality", "Chất lượng:"))
                            value: root.qualityValue(modelData)
                        }
                        ConfigChip {
                            label: "👤 " + (void i18n.revision, i18n.t("qml.master.queue_char_ctrl", "Nhân vật:"))
                            value: root.charConsistencyText(modelData)
                        }
                        ConfigChip {
                            label: "🔊 " + (void i18n.revision, i18n.t("qml.master.queue_voice_sync", "Giọng:"))
                            value: root.voiceText(modelData)
                        }
                        ConfigChip {
                            label: "🎬 " + (void i18n.revision, i18n.t("qml.master.queue_model_label", "Model:"))
                            value: root.modelValue(modelData)
                        }
                    }
                }

                // Character row - shown when the row uses library characters.
                Rectangle {
                    width: parent.width
                    visible: rowChars.length > 0
                    height: visible ? VfTheme.dp(26) : 0
                    color: VfTheme.violetFill
                    border.color: VfTheme.violetBorderSoft

                    Row {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: VfTheme.dp(10)
                        anchors.rightMargin: VfTheme.dp(8)
                        spacing: VfTheme.dp(5)

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (void i18n.revision, i18n.t("qml.master.queue_characters", "Characters:"))
                            color: "#7C3AED"
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: Font.DemiBold
                        }

                        Repeater {
                            model: rowChars

                            delegate: Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                height: VfTheme.dp(18)
                                width: charChipText.implicitWidth + VfTheme.dp(12)
                                radius: VfTheme.dp(9)
                                color: VfTheme.violetFill
                                border.color: VfTheme.violetBorderSoft

                                Text {
                                    id: charChipText
                                    anchors.centerIn: parent
                                    text: String(modelData || "")
                                    color: VfTheme.violetText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: queueList.count === 0
        text: (void i18n.revision, i18n.t("qml.master.no_queue_rows", "No queued rows yet"))
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(13)
        font.weight: Font.Medium
    }
}
