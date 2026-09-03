import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Card tài nguyên affiliate (Nhân vật KOL / Bối cảnh) — v4 ONE CLICK:
//   · CHUNG mọi SP, KHÔNG còn scope chung/riêng (bố chốt 20/7 — backend auto vốn đã
//     per-SP thật: CharGen/BG-Gen theo ngành + kịch bản TỪNG SP lúc chạy).
//   · Nguồn: "⚡ Auto (AI theo ngành SP)" ↔ "Thư viện". Auto = mặc định.
//   · Body = DẢI CARD ngang 1 hàng (ảnh + tên + giọng lock); auto mode hiện card
//     preview "AI sẽ tạo … hợp <ngành SP đang chọn>" — per-SP là GÓC NHÌN.
// Props scope/product cũ GIỮ (default) để không vỡ caller cũ; workspace không set nữa.
Rectangle {
    id: picker

    property string assetType: "character"
    property color accentColor: VfTheme.primary
    property string titleText: ""
    property string titleIcon: ""
    property var assetsModel: []
    property string emptyText: "Chưa có"
    property var imageResolver: (function(a) { return "" })
    property var voiceResolver: (function(a) { return "" })
    property bool aiMode: false
    property int maxAiSlots: 1
    property string aiLabel: "Tạo AI"
    property string hintText: ""     // nhiệm vụ khu — ⓘ tooltip
    property string previewHint: ""  // per-SP góc nhìn: "AI sẽ tạo KOL nữ hợp Mỹ phẩm…"
    property string footNote: ""     // caption đáy
    property string statusText: ""
    property string statusTone: "neutral" // auto | ready | warning | error
    // 💾 Tự lưu Thư viện (bố 22/7): KOL/BG AI tạo lúc chạy tự lưu để tái dùng.
    property bool autoSaveOn: true
    property bool showAutoSave: false
    // Legacy props (không dùng ở v4, giữ cho tương thích API)
    property string scopeMode: "global"
    property var productOptions: []
    property string activeProduct: ""

    signal choose()
    signal remove(string assetId)
    signal aiToggled(bool on)
    signal autoSaveToggled(bool on)
    signal scopeChanged(string mode)
    signal productChanged(string pid)

    radius: VfTheme.dp(8)
    color: VfTheme.surface
    border.color: picker.aiMode ? picker.accentColor : VfTheme.borderBox
    border.width: 1
    clip: true

    function assetCount() {
        var m = picker.assetsModel
        return (m && m.length !== undefined) ? m.length : 0
    }
    function idOf(a) {
        var item = a || ({})
        return String(item.id || item.media_id || item.asset_id || "")
    }
    function statusFill() {
        if (picker.statusTone === "ready") return VfTheme.greenFill
        if (picker.statusTone === "auto") return VfTheme.cyanFill
        if (picker.statusTone === "warning") return VfTheme.amberFill
        if (picker.statusTone === "error") return VfTheme.redFill
        return VfTheme.surfaceSoft
    }
    function statusBorder() {
        if (picker.statusTone === "ready") return VfTheme.greenBorder
        if (picker.statusTone === "auto") return VfTheme.cyanBorder
        if (picker.statusTone === "warning") return VfTheme.amberBorder
        if (picker.statusTone === "error") return VfTheme.redBorder
        return VfTheme.borderSoft
    }
    function statusColor() {
        if (picker.statusTone === "ready") return VfTheme.greenText
        if (picker.statusTone === "auto") return VfTheme.cyanText
        if (picker.statusTone === "warning") return VfTheme.amberText
        if (picker.statusTone === "error") return VfTheme.redText
        return VfTheme.textMuted
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        spacing: VfTheme.dp(7)

        // HEADER: icon + tiêu đề + đếm + ⓘ · nguồn Auto ↔ Thư viện.
        RowLayout {
            Layout.fillWidth: true
            spacing: VfTheme.dp(6)
            VfAppIcon {
                visible: picker.titleIcon.length > 0
                name: picker.titleIcon; size: VfTheme.dp(18); framed: false
                color: picker.aiMode ? picker.accentColor : VfTheme.textSubtle
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.minimumWidth: VfTheme.dp(54)
                spacing: VfTheme.dp(1)
                Text {
                    Layout.fillWidth: true
                    text: picker.titleText
                    color: VfTheme.text; font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(13); font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(4)
                    Rectangle {
                        visible: picker.statusText.length > 0
                        implicitWidth: assetStatusText.implicitWidth + VfTheme.dp(8)
                        implicitHeight: VfTheme.dp(15)
                        radius: height / 2
                        color: picker.statusFill()
                        border.width: picker.statusTone === "error" ? 1 : 0
                        border.color: Qt.alpha(picker.statusBorder(), 0.82)
                        Text {
                            id: assetStatusText
                            anchors.centerIn: parent
                            text: picker.statusText
                            color: picker.statusColor()
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(7.5)
                            font.weight: VfTheme.weightStrong
                        }
                    }
                    VfCountBadge {
                        visible: picker.statusText.length === 0 && !picker.aiMode
                        count: picker.assetCount()
                        accent: picker.accentColor
                    }
                    Item { Layout.fillWidth: true }
                }
            }
            Text {
                visible: picker.hintText.length > 0
                text: "ⓘ"
                color: picker.accentColor
                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontControl
                MouseArea {
                    id: pickerHintMouse
                    anchors.fill: parent; anchors.margins: -VfTheme.dp(4)
                    hoverEnabled: true; acceptedButtons: Qt.NoButton
                }
                ToolTip.visible: pickerHintMouse.containsMouse
                ToolTip.text: picker.hintText
                ToolTip.delay: 250
            }
            VfSourceSeg {
                Layout.preferredWidth: picker.width < VfTheme.dp(390)
                    ? VfTheme.dp(72)
                    : (picker.width < VfTheme.dp(560) ? VfTheme.dp(90) : VfTheme.dp(158))
                text: picker.width < VfTheme.dp(560)
                    ? "⚡ Auto"
                    : "⚡ " + (void i18n.revision, i18n.t("affiliate.src_auto", "Auto (AI theo ngành SP)"))
                selected: picker.aiMode
                accent: picker.accentColor
                onClicked: picker.aiToggled(true)
            }
            VfSourceSeg {
                Layout.preferredWidth: picker.width < VfTheme.dp(390)
                    ? VfTheme.dp(50)
                    : (picker.width < VfTheme.dp(560) ? VfTheme.dp(66) : VfTheme.dp(76))
                text: picker.width < VfTheme.dp(440)
                    ? "Kho"
                    : (void i18n.revision, i18n.t("affiliate.src_library_short", "Thư viện"))
                selected: !picker.aiMode
                accent: picker.accentColor
                onClicked: picker.aiToggled(false)
            }
            // 💾 Tự lưu — toggle độc lập với nguồn Auto/Thư viện.
            VfSourceSeg {
                visible: picker.showAutoSave
                Layout.preferredWidth: picker.width < VfTheme.dp(390)
                    ? VfTheme.dp(42)
                    : (picker.width < VfTheme.dp(560) ? VfTheme.dp(54) : VfTheme.dp(84))
                text: picker.width < VfTheme.dp(560)
                    ? "💾"
                    : "💾 " + (void i18n.revision, i18n.t("affiliate.auto_save_lib", "Tự lưu"))
                selected: picker.autoSaveOn
                accent: VfTheme.greenBorder
                onClicked: picker.autoSaveToggled(!picker.autoSaveOn)
            }
        }

        // BODY: dải CARD ngang MỘT hàng — tràn thì trượt ngang.
        Flickable {
            id: cardFlick
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: cardRow.implicitWidth
            contentHeight: height
            clip: true
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            // Nhiều asset → CẦM CHUỘT KÉO NGANG (bố 22/7: bỏ thanh scrollbar, nhìn gọn).
            readonly property int cardSpan: VfTheme.dp(124)
            // Tối thiểu 5 Ô TRỐNG (bố chốt) — thiếu chỗ thì trượt ngang.
            readonly property int ghostCount: picker.aiMode
                ? 0
                : Math.max(0, Math.max(5 + picker.assetCount(), Math.floor(width / cardSpan) - 1) - picker.assetCount())

            Row {
                id: cardRow
                height: parent.height
                spacing: VfTheme.dp(6)

                // AUTO mode: card ⚡ theo budget + card preview theo NGÀNH SP đang chọn.
                Repeater {
                    model: picker.aiMode ? Math.max(1, picker.maxAiSlots) : 0
                    Rectangle {
                        width: VfTheme.dp(118); height: cardRow.height
                        radius: VfTheme.dp(7)
                        color: Qt.alpha(picker.accentColor, 0.07)
                        border.color: Qt.alpha(picker.accentColor, 0.45); border.width: 1
                        Column {
                            anchors.centerIn: parent
                            width: parent.width - VfTheme.dp(12)
                            spacing: VfTheme.dp(2)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "⚡ AI " + (index + 1)
                                color: picker.accentColor
                                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(12); font.weight: Font.Bold
                            }
                            Text {
                                width: parent.width
                                horizontalAlignment: Text.AlignHCenter
                                text: picker.previewHint.length > 0 ? picker.previewHint : picker.aiLabel
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(9.5)
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // LIBRARY mode: card asset thật (ảnh + tên + giọng lock).
                Repeater {
                    model: picker.aiMode ? [] : picker.assetsModel
                    Rectangle {
                        required property var modelData
                        width: VfTheme.dp(118); height: cardRow.height
                        radius: VfTheme.dp(7)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border; border.width: 1
                        clip: true
                        Image {
                            id: cardImg
                            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
                            height: parent.height - VfTheme.dp(34)
                            source: picker.imageResolver(modelData)
                            fillMode: Image.PreserveAspectCrop; asynchronous: true
                            sourceSize.width: 236; sourceSize.height: 200
                            visible: source.toString() !== ""
                        }
                        VfAppIcon {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top; anchors.topMargin: VfTheme.dp(14)
                            visible: !cardImg.visible
                            name: picker.titleIcon.length > 0 ? picker.titleIcon : "busts-in-silhouette"
                            size: VfTheme.dp(24); framed: false; color: VfTheme.textSubtle
                        }
                        Column {
                            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
                            anchors.margins: VfTheme.dp(5)
                            spacing: 0
                            Text {
                                width: parent.width
                                text: String((modelData || {}).name || (modelData || {}).title || "")
                                color: VfTheme.text; font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.dp(10); font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                visible: String(picker.voiceResolver(modelData) || "").length > 0
                                text: "🔒 " + String(picker.voiceResolver(modelData) || "")
                                color: VfTheme.greenText; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(9)
                                elide: Text.ElideRight
                            }
                        }
                        Rectangle {
                            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: VfTheme.dp(3)
                            width: VfTheme.dp(18); height: VfTheme.dp(18); radius: VfTheme.dp(9)
                            color: Qt.rgba(0, 0, 0, 0.55)
                            Text { anchors.centerIn: parent; text: "✕"; color: "#FFFFFF"; font.pixelSize: VfTheme.dp(10) }
                            MouseArea {
                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: picker.remove(picker.idOf(modelData))
                            }
                        }
                    }
                }

                // LIBRARY mode: card "＋ Thêm từ Thư viện".
                Rectangle {
                    visible: !picker.aiMode
                    width: VfTheme.dp(118); height: cardRow.height
                    radius: VfTheme.dp(7)
                    color: addMouse.containsMouse ? VfTheme.surfaceSoft : "transparent"
                    border.color: picker.accentColor; border.width: 1
                    Column {
                        anchors.centerIn: parent
                        spacing: VfTheme.dp(2)
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "＋"; color: picker.accentColor
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(16); font.weight: Font.Bold
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (void i18n.revision, i18n.t("affiliate.add_from_library", "Thêm từ Thư viện"))
                            color: picker.accentColor
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(9.5); font.weight: Font.DemiBold
                        }
                    }
                    MouseArea {
                        id: addMouse
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: picker.choose()
                    }
                }

                // Ghost lấp vừa đúng 1 hàng (library mode).
                Repeater {
                    model: cardFlick.ghostCount
                    Rectangle {
                        width: VfTheme.dp(118); height: cardRow.height
                        radius: VfTheme.dp(7)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft; border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: (void i18n.revision, i18n.t("affiliate.slot_empty", "Ô trống")) + " " + (picker.assetCount() + index + 1)
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10)
                        }
                    }
                }
            }
        }

        // Caption đáy.
        Text {
            Layout.fillWidth: true
            visible: picker.footNote.length > 0
            text: picker.footNote
            color: VfTheme.textSubtle
            font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.dp(10)
            elide: Text.ElideRight
        }
    }
}
