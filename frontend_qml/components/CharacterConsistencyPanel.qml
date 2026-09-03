import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"
import "AppIconRegistry.js" as AppIconRegistry
import "MediaSourceResolver.js" as MediaSourceResolver

Rectangle {
    id: root
    // Tour target — used DIRECTLY in Clone/Transcript/Extend/Affiliate (Master/Voice
    // wrap it in MasterLibraryControl which also carries this objectName), so the
    // "libraryControl" step resolves on every tab.
    objectName: "libraryControl"

    // Compatibility input while old persisted configs migrate. The new UI is
    // always a per-category matrix and never hides it behind a global mode.
    property string charMode: "hybrid"
    property var scopeCategories: ["characters"]     // characters | objects | backgrounds
    property bool showScopes: true
    property bool showAddClear: true
    property bool showAutoSave: false
    property bool autoSaveEnabled: false
    property bool showVoiceSync: false
    property bool voiceSyncEnabled: false
    property bool voiceSyncSupported: false
    property string voiceSyncHint: ""
    property int voiceSyncCharacterCount: 0
    property bool allowCharacterSelection: true
    property bool allowObjectSelection: false
    property bool allowBackgroundSelection: false
    property var scopePolicies: ({})
    property var characters: []
    property var objects: []
    property var backgrounds: []

    signal scopeToggled(string category, bool enabled)
    signal scopePolicyChanged(string category, string key, string value)
    signal addRequested()
    signal addObjectsRequested()
    signal addBackgroundsRequested()
    signal clearRequested()
    signal moveRequested(string mediaId, int offset)
    signal removeRequested(string mediaId)
    signal removeObjectRequested(string mediaId)
    signal removeBackgroundRequested(string mediaId)
    signal autoSaveToggled(bool enabled)
    signal voiceSyncToggled(bool enabled)

    function cleanText(value) {
        return AppIconRegistry.stripGlyph(String(value || "").trim())
    }

    function scopeList() {
        var items = root.scopeCategories || []
        var out = []
        if (!items || items.length === undefined)
            return ["characters"]
        for (var i = 0; i < items.length; i += 1) {
            var value = String(items[i] || "")
            if (value.length > 0 && out.indexOf(value) < 0)
                out.push(value)
        }
        // RONG la hop le: user chon "AI tu tao" cho moi scope. Ep ve ["characters"]
        // o day lam segment AI cua nhan vat khong bao gio chon duoc (click chet).
        return out
    }

    function scopeEnabled(category) {
        return root.scopeList().indexOf(String(category || "")) >= 0
    }

    function scopeTitle(category) {
        if (category === "objects")
            return root.cleanText((void i18n.revision, i18n.t("library_control.scope_objects", "Äá»“ váº­t")))
        if (category === "backgrounds")
            return root.cleanText((void i18n.revision, i18n.t("library_control.scope_backgrounds", "Bá»‘i cáº£nh")))
        return root.cleanText((void i18n.revision, i18n.t("library_control.scope_characters", "NhÃ¢n váº­t")))
    }

    function scopeAccent(category) {
        if (category === "objects")
            return "#0EA5E9"
        if (category === "backgrounds")
            return "#059669"
        return "#7C3AED"
    }

    function scopeIcon(category) {
        if (category === "objects")
            return "package"
        if (category === "backgrounds")
            return "framed-picture"
        return "busts-in-silhouette"
    }

    function scopeAssets(category) {
        if (category === "objects")
            return (root.objects && root.objects.length !== undefined) ? root.objects : []
        if (category === "backgrounds")
            return (root.backgrounds && root.backgrounds.length !== undefined) ? root.backgrounds : []
        return (root.characters && root.characters.length !== undefined) ? root.characters : []
    }

    function canAddScope(category) {
        if (category === "objects")
            return root.allowObjectSelection
        if (category === "backgrounds")
            return root.allowBackgroundSelection
        return root.allowCharacterSelection
    }

    function scopePolicy(category) {
        var policies = root.scopePolicies || ({})
        var item = policies[String(category || "")] || ({})
        return item || ({})
    }

    function missingPolicy(category) {
        if (!root.scopeEnabled(category))
            return "generate"
        var policy = root.scopePolicy(category)
        var value = String(policy.missing || policy.missing_policy || "")
        return value === "omit" ? "omit" : "generate"
    }

    function rewritePolicy(category) {
        if (!root.scopeEnabled(category))
            return "fit_assets"
        var policy = root.scopePolicy(category)
        var value = String(policy.rewrite || policy.rewrite_policy || "")
        if (value === "replace_matching" || value === "omit_unavailable" || value === "fit_assets")
            return value
        return "fit_assets"
    }

    // Cong tat per-scope: BAT = cho AI tao them phan thieu (hybrid),
    // TAT = khoa cung chi dung asset da chon (library_only).
    function allowGenerate(category) {
        if (!root.scopeEnabled(category))
            return false
        var policy = root.scopePolicy(category)
        var source = String(policy.source || policy.source_policy || "")
        if (source === "library_only")
            return false
        var value = String(policy.missing || policy.missing_policy || "generate")
        return value !== "omit"
    }

    // Per-scope source = AI tu tao (ai) | AI + Thu vien (hybrid) | Chi Thu vien
    // (library_only) | Tat (disabled — khong entity id, khong gen, khong refs).
    // Matrix policy là SoT; category list chỉ còn fallback cho config legacy.
    function scopeSource(category) {
        var policy = root.scopePolicy(category)
        var direct = String(policy.source || policy.source_policy || "")
        if (direct === "ai" || direct === "hybrid"
                || direct === "library_only" || direct === "disabled")
            return direct
        if (!root.scopeEnabled(category)) {
            return "ai"
        }
        return root.allowGenerate(category) ? "hybrid" : "library_only"
    }

    // Mot cu chi = MOT signal = MOT round-trip duy nhat. Truoc day hybrid/library_only
    // tren scope dang tat ban scopeToggled + scopePolicyChanged -> host setOptions 2 lan
    // -> 2x broadcast/re-render moi click. Gio policy override tu kich hoat scope ngay
    // trong LibraryPolicy.build (override "missing" => scope active; override "source"
    // voi "ai"/"disabled" => go khoi active + persist trang thai trong scopes).
    function selectScopeSource(category, source) {
        if (source === "ai" || source === "disabled") {
            root.scopePolicyChanged(category, "source", source)
            return
        }
        root.scopePolicyChanged(category, "missing", source === "library_only" ? "omit" : "generate")
    }

    function scopeSourceDesc(category) {
        var source = root.scopeSource(category)
        var name = root.scopeTitle(category)
        if (source === "disabled")
            return (void i18n.revision, i18n.t("character_consistency_panel.source_desc_disabled", "Tắt đồng bộ ")) + name + (void i18n.revision, i18n.t("character_consistency_panel.source_desc_disabled_suffix", ": không tạo entity/ảnh ref; chỉ mô tả tự do trong kịch bản."))
        if (source === "ai")
            return (void i18n.revision, i18n.t("character_consistency_panel.source_desc_ai", "AI tự xử lý ")) + name + (void i18n.revision, i18n.t("character_consistency_panel.source_desc_ai_suffix", ", không lấy từ thư viện."))
        if (source === "library_only")
            return (void i18n.revision, i18n.t("character_consistency_panel.source_desc_library", "Chỉ dùng ")) + name + (void i18n.revision, i18n.t("character_consistency_panel.source_desc_library_suffix", " đã chọn; phần khác bị cắt hoặc gộp."))
        return (void i18n.revision, i18n.t("character_consistency_panel.source_desc_hybrid", "Ưu tiên ")) + name + (void i18n.revision, i18n.t("character_consistency_panel.source_desc_hybrid_suffix", " đã chọn; AI tạo thêm khi kịch bản cần."))
    }

    function voiceSyncStatusHint() {
        if (root.scopeSource("characters") === "disabled")
            return root.cleanText((void i18n.revision, i18n.t(
                "library_control.voice_sync_requires_characters",
                "Chọn một chế độ đồng nhất Nhân vật trước.")))
        if (!root.voiceSyncSupported)
            return root.voiceSyncHint.length > 0
                ? root.cleanText(root.voiceSyncHint)
                : root.cleanText((void i18n.revision, i18n.t(
                    "library_control.voice_sync_unsupported",
                    "Model video hiện tại không hỗ trợ đồng bộ giọng.")))
        if (root.voiceSyncCharacterCount > 0)
            return root.cleanText((void i18n.revision, i18n.t(
                "library_control.voice_sync_character_count",
                "Áp dụng cho {count} nhân vật đã chọn.")))
                .replace("{count}", String(root.voiceSyncCharacterCount))
        return root.voiceSyncHint.length > 0
            ? root.cleanText(root.voiceSyncHint)
            : root.cleanText((void i18n.revision, i18n.t(
                "library_control.voice_sync_after_analysis",
                "Sẽ áp dụng sau khi AI xác định nhân vật trong nội dung.")))
    }

    function addLabel(category) {
        if (category === "objects")
            return root.cleanText((void i18n.revision, i18n.t("library_control.add_objects", "+ ThÃªm Ä‘á»“ váº­t")))
        if (category === "backgrounds")
            return root.cleanText((void i18n.revision, i18n.t("library_control.add_backgrounds", "+ ThÃªm bá»‘i cáº£nh")))
        return root.cleanText((void i18n.revision, i18n.t("library_control.add_characters", "+ ThÃªm nhÃ¢n váº­t")))
    }

    function requestAdd(category) {
        if (category === "objects") {
            root.addObjectsRequested()
            return
        }
        if (category === "backgrounds") {
            root.addBackgroundsRequested()
            return
        }
        root.addRequested()
    }

    function requestRemove(category, mediaId) {
        if (category === "objects") {
            root.removeObjectRequested(mediaId)
            return
        }
        if (category === "backgrounds") {
            root.removeBackgroundRequested(mediaId)
            return
        }
        root.removeRequested(mediaId)
    }

    function assetName(asset) {
        var item = asset || {}
        return root.cleanText(item.name || item.title || item.label || item.id || "")
    }

    function assetSummary(asset) {
        var item = asset || {}
        return root.cleanText(item.summary || item.description || item.caption || "")
    }

    function mediaIdOf(asset) {
        var item = asset || {}
        return String(item.media_id || item.id || "")
    }

    function thumbSource(asset) {
        return MediaSourceResolver.imageSource(asset || {})
    }

    Layout.fillWidth: true
    implicitHeight: column.implicitHeight + VfTheme.dp(16)
    color: "transparent"

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: VfTheme.dp(8)
        spacing: VfTheme.dp(8)

        // Width bounded: panel chiem full-width workspace, title column co gian/elide
        // hap thu phan thieu; 2/5 nut conditional (clear + autosave) nen hang hiem khi
        // du 5 nut cung luc.
        RowLayout { // perf-lint: disable=R5
            Layout.fillWidth: true
            spacing: VfTheme.dp(8)

            ColumnLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(2)
                Text {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t("qml.master.library_control", "Äiá»u khiá»ƒn nhÃ¢n váº­t, Ä‘á»“ váº­t, bá»‘i cáº£nh")))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(14)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t(
                        "library_control.matrix_desc",
                        "Chọn cách đồng nhất riêng cho từng nhóm. Không đồng nhất cả ba = tạo video tự do, không dùng ảnh tham chiếu.")))
                    color: VfTheme.textMuted
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(10)
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                }
            }

            VfButton {
                // Mo thang Media Library (quan ly/import anh) ngay tai panel — dung
                // bus headerController.openDialog: App.qml lang nghe dialogRequested
                // va mo dialog manage, khong can luon signal qua tung host.
                actionId: "library_control.open_media_library"
                text: root.cleanText((void i18n.revision, i18n.t("library_control.open_media_library", "Thư viện media")))
                tone: "neutral"
                minWidth: VfTheme.dp(122)
                onClicked: headerController.openDialog("media_library")
            }
            VfButton {
                actionId: "master.feature.clear_characters"
                text: root.cleanText((void i18n.revision, i18n.t(
                    "library_control.clear_selected_assets", "Xóa asset đã chọn")))
                tone: "danger"
                minWidth: VfTheme.dp(96)
                visible: root.showAddClear
                onClicked: root.clearRequested()
            }
            VfButton {
                actionId: "clone.creative_autosave"
                text: root.cleanText((void i18n.revision, i18n.t("clone.creative_autosave", "Tá»± Ä‘á»™ng lÆ°u nhÃ¢n váº­t")))
                tone: root.autoSaveEnabled ? "success" : "neutral"
                minWidth: VfTheme.dp(154)
                // Luon hien khi host bat showAutoSave: truoc day gate theo
                // allowGenerate("characters") lam nut nhay ra/vao moi lan doi nguon
                // scope (an ca o "AI tu tao" - luc AI sinh nhan vat nhieu nhat).
                visible: root.showAutoSave
                onClicked: root.autoSaveToggled(!root.autoSaveEnabled)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: root.showScopes
            spacing: VfTheme.dp(8)

            ScopeCard {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                category: "characters"
            }
            ScopeCard {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                category: "objects"
            }
            ScopeCard {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                category: "backgrounds"
            }
        }
    }

    component ScopeCard: Rectangle {
        id: card
        property string category: "characters"
        objectName: "scope_" + card.category   // tour target: scope_characters/objects/backgrounds
        readonly property string source: root.scopeSource(category)
        readonly property bool active: source !== "disabled"
        readonly property bool usesLibrary: source === "hybrid" || source === "library_only"
        readonly property var assets: root.scopeAssets(category)
        readonly property color accent: root.scopeAccent(category)

        implicitHeight: cardColumn.implicitHeight + VfTheme.dp(16)
        radius: VfTheme.dp(8)
        color: active ? VfTheme.surface : VfTheme.surfaceSoft
        border.color: active ? accent : VfTheme.borderSoft
        border.width: 1

        ColumnLayout {
            id: cardColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: VfTheme.dp(8)
            spacing: VfTheme.dp(6)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(6)
                VfAppIcon {
                    name: root.scopeIcon(card.category)
                    size: VfTheme.dp(18)
                    framed: false
                    color: card.active ? card.accent : VfTheme.textSubtle
                }
                Text {
                    Layout.fillWidth: true
                    text: root.scopeTitle(card.category)
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                ToggleChip {
                    actionId: "library_control.voice_sync"
                    visible: card.category === "characters" && root.showVoiceSync
                    text: root.cleanText((void i18n.revision, i18n.t(
                        "library_control.voice_sync_short", "Sync giọng")))
                    tooltip: root.voiceSyncStatusHint()
                    selected: root.voiceSyncEnabled
                    enabled: card.active && root.voiceSyncSupported
                    accent: "#0D9488"
                    onClicked: root.voiceSyncToggled(!root.voiceSyncEnabled)
                }
                VfCountBadge {
                    count: card.assets.length
                    accent: card.accent
                }
            }

            // Per-scope source selector (thay 2 chip cu): chon segment = doi source.
            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(4)
                VfSourceSeg {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t("library_control.src_ai_short", "AI tạo")))
                    selected: root.scopeSource(card.category) === "ai"
                    accent: card.accent
                    onClicked: root.selectScopeSource(card.category, "ai")
                }
                VfSourceSeg {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t("library_control.src_hybrid", "AI + Thư viện")))
                    selected: root.scopeSource(card.category) === "hybrid"
                    accent: card.accent
                    onClicked: root.selectScopeSource(card.category, "hybrid")
                }
                VfSourceSeg {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t("library_control.src_library", "Chỉ Thư viện")))
                    selected: root.scopeSource(card.category) === "library_only"
                    accent: card.accent
                    onClicked: root.selectScopeSource(card.category, "library_only")
                }
                VfSourceSeg {
                    Layout.fillWidth: true
                    text: root.cleanText((void i18n.revision, i18n.t("library_control.src_disabled_clear", "Không đồng nhất")))
                    selected: root.scopeSource(card.category) === "disabled"
                    accent: card.accent
                    onClicked: root.selectScopeSource(card.category, "disabled")
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.scopeSourceDesc(card.category)
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? VfTheme.dp(42) : 0
                visible: card.usesLibrary && card.assets.length > 0
                orientation: ListView.Horizontal
                spacing: VfTheme.dp(6)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                reuseItems: true
                model: card.assets

                delegate: VfAssetChip {
                    required property var modelData
                    imageSource: root.thumbSource(modelData)
                    name: root.assetName(modelData)
                    summary: root.assetSummary(modelData)
                    iconName: root.scopeIcon(card.category)
                    accent: card.accent
                    onRemoveRequested: root.requestRemove(card.category, root.mediaIdOf(modelData))
                }
            }

            Text {
                Layout.fillWidth: true
                visible: card.usesLibrary && card.assets.length <= 0
                text: root.cleanText((void i18n.revision, i18n.t("library_control.no_assets", "ChÆ°a chá»n asset thÆ° viá»‡n cho pháº¡m vi nÃ y.")))
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }

            VfButton {
                Layout.fillWidth: true
                text: root.addLabel(card.category)
                visible: root.canAddScope(card.category) && card.usesLibrary
                enabled: root.canAddScope(card.category)
                opacity: enabled ? 1 : 0.5
                minWidth: VfTheme.dp(120)
                onClicked: root.requestAdd(card.category)
            }

        }
    }

    component SectionLabel: Text {
        Layout.fillWidth: true
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(10)
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }


    // Toggle switch ro rang (track + thumb truot) thay vi badge, de nhan biet la nut bat/tat.
    component ToggleChip: Rectangle {
        id: chip
        property string actionId: ""
        property string text: ""
        property string tooltip: ""
        property bool selected: false
        property color accent: VfTheme.primary
        signal clicked()
        implicitWidth: chipRow.implicitWidth + VfTheme.dp(12)
        // Match VfCountBadge's 20px header height so the Characters card stays
        // vertically aligned with Objects/Backgrounds.
        implicitHeight: VfTheme.dp(20)
        radius: VfTheme.dp(7)
        opacity: chip.enabled ? 1 : 0.58
        color: chipHover.containsMouse
            ? (selected ? Qt.rgba(accent.r, accent.g, accent.b, 0.18) : VfTheme.surface)
            : (selected ? Qt.rgba(accent.r, accent.g, accent.b, 0.12) : VfTheme.surfaceSoft)
        border.color: selected ? accent : VfTheme.borderSoft
        border.width: 1

        ToolTip.visible: chipHover.containsMouse && chip.tooltip.length > 0
        ToolTip.text: chip.tooltip
        ToolTip.delay: 350

        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: chip.text
                color: chip.selected ? accent : VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(9)
                font.weight: Font.DemiBold
            }

            // Track + thumb
            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                width: VfTheme.dp(30)
                height: VfTheme.dp(16)
                radius: height / 2
                color: chip.selected ? chip.accent : VfTheme.borderSoft
                border.color: chip.selected ? chip.accent : VfTheme.textSubtle
                border.width: 1

                Rectangle {
                    id: thumb
                    width: VfTheme.dp(12)
                    height: VfTheme.dp(12)
                    radius: height / 2
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                    x: chip.selected ? (track.width - width - VfTheme.dp(2)) : VfTheme.dp(2)
                    Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                }
            }
        }

        MouseArea {
            id: chipHover
            anchors.fill: parent
            enabled: chip.enabled
            hoverEnabled: true
            cursorShape: chip.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: chip.clicked()
        }
    }

    component PolicyButton: Rectangle {
        id: policyButton
        property string title: ""
        property string description: ""
        property bool selected: false
        property color accent: VfTheme.primary
        signal clicked()

        implicitHeight: VfTheme.dp(42)
        radius: VfTheme.dp(7)
        color: selected ? Qt.rgba(accent.r, accent.g, accent.b, 0.12) : VfTheme.surfaceSoft
        border.color: selected ? accent : VfTheme.borderSoft
        border.width: selected ? 2 : 1
        opacity: enabled ? 1 : 0.58

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(8)
            anchors.rightMargin: VfTheme.dp(8)
            anchors.topMargin: VfTheme.dp(5)
            anchors.bottomMargin: VfTheme.dp(5)
            spacing: VfTheme.dp(1)

            Text {
                Layout.fillWidth: true
                text: policyButton.title
                color: policyButton.selected ? policyButton.accent : VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: policyButton.description
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(7)
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: policyButton.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: policyButton.clicked()
        }
    }

}
