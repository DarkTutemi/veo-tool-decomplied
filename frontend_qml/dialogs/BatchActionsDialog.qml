import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var jobs: []
    property var selectedJobs: []
    property var failedJobs: []
    property var checkedIds: []
    property int currentIndex: -1
    property string validationMessage: ""
    property string feedbackTitle: ""
    property string feedbackMessage: ""

    signal applyRequested(var result)

    header: VfDialogHeader {
        title: (void i18n.revision, i18n.t("batch_actions.title", "Batch Actions"))
        iconName: "check-box-with-check"
        onCloseClicked: root.reject()
    }
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1125), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(750), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    onOpened: {
        root.validationMessage = ""
        root.selectAll()
        if (root.jobs && root.jobs.length > 0)
            root.currentIndex = 0
    }

    function jobId(job) {
        return String(job.job_id || job.row_id || job.id || "")
    }

    function jobPrompt(job) {
        return String(job.prompt || job.source || job.title || job.idea || "")
    }

    function jobStatus(job) {
        return String(job.status || job.state || "queued")
    }

    function statusText(status) {
        var key = String(status || "").toLowerCase()
        if (key === "failed")
            return (void i18n.revision, i18n.t("batch_actions.status_failed", "Failed"))
        if (key === "completed" || key === "done")
            return (void i18n.revision, i18n.t("batch_actions.status_completed", "Completed"))
        if (key === "generating" || key === "running")
            return (void i18n.revision, i18n.t("batch_actions.status_generating", "Generating"))
        if (key === "upscaling")
            return (void i18n.revision, i18n.t("batch_actions.status_upscaling", "Upscaling"))
        if (key === "pending")
            return (void i18n.revision, i18n.t("batch_actions.status_pending", "Pending"))
        return (void i18n.revision, i18n.t("batch_actions.status_queued", "Queued"))
    }

    function selectedJobIds(source) {
        var rows = source || []
        var ids = []
        for (var i = 0; i < rows.length; i++) {
            var id = root.jobId(rows[i])
            if (id.length > 0)
                ids.push(id)
        }
        return ids
    }

    function hasChecked(id) {
        return root.checkedIds.indexOf(String(id)) >= 0
    }

    function setChecked(id, checked) {
        id = String(id || "")
        if (id.length === 0)
            return
        var next = root.checkedIds.slice()
        var idx = next.indexOf(id)
        if (checked && idx < 0)
            next.push(id)
        if (!checked && idx >= 0)
            next.splice(idx, 1)
        root.checkedIds = next
    }

    function selectAll() {
        root.checkedIds = root.selectedJobIds(root.jobs)
    }

    function selectNone() {
        root.checkedIds = []
    }

    function selectOnlySelected() {
        root.checkedIds = root.selectedJobIds(root.selectedJobs)
    }

    function selectOnlyFailed() {
        var explicitFailed = root.selectedJobIds(root.failedJobs)
        if (explicitFailed.length > 0) {
            root.checkedIds = explicitFailed
            return
        }
        var ids = []
        for (var i = 0; i < (root.jobs || []).length; i++) {
            var row = root.jobs[i]
            var status = root.jobStatus(row).toLowerCase()
            if (status === "failed" || status === "error")
                ids.push(root.jobId(row))
        }
        root.checkedIds = ids
    }

    function currentJob() {
        if (!root.jobs || root.currentIndex < 0 || root.currentIndex >= root.jobs.length)
            return ({})
        return root.jobs[root.currentIndex]
    }

    function previewPrompt() {
        var original = root.jobPrompt(root.currentJob())
        if (overrideCheck.checked)
            return overrideEditor.text.length > 0 ? overrideEditor.text : (void i18n.revision, i18n.t("batch_actions.enter_new_prompt_hint", "Enter a new prompt to replace the selected jobs."))
        if (injectCheck.checked && prependInput.text.length > 0)
            return prependInput.text + original
        return original
    }

    function showFeedback(title, message) {
        root.feedbackTitle = String(title || (void i18n.revision, i18n.t("common.notice", "Notice")))
        root.feedbackMessage = String(message || "")
        feedbackDialog.open()
    }

    function applyResult(result) {
        var payload = result || ({})
        root.validationMessage = String(payload.message || "")
        if (payload.ok) {
            root.accept()
            return
        }
        root.showFeedback(
            (void i18n.revision, i18n.t("batch_actions.apply_failed_title", "Batch action failed")),
            String(payload.message || payload.error || (void i18n.revision, i18n.t("batch_actions.apply_failed_message", "Could not apply the requested batch actions.")))
        )
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(12)

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 16
            spacing: VfTheme.dp(8)

            Text {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.select_label", "Chọn:"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.Bold
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.select_all_button", "Tất cả (")) + (root.jobs ? root.jobs.length : 0) + ")"
                leadingIcon: "check-mark-button"
                tone: "success"
                minWidth: VfTheme.dp(82)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.selectAll()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.deselect_all_button", "Bỏ chọn"))
                leadingIcon: "cross-mark"
                tone: "danger"
                minWidth: VfTheme.dp(76)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.selectNone()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.select_selected_button", "Đã chọn (")) + (root.selectedJobs ? root.selectedJobs.length : 0) + ")"
                leadingIcon: "check-box-with-check"
                tone: "accent"
                minWidth: VfTheme.dp(106)
                implicitHeight: VfTheme.dp(28)
                enabled: root.selectedJobs && root.selectedJobs.length > 0
                onClicked: root.selectOnlySelected()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.select_failed_button", "Lỗi (")) + (root.failedJobs ? root.failedJobs.length : 0) + ")"
                leadingIcon: "cross-mark"
                tone: "warning"
                minWidth: VfTheme.dp(90)
                implicitHeight: VfTheme.dp(28)
                onClicked: root.selectOnlyFailed()
            }

            Text {
                Layout.fillWidth: true
                visible: root.validationMessage.length > 0
                text: root.validationMessage
                color: VfTheme.redText
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
            }

            CheckBox {
                id: retryCheck
                text: "Retry"
                checked: true
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.Bold
            }

            CheckBox {
                id: injectCheck
                text: (void i18n.revision, i18n.t("batch_actions_dialog.inject_text_checkbox", "Thêm text"))
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(12)
                font.weight: Font.Bold
            }
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            orientation: Qt.Horizontal

            Rectangle {
                SplitView.preferredWidth: Math.min(VfTheme.dp(500), Math.max(VfTheme.dp(320), Math.round(root.width * 0.48)))
                SplitView.minimumWidth: Math.min(VfTheme.dp(380), Math.max(VfTheme.dp(260), Math.round(root.width * 0.34)))
                color: VfTheme.surface

                ColumnLayout {
                    anchors.fill: parent
                    spacing: VfTheme.dp(4)

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: (void i18n.revision, i18n.t("batch_actions_dialog.jobs_list_title", "Danh sách Jobs"))
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.checkedIds.length + "/" + (root.jobs ? root.jobs.length : 0) + " " + (void i18n.revision, i18n.t("batch_actions_dialog.selected_count_suffix", "đã chọn"))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(34)
                        radius: VfTheme.dp(6)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: 0

                            HeaderCell { Layout.preferredWidth: VfTheme.dp(34); text: "" }
                            HeaderCell { Layout.preferredWidth: VfTheme.dp(86); text: (void i18n.revision, i18n.t("batch_actions_dialog.status_column_header", "Trạng thái")) }
                            HeaderCell { Layout.fillWidth: true; text: "Prompt" }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: VfTheme.dp(6)
                        color: VfTheme.surface
                        border.color: VfTheme.border
                        clip: true

                        ListView {
                            id: jobList
                            anchors.fill: parent
                            model: root.jobs || []  // perf-lint: disable=R2  user-action list via a component alias; reuseItems recycles delegates — QAbstractListModel deferred
                            clip: true
                            reuseItems: true

                            delegate: Rectangle {
                                width: jobList.width
                                height: VfTheme.dp(44)
                                color: index === root.currentIndex ? VfTheme.violetFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft)
                                border.color: VfTheme.surfaceSoft

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: 0

                                    CheckBox {
                                        Layout.preferredWidth: VfTheme.dp(34)
                                        checked: root.hasChecked(root.jobId(modelData))
                                        onToggled: root.setChecked(root.jobId(modelData), checked)
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(86)
                                        text: root.statusText(root.jobStatus(modelData))
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.jobPrompt(modelData)
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.dp(11)
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton
                                    onClicked: root.currentIndex = index
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: false
                            text: (void i18n.revision, i18n.t("batch_actions.no_jobs", "No jobs to edit."))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(12)
                        }
                    }
                }
            }

            Rectangle {
                SplitView.fillWidth: true
                SplitView.minimumWidth: Math.min(VfTheme.dp(320), Math.max(VfTheme.dp(240), Math.round(root.width * 0.30)))
                color: VfTheme.surface

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(8)
                    spacing: VfTheme.dp(8)

                    Text {
                        text: (void i18n.revision, i18n.t("batch_actions_dialog.details_and_edit_title", "Chi tiết && Chỉnh sửa"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }

                    AccentBox {
                        Layout.fillWidth: true
                        colorValue: VfTheme.amberFill
                        borderValue: VfTheme.amberBorderSoft

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(8)
                            spacing: VfTheme.dp(4)

                            Text {
                                text: (void i18n.revision, i18n.t("batch_actions_dialog.prepend_prompt_label", "Thêm vào đầu prompt:"))
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }

                            TextField {
                                id: prependInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(30)
                                enabled: !overrideCheck.checked
                                placeholderText: (void i18n.revision, i18n.t("batch_actions_dialog.prepend_input_placeholder", "Nhập text muốn thêm vào ĐẦU mỗi prompt..."))
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(12)
                                background: Rectangle {
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surface
                                    border.color: VfTheme.amberBorderSoft
                                }
                            }
                        }
                    }

                    AccentBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(116)
                        colorValue: VfTheme.redFill
                        borderValue: VfTheme.redBorderSoft

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(8)
                            spacing: VfTheme.dp(4)

                            CheckBox {
                                id: overrideCheck
                                text: (void i18n.revision, i18n.t("batch_actions_dialog.override_all_prompts_checkbox", "Ghi đè toàn bộ prompt (áp dụng 1 prompt cho tất cả)"))
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                font.weight: Font.Bold
                            }

                            TextArea {
                                id: overrideEditor
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                enabled: overrideCheck.checked
                                placeholderText: (void i18n.revision, i18n.t("batch_actions_dialog.override_editor_placeholder", "Nhập prompt mới sẽ thay thế tất cả prompt cũ..."))
                                wrapMode: TextArea.Wrap
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(11)
                                background: Rectangle {
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surface
                                    border.color: VfTheme.redBorderSoft
                                }
                            }
                        }
                    }

                    Text {
                        text: (void i18n.revision, i18n.t("batch_actions_dialog.original_prompt_label", "Prompt gốc:"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    TextBox {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(120)
                        text: root.jobPrompt(root.currentJob())
                        placeholder: (void i18n.revision, i18n.t("batch_actions_dialog.original_prompt_placeholder", "Chọn 1 job từ bảng bên trái để xem..."))
                        readOnly: true
                        fillColor: VfTheme.surfaceSoft
                        borderColor: VfTheme.border
                    }

                    Text {
                        text: (void i18n.revision, i18n.t("batch_actions_dialog.preview_after_add_label", "Xem trước sau khi thêm:"))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        font.weight: Font.Bold
                    }

                    TextBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.previewPrompt()
                        placeholder: (void i18n.revision, i18n.t("batch_actions_dialog.preview_placeholder", "Preview sẽ hiện ở đây..."))
                        readOnly: true
                        fillColor: VfTheme.greenFill
                        borderColor: "#10B981"
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.bottomMargin: 16
            spacing: VfTheme.dp(8)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                minWidth: VfTheme.dp(100)
                onClicked: root.reject()
            }

            VfButton {
                text: (void i18n.revision, i18n.t("batch_actions_dialog.apply_button", "Áp dụng cho ")) + root.checkedIds.length + " jobs"
                tone: "accent"
                minWidth: VfTheme.dp(180)
                enabled: root.checkedIds.length > 0 && (retryCheck.checked || injectCheck.checked)
                onClicked: {
                    root.validationMessage = ""
                    root.applyRequested({
                        accepted: true,
                        action_retry: retryCheck.checked,
                        action_inject: injectCheck.checked && !overrideCheck.checked,
                        action_override: overrideCheck.checked,
                        inject_text: injectCheck.checked && !overrideCheck.checked ? prependInput.text : "",
                        override_text: overrideCheck.checked ? overrideEditor.text : "",
                        job_ids: root.checkedIds
                    })
                }
            }
        }
    }

    Dialog {
        id: feedbackDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(390), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.border
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: root.feedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: root.feedbackMessage
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4

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

    component HeaderCell: Text {
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(11)
        font.weight: Font.Bold
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component AccentBox: Rectangle {
        property color colorValue: VfTheme.surface
        property color borderValue: VfTheme.border

        implicitHeight: VfTheme.dp(74)
        radius: VfTheme.dp(6)
        color: colorValue
        border.color: borderValue
    }

    component TextBox: Rectangle {
        id: textBoxRoot
        property alias text: editor.text
        property alias placeholder: editor.placeholderText
        property bool readOnly: false
        property color fillColor: VfTheme.surface
        property color borderColor: VfTheme.border

        radius: VfTheme.dp(6)
        color: fillColor
        border.color: borderColor
        clip: true

        ScrollView {
            id: textBoxScroll
            anchors.fill: parent
            anchors.margins: VfTheme.dp(7)
            contentWidth: availableWidth
            contentHeight: editor.implicitHeight
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
                id: editor
                width: textBoxScroll.availableWidth
                readOnly: textBoxRoot.readOnly
                wrapMode: TextArea.Wrap
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                color: VfTheme.text
                background: Item {}
            }
        }
    }
}
