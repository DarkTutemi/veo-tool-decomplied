import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Kiểm duyệt nội dung AI: xem / sửa / bỏ chọn từng kịch bản trước khi tạo audio.
// Chỉ kịch bản được DUYỆT (checkbox) mới đẩy vào hàng chờ → TTS → quy trình gốc.
Dialog {
    id: root

    property string category: ""
    property var voiceOptions: []
    property string voiceValue: ""
    property var emotionOptions: []
    property string emotionValue: ""
    property string emotionProvider: ""
    property var trText: function(key, fallback) { return fallback }

    // items: [{title, script}] đã duyệt + voice + category + emotion
    signal approveRequested(var items, string voice, string category, string emotion)

    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape
    width: VfDialogMetrics.width(parent, VfTheme.dp(900), VfTheme.dp(80))
    height: VfDialogMetrics.height(parent, VfTheme.dp(760), VfTheme.dp(80))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderBox
    }

    ListModel { id: reviewModel }

    function openWith(items) {
        reviewModel.clear()
        var arr = items || []
        for (var i = 0; i < arr.length; i++) {
            reviewModel.append({
                "title": String((arr[i] && arr[i].title) || ((void i18n.revision, i18n.t("transcript_content_review_dialog.script_default", "Kịch bản ")) + (i + 1))),
                "script": String((arr[i] && arr[i].script) || ""),
                "approved": true
            })
        }
        root.open()
    }

    function approvedCount() {
        var n = 0
        for (var i = 0; i < reviewModel.count; i++) {
            var it = reviewModel.get(i)
            if (it.approved && String(it.script).trim().length > 0)
                n += 1
        }
        return n
    }

    function collectApproved() {
        var out = []
        for (var i = 0; i < reviewModel.count; i++) {
            var it = reviewModel.get(i)
            if (it.approved && String(it.script).trim().length > 0)
                out.push({ "title": String(it.title), "script": String(it.script) })
        }
        return out
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(62)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border
            topLeftRadius: VfTheme.dp(10)
            topRightRadius: VfTheme.dp(10)

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(16)
                anchors.rightMargin: VfTheme.dp(16)
                anchors.topMargin: VfTheme.dp(10)
                anchors.bottomMargin: VfTheme.dp(10)
                spacing: VfTheme.dp(2)

                Text {
                    text: (void i18n.revision, i18n.t("transcript_content_review_dialog.title", "Kiểm duyệt nội dung AI"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(17)
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.fillWidth: true
                    text: (void i18n.revision, i18n.t("transcript_content_review_dialog.subtitle", "Xem / sửa / bỏ chọn từng kịch bản. Chỉ kịch bản được duyệt mới tạo audio."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                    elide: Text.ElideRight
                }
            }
        }

        // Danh sách kịch bản (sửa được)
        ScrollView {
            id: scriptScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: availableWidth
            contentHeight: scriptBody.implicitHeight
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            ColumnLayout {
                id: scriptBody
                width: scriptScroll.availableWidth
                spacing: VfTheme.dp(8)

                Item { Layout.preferredHeight: VfTheme.dp(8) }

                Repeater {
                    model: reviewModel

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.leftMargin: VfTheme.dp(14)
                        Layout.rightMargin: VfTheme.dp(14)
                        radius: VfTheme.dp(8)
                        color: model.approved ? VfTheme.surface : VfTheme.surfaceSoft
                        border.color: model.approved ? VfTheme.blueBorderSoft : VfTheme.border
                        border.width: 1
                        implicitHeight: cardCol.implicitHeight + VfTheme.dp(18)
                        opacity: model.approved ? 1.0 : 0.6

                        ColumnLayout {
                            id: cardCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: VfTheme.dp(9)
                            spacing: VfTheme.dp(6)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(8)

                                CheckBox {
                                    checked: model.approved
                                    onToggled: reviewModel.setProperty(index, "approved", checked)
                                }

                                Text {
                                    text: "#" + (index + 1)
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(11)
                                    font.weight: Font.Bold
                                }

                                TextField {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: VfTheme.dp(30)
                                    text: model.title
                                    placeholderText: (void i18n.revision, i18n.t("transcript_content_review_dialog.title_placeholder", "Tiêu đề kịch bản"))
                                    color: VfTheme.text
                                    placeholderTextColor: VfTheme.textSubtle
                                    selectByMouse: true
                                    leftPadding: VfTheme.dp(8); rightPadding: VfTheme.dp(8)
                                    verticalAlignment: TextInput.AlignVCenter
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    font.weight: Font.DemiBold
                                    onTextChanged: reviewModel.setProperty(index, "title", text)
                                    background: Rectangle {
                                        radius: VfTheme.dp(6); color: VfTheme.surfaceSoft
                                        border.color: parent.activeFocus ? VfTheme.primary : VfTheme.border
                                        border.width: 1
                                    }
                                }

                                Text {
                                    text: String(model.script).length + " " + (void i18n.revision, i18n.t("transcript_content_review_dialog.characters", "ký tự"))
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(10)
                                }
                            }

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(108)
                                clip: true

                                TextArea {
                                    text: model.script
                                    wrapMode: TextArea.Wrap
                                    color: VfTheme.text
                                    selectByMouse: true
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(12)
                                    onTextChanged: reviewModel.setProperty(index, "script", text)
                                    background: Rectangle {
                                        radius: VfTheme.dp(6); color: VfTheme.surfaceSoft
                                        border.color: parent.activeFocus ? VfTheme.primary : VfTheme.border
                                        border.width: 1
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: VfTheme.dp(14)
                    visible: reviewModel.count === 0
                    text: (void i18n.revision, i18n.t("transcript_content_review_dialog.empty_message", "AI chưa trả về kịch bản nào. Thử lại với chủ đề/định hướng khác."))
                    color: VfTheme.textSubtle
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(12)
                    wrapMode: Text.WordWrap
                }

                Item { Layout.preferredHeight: VfTheme.dp(8) }
            }
        }

        // Footer: giọng đọc + nút
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(64)
            color: VfTheme.surfaceSoft
            border.color: VfTheme.border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(14)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(10)

                VfSelectField {
                    Layout.fillWidth: true
                    Layout.maximumWidth: VfTheme.dp(280)
                    label: (void i18n.revision, i18n.t("transcript_content_review_dialog.voice_label", "Giọng đọc (Voice Studio)"))
                    accent: "#0891B2"
                    options: root.voiceOptions
                    value: root.voiceValue
                    onSelected: value => root.voiceValue = String(value)
                }

                VfSelectField {
                    Layout.fillWidth: true
                    Layout.maximumWidth: VfTheme.dp(220)
                    label: root.emotionProvider.length > 0
                        ? ((void i18n.revision, i18n.t("transcript_content_review_dialog.emotion_label", "Cảm xúc")) + " (" + root.emotionProvider + ")")
                        : (void i18n.revision, i18n.t("transcript_content_review_dialog.emotion_label", "Cảm xúc"))
                    accent: "#7C3AED"
                    options: root.emotionOptions
                    value: root.emotionValue
                    onSelected: value => root.emotionValue = String(value)
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Hủy"))
                    tone: "neutral"
                    minWidth: VfTheme.dp(92)
                    onClicked: root.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("transcript_content_review_dialog.approve_button", "Duyệt & tạo audio")) + " (" + root.approvedCount() + ")"
                    tone: "primary"
                    minWidth: VfTheme.dp(170)
                    enabled: root.approvedCount() > 0
                    onClicked: {
                        root.approveRequested(root.collectApproved(), root.voiceValue, root.category, root.emotionValue)
                        root.close()
                    }
                }
            }
        }
    }
}
