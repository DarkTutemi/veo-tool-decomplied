import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../dialogs"
import "../theme"

Item {
    id: screen
    objectName: "accountSettingsScreen"

    property bool compact: width < 1280
    property string selectedAccountEmail: ""
    property string selectedProxyKey: ""
    property string pendingProxyDeleteKey: ""
    property string proxyActionStatusText: ""
    property string proxyFeedbackTitle: ""
    property string proxyFeedbackMessage: ""
    // PRO/ULTRA mode toggle state (effective + đếm account mỗi loại). Default "pro"
    // (fallback an toàn) — refreshAccountMode() ghi đè ngay khi màn hình load.
    property var accountModeState: ({ "effective": "pro", "ultraCount": 0, "proCount": 0, "ultraMax": 10, "hasLiveUltra": false, "needsRelogin": false, "reloginEmail": "", "reloginAccountId": "" })

    function refreshAccountMode() {
        screen.accountModeState = accountSettingsController.accountMode() || screen.accountModeState
    }

    function openPendingDialogs() {
        if (accountSettingsController.consumePendingDialog("api_keys")) {
            accountSettingsController.refreshApiKeys()
            apiKeysDialog.open()
        }
    }

    function statusTone(status) {
        var value = String(status || "").toLowerCase()
        if (value === "live" || value === "ready" || value === "ok")
            return "green"
        if (value === "dead" || value === "failed" || value === "missing" || value === "free")
            return "red"
        if (value === "need login" || value === "expired")
            return "amber"
        return "blue"
    }

    function proxyChoices(email) {
        return accountSettingsController.proxyChoices(String(email || "")) || []
    }

    function projectActionError(payload) {
        var code = String((payload && payload.error) || "")
        if (code === "empty_project_id" || code === "invalid_project_id_format")
            return i18n.t("accounts.invalid_project_id", "Project ID không hợp lệ.")
        if (code === "project_not_owned_by_account")
            return i18n.t("accounts.project_not_owned", "Project không tồn tại hoặc không thuộc tài khoản này.")
        if (code === "project_persist_failed")
            return i18n.t("accounts.project_save_failed", "Không lưu được Project ID.")
        if (code.indexOf("project_list_failed:") === 0)
            return i18n.t("accounts.project_verify_failed", "Không xác minh được project với tài khoản này. Hãy đăng nhập lại rồi thử lại.")
        return String((payload && payload.message) || code || i18n.t("common.action_failed", "Action failed"))
    }

    function openAssignProxyFor(accountRow) {
        var row = accountRow || ({})
        var email = String(row.email || "")
        var currentProxy = String(row.proxy || "")
        var choices = screen.proxyChoices(email)
        screen.selectedAccountEmail = email
        // No pool yet → open Add Proxy (proxy section removed; per-account entry only).
        if ((!choices || choices.length === 0) && currentProxy.length === 0) {
            addProxyDialog.resetForm()
            addProxyDialog.open()
            return
        }
        assignProxyDialog.openFor(email, choices, currentProxy)
    }

    function nativeActionRequiresText() {
        var payload = (accountSettingsController ? accountSettingsController.nativeAction : null) || ({})
        var contract = payload.contract || ({})
        var requires = contract.requires || payload.requires || []
        if (!requires || requires.length === 0)
            return ""
        var parts = []
        for (var i = 0; i < requires.length; i += 1)
            parts.push(String(requires[i] || ""))
        return "Requires: " + parts.join(", ")
    }

    function cleanText(value) {
        var text = String(value || "")
        while (text.length > 0) {
            var code = text.charCodeAt(0)
            if (code === 0x20) {
                text = text.slice(1)
                continue
            }
            if (code >= 0xD800 && code <= 0xDBFF) {
                text = text.slice(2).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            if ((code >= 0x2600 && code <= 0x27BF) || code === 0x25A1 || code === 0xFFFD) {
                text = text.slice(1).replace(/^[\ufe0f\u200d\s]+/, "")
                continue
            }
            if (text.indexOf("ð") === 0 || text.indexOf("ï") === 0 || text.indexOf((void i18n.revision, i18n.t("account_settings_screen.diacritic_check_char", "â"))) === 0) {
                var firstSpace = text.indexOf(" ")
                if (firstSpace >= 0) {
                    text = text.slice(firstSpace + 1)
                    continue
                }
            }
            break
        }
        return text
    }

    function requestProxyDelete(proxyKey) {
        screen.pendingProxyDeleteKey = String(proxyKey || screen.selectedProxyKey || "")
        if (screen.pendingProxyDeleteKey.length === 0) {
            screen.proxyActionStatusText = (void i18n.revision, i18n.t("settings.select_proxy_to_delete", "Select a proxy to delete."))
            screen.showSettingsFeedback((void i18n.revision, i18n.t("common.warning", "Warning")), screen.proxyActionStatusText)
            return
        }
        proxyDeleteConfirmDialog.open()
    }

    function openAddProxyDialog() {
        addProxyDialog.open()
    }

    function requestProfileCleanup() {
        profileCleanupConfirmDialog.open()
    }

    function showSettingsFeedback(title, message) {
        screen.proxyFeedbackTitle = String(title || "")
        screen.proxyFeedbackMessage = String(message || "")
        proxyFeedbackDialog.open()
    }

    function applySettingsActionResult(result, fallbackError, fallbackSuccess) {
        var payload = result && typeof result === "object" ? result : ({})
        if (payload.pending) {
            screen.proxyActionStatusText = String(payload.message || fallbackSuccess || (void i18n.revision, i18n.t("common.working", "Working...")))
            return true
        }
        if (!payload.ok) {
            screen.showSettingsFeedback(
                (void i18n.revision, i18n.t("common.warning", "Warning")),
                String(payload.message || payload.error || fallbackError || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
            )
            return false
        }
        screen.showSettingsFeedback(
            (void i18n.revision, i18n.t("common.success", "Success")),
            String(payload.message || fallbackSuccess || (void i18n.revision, i18n.t("common.done", "Done")))
        )
        return true
    }

    function startProxyCheck() {
        proxyCheckDialog.open()
        proxyCheckDialog.applyStartResult(accountSettingsController.checkProxies())
    }

    function runCheckAccounts() {
        screen.applySettingsActionResult(
            accountSettingsController.checkAccounts(),
            "Could not check accounts.",
            "Checked accounts"
        )
    }

    function runClearAccountProxies() {
        screen.applySettingsActionResult(
            accountSettingsController.clearAccountProxies(),
            "Could not clear account proxy mappings.",
            "Cleared account proxy mappings"
        )
    }

    function runRemoveDeadProxies() {
        screen.applySettingsActionResult(
            accountSettingsController.removeDeadProxies(),
            "Could not remove dead proxies.",
            "Removed dead proxies"
        )
    }

    function applyProxyDeleteResult(result) {
        var response = result || ({})
        if (response.pending) {
            screen.proxyActionStatusText = String(response.message || (void i18n.revision, i18n.t("common.working", "Working...")))
            return
        }
        if (!response.ok) {
            screen.proxyActionStatusText = String(response.message || response.error || response.code || (void i18n.revision, i18n.t("settings.delete_proxy_failed", "Failed to delete proxy.")))
            screen.showSettingsFeedback((void i18n.revision, i18n.t("common.error", "Error")), screen.proxyActionStatusText)
            return
        }
        var removedKey = String(response.removed || screen.pendingProxyDeleteKey || "")
        if (removedKey.length > 0 && removedKey === screen.selectedProxyKey)
            screen.selectedProxyKey = ""
        screen.proxyActionStatusText = String(response.message || (void i18n.revision, i18n.t("common.deleted", "Deleted")))
        screen.showSettingsFeedback((void i18n.revision, i18n.t("common.success", "Success")), screen.proxyActionStatusText)
    }

    function applyFinishedSettingsAction(action, result) {
        var actionName = String(action || "")
        var payload = result || ({})
        if (actionName === "account.toggle") {
            // Bật/tắt account đổi loại đang chạy → cập nhật nút MODE ngay (không dựa
            // gián tiếp vào onAccountsChanged, vốn có thể bị guard _accounts_loading nuốt).
            screen.refreshAccountMode()
        }
        if (actionName === "account.update") {
            accountEditDialog.applySaveResult(payload)
            return
        }
        if (actionName === "account.delete") {
            accountDeleteDialog.applyDeleteResult(payload)
            return
        }
        if (actionName === "proxy.add") {
            addProxyDialog.applyAcceptResult(payload)
            return
        }
        if (actionName === "proxy.assign") {
            assignProxyDialog.applyAssignResult(payload)
            return
        }
        if (actionName === "proxy.remove") {
            screen.applyProxyDeleteResult(payload)
            return
        }
        if (actionName === "api_key.add") {
            if (apiKeyDialog.visible)
                apiKeyDialog.applySaveResult(payload)
            if (apiKeysDialog.visible)
                apiKeysDialog.applyAddResult(payload)
            return
        }
        if (actionName === "api_key.remove") {
            apiKeysDialog.applyDeleteResult(payload)
            return
        }
        if (actionName === "api_key.mode") {
            apiKeysDialog.applyModeResult(payload)
            return
        }
        if (actionName === "account.browser_login_import") {
            if (payload.pending)
                return
            if (payload.ok) {
                browserLoginDialog.close()
                if (payload.needsProjectChoice) {
                    projectChooserDialog.accountEmail = String(payload.email || payload.accountEmail || "")
                    projectChooserDialog.projects = payload.projects || []
                    projectChooserDialog.open()
                }
            } else {
                screen.showSettingsFeedback(
                    (void i18n.revision, i18n.t("common.error", "Error")),
                    String(payload.message || payload.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            }
            return
        }
        if (actionName === "account.browser_login_project_setup") {
            if (payload.needsProjectChoice) {
                projectChooserDialog.accountEmail = String(payload.email || "")
                projectChooserDialog.projects = payload.projects || []
                projectChooserDialog.loading = false
                projectChooserDialog.busy = false
                projectChooserDialog.open()
            } else if (!payload.ok) {
                screen.showSettingsFeedback(
                    (void i18n.revision, i18n.t("common.error", "Error")),
                    String(payload.message || payload.projectError || (void i18n.revision, i18n.t("accounts.project_setup_failed", "Account imported, but project setup failed.")))
                )
            }
            return
        }
        if (actionName === "account.list_projects") {
            projectChooserDialog.loading = false
            if (payload.ok) {
                projectChooserDialog.projects = payload.projects || []
            } else {
                screen.showSettingsFeedback(
                    (void i18n.revision, i18n.t("common.error", "Error")),
                    String(payload.message || payload.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
                )
            }
            return
        }
        if (actionName === "account.create_project" || actionName === "account.use_project") {
            projectChooserDialog.busy = false
            if (payload.ok) {
                projectChooserDialog.close()
            } else {
                screen.showSettingsFeedback(
                    (void i18n.revision, i18n.t("common.error", "Error")),
                    screen.projectActionError(payload)
                )
            }
            return
        }
        if (!payload.ok) {
            screen.showSettingsFeedback(
                (void i18n.revision, i18n.t("common.error", "Error")),
                String(payload.message || payload.error || (void i18n.revision, i18n.t("common.action_failed", "Action failed")))
            )
            return
        }
        screen.proxyActionStatusText = String(payload.message || "")
    }

    function openProjectChooserFor(modelData) {
        projectChooserDialog.accountEmail = String((modelData && modelData.email) || "")
        projectChooserDialog.projects = []
        projectChooserDialog.busy = false
        projectChooserDialog.loading = true
        projectChooserDialog.open()
        // Async: existing projects arrive via settingsActionFinished (account.list_projects).
        accountSettingsController.requestAccountProjects(projectChooserDialog.accountEmail)
    }

    Rectangle {
        anchors.fill: parent
        color: VfTheme.surfaceSoft
    }

    ScrollView {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(10)
        clip: true
        contentWidth: contentColumn.width
        contentHeight: contentColumn.implicitHeight
        ScrollBar.horizontal.policy: ScrollBar.AsNeeded
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        ColumnLayout {
            id: contentColumn

            width: Math.max(screen.width - VfTheme.dp(20), VfTheme.dp(1105))
            spacing: VfTheme.dp(10)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 74 : 0
                visible: Boolean(accountSettingsController && accountSettingsController.nativeAction && accountSettingsController.nativeAction.blocked)
                radius: VfTheme.radiusPanel
                color: VfTheme.amberFill
                border.color: VfTheme.amberBorderSoft

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(10)
                    spacing: VfTheme.dp(10)

                    Rectangle {
                        Layout.preferredWidth: VfTheme.dp(7)
                        Layout.fillHeight: true
                        radius: VfTheme.dp(4)
                        color: "#F97316"
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(3)

                        Text {
                            Layout.fillWidth: true
                            text: String((accountSettingsController && accountSettingsController.nativeAction ? accountSettingsController.nativeAction.code : null) || "native_action_blocked")
                            color: VfTheme.amberText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            font.weight: VfTheme.weightTitle
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: String((accountSettingsController && accountSettingsController.nativeAction ? (accountSettingsController.nativeAction.reason || accountSettingsController.nativeAction.message) : null) || "")
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: screen.nativeActionRequiresText().length > 0
                            text: screen.nativeActionRequiresText()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            SectionFrame {
                Layout.fillWidth: true
                // Height tracks real content (header + all rows + footer) so the
                // whole account list is always contained; the outer ScrollView
                // owns scrolling (account list is interactive:false).
                Layout.preferredHeight: VfTheme.dp(38) + accountsBody.implicitHeight
                title: (void i18n.revision, i18n.t("accounts.section_title", "Accounts"))
                // ULTRA giới hạn 10; PRO unlimited (∞).
                countText: screen.accountModeState.effective === "ultra"
                    ? (String(screen.accountModeState.ultraCount || 0) + "/" + String(screen.accountModeState.ultraMax || 10))
                    : (String((accountSettingsController ? accountSettingsController.stats.accounts : null) || 0) + "/∞")
                headerColor: VfTheme.primary

                ColumnLayout {
                    id: accountsBody

                    anchors.fill: parent
                    spacing: 0

                    // PRO/ULTRA MODE toggle — tool chạy 1 mode, không trộn. PRO = chống cháy.
                    // Cùng hàng: RUNTIME POOL (xoay vòng, CHỈ ÁP PRO — account cạn 0cr
                    // tự tắt, đề bạt account kế; ULTRA mode bypass ở lớp pool, nguyên
                    // đội song song; Google reset credit → sweep 6h/lần bật lại).
                    Rectangle {
                        id: modePoolRow
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(40)
                        color: VfTheme.surface
                        border.color: VfTheme.borderSoft

                        readonly property var pool: accountSettingsController ? (accountSettingsController.runtimePool || ({})) : ({})

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(10)
                            spacing: VfTheme.dp(8)

                            Text {
                                text: (void i18n.revision, i18n.t("accounts.mode_label", "MODE"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightTitle
                            }

                            Repeater {
                                // Chỉ 2 mode, KHÔNG auto — highlight mode đang chạy thật.
                                model: [
                                    { "key": "ultra", "label": "ULTRA" },
                                    { "key": "pro", "label": "PRO" }
                                ]
                                delegate: Rectangle {
                                    objectName: "set_mode_" + modelData.key   // set_mode_ultra / set_mode_pro (tour)
                                    readonly property bool active: screen.accountModeState.effective === modelData.key
                                    // Radio thuần: mỗi nút chỉ disable khi hệ thống KHÔNG có
                                    // account thuộc loại đó. Chọn nút nào → tự bật loại đó, tắt loại kia.
                                    readonly property bool disabledMode:
                                        (modelData.key === "ultra" && (screen.accountModeState.ultraCount || 0) === 0)
                                        || (modelData.key === "pro" && (screen.accountModeState.proCount || 0) === 0)
                                    // This delegate is managed by RowLayout.  Plain
                                    // width/height are not layout hints and can be
                                    // overwritten to zero during a relayout, putting
                                    // ULTRA and PRO in the same slot.  Give the layout
                                    // deterministic geometry instead.
                                    implicitWidth: VfTheme.dp(64)
                                    implicitHeight: VfTheme.dp(26)
                                    Layout.preferredWidth: implicitWidth
                                    Layout.preferredHeight: implicitHeight
                                    radius: VfTheme.dp(13)
                                    opacity: disabledMode ? 0.4 : 1.0
                                    color: active
                                        ? (modelData.key === "ultra" ? "#F59E0B" : "#3B82F6")
                                        : VfTheme.surfaceSoft
                                    border.color: active ? "transparent" : VfTheme.borderSoft

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        color: parent.active ? "#FFFFFF" : VfTheme.textMuted
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightTitle
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: !parent.disabledMode
                                        cursorShape: parent.disabledMode ? Qt.ArrowCursor : Qt.PointingHandCursor
                                        onClicked: {
                                            accountSettingsController.setAccountMode(modelData.key)
                                            screen.refreshAccountMode()
                                        }
                                    }
                                }
                            }

                            // Separator phân vùng MODE | RUNTIME POOL
                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: VfTheme.dp(20)
                                color: VfTheme.borderSoft
                            }

                            Text {
                                text: (void i18n.revision, i18n.t("accounts.pool_label", "RUNTIME POOL"))
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightTitle

                                // Giải thích ngắn: chỉ PRO bị cap xoay; ULTRA nguyên đội.
                                HoverHandler { id: poolLabelHover }
                                ToolTip.visible: poolLabelHover.hovered
                                ToolTip.text: (void i18n.revision, i18n.t(
                                    "accounts.pool_hint",
                                    "Chỉ áp PRO mode: hết khả năng tạo video thì xoay account khác, không chạy hàng loạt. ULTRA mode chạy song song nguyên đội."))
                            }

                            // ON/OFF — commit-once: 1 click = 1 lần gọi backend.
                            Rectangle {
                                objectName: "set_pool_switch"
                                readonly property bool isOn: Boolean(modePoolRow.pool.enabled)
                                implicitWidth: VfTheme.dp(64)
                                implicitHeight: VfTheme.dp(26)
                                Layout.preferredWidth: implicitWidth
                                Layout.preferredHeight: implicitHeight
                                radius: VfTheme.dp(13)
                                color: isOn ? "#22C55E" : VfTheme.surfaceSoft
                                border.color: isOn ? "transparent" : VfTheme.borderSoft

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.isOn ? "ON" : "OFF"
                                    color: parent.isOn ? "#FFFFFF" : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightTitle
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: screen.applySettingsActionResult(
                                        accountSettingsController.setRuntimePoolEnabled(!parent.isOn),
                                        (void i18n.revision, i18n.t("accounts.pool_toggle_failed", "Không đổi được Runtime Pool.")),
                                        ""
                                    )
                                }
                            }

                            // Stepper số account runtime đồng thời (1..5).
                            RowLayout {
                                spacing: VfTheme.dp(6)
                                opacity: modePoolRow.pool.enabled ? 1.0 : 0.4

                                Rectangle {
                                    objectName: "set_pool_minus"
                                    implicitWidth: VfTheme.dp(26)
                                    implicitHeight: VfTheme.dp(26)
                                    Layout.preferredWidth: implicitWidth
                                    Layout.preferredHeight: implicitHeight
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderSoft

                                    Text {
                                        anchors.centerIn: parent
                                        text: "−"
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightTitle
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: Boolean(modePoolRow.pool.enabled) && (parseInt(modePoolRow.pool.maxActive || 2, 10) > 1)
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: screen.applySettingsActionResult(
                                            accountSettingsController.setRuntimePoolSize(parseInt(modePoolRow.pool.maxActive || 2, 10) - 1),
                                            (void i18n.revision, i18n.t("accounts.pool_size_failed", "Không đổi được số account runtime.")),
                                            ""
                                        )
                                    }
                                }

                                Text {
                                    text: String(modePoolRow.pool.maxActive || 2)
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightTitle
                                }

                                Rectangle {
                                    objectName: "set_pool_plus"
                                    implicitWidth: VfTheme.dp(26)
                                    implicitHeight: VfTheme.dp(26)
                                    Layout.preferredWidth: implicitWidth
                                    Layout.preferredHeight: implicitHeight
                                    radius: VfTheme.dp(4)
                                    color: VfTheme.surfaceSoft
                                    border.color: VfTheme.borderSoft

                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        font.weight: VfTheme.weightTitle
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: Boolean(modePoolRow.pool.enabled) && (parseInt(modePoolRow.pool.maxActive || 2, 10) < 5)
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: screen.applySettingsActionResult(
                                            accountSettingsController.setRuntimePoolSize(parseInt(modePoolRow.pool.maxActive || 2, 10) + 1),
                                            (void i18n.revision, i18n.t("accounts.pool_size_failed", "Không đổi được số account runtime.")),
                                            ""
                                        )
                                    }
                                }
                            }

                            // Trạng thái pool (fill phần dư, elide ở màn hẹp) + tooltip
                            // sự kiện xoay gần nhất (đề bạt ai / cạn ai).
                            Text {
                                Layout.fillWidth: true
                                text: {
                                    void i18n.revision
                                    var p = modePoolRow.pool
                                    if (String(screen.accountModeState.effective || "") === "ultra")
                                        return i18n.t("accounts.pool_ultra", "ULTRA — nguyên đội chạy song song (pool chỉ áp PRO)")
                                    if (!Boolean(p.enabled))
                                        return i18n.t("accounts.pool_off", "Tắt — mọi account Live đều nhận job")
                                    var act = (p.active || []).length
                                    var drained = parseInt(p.drainedCount || 0, 10)
                                    var line = act + "/" + String(p.maxActive || 0) + " " + i18n.t("accounts.pool_running", "đang runtime") + " (PRO)"
                                    if (drained > 0)
                                        line += " · " + drained + " " + i18n.t("accounts.pool_drained", "đã cạn, chờ reset")
                                    return line
                                }
                                color: {
                                    if (String(screen.accountModeState.effective || "") === "ultra")
                                        return "#F59E0B"
                                    return Boolean(modePoolRow.pool.enabled) ? "#22C55E" : VfTheme.textMuted
                                }
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightTitle
                                elide: Text.ElideRight
                                horizontalAlignment: Text.AlignRight

                                HoverHandler { id: poolEventHover }
                                ToolTip.visible: poolEventHover.hovered && String(modePoolRow.pool.lastEvent.text || "").length > 0
                                ToolTip.text: String(modePoolRow.pool.lastEvent.text || "")
                            }

                            // Effective mode hiện tại (rõ khi đang Auto → đang chạy gì).
                            Text {
                                text: {
                                    var eff = String(screen.accountModeState.effective || "").toUpperCase()
                                    return (void i18n.revision, i18n.t("accounts.mode_running", "Running")) + ": " + eff
                                }
                                color: screen.accountModeState.effective === "ultra" ? "#F59E0B" : "#3B82F6"
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                font.weight: VfTheme.weightTitle
                            }
                        }
                    }

                    // Banner: mode đang chạy nhưng 0 tài khoản Live vì tài khoản đang bật
                    // rơi "Need Login" → nhắc + nút mở trình duyệt đăng nhập lại.
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: visible ? VfTheme.dp(44) : 0
                        visible: Boolean(screen.accountModeState.needsRelogin)
                        color: VfTheme.amberFill
                        border.color: VfTheme.amberBorderSoft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(10)
                            spacing: VfTheme.dp(8)

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    void i18n.revision
                                    var em = String(screen.accountModeState.reloginEmail || "")
                                    var md = String(screen.accountModeState.effective || "").toUpperCase()
                                    return i18n.t("accounts.relogin_needed", "Tài khoản %1 cần đăng nhập lại — chế độ %2 đang tạm dừng (0 tài khoản chạy được).")
                                        .replace("%1", em).replace("%2", md)
                                }
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                wrapMode: Text.WordWrap
                            }

                            VfButton {
                                text: (void i18n.revision, i18n.t("accounts.relogin_now", "Đăng nhập lại"))
                                onClicked: screen.applySettingsActionResult(
                                    accountSettingsController.requestRelogin(
                                        String(screen.accountModeState.reloginAccountId || ""),
                                        String(screen.accountModeState.reloginEmail || "")),
                                    (void i18n.revision, i18n.t("accounts.relogin_failed", "Không mở được trình duyệt đăng nhập.")),
                                    (void i18n.revision, i18n.t("accounts.relogin_started", "Đang mở trình duyệt đăng nhập..."))
                                )
                            }
                        }
                    }

                    // Banner: KHÔNG còn tài khoản nào SẴN SÀNG (Live + BẬT) → job sẽ bị chặn.
                    // Case hay gặp nhất mà banner relogin ở trên KHÔNG bắt được: tài khoản đã
                    // đăng nhập (Live) nhưng công tắc BẬT đang OFF — user không hề biết vì sao
                    // không chạy được. Hints đến từ accountsReadiness (cùng bộ lọc Live+enabled
                    // với run gate) nên banner và blocker lúc Chạy không bao giờ mâu thuẫn.
                    Rectangle {
                        id: readinessBanner
                        readonly property var rd: accountSettingsController
                            ? (accountSettingsController.accountsReadiness || ({}))
                            : ({})

                        Layout.fillWidth: true
                        visible: !Boolean(readinessBanner.rd.ready)
                            && !Boolean(screen.accountModeState.needsRelogin)
                        Layout.preferredHeight: visible ? (readinessCol.implicitHeight + VfTheme.dp(16)) : 0
                        color: VfTheme.amberFill
                        border.color: VfTheme.amberBorderSoft
                        border.width: 1

                        ColumnLayout {
                            id: readinessCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: VfTheme.dp(12)
                            anchors.rightMargin: VfTheme.dp(12)
                            spacing: VfTheme.dp(3)

                            Text {
                                Layout.fillWidth: true
                                // Message + hints đến từ notice_registry (cùng Notice với gate
                                // + runtime alert) → banner không bao giờ lệch với cái chặn khi Chạy.
                                text: "⚠️ " + String(readinessBanner.rd.message
                                    || (void i18n.revision, i18n.t(
                                        "accounts.not_ready_title",
                                        "Không có tài khoản nào SẴN SÀNG chạy — mọi job sẽ bị chặn.")))
                                color: VfTheme.amberText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: Font.Bold
                                wrapMode: Text.WordWrap
                            }

                            Repeater {
                                model: readinessBanner.rd.hints || []
                                Text {
                                    Layout.fillWidth: true
                                    text: "• " + String(modelData)
                                    color: VfTheme.amberText
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(36)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(10)
                            anchors.rightMargin: VfTheme.dp(10)
                            spacing: 0

                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_enabled", "ON")); cellWidth: 110; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_account", "Account")); cellWidth: 120 }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_email", "Email")); cellWidth: 200 }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_status", "Status")); cellWidth: 70; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_credits", "Credits")); cellWidth: 70; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_tier", "Tier")); cellWidth: 70; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_project", "Project")); cellWidth: 100; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_proxy", "Proxy")); cellWidth: 130 }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_checked", "Checked")); cellWidth: 80; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_profile", "Profile")); cellWidth: 50; align: Text.AlignHCenter }
                            HeaderCell { text: (void i18n.revision, i18n.t("settings.col_actions", "Actions")); cellWidth: 185; fillCell: true; align: Text.AlignHCenter }
                        }
                    }

                    ListView {
                        id: accountList

                        Layout.fillWidth: true
                        // Deterministic full height (count × row height) so every
                        // row renders; interactive:false hands scrolling to the
                        // outer ScrollView. Avoids the contentHeight chicken-egg.
                        Layout.preferredHeight: (accountSettingsController ? accountSettingsController.accounts.length : 0) * VfTheme.dp(44)
                        interactive: false
                        clip: true
                        reuseItems: true
                        model: accountSettingsController ? accountSettingsController.accounts : []

                        delegate: Rectangle {
                            width: accountList.width
                            height: VfTheme.dp(44)
                            color: screen.selectedAccountEmail === String(modelData.email || "") ? VfTheme.blueFill : (index % 2 === 0 ? VfTheme.surface : VfTheme.blueFill)
                            border.color: VfTheme.borderSoft

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: screen.selectedAccountEmail = String(modelData.email || "")
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(10)
                                anchors.rightMargin: VfTheme.dp(10)
                                spacing: 0

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(110)
                                    Layout.fillHeight: true

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: VfTheme.dp(2)

                                        Rectangle {
                                            Layout.preferredWidth: VfTheme.dp(88)
                                            Layout.preferredHeight: VfTheme.dp(28)
                                            radius: VfTheme.dp(4)
                                            color: modelData.enabled ? "#22C55E" : VfTheme.textSubtle

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.enabled ? "ON" : "OFF"
                                                color: "#FFFFFF"
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.fontSmall
                                                font.weight: VfTheme.weightTitle
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: screen.applySettingsActionResult(
                                                    accountSettingsController.toggleAccount(String(modelData.email || ""), !modelData.enabled),
                                                    (void i18n.revision, i18n.t("accounts.toggle_failed", "Could not update account state.")),
                                                    (void i18n.revision, i18n.t("accounts.toggle_done", "Account state updated."))
                                                )
                                            }
                                        }

                                        // Runtime pool badge: account đang thuộc active set
                                        // (được giao job) hay đang standby chờ lượt xoay.
                                        Rectangle {
                                            readonly property bool isRuntime: String(modelData.poolState || "") === "runtime"
                                            readonly property bool isStandby: String(modelData.poolState || "") === "standby"
                                            visible: isRuntime || isStandby
                                            Layout.preferredWidth: poolBadgeLbl.implicitWidth + VfTheme.dp(10)
                                            Layout.preferredHeight: VfTheme.dp(14)
                                            radius: VfTheme.dp(7)
                                            color: "transparent"
                                            border.color: isRuntime ? "#22C55E" : VfTheme.textSubtle

                                            Text {
                                                id: poolBadgeLbl
                                                anchors.centerIn: parent
                                                text: parent.isRuntime ? "RUNTIME" : "STANDBY"
                                                color: parent.isRuntime ? "#22C55E" : VfTheme.textMuted
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.fontTiny
                                                font.weight: VfTheme.weightTitle
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(120)
                                    Layout.fillHeight: true

                                    RowLayout {
                                        anchors.fill: parent
                                        spacing: VfTheme.dp(6)

                                        Rectangle {
                                            Layout.preferredWidth: VfTheme.dp(26)
                                            Layout.preferredHeight: VfTheme.dp(26)
                                            radius: width / 2
                                            clip: true
                                            color: VfTheme.surfaceSoft
                                            border.color: VfTheme.borderSoft

                                            Image {
                                                anchors.fill: parent
                                                fillMode: Image.PreserveAspectCrop
                                                source: String(modelData.avatarUrl || "")
                                                visible: String(modelData.avatarUrl || "").length > 0
                                                asynchronous: true
                                                cache: true
                                            }
                                            Text {
                                                anchors.centerIn: parent
                                                visible: String(modelData.avatarUrl || "").length === 0
                                                text: String((modelData.displayName || modelData.name || modelData.email || "?")).substring(0, 1).toUpperCase()
                                                color: VfTheme.textMuted
                                                font.family: VfTheme.fontFamily
                                                font.pixelSize: VfTheme.fontSmall
                                                font.weight: VfTheme.weightTitle
                                            }
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: String(modelData.displayName || modelData.name || "")
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontSmall
                                            font.weight: VfTheme.weightStrong
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }
                                }
                                BodyCell { text: String(modelData.email || ""); cellWidth: 200; muted: true }

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(70)
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width - 10
                                        text: String(modelData.status || "")
                                        color: screen.statusTone(modelData.status) === "green" ? "#22C55E"
                                             : (screen.statusTone(modelData.status) === "red" ? "#EF4444"
                                             : (screen.statusTone(modelData.status) === "amber" ? "#F59E0B" : VfTheme.text))
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }

                                BodyCell { text: String(modelData.credits || 0); cellWidth: 70; align: Text.AlignHCenter; strong: true }

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(70)
                                    Layout.fillHeight: true

                                    // Badge tier màu: phân biệt nhanh ULTRA/PRO/FREE để chống
                                    // bật nhầm tier lẫn nhau trong cùng phiên làm việc.
                                    Rectangle {
                                        anchors.centerIn: parent
                                        readonly property string tierText: String(modelData.tier || "-").toUpperCase()
                                        readonly property bool known: tierText === "ULTRA" || tierText === "PRO" || tierText === "FREE"
                                        width: tierLabel.implicitWidth + VfTheme.dp(14)
                                        height: VfTheme.dp(20)
                                        radius: VfTheme.dp(10)
                                        color: tierText === "ULTRA" ? "#F59E0B"
                                             : tierText === "PRO" ? "#3B82F6"
                                             : tierText === "FREE" ? VfTheme.textSubtle
                                             : "transparent"

                                        Text {
                                            id: tierLabel
                                            anchors.centerIn: parent
                                            text: parent.tierText
                                            color: parent.known ? "#FFFFFF" : VfTheme.textMuted
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.fontTiny
                                            font.weight: VfTheme.weightTitle
                                        }

                                        // Hover ra sku/serviceTier gốc: badge gộp G1_TIER1,
                                        // G1_TIER1P5, WS_PRO… về cùng "PRO" nên cần chỗ soi bản gốc.
                                        HoverHandler { id: tierHover }
                                        ToolTip.visible: tierHover.hovered && ToolTip.text.length > 0
                                        ToolTip.text: {
                                            var parts = []
                                            if (modelData.sku)
                                                parts.push(String(modelData.sku))
                                            if (modelData.serviceTier)
                                                parts.push(String(modelData.serviceTier))
                                            return parts.join(" · ")
                                        }
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(100)
                                    Layout.fillHeight: true

                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width - VfTheme.dp(8)
                                        text: modelData.projectId ? String(modelData.projectId).substring(0, 8) + "..." : "—"
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                        elide: Text.ElideRight
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        hoverEnabled: true
                                        onClicked: screen.openProjectChooserFor(modelData)

                                        ToolTip.visible: containsMouse && !!modelData.projectId
                                        ToolTip.text: modelData.projectId
                                            ? String(modelData.projectId)
                                            : (void i18n.revision, i18n.t("accounts.no_project", "No project selected"))
                                    }
                                }

                                Item {
                                    Layout.preferredWidth: VfTheme.dp(130)
                                    Layout.fillHeight: true

                                    VfButton {
                                        actionId: "assign_account_proxy"
                                        anchors.centerIn: parent
                                        text: modelData.proxy ? String(modelData.proxy) : (void i18n.revision, i18n.t("accounts.no_proxy", "No Proxy"))
                                        minWidth: VfTheme.dp(110)
                                        onClicked: screen.openAssignProxyFor(modelData)
                                    }
                                }

                                BodyCell { text: String(modelData.lastChecked || "Never"); cellWidth: 80; align: Text.AlignHCenter; muted: true }
                                BodyCell { text: String(modelData.profile || "") ? "OK" : "X"; cellWidth: 50; align: Text.AlignHCenter; muted: true }

                                RowLayout { // perf-lint: disable=R5 bounded desktop account table; five legacy actions fit the supported width
                                    Layout.preferredWidth: VfTheme.dp(255)
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: VfTheme.dp(6)

                                    VfButton {
                                        actionId: "open_account_browser"
                                        text: (void i18n.revision, i18n.t("common.open", "Open"))
                                        minWidth: VfTheme.dp(54)
                                        tone: "primary"
                                        onClicked: {
                                            var result = accountSettingsController.requestOpenBrowser(String(modelData.id || ""), String(modelData.email || ""))
                                            if (!result.ok) {
                                                screen.applySettingsActionResult(
                                                    result,
                                                    (void i18n.revision, i18n.t("accounts.open_failed", "Could not open browser.")),
                                                    (void i18n.revision, i18n.t("accounts.open_started", "Browser opened."))
                                                )
                                                return
                                            }
                                        }
                                    }

                                    VfButton {
                                        actionId: "edit_account"
                                        text: (void i18n.revision, i18n.t("common.edit", "Edit"))
                                        minWidth: VfTheme.dp(50)
                                        onClicked: accountEditDialog.openFor(modelData)
                                    }

                                    VfButton {
                                        actionId: "select_account_project"
                                        text: (void i18n.revision, i18n.t("accounts.project", "Project"))
                                        minWidth: VfTheme.dp(64)
                                        onClicked: screen.openProjectChooserFor(modelData)
                                    }

                                    VfButton {
                                        actionId: "refresh_account"
                                        text: (void i18n.revision, i18n.t("common.refresh", "Refresh"))
                                        minWidth: VfTheme.dp(78)
                                        onClicked: screen.applySettingsActionResult(
                                            accountSettingsController.requestRefreshCookies(String(modelData.id || ""), String(modelData.email || "")),
                                            (void i18n.revision, i18n.t("accounts.refresh_failed", "Could not refresh account status.")),
                                            (void i18n.revision, i18n.t("accounts.refresh_started", "Account status refreshed."))
                                        )
                                    }

                                    VfButton {
                                        actionId: "delete_account"
                                        text: (void i18n.revision, i18n.t("common.delete_short", "Delete"))
                                        minWidth: VfTheme.dp(58)
                                        tone: "danger"
                                        onClicked: accountDeleteDialog.openFor(modelData)
                                    }

                                    Item { Layout.fillWidth: true }
                                }
                            }
                        }
                    }

                    EmptyState {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(56)
                        visible: accountSettingsController.accounts.length === 0
                        text: (void i18n.revision, i18n.t("accounts.empty", "No accounts loaded."))
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: (accountSettingsController.accountCheck.running || String(accountSettingsController.accountCheck.message || "").length > 0) ? 82 : 58
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.borderSoft

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: VfTheme.dp(12)
                            spacing: VfTheme.dp(6)

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: VfTheme.dp(10)

                                VfButton {
                                    actionId: "add_account"
                                    text: (void i18n.revision, i18n.t("accounts.add_account", "Add Account"))
                                    tone: "primary"
                                    minWidth: VfTheme.dp(132)
                                    onClicked: {
                                        var result = accountSettingsController.requestAddAccount()
                                        if (!result.ok) {
                                            screen.applySettingsActionResult(
                                                result,
                                                (void i18n.revision, i18n.t("accounts.add_account_failed", "Could not start account add flow.")),
                                                (void i18n.revision, i18n.t("accounts.add_account_started", "Account add flow is ready."))
                                            )
                                            return
                                        }
                                    }
                                }

                                VfButton {
                                    actionId: "check_all_accounts"
                                    text: (void i18n.revision, i18n.t("accounts.check_all", "Check All"))
                                    minWidth: VfTheme.dp(116)
                                    enabled: !accountSettingsController.accountCheck.running
                                    onClicked: screen.runCheckAccounts()
                                }

                                VfButton {
                                    actionId: "reset_profiles"
                                    text: (void i18n.revision, i18n.t("accounts.reset_profiles", "Reset Profiles"))
                                    tone: "danger"
                                    minWidth: VfTheme.dp(134)
                                    onClicked: profileCleanupConfirmDialog.open()
                                }

                                VfButton {
                                    actionId: "clear_proxy_mappings"
                                    text: (void i18n.revision, i18n.t("accounts.clear_proxy", "Clear Proxy"))
                                    minWidth: VfTheme.dp(126)
                                    onClicked: screen.runClearAccountProxies()
                                }


                                Item { Layout.fillWidth: true }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: accountSettingsController.accountCheck.running
                                    ? String(accountSettingsController.accountCheck.message || "")
                                        + "  "
                                        + String(accountSettingsController.accountCheck.healthy || 0)
                                        + " healthy / "
                                        + String(accountSettingsController.accountCheck.failed || 0)
                                        + " failed"
                                    : String(accountSettingsController.accountCheck.message || "")
                                color: accountSettingsController.accountCheck.running ? VfTheme.primary : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            RuntimeResourceSuite {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                compact: screen.compact
                onRepairRequested: function(resourceId) {
                    screen.applySettingsActionResult(
                        accountSettingsController.repairResource(String(resourceId || "")),
                        (void i18n.revision, i18n.t("settings.resource_repair_failed", "Không cài / sửa được tài nguyên.")),
                        (void i18n.revision, i18n.t("settings.resource_repair_started", "Đang cài / sửa tài nguyên..."))
                    )
                }
            }

            // AI & API — full config lives in header Credits / Gateway dialog
            SectionFrame {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(38) + aiNoteCol.implicitHeight + VfTheme.dp(28)
                title: (void i18n.revision, i18n.t("settings.ai_providers_title", "AI & API Providers"))
                headerColor: "#6366F1"

                ColumnLayout {
                    id: aiNoteCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: VfTheme.dp(14)
                    spacing: VfTheme.dp(10)

                    Text {
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        text: (void i18n.revision, i18n.t("settings.ai_moved_to_header", "Cấu hình 3 nguồn AI (Studio / Server / Cá nhân) và nạp tiền (chỉ khi API Server) nằm ở dialog Credits trên header — bấm số dư/credits góc trên."))
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(12)
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        VfButton {
                            text: (void i18n.revision, i18n.t("settings.open_ai_billing", "Mở cấu hình AI & billing"))
                            tone: "primary"
                            minWidth: VfTheme.dp(200)
                            onClicked: {
                                if (typeof headerController !== "undefined" && headerController)
                                    headerController.openDialog("credits")
                            }
                        }
                        VfButton {
                            text: (void i18n.revision, i18n.t("billing.gemini_keys", "Gemini API keys"))
                            minWidth: VfTheme.dp(140)
                            onClicked: {
                                accountSettingsController.refreshApiKeys()
                                apiKeysDialog.open()
                            }
                        }
                        Item { Layout.fillWidth: true }
                    }
                }
            }


        }
    }

    Timer {
        id: browserLoginPollTimer

        interval: 1500
        repeat: true
        running: browserLoginDialog.visible && Boolean(accountSettingsController.browserLogin.active)
        // pollBrowserLogin only DETECTS login now; the heavy import runs off the GUI
        // thread and completion (dialog close + project chooser) is driven by
        // applyFinishedSettingsAction("account.browser_login_import").
        onTriggered: accountSettingsController.pollBrowserLogin()
    }

    Dialog {
        id: projectChooserDialog

        property string accountEmail: ""
        property var projects: []
        property bool busy: false
        property bool loading: false

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(520), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        function bindExisting(projectId) {
            if (projectChooserDialog.busy)
                return
            projectChooserDialog.busy = true
            // Async: result arrives via settingsActionFinished (account.use_project).
            accountSettingsController.useExistingProject(projectChooserDialog.accountEmail, String(projectId || ""))
        }

        function createNew() {
            if (projectChooserDialog.busy)
                return
            projectChooserDialog.busy = true
            // Async: result arrives via settingsActionFinished (account.create_project).
            accountSettingsController.createNewProject(projectChooserDialog.accountEmail)
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("accounts.choose_project", "Chọn project chính"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: projectChooserDialog.accountEmail + " — "
                    + (projectChooserDialog.projects.length > 0
                        ? (void i18n.revision, i18n.t("accounts.choose_project_hint", "Dùng lại project có sẵn (giữ media đã upload) hoặc tạo mới."))
                        : (void i18n.revision, i18n.t("accounts.no_project_hint", "Tài khoản chưa có project — tạo mới để bắt đầu.")))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: projectChooserDialog.loading
                text: (void i18n.revision, i18n.t("accounts.loading_projects", "Đang tải danh sách project..."))
                color: VfTheme.primary
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
            }

            ListView {
                id: projectListView
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(Math.min(280, 12 + projectChooserDialog.projects.length * 58))
                visible: projectChooserDialog.projects.length > 0
                clip: true
                reuseItems: true
                model: projectChooserDialog.projects
                spacing: VfTheme.dp(8)

                delegate: Rectangle {
                    width: ListView.view.width
                    height: VfTheme.dp(50)
                    radius: VfTheme.dp(6)
                    color: VfTheme.surfaceAlt !== undefined ? VfTheme.surfaceAlt : VfTheme.surface
                    border.color: VfTheme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: VfTheme.dp(12)
                        anchors.rightMargin: VfTheme.dp(10)
                        spacing: VfTheme.dp(10)

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(2)
                            Text {
                                Layout.fillWidth: true
                                text: String((modelData && modelData.title) || (modelData && modelData.project_id) || "")
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: String((modelData && modelData.project_id) || "").substring(0, 8)
                                    + "  ·  " + String((modelData && modelData.creation_time) || "").substring(0, 10)
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                elide: Text.ElideRight
                            }
                        }

                        VfButton {
                            text: (void i18n.revision, i18n.t("common.select", "Chọn"))
                            enabled: !projectChooserDialog.busy
                            onClicked: projectChooserDialog.bindExisting(modelData ? modelData.project_id : "")
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                VfButton {
                    text: (void i18n.revision, i18n.t("accounts.create_new_project", "Tạo project mới"))
                    enabled: !projectChooserDialog.busy
                    onClicked: projectChooserDialog.createNew()
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Đóng"))
                    enabled: !projectChooserDialog.busy
                    onClicked: projectChooserDialog.close()
                }
            }
        }
    }

    AddProxyDialog {
        id: addProxyDialog
        onAcceptedText: (text, rotateUrl) => addProxyDialog.applyAcceptResult(accountSettingsController.addProxies(text, rotateUrl))
    }

    Dialog {
        id: rotateUrlEditDialog
        property string proxyKey: ""
        property string currentUrl: ""

        parent: Overlay.overlay
        modal: true
        width: VfDialogMetrics.width(parent, VfTheme.dp(520), VfTheme.dp(48))
        height: VfDialogMetrics.height(parent, VfTheme.dp(180), VfTheme.dp(48))
        x: VfDialogMetrics.centerX(parent, width)
        y: VfDialogMetrics.centerY(parent, height)
        padding: 0
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.radiusPanel
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
            border.width: 1
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: VfTheme.dp(16)
            spacing: VfTheme.dp(12)

            Text {
                text: "Link xoay IP — " + rotateUrlEditDialog.proxyKey
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(14)
                font.weight: VfTheme.weightTitle
            }

            TextField {
                id: rotateUrlEditInput
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(36)
                placeholderText: "https://api.provider.com/change-ip/..."
                selectByMouse: true
                color: VfTheme.text
                placeholderTextColor: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                background: Rectangle {
                    color: VfTheme.surface
                    border.color: VfTheme.borderBox
                    border.width: 1
                    radius: VfTheme.radiusControl
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)
                Item { Layout.fillWidth: true }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.save", "Save"))
                    tone: "primary"
                    onClicked: {
                        accountSettingsController.setProxyRotateUrl(rotateUrlEditDialog.proxyKey, rotateUrlEditInput.text.trim())
                        rotateUrlEditDialog.close()
                    }
                }
                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: rotateUrlEditDialog.close()
                }
            }
        }
    }

    AssignProxyDialog {
        id: assignProxyDialog
        onAssignRequested: (email, proxyKey) => assignProxyDialog.applyAssignResult(accountSettingsController.assignProxy(email, proxyKey))
        onAddProxyRequested: {
            addProxyDialog.resetForm()
            addProxyDialog.open()
        }
    }

    ProxyCheckDialog {
        id: proxyCheckDialog
        check: accountSettingsController.proxyCheck
        onStartRequested: proxyCheckDialog.applyStartResult(accountSettingsController.checkProxies())
    }

    AccountEditDialog {
        id: accountEditDialog
        onSaveRequested: (accountId, originalEmail, name, email, status, credits, tier, accountType, cookieType, browserType, tag, totpSecret) => accountEditDialog.applySaveResult(accountSettingsController.updateAccount(accountId, originalEmail, name, email, status, credits, tier, accountType, cookieType, browserType, tag, totpSecret))
    }

    AccountDeleteDialog {
        id: accountDeleteDialog
        onDeleteRequested: (accountId, email) => accountDeleteDialog.applyDeleteResult(accountSettingsController.deleteAccount(accountId, email))
    }

    ApiKeyDialog {
        id: apiKeyDialog
        onSaveRequested: (provider, apiKey, label) => apiKeyDialog.applySaveResult(accountSettingsController.addApiKey(provider, apiKey, label))
    }

    ApiKeysDialog {
        id: apiKeysDialog
        keys: accountSettingsController.apiKeys
        apiMode: accountSettingsController.apiMode
        onRefreshRequested: accountSettingsController.refreshApiKeys()
        onAddRequested: (provider, label, key) => apiKeysDialog.applyAddResult(accountSettingsController.addApiKey(provider, key, label))
        onDeleteRequested: keyId => apiKeysDialog.applyDeleteResult(accountSettingsController.removeApiKey(Number(keyId || 0)))
        onModeRequested: mode => apiKeysDialog.applyModeResult(accountSettingsController.setApiMode(mode))
    }

    Component.onCompleted: {
        Qt.callLater(accountSettingsController.refresh)
        Qt.callLater(screen.refreshAccountMode)
        if (accountSettingsController.browserLogin && accountSettingsController.browserLogin.active)
            Qt.callLater(browserLoginDialog.open)
    }

    Connections {
        target: accountSettingsController

        function onOpenPathRequested(path) {
            nativeShell.openPath(path)
        }

        function onAccountModeChanged() {
            screen.refreshAccountMode()
        }

        function onAccountsChanged() {
            screen.refreshAccountMode()
        }

        function onBrowserLoginChanged() {
            if (accountSettingsController.browserLogin && accountSettingsController.browserLogin.active)
                browserLoginDialog.open()
        }

        function onProxiesChanged() {
            var proxies = accountSettingsController.proxies || []
            for (var i = 0; i < proxies.length; i += 1) {
                if (String(proxies[i].key || "") === screen.selectedProxyKey)
                    return
            }
            screen.selectedProxyKey = ""
        }

        function onSettingsActionFinished(action, result) {
            screen.applyFinishedSettingsAction(action, result)
        }
    }

    Dialog {
        id: browserLoginDialog

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(460), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton
        closePolicy: Popup.NoAutoClose

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: accountSettingsController.browserLogin.mode === "add_account"
                    ? (void i18n.revision, i18n.t("accounts.add_account", "Add Account"))
                    : (void i18n.revision, i18n.t("accounts.relogin_now", "Đăng nhập lại"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: String(accountSettingsController.browserLogin.message || "")
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                visible: String(accountSettingsController.browserLogin.accountEmail || "").length > 0
                text: String(accountSettingsController.browserLogin.accountEmail || "")
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
                wrapMode: Text.WordWrap
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(6)
                radius: VfTheme.dp(3)
                color: VfTheme.border

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: accountSettingsController.browserLogin.active ? parent.width * 0.55 : parent.width
                    radius: VfTheme.dp(3)
                    color: accountSettingsController.browserLogin.active ? "#2563EB" : "#10B981"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.close", "Close"))
                    enabled: !accountSettingsController.browserLogin.active
                    onClicked: browserLoginDialog.close()
                }
            }
        }
    }

    Dialog {
        id: profileCleanupConfirmDialog

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(440), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("accounts.reset_profiles_title", "Reset Browser Profiles"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("accounts.reset_profiles_warning", "This will delete all browser profiles.\n\nYou will need to login again for all accounts.\n\nContinue?"))
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: profileCleanupConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                    tone: "danger"
                    minWidth: VfTheme.dp(104)
                    onClicked: {
                        profileCleanupConfirmDialog.close()
                        screen.applySettingsActionResult(
                            accountSettingsController.runBrowserProfileCleanup(),
                            (void i18n.revision, i18n.t("accounts.reset_profiles_failed", "Could not clean browser profiles.")),
                            (void i18n.revision, i18n.t("accounts.reset_complete_msg", "Deleted browser profiles. Please login again."))
                        )
                    }
                }
            }
        }
    }

    Dialog {
        id: proxyDeleteConfirmDialog

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("common.confirm", "Confirm"))
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: (void i18n.revision, i18n.t("settings.confirm_delete_proxy", "Delete proxy {proxy}?"))
                    .replace("{proxy}", screen.pendingProxyDeleteKey)
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontControl
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    onClicked: proxyDeleteConfirmDialog.close()
                }

                VfButton {
                    text: (void i18n.revision, i18n.t("common.delete_short", "Delete"))
                    tone: "danger"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        proxyDeleteConfirmDialog.close()
                        screen.applyProxyDeleteResult(accountSettingsController.removeProxy(screen.pendingProxyDeleteKey))
                    }
                }
            }
        }
    }

    Dialog {
        id: proxyFeedbackDialog

        parent: Overlay.overlay
        modal: true
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(420), VfTheme.dp(48))
        padding: VfTheme.dp(20)
        title: ""
        standardButtons: Dialog.NoButton

        background: Rectangle {
            radius: VfTheme.dp(8)
            color: VfTheme.surface
            border.color: VfTheme.borderBox
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(14)

            Text {
                Layout.fillWidth: true
                text: screen.proxyFeedbackTitle
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(18)
                font.weight: VfTheme.weightTitle
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: screen.proxyFeedbackMessage
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
                    onClicked: proxyFeedbackDialog.close()
                }
            }
        }
    }

    component SectionFrame: Rectangle {
        id: section

        property string title: ""
        property string countText: ""
        property color headerColor: VfTheme.primary
        property bool showHeaderCheck: false
        property string headerCheckText: ""
        default property alias content: body.data
        signal headerCheckClicked()

        radius: VfTheme.radiusControl
        color: VfTheme.surface
        border.color: VfTheme.borderBox
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(38)
                color: section.headerColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(14)
                    anchors.rightMargin: VfTheme.dp(14)
                    spacing: VfTheme.dp(8)

                    Text {
                        Layout.fillWidth: true
                        text: screen.cleanText(section.title)
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.dp(14)
                        font.weight: VfTheme.weightTitle
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: section.countText.length > 0
                        text: section.countText
                        color: "#FFFFFF"
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        horizontalAlignment: Text.AlignRight
                    }

                    Rectangle {
                        Layout.preferredWidth: visible ? Math.max(62, headerCheckLabel.implicitWidth + 20) : 0
                        Layout.preferredHeight: VfTheme.dp(24)
                        visible: section.showHeaderCheck
                        radius: VfTheme.dp(4)
                        color: VfTheme.surface

                        Text {
                            id: headerCheckLabel

                            anchors.centerIn: parent
                            text: section.headerCheckText.length > 0 ? section.headerCheckText : (void i18n.revision, i18n.t("common.check", "Check"))
                            color: section.headerColor
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            font.weight: VfTheme.weightStrong
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: section.headerCheckClicked()
                        }
                    }
                }
            }

            Item {
                id: body

                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    component HeaderCell: Text {
        property int cellWidth: 100
        property bool fillCell: false
        property int align: Text.AlignLeft

        Layout.preferredWidth: VfTheme.dp(cellWidth)
        Layout.fillWidth: fillCell
        color: VfTheme.textMuted
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontTiny
        font.weight: VfTheme.weightStrong
        horizontalAlignment: align
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component BodyCell: Text {
        property int cellWidth: 100
        property bool fillCell: false
        property bool strong: false
        property bool muted: false
        property int align: Text.AlignLeft

        Layout.preferredWidth: VfTheme.dp(cellWidth)
        Layout.fillWidth: fillCell
        color: muted ? VfTheme.textMuted : VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        font.weight: strong ? VfTheme.weightStrong : VfTheme.weightRegular
        horizontalAlignment: align
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component EmptyState: Text {
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontSmall
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    component FieldBox: Rectangle {
        property string text: ""

        implicitHeight: VfTheme.dp(36)
        radius: VfTheme.radiusControl
        color: VfTheme.surfaceSoft
        border.color: VfTheme.borderBox

        Text {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(12)
            anchors.rightMargin: VfTheme.dp(12)
            text: parent.text
            color: VfTheme.text
            font.family: VfTheme.fontFamily
            font.pixelSize: VfTheme.fontSmall
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideMiddle
        }
    }

    component HintText: Text {
        color: VfTheme.textSubtle
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.fontTiny
        wrapMode: Text.WordWrap
    }
}
