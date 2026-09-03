import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

// Xác nhận cuối trước khi thêm vào hàng chờ tạo video.
// Gom: kiểm tài khoản (ưu tiên) -> kiểm nguồn đã chọn (server=tiền / personal=key)
// -> tóm tắt config để user xác nhận. Kèm "không hỏi lại".
Dialog {
    id: root

    property string route: "master"
    property bool imageOutput: false   // Audio→Ảnh: đổi tiêu đề (tạo ẢNH, không phải video)
    property var configRows: []   // [{label, value}] do màn hình truyền vào
    // Số tài khoản Live — lấy CÙNG nguồn với gate enqueue (appController) để
    // dialog và gate không bao giờ mâu thuẫn. Snapshot lúc mở (state ổn định).
    property int liveCount: 0
    signal confirmed()

    function openFor(rows) {
        root.configRows = rows || []
        root.liveCount = appController.liveAccountCount()
        root.open()
    }

    // ---- đọc trạng thái từ controller ----
    function _mode() { return String(accountSettingsController.apiMode || "server").toLowerCase() }
    // liveCount: >0 có tài khoản, 0 không có, -1 không xác định (coi như ok, gate sẽ quyết)
    function _accountOk() { return root.liveCount !== 0 }
    function _hasGeminiKey() {
        var keys = accountSettingsController.apiKeys || []
        for (var i = 0; i < keys.length; i++)
            if (String((keys[i] || {}).provider || "").toLowerCase() === "gemini")
                return true
        return false
    }
    function _money() {
        var s = headerController.summary || ({})
        return (s.money && typeof s.money === "object") ? s.money : ({})
    }
    function _moneyApplicable() { return root._mode() === "server" }
    function _keyApplicable() { return root._mode() === "personal" }
    function _moneyOk() {
        var m = root._money()
        if (String(m.source || "") === "credits_fallback") return true
        var b = Number(m.available_balance)
        if (isNaN(b)) return true
        return b > 0
    }
    function _fmtMoney() {
        var m = root._money()
        var b = Number(m.available_balance)
        var cur = String(m.currency || (void i18n.revision, i18n.t("queue_preflight_dialog.currency_default", "đ")))
        if (isNaN(b)) return "—"
        return String(b).replace(/\B(?=(\d{3})+(?!\d))/g, ".") + " " + cur
    }
    // ---- Cost preview (clone): controller.queueCost {status, input_tokens, est_output_tokens, est_cost, billing_unit} ----
    function _cost() { return workPanelController.queueCost || ({}) }
    function _costStatus() { return String(root._cost().status || "") }
    function _costVisible() { return root._costStatus().length > 0 }
    function _fmtNum(n) { return String(Math.round(Number(n) || 0)).replace(/\B(?=(\d{3})+(?!\d))/g, ".") }
    function _costItems() { return root._cost().items || [] }
    function _costUnit() { return String(root._cost().billing_unit || "đ") }
    function _costItemLabel(it) {
        var t = String((it || {}).title || "")
        return t.length > 34 ? (t.slice(0, 33) + "…") : t
    }
    function _costItemValue(it) {
        var i = it || {}
        var tok = root._fmtNum(Number(i.system_tokens || 0) + Number(i.video_tokens || 0) + Number(i.output_tokens || 0))
        var sc = Number(i.scenes || 0)
        return (sc > 0 ? (root._fmtNum(sc) + " cảnh · ") : "") + "~" + root._fmtNum(i.cost) + " " + root._costUnit() + " · " + tok + " tok"
    }
    function _costTotal() { return "~" + root._fmtNum(root._cost().total_cost) + " " + root._costUnit() }
    // Hard gate = phải có tài khoản. Tiền/key chỉ cảnh báo.
    function _ready() { return root._accountOk() }

    title: ""
    modal: true
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape
    width: VfDialogMetrics.width(parent, VfTheme.dp(560), 60)
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: VfTheme.dp(16)
    standardButtons: Dialog.NoButton

    background: Rectangle {
        color: VfTheme.surface
        radius: VfTheme.radiusPanel
        border.color: VfTheme.borderStrong
        border.width: 1
    }

    contentItem: ColumnLayout {
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: VfTheme.dp(48)
            color: VfTheme.surfaceSoft
            radius: VfTheme.radiusPanel

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: VfTheme.dp(18)
                anchors.rightMargin: VfTheme.dp(14)
                spacing: VfTheme.dp(10)

                VfAppIcon { name: "clipboard"; size: VfTheme.dp(16); framed: false; color: VfTheme.primary; Layout.alignment: Qt.AlignVCenter }
                Text {
                    Layout.fillWidth: true
                    text: root.imageOutput
                        ? (void i18n.revision, i18n.t("queue_confirm.title_image", "Xác nhận trước khi tạo video ảnh"))
                        : (void i18n.revision, i18n.t("queue_confirm.title", "Xác nhận trước khi tạo video"))
                    color: VfTheme.text
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.dp(16)
                    font.weight: VfTheme.weightTitle
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.borderBox }

        // Body
        ColumnLayout {
            Layout.fillWidth: true
            Layout.margins: VfTheme.dp(18)
            spacing: VfTheme.dp(12)

            // --- Nhắc nhở loại video nên clone (clone only) ---
            Rectangle {
                visible: root.route === "clone"
                Layout.fillWidth: true
                radius: VfTheme.radiusControl
                color: VfTheme.amberFill
                border.color: VfTheme.amberBorderSoft
                border.width: 1
                implicitHeight: _warnCol.implicitHeight + VfTheme.dp(16)
                ColumnLayout {
                    id: _warnCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: VfTheme.dp(12)
                    anchors.rightMargin: VfTheme.dp(12)
                    spacing: VfTheme.dp(2)
                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("queue_confirm.clone_warn", "⚠️ Chỉ nên clone video NGẮN, chủ đề rõ ràng, dễ bắt chước."))
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("queue_confirm.clone_warn2", "KHÔNG nên clone video kể chuyện (storytelling) / quá dài: số cảnh Veo3 CỰC LỚN → tốn token, LÃNG PHÍ tài nguyên. Dạng video này KHÔNG phù hợp — xem số cảnh + chi phí bên dưới."))
                        color: VfTheme.amberText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(11)
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // --- SẴN SÀNG ---
            Text {
                text: (void i18n.revision, i18n.t("queue_confirm.readiness", "SẴN SÀNG"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.Bold
            }

            // Account (hard)
            CheckRow {
                state2: root._accountOk() ? "ok" : "bad"
                label: (void i18n.revision, i18n.t("queue_confirm.account", "Tài khoản"))
                detail: root.liveCount > 0
                    ? root.liveCount + " " + (void i18n.revision, i18n.t("queue_confirm.accounts_active", "tài khoản hoạt động"))
                    : (root.liveCount === 0
                        ? (void i18n.revision, i18n.t("queue_confirm.no_account", "Chưa có tài khoản — cần thêm để chạy"))
                        : (void i18n.revision, i18n.t("queue_confirm.account_unknown", "Sẽ kiểm tra khi chạy")))
            }

            // Mode: server -> money
            CheckRow {
                visible: root._moneyApplicable()
                state2: root._moneyOk() ? "ok" : "warn"
                label: (void i18n.revision, i18n.t("queue_confirm.balance", "Số dư (chế độ Server)"))
                detail: !root._moneyOk()
                    ? (void i18n.revision, i18n.t("queue_confirm.balance_low", "Số dư không đủ — có thể nạp thêm"))
                    : (String(root._money().source || "") === "gateway"
                        ? (void i18n.revision, i18n.t("queue_confirm.balance_ok", "Còn")) + " " + root._fmtMoney()
                        : (void i18n.revision, i18n.t("queue_confirm.balance_na", "Đủ điều kiện")))
            }

            // Mode: personal -> key
            CheckRow {
                visible: root._keyApplicable()
                state2: root._hasGeminiKey() ? "ok" : "warn"
                label: (void i18n.revision, i18n.t("queue_confirm.personal_key", "API key cá nhân"))
                detail: root._hasGeminiKey()
                    ? (void i18n.revision, i18n.t("queue_confirm.key_ok", "Đã có Gemini key"))
                    : (void i18n.revision, i18n.t("queue_confirm.key_missing", "Chưa có Gemini key — thêm trong Cài đặt"))
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.borderBox; visible: root.configRows.length > 0 }

            // --- CẤU HÌNH ---
            Text {
                visible: root.configRows.length > 0
                text: (void i18n.revision, i18n.t("queue_confirm.config", "CẤU HÌNH"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.Bold
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: VfTheme.dp(18)
                rowSpacing: VfTheme.dp(6)
                Repeater {
                    model: root.configRows
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        Text {
                            text: String((modelData || {}).label || "")
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String((modelData || {}).value || "—")
                            color: Boolean((modelData || {}).warn) ? "#F59E0B" : VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignRight
                            wrapMode: Boolean((modelData || {}).warn) ? Text.WordWrap : Text.NoWrap
                            elide: Boolean((modelData || {}).warn) ? Text.ElideNone : Text.ElideRight
                        }
                    }
                }
            }

            // --- CHI PHÍ ƯỚC TÍNH (clone) ---
            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.borderBox; visible: root._costVisible() }
            Text {
                visible: root._costVisible()
                text: (void i18n.revision, i18n.t("queue_confirm.cost", "CHI PHÍ ƯỚC TÍNH"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(10)
                font.weight: Font.Bold
            }
            Text {
                visible: root._costVisible() && root._costStatus() !== "ready"
                Layout.fillWidth: true
                text: root._costStatus() === "computing"
                    ? (void i18n.revision, i18n.t("queue_confirm.cost_computing", "Đang tính chi phí…"))
                    : (void i18n.revision, i18n.t("queue_confirm.cost_error", "Không tính được chi phí — bỏ qua"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(11)
            }
            ColumnLayout {
                visible: root._costVisible() && root._costStatus() === "ready"
                Layout.fillWidth: true
                spacing: VfTheme.dp(5)
                // Per-link: mỗi video 1 hàng (tên + chi phí + tổng token)
                Repeater {
                    model: root._costItems()
                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        Text {
                            Layout.fillWidth: true
                            text: root._costItemLabel(modelData)
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            elide: Text.ElideRight
                        }
                        Text {
                            text: root._costItemValue(modelData)
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(11)
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.borderBox }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: VfTheme.dp(8)
                    Text {
                        Layout.fillWidth: true
                        text: (void i18n.revision, i18n.t("queue_confirm.cost_total", "Tổng ước tính")) + " (" + root._fmtNum(root._cost().count) + " video)"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                        font.weight: Font.Bold
                    }
                    Text {
                        text: root._costTotal()
                        color: VfTheme.primary
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(13)
                        font.weight: Font.Bold
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: VfTheme.borderBox }

        // Footer
        RowLayout {
            Layout.fillWidth: true
            Layout.margins: VfTheme.dp(14)
            spacing: VfTheme.dp(10)

            Item { Layout.fillWidth: true }

            VfButton {
                text: (void i18n.revision, i18n.t("common.cancel", "Huỷ"))
                minWidth: VfTheme.dp(88)
                onClicked: root.close()
            }

            // Không có tài khoản -> nút hướng dẫn thêm
            VfButton {
                visible: !root._accountOk()
                text: (void i18n.revision, i18n.t("queue_confirm.add_account", "Thêm tài khoản"))
                tone: "primary"
                minWidth: VfTheme.dp(140)
                onClicked: {
                    appController.setRoute("settings")
                    root.close()
                }
            }

            // Đủ điều kiện -> vào hàng chờ
            VfButton {
                visible: root._accountOk()
                text: (void i18n.revision, i18n.t("queue_confirm.proceed", "Vào hàng chờ"))
                tone: "primary"
                minWidth: VfTheme.dp(140)
                onClicked: {
                    root.confirmed()
                    root.close()
                }
            }
        }
    }

    // Một dòng check ✓/⚠/✗
    component CheckRow: RowLayout {
        property string state2: "ok"   // ok | warn | bad
        property string label: ""
        property string detail: ""
        Layout.fillWidth: true
        spacing: VfTheme.dp(8)

        Rectangle {
            width: VfTheme.dp(18); height: VfTheme.dp(18); radius: width / 2
            color: state2 === "ok" ? VfTheme.greenFill : (state2 === "warn" ? VfTheme.amberFill : VfTheme.redFill)
            Layout.alignment: Qt.AlignVCenter
            Text {
                anchors.centerIn: parent
                text: state2 === "ok" ? "✓" : (state2 === "warn" ? "!" : "✕")
                color: state2 === "ok" ? VfTheme.greenText : (state2 === "warn" ? VfTheme.amberText : "#DC2626")
                font.pixelSize: VfTheme.dp(11); font.weight: Font.Bold
            }
        }
        Text {
            text: parent.label
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(12)
            font.weight: Font.DemiBold
        }
        Text {
            Layout.fillWidth: true
            text: parent.detail
            color: VfTheme.textMuted
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.dp(11)
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }
    }
}
