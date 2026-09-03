import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Curator v2 review surface: shows AI proposals (curated mediums + authored
// surfaces) WITH rationale (why it fits, why it's beautiful, the material) and a
// preview, lets the user pick which to keep, then commits only those.
Dialog {
    id: root
    parent: Overlay.overlay

    property var topicMeta: ({})
    property var briefData: ({})
    property var proposals: []
    property string noticeMessage: ""

    // Approved proposals → host persists via masterOptionsController.commitStyleTopic.
    signal commitRequested(var payload)
    // One proposal → host generates a preview image for it (works pre-commit).
    signal previewRequested(var proposal)

    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(680), VfTheme.dp(64))
    height: Math.min(parent ? parent.height - VfTheme.dp(72) : VfTheme.dp(640), VfTheme.dp(760))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0
    header: null

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.dp(10)
        border.color: VfTheme.borderBox
    }

    function trText(key, fallback) {
        if (typeof i18n !== "undefined" && i18n && i18n.t)
            return (void i18n.revision, i18n.t(key, fallback))
        return fallback
    }

    function openWith(result) {
        var payload = result || ({})
        root.topicMeta = payload.topic || ({})
        root.briefData = payload.brief || ({})
        var incoming = payload.proposals || []
        var prepared = []
        for (var i = 0; i < incoming.length; i++) {
            var p = incoming[i] || ({})
            if (p._selected === undefined)
                p._selected = (p.selected === undefined ? true : !!p.selected)
            prepared.push(p)
        }
        root.proposals = prepared
        root.noticeMessage = ""
        if (prepared.length > 0)
            root.open()
    }

    function selectedCount() {
        var n = 0
        for (var i = 0; i < root.proposals.length; i++)
            if (root.proposals[i] && root.proposals[i]._selected) n++
        return n
    }

    function selectedProposals() {
        var out = []
        for (var i = 0; i < root.proposals.length; i++)
            if (root.proposals[i] && root.proposals[i]._selected) out.push(root.proposals[i])
        return out
    }

    function toggleAt(index) {
        if (index < 0 || index >= root.proposals.length) return
        var arr = root.proposals.slice()
        arr[index]._selected = !arr[index]._selected
        root.proposals = arr
    }

    function setAll(value) {
        var arr = root.proposals.slice()
        for (var i = 0; i < arr.length; i++) arr[i]._selected = !!value
        root.proposals = arr
    }

    // Patch a proposal's preview_state after the host generates its image.
    function applyPreviewResult(result) {
        var payload = result || ({})
        var sid = String(payload.style_id || "")
        if (sid.length === 0) return
        var state = payload.preview_state || payload
        var arr = root.proposals.slice()
        for (var i = 0; i < arr.length; i++) {
            if (String(arr[i].style_id || "") === sid) {
                arr[i].preview_state = state
                break
            }
        }
        root.proposals = arr
    }

    function previewPathOf(proposal) {
        var st = (proposal && proposal.preview_state) || ({})
        var prev = st.preview || ({})
        if (prev && prev.exists && String(prev.path || "").length > 0)
            return "file:///" + String(prev.path).replace(/\\/g, "/")
        return ""
    }

    function briefLine() {
        var b = root.briefData || ({})
        var parts = []
        if (String(b.visual_culture || "").length > 0) parts.push(String(b.visual_culture))
        var mats = b.signature_materials || []
        if (mats.length > 0) parts.push((void i18n.revision, i18n.t("style_topic_proposal_dialog.brief_materials", "Chất liệu")) + ": " + mats.join(", "))
        return parts.join("  •  ")
    }

    contentItem: ColumnLayout {
        spacing: VfTheme.dp(10)

        // ---- Header ----
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: VfTheme.dp(16)
            Layout.leftMargin: VfTheme.dp(18)
            Layout.rightMargin: VfTheme.dp(18)
            spacing: VfTheme.dp(4)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.review_title", "Đề xuất style cho chủ đề"))
                    + "  •  " + String((root.topicMeta || {}).name || "")
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(16)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.briefLine().length > 0
                text: root.briefLine()
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                Text {
                    text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.review_hint", "Chọn những style muốn lưu vào thư viện."))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(11)
                }
                Item { Layout.fillWidth: true }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.select_all", "Chọn tất cả"))
                    tone: "neutral"
                    minWidth: VfTheme.dp(88)
                    onClicked: root.setAll(true)
                }
                VfButton {
                    text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.deselect_all", "Bỏ chọn"))
                    tone: "neutral"
                    minWidth: VfTheme.dp(80)
                    onClicked: root.setAll(false)
                }
            }
        }

        // ---- Proposal cards ----
        ListView {
            id: cardList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: VfTheme.dp(14)
            Layout.rightMargin: VfTheme.dp(14)
            clip: true
            spacing: VfTheme.dp(8)
            reuseItems: true
            model: root.proposals
            ScrollBar.vertical: ScrollBar {}

            delegate: Rectangle {
                width: ListView.view.width
                height: cardBody.implicitHeight + VfTheme.dp(20)
                radius: VfTheme.dp(9)
                color: (modelData && modelData._selected) ? VfTheme.violetFill : VfTheme.surfaceSoft
                border.width: 1
                border.color: (modelData && modelData._selected) ? VfTheme.violetBorder : VfTheme.border

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.toggleAt(index)
                }

                RowLayout {
                    id: cardBody
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(10)

                    CheckBox {
                        Layout.alignment: Qt.AlignTop
                        checked: !!(modelData && modelData._selected)
                        onToggled: root.toggleAt(index)
                    }

                    // Preview thumbnail (or placeholder)
                    Rectangle {
                        Layout.alignment: Qt.AlignTop
                        Layout.preferredWidth: VfTheme.dp(78)
                        Layout.preferredHeight: VfTheme.dp(54)
                        radius: VfTheme.dp(6)
                        color: VfTheme.surface
                        border.width: 1
                        border.color: VfTheme.border
                        clip: true

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false
                            visible: source != ""
                            source: root.previewPathOf(modelData)
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.previewPathOf(modelData) === ""
                            text: root.trText("style_topic.no_preview", "No\npreview")
                            horizontalAlignment: Text.AlignHCenter
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(9)
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(3)

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(6)

                            Text {
                                Layout.fillWidth: true
                                text: String((modelData || {}).name || "")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(13)
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            // kind badge
                            Rectangle {
                                radius: VfTheme.dp(5)
                                implicitWidth: kindLbl.implicitWidth + VfTheme.dp(12)
                                implicitHeight: VfTheme.dp(18)
                                color: String((modelData || {}).kind || "") === "new" ? VfTheme.greenFill : VfTheme.surface
                                border.width: 1
                                border.color: String((modelData || {}).kind || "") === "new" ? VfTheme.greenBorder : VfTheme.border
                                Text {
                                    id: kindLbl
                                    anchors.centerIn: parent
                                    text: String((modelData || {}).kind || "") === "new"
                                        ? (void i18n.revision, i18n.t("style_topic_proposal_dialog.badge_new", "Mới"))
                                        : (void i18n.revision, i18n.t("style_topic_proposal_dialog.badge_curated", "Có sẵn"))
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(9)
                                }
                            }
                            // framework_type badge
                            Text {
                                text: String((modelData || {}).framework_type || "")
                                color: VfTheme.violetText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(9)
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: String((modelData || {}).why_fit || "").length > 0
                            text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.why_fit", "Hợp vì")) + ": " + String((modelData || {}).why_fit || "")
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: String((modelData || {}).why_beautiful || "").length > 0
                            text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.why_beautiful", "Đẹp ở")) + ": " + String((modelData || {}).why_beautiful || "")
                            color: VfTheme.violetText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: String((modelData || {}).material || "").length > 0
                            text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.material", "Chất liệu")) + ": " + String((modelData || {}).material || "")
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(10)
                            wrapMode: Text.WordWrap
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Item { Layout.fillWidth: true }
                            VfButton {
                                text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.make_preview", "Tạo preview"))
                                tone: "neutral"
                                minWidth: VfTheme.dp(96)
                                onClicked: root.previewRequested(modelData)
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(18)
            Layout.rightMargin: VfTheme.dp(18)
            visible: root.noticeMessage.length > 0
            text: root.noticeMessage
            color: VfTheme.redText
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            wrapMode: Text.WordWrap
        }

        // ---- Footer ----
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: VfTheme.dp(18)
            Layout.rightMargin: VfTheme.dp(18)
            Layout.bottomMargin: VfTheme.dp(16)
            spacing: VfTheme.dp(8)

            Text {
                text: root.selectedCount() + "/" + root.proposals.length + " "
                    + (void i18n.revision, i18n.t("common.selected", "đã chọn"))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }
            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.close", "Đóng"))
                tone: "neutral"
                minWidth: VfTheme.dp(88)
                onClicked: root.close()
            }
            VfButton {
                text: (void i18n.revision, i18n.t("style_topic_proposal_dialog.commit_selected", "Lưu đã chọn"))
                tone: "primary"
                minWidth: VfTheme.dp(120)
                enabled: root.selectedCount() > 0
                onClicked: {
                    var chosen = root.selectedProposals()
                    if (chosen.length === 0) {
                        root.noticeMessage = (void i18n.revision, i18n.t("style_topic_proposal_dialog.none_selected", "Chưa chọn style nào để lưu."))
                        return
                    }
                    root.noticeMessage = ""
                    root.commitRequested({ topic: root.topicMeta, proposals: chosen })
                    root.close()
                }
            }
        }
    }
}
