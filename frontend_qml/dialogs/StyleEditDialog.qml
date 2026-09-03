import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    objectName: "styleEditDialog"

    property string styleId: ""
    property string styleKind: "style"
    property string styleName: ""
    property string ideaText: ""
    property string referenceImagePath: ""
    property string statusText: (void i18n.revision, i18n.t("style_edit.status_waiting", "Đang chờ ý tưởng của bạn. JSON nội bộ sẽ được tạo tự động."))
    property var previewState: ({})
    property string previewImagePath: ""
    property string previewMessage: ""
    property string frameworkJson: ""
    property string veo3Prompt: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""
    property bool editingExisting: false
    // Bound from MasterConfigPanel → masterOptionsController.styleAiBusy / styleAiPhase
    property bool aiBusy: false
    // Real worker stage: framework | preview | preview_retry | done | ""
    property string aiPhaseKey: ""
    readonly property string aiPhaseText: root.phaseLabel(root.aiPhaseKey)
    readonly property bool canChangeKind: root.styleKind !== "camera"
    readonly property bool drawAuthoring: root.styleKind === "draw"
    readonly property int dialogBorderWidth: 2

    // Map backend stage → user-facing status (NOT a fake rotating timer).
    function phaseLabel(key) {
        var k = String(key || "")
        if (k === "framework")
            return (void i18n.revision, i18n.t("style_edit.phase_framework", "AI đang phân tích framework JSON…"))
        if (k === "preview")
            return (void i18n.revision, i18n.t("style_edit.phase_preview", "Đang tạo ảnh preview…"))
        if (k === "preview_retry")
            return (void i18n.revision, i18n.t("style_edit.phase_preview_retry", "Preview 403/captcha — đang thử lại…"))
        if (k === "done")
            return (void i18n.revision, i18n.t("style_edit.phase_done", "Hoàn tất."))
        if (root.aiBusy)
            return (void i18n.revision, i18n.t("style_edit.phase_starting", "Đang bắt đầu AI phân tích…"))
        return ""
    }

    onAiBusyChanged: {
        if (root.aiBusy) {
            var label = root.aiPhaseText
            if (label.length > 0)
                root.statusText = label
        }
    }

    onAiPhaseKeyChanged: {
        if (!root.aiBusy)
            return
        var label = root.aiPhaseText
        if (label.length > 0)
            root.statusText = label
    }

    signal saveRequested(string styleId, string name, string prompt, string kind)
    signal aiGeneratePreviewRequested(var payload)
    signal chooseReferenceRequested()
    signal pasteReferenceRequested()
    signal savePayloadRequested(var payload)

    title: root.editingExisting
        ? (void i18n.revision, i18n.t("styles_mgmt_v3.edit_framework", "Sửa Framework"))
        : (void i18n.revision, i18n.t("styles_mgmt_v3.new_framework", "Tạo mới Style Framework"))
    parent: Overlay.overlay
    header: null
    modal: true
    width: VfDialogMetrics.width(parent, VfTheme.dp(1240), VfTheme.dp(40))
    height: VfDialogMetrics.height(parent, VfTheme.dp(820), VfTheme.dp(40))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    standardButtons: Dialog.NoButton
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    function localFileSource(path) {
        var normalized = String(path || "").trim()
        if (!normalized.length)
            return ""
        if (normalized.indexOf("file:") === 0 || normalized.indexOf("data:") === 0 || normalized.indexOf("qrc:") === 0)
            return normalized
        if (root.looksLikeBase64Image(normalized))
            return "data:image/png;base64," + root.cleanBase64Payload(normalized)
        normalized = normalized.replace(/\\/g, "/")
        if (/^[A-Za-z]:\//.test(normalized))
            return "file:///" + normalized
        if (normalized.charAt(0) === "/")
            return "file://" + normalized
        return normalized
    }

    function cleanBase64Payload(value) {
        var raw = String(value || "").trim()
        var marker = "base64,"
        var index = raw.indexOf(marker)
        if (index >= 0)
            raw = raw.slice(index + marker.length)
        return raw.replace(/\s/g, "")
    }

    function looksLikeBase64Image(value) {
        var raw = root.cleanBase64Payload(value)
        if (raw.length < 80)
            return false
        return /^[A-Za-z0-9+/]+={0,2}$/.test(raw)
    }

    function cleanOneLine(value, fallback) {
        var text = String(value || "").replace(/\s+/g, " ").trim()
        if (!text.length)
            return fallback || ""
        return text.length > 150 ? text.slice(0, 147) + "..." : text
    }

    function kindLabel() {
        return root.drawAuthoring
            ? (void i18n.revision, i18n.t("style_edit.draw_framework", "Draw / VideoScribe"))
            : root.styleKind === "camera"
            ? (void i18n.revision, i18n.t("styles_mgmt_v3.camera_framework", "Camera Framework"))
            : (void i18n.revision, i18n.t("styles_mgmt_v3.style_framework", "Style Framework"))
    }

    function setAuthoringMode(mode) {
        if (!root.canChangeKind)
            return
        root.styleKind = String(mode || "style") === "draw" ? "draw" : "style"
        root.statusText = root.drawAuthoring
            ? (void i18n.revision, i18n.t("style_edit.draw_mode_ready", "Draw mode: AI sẽ khóa nền sáng, nét vẽ thưa và capability vẽ tay/bút."))
            : (void i18n.revision, i18n.t("style_edit.style_mode_ready", "Style Framework thường: không chạy renderer vẽ tay."))
    }

    function applyPreviewState(state) {
        var previewState = state || ({})
        var preview = previewState.preview || ({})
        root.previewState = previewState
        root.previewImagePath = String(preview.path || "")
        root.previewMessage = String(previewState.message || "")
    }

    function emitSave() {
        root.statusText = ""
        var normalizedFramework = String(root.frameworkJson || "").trim()
        if (!normalizedFramework.length || normalizedFramework === "{}") {
            root.feedbackTitle = (void i18n.revision, i18n.t("style_edit.ai_header", "AI phân tích"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.need_generate_first", "Hãy nhập ý tưởng/ảnh tham chiếu và bấm AI phân tích trước. Hệ thống sẽ tự tạo framework."))
            feedbackDialog.open()
            return
        }
        if (!String(root.styleId || "").trim().length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.missing_id", "Framework chưa có ID. Hãy bấm AI phân tích để hệ thống tạo framework trước khi lưu."))
            feedbackDialog.open()
            return
        }
        if (String(root.styleId || "").trim().indexOf("__") === 0) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.reserved_id", "ID bắt đầu bằng '__' là ID hệ thống, không dùng cho custom framework."))
            feedbackDialog.open()
            return
        }
        if (!String(nameInput.text || "").trim().length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.name_required", "Tên hiển thị là bắt buộc sau khi AI phân tích."))
            nameInput.forceActiveFocus()
            feedbackDialog.open()
            return
        }
        root.savePayloadRequested({
            styleId: root.styleId,
            name: nameInput.text,
            prompt: root.veo3Prompt && root.veo3Prompt.length > 0 ? root.veo3Prompt : ideaInput.text,
            kind: root.styleKind,
            description: ideaInput.text,
            framework_json: root.frameworkJson || ""
        })
    }

    // Manual: save the user's typed prompt as a custom style WITHOUT AI. The
    // service builds a default framework from the prompt (empty framework_json)
    // and derives an id from the name (empty styleId).
    function emitManualSave() {
        root.statusText = ""
        var name = String(nameInput.text || "").trim()
        var prompt = String(root.veo3Prompt || "").trim()
        if (!prompt.length)
            prompt = String(ideaInput.text || "").trim()
        if (!name.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.manual_name_required", "Nhập tên hiển thị cho style."))
            nameInput.forceActiveFocus()
            feedbackDialog.open()
            return
        }
        if (!prompt.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.manual_prompt_required", "Nhập mô tả/prompt style trước khi lưu thủ công."))
            ideaInput.forceActiveFocus()
            feedbackDialog.open()
            return
        }
        var sid = String(root.styleId || "").trim()
        if (sid.indexOf("__") === 0) {
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.reserved_id", "ID bắt đầu bằng '__' là ID hệ thống, không dùng cho custom framework."))
            feedbackDialog.open()
            return
        }
        root.savePayloadRequested({
            styleId: sid,
            name: name,
            prompt: prompt,
            kind: root.styleKind,
            description: ideaInput.text,
            framework_json: ""
        })
    }

    function emitAiAnalyze() {
        var payload = root.aiRequestPayload()
        var idea = String(payload.idea || "").trim()
        var reference = String(payload.reference || payload.reference_image_path || "").trim()
        if (!idea.length && !reference.length) {
            root.feedbackTitle = (void i18n.revision, i18n.t("style_edit.ai_header", "AI phân tích"))
            root.feedbackMessage = (void i18n.revision, i18n.t("style_edit.ai_input_required", "Hãy nhập ý tưởng hoặc chọn ảnh tham chiếu trước khi AI phân tích."))
            feedbackDialog.open()
            return
        }
        root.previewMessage = ""
        root.previewImagePath = ""
        root.statusText = (void i18n.revision, i18n.t("style_edit.phase_starting", "Đang bắt đầu AI phân tích…"))
        root.aiGeneratePreviewRequested(payload)
    }

    function applySaveResult(result, fallbackPayload) {
        var response = result || ({ ok: true, style: fallbackPayload || ({}) })
        if (response.ok === false) {
            var message = String(response.message || response.error || response.code || "Save failed.")
            root.statusText = message
            root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
            root.feedbackMessage = message
            feedbackDialog.open()
            return
        }
        var style = response.style || response.item || fallbackPayload || ({})
        if (String(style.id || style.style_id || "").length > 0)
            root.styleId = String(style.id || style.style_id || "")
        if (String(style.name || style.display_name || "").length > 0) {
            root.styleName = String(style.name || style.display_name || "")
            nameInput.text = root.styleName
        }
        root.statusText = String(response.message || "Style saved.")
        root.accept()
    }

    function aiRequestPayload() {
        return {
            id: root.styleId,
            style_id: root.styleId,
            name: nameInput.text,
            kind: root.styleKind,
            idea: ideaInput.text,
            description: ideaInput.text,
            reference: refInput.text,
            reference_image_path: refInput.text
        }
    }

    function applyAiPayload(result) {
        var style = (result || {}).style || {}
        if (String(style.id || style.style_id || "").length > 0)
            root.styleId = String(style.id || style.style_id || "")
        var generatedFramework = style.framework_definition || (result || {}).framework_definition || ({})
        var generatedMotion = ((generatedFramework.render_capabilities || {}).image_motion || {})
        if (String(style.kind || style.authoring_mode || "").length > 0) {
            root.styleKind = String(style.authoring_mode || "").toLowerCase() === "draw"
                || String(style.topic_id || "").toLowerCase() === "draw_motion_2d"
                || Boolean(generatedMotion.enabled)
                ? "draw"
                : (String(style.kind || "style") === "camera" ? "camera" : "style")
        }
        if (String(style.display_name || style.name || "").length > 0) {
            root.styleName = String(style.display_name || style.name || "")
            nameInput.text = root.styleName
        }
        if (String(style.description || "").length > 0) {
            root.ideaText = String(style.description || "")
            ideaInput.text = root.ideaText
        }
        if (String(style.reference_image_path || "").length > 0) {
            root.referenceImagePath = String(style.reference_image_path || "")
            refInput.text = root.referenceImagePath
        }
        root.frameworkJson = String((result || {}).framework_json || "")
        root.veo3Prompt = String(style.veo3_prompt || style.prompt || root.ideaText || "")
        root.statusText = String((result || {}).message || (void i18n.revision, i18n.t("style_edit.ai_done", "Đã tạo framework. Bạn có thể lưu ngay.")))
        if (result && result.preview_result) {
            var previewResult = result.preview_result || ({})
            if (previewResult.preview_state)
                root.applyPreviewState(previewResult.preview_state)
            else if (String(previewResult.output_path || "").length > 0)
                root.applyPreviewState({ preview: { path: String(previewResult.output_path || ""), exists: true }, message: String(previewResult.message || "") })
            var previewMessage = String(previewResult.message || previewResult.error || previewResult.code || root.statusText)
            root.statusText = previewResult.ok === false ? previewMessage : (void i18n.revision, i18n.t("style_edit.status_ready", "Đã tạo framework và preview. Kiểm tra tên nếu cần, rồi bấm Lưu style."))
            if (previewResult.ok === false) {
                root.feedbackTitle = (void i18n.revision, i18n.t("common.error", "Lỗi"))
                root.feedbackMessage = previewMessage
                feedbackDialog.open()
            }
        }
    }

    function openFor(style) {
        var item = style || ({})
        var itemFramework = item.framework_definition || ({})
        var itemMotion = ((itemFramework.render_capabilities || {}).image_motion || {})
        root.editingExisting = true
        root.styleId = String(item.id || item.style_id || "")
        root.styleKind = String(item.authoring_mode || "").toLowerCase() === "draw"
            || String(item.topic_id || "").toLowerCase() === "draw_motion_2d"
            || Boolean(itemMotion.enabled)
            ? "draw"
            : (String(item.kind || "style") === "camera" ? "camera" : "style")
        root.styleName = String(item.display_name || item.name || "")
        root.ideaText = String(item.description || item.prompt || item.veo3_prompt || "")
        root.referenceImagePath = String(item.reference_image_path || item.reference_path || "")
        root.frameworkJson = JSON.stringify(item.framework_definition || {}, null, 2)
        root.veo3Prompt = String(item.veo3_prompt || item.prompt || root.ideaText || "")
        root.applyPreviewState(item.preview_state || item.previewState || ({}))
        root.statusText = (void i18n.revision, i18n.t("styles_mgmt_v3.edit_framework", "Sửa Framework"))
        root.open()
    }

    function openNew(kind) {
        root.editingExisting = false
        root.styleId = ""
        root.styleKind = String(kind || "style").toLowerCase() === "draw" ? "draw" : "style"
        root.styleName = ""
        root.ideaText = ""
        root.referenceImagePath = ""
        root.frameworkJson = ""
        root.veo3Prompt = ""
        root.applyPreviewState({})
        root.statusText = root.drawAuthoring
            ? (void i18n.revision, i18n.t("style_edit.status_waiting_draw", "Tạo Draw style: mô tả nét vẽ/nền sáng rồi bấm AI phân tích; backend sẽ khóa capability vẽ tay/bút."))
            : (void i18n.revision, i18n.t("style_edit.status_waiting_manual", "Nhập mô tả/prompt rồi bấm 'Lưu thủ công' — hoặc 'AI phân tích' để hệ thống tự tạo framework."))
        root.open()
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.blueBorderSoft
        border.width: root.dialogBorderWidth
        antialiasing: true
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: root.dialogBorderWidth
        clip: true
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(78)
            color: VfTheme.surface
            border.width: 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(12)

                Rectangle {
                    Layout.preferredWidth: VfTheme.dp(44)
                    Layout.preferredHeight: VfTheme.dp(44)
                    radius: VfTheme.dp(10)
                    color: VfTheme.blueFill
                    border.width: 1
                    border.color: VfTheme.blueBorderSoft

                    VfAppIcon {
                        anchors.centerIn: parent
                        name: "artist-palette"
                        size: VfTheme.dp(24)
                        color: VfTheme.primary
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(2)

                    Label {
                        Layout.fillWidth: true
                        text: root.editingExisting
                            ? (void i18n.revision, i18n.t("style_edit.edit_title", "Sửa Style Framework"))
                            : (root.drawAuthoring
                                ? (void i18n.revision, i18n.t("style_edit.create_draw_title", "Tạo mới Draw / VideoScribe Style"))
                                : root.styleKind === "camera"
                                ? (void i18n.revision, i18n.t("style_edit.create_camera_title", "Tạo mới Camera Framework"))
                                : (void i18n.revision, i18n.t("style_edit.create_style_title", "Tạo mới Style Framework")))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(20)
                        font.weight: VfTheme.weightStrong
                        elide: Text.ElideRight
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.drawAuthoring
                            ? (void i18n.revision, i18n.t("style_edit.create_draw_subtitle", "Tạo style nền sáng, nét thưa để renderer tay/bút dựng dần toàn ảnh."))
                            : (void i18n.revision, i18n.t("style_edit.create_subtitle", "Tạo framework dùng lại cho Master, Clone và Batch Image. AI phân tích xong sẽ tự tạo preview."))
                        color: VfTheme.textMuted
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        elide: Text.ElideRight
                    }
                }

                // Kind picker Style/Camera đã bỏ cùng Camera Framework — mọi
                // framework tạo mới đều là style; sửa item camera cũ vẫn giữ kind.
                IconCloseButton {
                    onClicked: root.reject()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: VfTheme.border
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: VfTheme.dp(16)
            spacing: VfTheme.dp(12)

            SectionPanel {
                Layout.preferredWidth: Math.max(VfTheme.dp(310), Math.round(root.width * 0.30))
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("style_edit.setup_title", "Thiết lập"))
                iconName: "settings"

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.authoring_type", "Loại framework")) }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(42)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: root.drawAuthoring ? "#F59E0B" : VfTheme.borderBox

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(4)
                        spacing: VfTheme.dp(4)

                        SegmentChoice {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            label: (void i18n.revision, i18n.t("style_edit.mode_style", "Style thường"))
                            iconName: "artist-palette"
                            selected: !root.drawAuthoring
                            enabled: root.canChangeKind
                            onClicked: root.setAuthoringMode("style")
                        }

                        SegmentChoice {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            label: (void i18n.revision, i18n.t("style_edit.mode_draw", "Draw / VideoScribe"))
                            iconName: "pencil"
                            selected: root.drawAuthoring
                            enabled: root.canChangeKind
                            onClicked: root.setAuthoringMode("draw")
                        }
                    }
                }

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.optional_name", "Tên hiển thị")) }

                TextField {
                    id: nameInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(42)
                    text: root.styleName
                    placeholderText: (void i18n.revision, i18n.t("style_edit.optional_name_placeholder", "Để trống để AI tự đặt tên"))
                    selectByMouse: true
                    color: VfTheme.text
                    placeholderTextColor: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    onTextChanged: {
                        if (root.styleName !== text)
                            root.styleName = text
                    }
                    background: Rectangle {
                        color: VfTheme.surface
                        border.color: nameInput.activeFocus ? VfTheme.primary : VfTheme.borderBox
                        border.width: 1
                        radius: VfTheme.dp(7)
                    }
                    leftPadding: VfTheme.dp(12)
                    rightPadding: VfTheme.dp(12)
                }

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.reference_preview", "Ảnh tham chiếu")) }

                Rectangle {
                    id: referencePanel

                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(132)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: VfTheme.borderBox
                    focus: true
                    activeFocusOnTab: true

                    TapHandler {
                        onTapped: referencePanel.forceActiveFocus()
                    }

                    Keys.onPressed: {
                        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) {
                            root.pasteReferenceRequested()
                            event.accepted = true
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        Label {
                            Layout.fillWidth: true
                            text: root.referenceImagePath.trim().length > 0
                                ? (void i18n.revision, i18n.t("style_edit.reference_ready", "Ảnh tham chiếu đã sẵn sàng. Preview đầy đủ hiển thị bên dưới."))
                                : (void i18n.revision, i18n.t("style_edit.drop_or_paste", "Chọn ảnh, dán ảnh, hoặc nhấn Ctrl+V tại đây"))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            wrapMode: Text.WordWrap
                            elide: Text.ElideRight
                        }

                        TextField {
                            id: refInput
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(36)
                            text: root.referenceImagePath
                            placeholderText: (void i18n.revision, i18n.t("style_edit.reference_path_placeholder", "Đường dẫn ảnh mẫu tùy chọn"))
                            selectByMouse: true
                            color: VfTheme.text
                            placeholderTextColor: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            onTextChanged: {
                                if (root.referenceImagePath !== text)
                                    root.referenceImagePath = text
                            }
                            Keys.onPressed: {
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) {
                                    root.pasteReferenceRequested()
                                    event.accepted = true
                                }
                            }
                            background: Rectangle {
                                color: VfTheme.surface
                                border.color: VfTheme.borderBox
                                border.width: 1
                                radius: VfTheme.dp(6)
                            }
                            leftPadding: VfTheme.dp(10)
                            rightPadding: VfTheme.dp(10)
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            VfButton {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("styles_mgmt_v3.choose_image", "Chọn ảnh"))
                                compact: true
                                minWidth: VfTheme.dp(70)
                                iconName: "upload"
                                onClicked: root.chooseReferenceRequested()
                            }

                            VfButton {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("style_edit.paste_image", "Dán ảnh"))
                                compact: true
                                minWidth: VfTheme.dp(70)
                                iconName: "clipboard"
                                onClicked: root.pasteReferenceRequested()
                            }

                            VfButton {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("common.clear", "Xóa"))
                                compact: true
                                minWidth: VfTheme.dp(70)
                                tone: "danger"
                                iconName: "x"
                                enabled: root.referenceImagePath.trim().length > 0
                                onClicked: root.referenceImagePath = ""
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(46)
                    radius: VfTheme.dp(8)
                    color: VfTheme.blueFill
                    border.width: 1
                    border.color: VfTheme.blueBorderSoft

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        VfAppIcon {
                            name: "light-bulb"
                            size: VfTheme.dp(16)
                            color: VfTheme.primary
                        }

                        Label {
                            Layout.fillWidth: true
                            text: (void i18n.revision, i18n.t("style_edit.reference_rule", "AI chỉ trích xuất cách tạo hình, không copy nội dung/chủ thể trong ảnh."))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                Rectangle {
                    id: referenceLargePreview

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: VfTheme.dp(150)
                    radius: VfTheme.dp(10)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: root.referenceImagePath.trim().length > 0 ? VfTheme.blueBorderSoft : VfTheme.borderBox
                    clip: true

                    Image {
                        id: largeReferenceImage

                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        source: root.localFileSource(root.referenceImagePath)
                        visible: root.referenceImagePath.trim().length > 0 && status !== Image.Error
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        cache: false
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(8)
                        visible: root.referenceImagePath.trim().length === 0 || largeReferenceImage.status === Image.Error

                        VfAppIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "image"
                            size: VfTheme.dp(34)
                            color: root.referenceImagePath.trim().length > 0 ? "#DC2626" : VfTheme.primary
                        }

                        Label {
                            width: Math.min(referenceLargePreview.width - VfTheme.dp(32), VfTheme.dp(260))
                            text: root.referenceImagePath.trim().length > 0
                                ? (void i18n.revision, i18n.t("style_edit.reference_load_failed", "Không tải được ảnh tham chiếu. Kiểm tra lại đường dẫn hoặc dán ảnh lại."))
                                : (void i18n.revision, i18n.t("style_edit.reference_large_empty", "Ảnh tham chiếu sẽ hiển thị tại đây."))
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                    Rectangle {
                        visible: root.referenceImagePath.trim().length > 0 && largeReferenceImage.status !== Image.Error
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(10)
                        height: VfTheme.dp(24)
                        radius: VfTheme.dp(12)
                        color: VfTheme.surface
                        border.width: 1
                        border.color: VfTheme.borderBox
                        width: referenceBadgeLabel.implicitWidth + VfTheme.dp(18)

                        Label {
                            id: referenceBadgeLabel
                            anchors.centerIn: parent
                            text: (void i18n.revision, i18n.t("style_edit.reference_badge", "Ảnh tham chiếu"))
                            color: VfTheme.primary
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            font.weight: VfTheme.weightStrong
                        }
                    }
                }
            }

            SectionPanel {
                Layout.preferredWidth: Math.max(VfTheme.dp(330), Math.round(root.width * 0.31))
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("style_edit.ai_panel_title", "AI phân tích framework"))
                iconName: "sparkles"

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.idea_label", "Mô tả / prompt style (tự nhập được)")) }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: VfTheme.dp(190)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.borderBox

                    TextArea {
                        id: ideaInput
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        text: root.ideaText
                        placeholderText: root.drawAuthoring
                            ? (void i18n.revision, i18n.t("style_edit.draw_idea_placeholder", "Ví dụ: stickman nét mực đen, vài đạo cụ màu phẳng, nền giấy trắng rộng, ít chi tiết, không 3D/ảnh thật/texture dày."))
                            : (void i18n.revision, i18n.t("style_edit.idea_placeholder", "Mô tả công thức style/camera muốn dùng lại. Ví dụ: tài liệu handheld 16mm có hạt phim, ánh sáng tự nhiên ấm, cận cảnh thân mật, không drone/orbit."))
                        wrapMode: TextArea.Wrap
                        selectByMouse: true
                        color: VfTheme.text
                        placeholderTextColor: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        onTextChanged: {
                            if (root.ideaText !== text)
                                root.ideaText = text
                        }
                        background: Rectangle {
                            color: VfTheme.surface
                        }
                    }

                    Label {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: VfTheme.dp(9)
                        text: String(ideaInput.text.length) + "/2000"
                        color: VfTheme.textSubtle
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(10)
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)

                    VfButton {
                        // Save the typed prompt directly — no AI needed.
                        text: (void i18n.revision, i18n.t("style_edit.manual_save", "Lưu thủ công"))
                        tone: "neutral"
                        minWidth: VfTheme.dp(132)
                        implicitHeight: VfTheme.dp(42)
                        iconName: "save"
                        enabled: !root.aiBusy
                        onClicked: root.emitManualSave()
                    }

                    VfButton {
                        Layout.fillWidth: true
                        text: root.aiBusy
                            ? (void i18n.revision, i18n.t("style_edit.ai_analyzing_btn", "Đang phân tích…"))
                            : (void i18n.revision, i18n.t("style_edit.ai_analyze", "AI phân tích"))
                        tone: "primary"
                        minWidth: VfTheme.dp(140)
                        implicitHeight: VfTheme.dp(42)
                        iconName: root.aiBusy ? "timer" : "sparkles"
                        enabled: !root.aiBusy
                        onClicked: root.emitAiAnalyze()
                    }
                }

                // Live activity strip — visible while AI runs so the dialog never looks frozen.
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(40)
                    radius: VfTheme.dp(8)
                    visible: root.aiBusy
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: VfTheme.primary
                    clip: true

                    // Soft indeterminate bar (no GraphicsEffects)
                    Rectangle {
                        id: aiBusyShimmer
                        width: parent.width * 0.35
                        height: parent.height
                        radius: parent.radius
                        opacity: 0.22
                        color: VfTheme.primary
                        x: -width

                        SequentialAnimation on x {
                            running: root.aiBusy
                            loops: Animation.Infinite
                            NumberAnimation {
                                from: -aiBusyShimmer.width
                                to: aiBusyShimmer.parent ? aiBusyShimmer.parent.width : 400
                                duration: 1400
                                easing.type: Easing.InOutSine
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        BusyIndicator {
                            running: root.aiBusy
                            implicitWidth: VfTheme.dp(18)
                            implicitHeight: VfTheme.dp(18)
                            Layout.preferredWidth: VfTheme.dp(18)
                            Layout.preferredHeight: VfTheme.dp(18)
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.aiPhaseText
                            color: VfTheme.primary
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                    }
                }

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.checklist_title", "Kiểm tra nội dung mô tả")) }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: VfTheme.dp(8)
                    columnSpacing: VfTheme.dp(8)

                    CheckTile {
                        Layout.fillWidth: true
                        title: "Reusable"
                        subtitle: (void i18n.revision, i18n.t("style_edit.check_reusable", "Đủ thông tin để tái sử dụng"))
                    }

                    CheckTile {
                        Layout.fillWidth: true
                        title: (void i18n.revision, i18n.t("style_edit.check_no_subject_title", "Không copy chủ thể"))
                        subtitle: (void i18n.revision, i18n.t("style_edit.check_no_subject", "Tập trung vào phong cách"))
                    }

                    CheckTile {
                        Layout.fillWidth: true
                        title: (void i18n.revision, i18n.t("style_edit.check_negative_title", "Có negative rules"))
                        subtitle: (void i18n.revision, i18n.t("style_edit.check_negative", "Hạn chế rõ ràng"))
                    }

                    CheckTile {
                        Layout.fillWidth: true
                        title: (void i18n.revision, i18n.t("style_edit.check_dispatch_title", "Có dispatch prompt"))
                        subtitle: (void i18n.revision, i18n.t("style_edit.check_dispatch", "Hướng dẫn hệ thống rõ ràng"))
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(42)
                    radius: VfTheme.dp(8)
                    color: root.aiBusy
                        ? VfTheme.surfaceSoft
                        : (root.frameworkJson.trim().length > 0 ? VfTheme.greenFill : VfTheme.surfaceSoft)
                    border.width: 1
                    border.color: root.aiBusy
                        ? VfTheme.borderBox
                        : (root.frameworkJson.trim().length > 0 ? VfTheme.greenBorderSoft : VfTheme.borderBox)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        VfAppIcon {
                            name: root.aiBusy
                                ? "timer"
                                : (root.frameworkJson.trim().length > 0 ? "shield-check" : "timer")
                            size: VfTheme.dp(16)
                            color: root.aiBusy
                                ? VfTheme.primary
                                : (root.frameworkJson.trim().length > 0 ? "#059669" : VfTheme.textMuted)
                        }

                        Label {
                            Layout.fillWidth: true
                            text: root.aiBusy
                                ? root.aiPhaseText
                                : (root.frameworkJson.trim().length > 0
                                    ? (void i18n.revision, i18n.t("style_edit.ready_json", "Đã có framework JSON, sẵn sàng lưu."))
                                    : (void i18n.revision, i18n.t("style_edit.waiting_json", "Sẵn sàng phân tích để tạo framework JSON.")))
                            color: root.aiBusy
                                ? VfTheme.primary
                                : (root.frameworkJson.trim().length > 0 ? VfTheme.greenText : VfTheme.textMuted)
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            SectionPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: (void i18n.revision, i18n.t("style_edit.result_title", "Kết quả"))
                iconName: "image"

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(230)
                    radius: VfTheme.dp(9)
                    color: VfTheme.surfaceSoft
                    border.width: 1
                    border.color: VfTheme.borderBox
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(6)
                        source: root.localFileSource(root.previewImagePath)
                        visible: root.previewImagePath.trim().length > 0
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        asynchronous: true
                        cache: false
                    }

                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: VfTheme.dp(10)
                        spacing: VfTheme.dp(8)

                        MiniBadge {
                            textValue: (void i18n.revision, i18n.t("style_edit.preview_badge", "Preview"))
                            fillColor: VfTheme.surface
                            textColor: VfTheme.text
                        }

                        Item { Layout.fillWidth: true }

                        MiniBadge {
                            textValue: root.frameworkJson.trim().length > 0
                                ? (void i18n.revision, i18n.t("style_edit.unsaved_badge", "Chưa lưu"))
                                : (void i18n.revision, i18n.t("style_edit.waiting_badge", "Đang chờ"))
                            fillColor: root.frameworkJson.trim().length > 0 ? VfTheme.greenFill : VfTheme.surfaceSoft
                            textColor: root.frameworkJson.trim().length > 0 ? VfTheme.greenText : VfTheme.textMuted
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(8)
                        visible: root.previewImagePath.trim().length === 0

                        BusyIndicator {
                            anchors.horizontalCenter: parent.horizontalCenter
                            running: root.aiBusy
                            visible: root.aiBusy
                            implicitWidth: VfTheme.dp(36)
                            implicitHeight: VfTheme.dp(36)
                        }

                        VfAppIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            name: "image"
                            size: VfTheme.dp(36)
                            color: VfTheme.primary
                            visible: !root.aiBusy
                        }

                        Label {
                            width: VfTheme.dp(260)
                            text: root.aiBusy
                                ? root.aiPhaseText
                                : (root.previewMessage.length > 0
                                    ? root.previewMessage
                                    : (void i18n.revision, i18n.t("style_edit.preview_waiting", "Preview sẽ tự xuất hiện sau khi AI phân tích.")))
                            color: root.aiBusy ? VfTheme.primary : VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Dim overlay when regenerating with an existing preview still shown.
                    Rectangle {
                        anchors.fill: parent
                        visible: root.aiBusy && root.previewImagePath.trim().length > 0
                        color: Qt.rgba(0, 0, 0, 0.35)

                        Column {
                            anchors.centerIn: parent
                            spacing: VfTheme.dp(8)

                            BusyIndicator {
                                anchors.horizontalCenter: parent.horizontalCenter
                                running: parent.parent.visible
                                implicitWidth: VfTheme.dp(32)
                                implicitHeight: VfTheme.dp(32)
                            }

                            Label {
                                width: VfTheme.dp(220)
                                text: root.aiPhaseText
                                color: "#FFFFFF"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: VfTheme.dp(62)
                    radius: VfTheme.dp(8)
                    color: VfTheme.surface
                    border.width: 1
                    border.color: VfTheme.border

                    GridLayout {
                        anchors.fill: parent
                        anchors.margins: VfTheme.dp(8)
                        columns: 3
                        columnSpacing: VfTheme.dp(10)

                        ResultMetric {
                            Layout.fillWidth: true
                            label: "Summary"
                            value: root.cleanOneLine(root.veo3Prompt || root.ideaText, (void i18n.revision, i18n.t("style_edit.waiting_result", "Chưa có kết quả")))
                        }

                        ResultMetric {
                            Layout.fillWidth: true
                            label: "ID"
                            value: root.styleId.length > 0 ? root.styleId : "-"
                        }

                        ResultMetric {
                            Layout.fillWidth: true
                            label: "Type"
                            value: root.kindLabel()
                        }
                    }
                }

                FieldLabel { text: (void i18n.revision, i18n.t("style_edit.framework_json", "Framework JSON")) }

                TextArea {
                    id: frameworkText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: root.frameworkJson
                    placeholderText: (void i18n.revision, i18n.t("style_edit.framework_placeholder", "AI phân tích xong sẽ hiển thị JSON ở đây."))
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    color: VfTheme.textMuted
                    placeholderTextColor: VfTheme.textSubtle
                    font.family: "Consolas"
                    font.pixelSize: VfTheme.dp(11)
                    onTextChanged: {
                        if (root.frameworkJson !== text)
                            root.frameworkJson = text
                    }
                    background: Rectangle {
                        color: VfTheme.surface
                        border.width: 1
                        border.color: VfTheme.borderBox
                        radius: VfTheme.dp(8)
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(68)
            color: VfTheme.surface
            border.width: 0

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: VfTheme.border
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(18)
                spacing: VfTheme.dp(12)

                BusyIndicator {
                    running: root.aiBusy
                    visible: root.aiBusy
                    implicitWidth: VfTheme.dp(16)
                    implicitHeight: VfTheme.dp(16)
                    Layout.preferredWidth: VfTheme.dp(16)
                    Layout.preferredHeight: VfTheme.dp(16)
                }

                VfAppIcon {
                    name: root.aiBusy ? "timer" : "light-bulb"
                    size: VfTheme.dp(16)
                    color: root.aiBusy ? VfTheme.primary : VfTheme.textMuted
                    visible: !root.aiBusy
                }

                Label {
                    Layout.fillWidth: true
                    text: root.statusText
                    color: root.aiBusy ? VfTheme.primary : VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    elide: Text.ElideRight
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                    minWidth: VfTheme.dp(106)
                    implicitHeight: VfTheme.dp(42)
                    enabled: !root.aiBusy
                    onClicked: root.reject()
                }

                VfButton {
                    text: root.drawAuthoring
                        ? (void i18n.revision, i18n.t("style_edit.save_draw", "Lưu Draw style"))
                        : root.styleKind === "camera"
                        ? (void i18n.revision, i18n.t("style_edit.save_camera", "Lưu camera"))
                        : (void i18n.revision, i18n.t("style_edit.save_style", "Lưu style"))
                    tone: "primary"
                    minWidth: VfTheme.dp(132)
                    implicitHeight: VfTheme.dp(42)
                    iconName: "save"
                    enabled: !root.aiBusy && root.frameworkJson.trim().length > 0
                    onClicked: root.emitSave()
                }
            }
        }
    }

    component SegmentChoice: Rectangle {
        id: segment

        property string label: ""
        property string iconName: ""
        property bool selected: false
        signal clicked()

        radius: VfTheme.dp(7)
        color: selected ? VfTheme.surface : "transparent"
        border.width: selected ? 1 : 0
        border.color: selected ? VfTheme.primary : "transparent"

        Row {
            anchors.centerIn: parent
            spacing: VfTheme.dp(6)

            VfAppIcon {
                anchors.verticalCenter: parent.verticalCenter
                name: segment.iconName
                size: VfTheme.dp(15)
                color: segment.selected ? VfTheme.primary : VfTheme.textMuted
            }

            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: segment.label
                color: segment.selected ? VfTheme.primary : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: segment.selected ? VfTheme.weightStrong : VfTheme.weightControl
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: segment.clicked()
        }
    }

    component IconCloseButton: Rectangle {
        id: closeButton

        signal clicked()

        Layout.preferredWidth: VfTheme.dp(38)
        Layout.preferredHeight: VfTheme.dp(38)
        radius: VfTheme.dp(9)
        color: closeArea.containsMouse ? VfTheme.surfaceSoft : VfTheme.surface
        border.width: 1
        border.color: closeArea.containsMouse ? VfTheme.borderStrong : VfTheme.border

        VfAppIcon {
            anchors.centerIn: parent
            name: "x"
            size: VfTheme.dp(18)
            color: closeArea.containsMouse ? "#DC2626" : VfTheme.text
        }

        MouseArea {
            id: closeArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: closeButton.clicked()
        }
    }

    component SectionPanel: Rectangle {
        id: panel

        property string title: ""
        property string iconName: ""
        default property alias contentData: panelBody.data

        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.borderBox

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(12)
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfAppIcon {
                    name: panel.iconName
                    size: VfTheme.dp(18)
                    color: VfTheme.primary
                }

                Label {
                    Layout.fillWidth: true
                    text: panel.title
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(15)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }
            }

            ColumnLayout {
                id: panelBody
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: VfTheme.dp(8)
            }
        }
    }

    component FieldLabel: Label {
        Layout.fillWidth: true
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        font.weight: VfTheme.weightStrong
    }

    component MiniBadge: Rectangle {
        id: badge

        property string textValue: ""
        property color fillColor: VfTheme.surface
        property color textColor: VfTheme.text

        Layout.preferredHeight: VfTheme.dp(26)
        implicitWidth: badgeLabel.implicitWidth + VfTheme.dp(18)
        radius: VfTheme.dp(13)
        color: fillColor
        border.width: 1
        border.color: VfTheme.border

        Label {
            id: badgeLabel
            anchors.centerIn: parent
            text: badge.textValue
            color: badge.textColor
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            font.weight: VfTheme.weightStrong
        }
    }

    component CheckTile: Rectangle {
        id: checkTile

        property string title: ""
        property string subtitle: ""

        Layout.preferredHeight: VfTheme.dp(62)
        radius: VfTheme.dp(8)
        color: VfTheme.surface
        border.width: 1
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(10)
            spacing: VfTheme.dp(8)

            VfAppIcon {
                name: "check"
                size: VfTheme.dp(16)
                color: VfTheme.greenText
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(1)

                Label {
                    Layout.fillWidth: true
                    text: checkTile.title
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    font.weight: VfTheme.weightStrong
                    elide: Text.ElideRight
                }

                Label {
                    Layout.fillWidth: true
                    text: checkTile.subtitle
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    elide: Text.ElideRight
                }
            }
        }
    }

    component ResultMetric: ColumnLayout {
        id: metric

        property string label: ""
        property string value: ""

        spacing: VfTheme.dp(2)

        Label {
            Layout.fillWidth: true
            text: metric.label
            color: VfTheme.primary
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(10)
            font.weight: VfTheme.weightStrong
            elide: Text.ElideRight
        }

        Label {
            Layout.fillWidth: true
            text: metric.value
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(64))
        padding: VfTheme.dp(18)
        parent: Overlay.overlay
        anchors.centerIn: parent
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.ok", "OK"))
                    tone: "primary"
                    minWidth: VfTheme.dp(96)
                    onClicked: feedbackDialog.close()
                }
            }
        }
    }
}
