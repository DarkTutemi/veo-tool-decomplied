import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var rows: []
    property var historyRows: []
    property var accounts: []
    property string statusFilter: "All"
    property string featureFilter: "All"
    property string searchText: ""
    property bool accountsExpanded: false
    property bool dispatcherRunning: false
    property string actionStatusText: ""
    property bool actionStatusOk: true

    signal refreshRequested()
    signal stopRequested()
    signal startRequested()
    signal cancelAllRequested()
    signal cancelJobRequested(string jobId)
    signal regenJobRequested(string jobId)
    signal copyPromptRequested(string prompt)
    signal copyJobIdRequested(string jobId)

    header: VfDialogHeader {
        title: "Job Monitor"
        iconName: "clockwise-arrows"
        onCloseClicked: root.close()
    }
    parent: Overlay.overlay

    function applyActionResult(result) {
        var payload = result && typeof result === "object" ? result : ({})
        root.actionStatusOk = payload.ok !== false
        root.actionStatusText = String(payload.message || payload.error || "")
    }

    modal: false
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1180), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(740), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    onOpened: {
        root.actionStatusText = ""
        root.refreshRequested()
    }

    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        onTriggered: root.refreshRequested()
    }

    function activeStatuses() {
        return ["pending", "queued", "generating", "polling", "processing", "upscaling", "retrying"]
    }

    function featureOptions() {
        var seen = {"All": true}
        var values = ["All"]
        var source = root.rows || []
        for (var i = 0; i < source.length; i++) {
            var feature = String(source[i].feature || "")
            if (feature.length > 0 && !seen[feature]) {
                seen[feature] = true
                values.push(feature)
            }
        }
        return values
    }

    function statusOptions() {
        return ["All", "Active", "pending", "queued", "generating", "polling", "processing", "upscaling", "retrying", "complete", "failed", "cancelled"]
    }

    function statusIcon(status) {
        switch (String(status || "").toLowerCase()) {
        case "pending":
            return "\u2026"
        case "queued":
            return "\u25A4"
        case "running":
        case "generating":
            return "\u25CF"
        case "polling":
            return "\u25CC"
        case "processing":
            return "\u2699"
        case "upscaling":
            return "\u25B2"
        case "merging":
            return "\u25C6"
        case "retrying":
            return "\u21BB"
        case "complete":
            return "\u2713"
        case "failed":
            return "\u2715"
        case "cancelled":
            return "\u2298"
        default:
            return "?"
        }
    }

    function statusColor(status) {
        switch (String(status || "").toLowerCase()) {
        case "pending":
            return VfTheme.textSubtle
        case "queued":
            return "#f59e0b"
        case "running":
        case "generating":
            return "#10b981"
        case "polling":
            return "#06b6d4"
        case "processing":
            return "#3b82f6"
        case "upscaling":
            return "#8b5cf6"
        case "merging":
            return "#06b6d4"
        case "retrying":
            return "#f97316"
        case "complete":
            return "#10b981"
        case "failed":
            return "#ef4444"
        case "cancelled":
            return VfTheme.textSubtle
        default:
            return VfTheme.textSubtle
        }
    }

    function displayFeature(raw) {
        switch (String(raw || "")) {
        case "text_video":
            return "Text -> Video"
        case "portrait_video":
            return "Portrait"
        case "image_video":
            return "Image -> Video"
        case "extend_video":
            return "Extend"
        case "upscale":
            return "Upscale"
        case "clone_video":
            return "Clone"
        case "master_prompt":
            return "Master"
        case "transcript_video":
            return "Audio"
        default:
            return String(raw || "")
        }
    }

    function maskAccount(value) {
        var acc = String(value || "")
        if (acc.indexOf("_slot_") >= 0)
            acc = acc.split("_slot_")[0]
        if (acc.indexOf("@") >= 0) {
            var parts = acc.split("@")
            acc = parts[0].slice(0, 3) + "***@" + parts[1]
        }
        return acc
    }

    function filteredRows() {
        var result = []
        var query = String(root.searchText || "").toLowerCase()
        var statusFilter = String(root.statusFilter || "All")
        var featureFilter = String(root.featureFilter || "All")
        var rows = root.rows || []
        var active = activeStatuses()
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i]
            var status = String(row.status || "").toLowerCase()
            var feature = String(row.feature || "")
            var prompt = String(row.prompt || "").toLowerCase()
            if (statusFilter === "Active" && active.indexOf(status) < 0)
                continue
            if (statusFilter !== "All" && statusFilter !== "Active" && status !== statusFilter.toLowerCase())
                continue
            if (featureFilter !== "All" && feature !== featureFilter)
                continue
            if (query.length > 0 && prompt.indexOf(query) < 0)
                continue
            result.push(row)
        }
        return result
    }

    function summaryText() {
        var rows = root.rows || []
        var accounts = root.accounts || []
        var total = rows.length
        var generating = 0
        var processing = 0
        var queued = 0
        var retrying = 0
        var failed = 0
        var complete = 0

        for (var i = 0; i < rows.length; i++) {
            var status = String(rows[i].status || "").toLowerCase()
            if (status === "generating" || status === "running")
                generating += 1
            else if (status === "processing")
                processing += 1
            else if (status === "queued")
                queued += 1
            else if (status === "retrying")
                retrying += 1
            else if (status === "failed")
                failed += 1
            else if (status === "complete")
                complete += 1
        }

        var online = 0
        var dead = 0
        var cooldown = 0
        for (var j = 0; j < accounts.length; j++) {
            var acc = accounts[j] || {}
            if (acc.is_dead)
                dead += 1
            else
                online += 1
            if (acc.rate_limited || acc.cooldown_403)
                cooldown += 1
        }

        var parts = [
            "Total: " + total,
            "\u25CF Gen: " + generating,
            "\u2699 Proc: " + processing,
            "\u25A4 Queue: " + queued,
            "\u21BB Retry: " + retrying,
            "\u2715 Fail: " + failed,
            "\u2713 Done: " + complete,
            "Accounts: " + online + " online / " + dead + " dead"
        ]
        if (cooldown > 0)
            parts.push(cooldown + " cooldown")
        return parts.join("  |  ")
    }

    function historyTotalLabel() {
        var source = root.historyRows || []
        var total = 0
        for (var i = 0; i < source.length; i++)
            total += Number(source[i].elapsed_seconds || 0)
        var hours = Math.floor(total / 3600)
        var minutes = Math.floor((total % 3600) / 60)
        var seconds = Math.floor(total % 60)
        if (hours > 0)
            return String(hours) + "h " + String(minutes) + "m"
        if (minutes > 0)
            return String(minutes) + "m " + String(seconds) + "s"
        if (seconds > 0)
            return String(seconds) + "s"
        return "-"
    }

    function accountStateLabel(acc) {
        if (acc.is_dead)
            return "Dead"
        if (acc.rate_limited || acc.cooldown_403)
            return "Cooldown"
        return "Online"
    }

    function accountStateColor(acc) {
        if (acc.is_dead)
            return "#ef4444"
        if (acc.rate_limited || acc.cooldown_403)
            return "#f59e0b"
        return "#10b981"
    }

    function accountRateLimitLabel(acc) {
        var value = Number(acc.rate_limited_remaining || 0)
        return value > 0 ? String(Math.floor(value)) + "s" : "-"
    }

    function accountCooldownLabel(acc) {
        var value = Number(acc.cooldown_403_remaining || 0)
        return value > 0 ? String(Math.floor(value)) + "s" : "-"
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: VfTheme.dp(16)
        spacing: VfTheme.dp(10)

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(44)
                radius: VfTheme.radiusPanel
                color: VfTheme.surfaceSoft
                border.color: VfTheme.borderBox

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(10)
                    anchors.rightMargin: VfTheme.dp(10)
                    spacing: VfTheme.dp(8)

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "Status:"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightControl
                    }

                    NoScrollComboBox {
                        Layout.preferredWidth: VfTheme.dp(120)
                        Layout.preferredHeight: VfTheme.controlHeight
                        model: root.statusOptions()
                        currentIndex: Math.max(0, root.statusOptions().indexOf(root.statusFilter))
                        onCurrentTextChanged: if (currentText.length > 0) root.statusFilter = currentText
                    }

                    Text {
                        Layout.alignment: Qt.AlignVCenter
                        text: "Feature:"
                        color: VfTheme.text
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        font.weight: VfTheme.weightControl
                    }

                    NoScrollComboBox {
                        Layout.preferredWidth: VfTheme.dp(140)
                        Layout.preferredHeight: VfTheme.controlHeight
                        model: root.featureOptions()
                        currentIndex: Math.max(0, root.featureOptions().indexOf(root.featureFilter))
                        onCurrentTextChanged: if (currentText.length > 0) root.featureFilter = currentText
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.controlHeight
                        placeholderText: "Search prompt..."
                        text: root.searchText
                        leftPadding: VfTheme.dp(12)
                        rightPadding: VfTheme.dp(12)
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontControl
                        onTextChanged: root.searchText = text
                        background: Rectangle {
                            radius: VfTheme.radiusControl
                            color: VfTheme.surface
                            border.width: 1
                            border.color: searchField.activeFocus ? VfTheme.primary : VfTheme.borderBox
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.summaryText()
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: VfTheme.dp(200)
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(24)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: VfTheme.dp(8)

                            Text { Layout.preferredWidth: VfTheme.dp(34); text: "#"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(100); text: "Status"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(140); text: "Feature"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.fillWidth: true; text: "Prompt"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(120); text: "Account"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(64); text: "Retry"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: VfTheme.dp(88); text: "Time"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: VfTheme.dp(96); text: "ID"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                        }
                    }

                    ListView {
                        id: jobList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        reuseItems: true
                        model: root.filteredRows()

                        delegate: Rectangle {
                            width: jobList.width
                            height: VfTheme.dp(28)
                            color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                Text { Layout.preferredWidth: VfTheme.dp(34); text: String(index + 1); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(100)
                                    text: root.statusIcon(modelData.status) + " " + String(modelData.status || "")
                                    color: root.statusColor(modelData.status)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightStrong
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(140)
                                    text: root.displayFeature(modelData.feature)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: String(modelData.prompt || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(120)
                                    text: root.maskAccount(modelData.account || modelData.locked_account || "")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(64)
                                    text: String(modelData.retry_count || 0) + "/" + String(modelData.max_retries || 3)
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(88)
                                    text: String(modelData.elapsed_label || "-")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(96)
                                    text: String(modelData.id || "").slice(0, 8)
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    horizontalAlignment: Text.AlignRight
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onPressed: function(mouse) {
                                    if (mouse.button === Qt.RightButton) {
                                        rowMenu.x = Math.min(mouse.x, Math.max(0, parent.width - rowMenu.width - 8))
                                        rowMenu.y = Math.min(mouse.y, Math.max(0, parent.height - rowMenu.height - 8))
                                        rowMenu.open()
                                    }
                                }
                            }

                            Popup {
                                id: rowMenu
                                width: VfTheme.dp(168)
                                modal: false
                                focus: true
                                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

                                background: Rectangle {
                                    radius: VfTheme.dp(10)
                                    color: VfTheme.surface
                                    border.color: VfTheme.border
                                }

                                contentItem: Column {
                                    spacing: 0

                                    Rectangle {
                                        width: parent ? parent.width : 168
                                        height: VfTheme.dp(34)
                                        color: "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: VfTheme.dp(12)
                                            text: "Cancel Job"
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(12)
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                rowMenu.close()
                                                root.cancelJobRequested(String(modelData.id || ""))
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent ? parent.width : 168
                                        height: VfTheme.dp(34)
                                        color: "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: VfTheme.dp(12)
                                            text: "Regen Job"
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(12)
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                rowMenu.close()
                                                root.regenJobRequested(String(modelData.id || ""))
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent ? parent.width : 168
                                        height: 1
                                        color: VfTheme.border
                                    }

                                    Rectangle {
                                        width: parent ? parent.width : 168
                                        height: VfTheme.dp(34)
                                        color: "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: VfTheme.dp(12)
                                            text: "Copy Prompt"
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(12)
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                rowMenu.close()
                                                root.copyPromptRequested(String(modelData.prompt || ""))
                                            }
                                        }
                                    }

                                    Rectangle {
                                        width: parent ? parent.width : 168
                                        height: VfTheme.dp(34)
                                        color: "transparent"

                                        Text {
                                            anchors.verticalCenter: parent.verticalCenter
                                            anchors.left: parent.left
                                            anchors.leftMargin: VfTheme.dp(12)
                                            text: "Copy Job ID"
                                            color: VfTheme.text
                                            font.family: VfTheme.fontFamily
                                            font.pixelSize: VfTheme.dp(12)
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                rowMenu.close()
                                                root.copyJobIdRequested(String(modelData.id || ""))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(200)
                Layout.maximumHeight: VfTheme.dp(240)
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(28)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: VfTheme.dp(8)

                            Text {
                                text: (void i18n.revision, i18n.t("job_monitor.history_title", "Lịch sử job"))
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                            }

                            Text {
                                Layout.fillWidth: true
                                text: (void i18n.revision, i18n.t("job_monitor.history_total", "Tổng: {time}")).replace("{time}", root.historyTotalLabel())
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                                elide: Text.ElideRight
                            }

                            Text {
                                text: String((root.historyRows || []).length)
                                color: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontTiny
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(24)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: VfTheme.dp(8)

                            Text { Layout.preferredWidth: VfTheme.dp(34); text: "#"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(100); text: "Status"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(140); text: "Feature"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.fillWidth: true; text: (void i18n.revision, i18n.t("job_monitor.col_job", "Job")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: VfTheme.dp(72); text: (void i18n.revision, i18n.t("job_monitor.col_when", "Lúc")); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: VfTheme.dp(88); text: "Time"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ListView {
                            id: historyList
                            anchors.fill: parent
                            clip: true
                            reuseItems: true
                            model: root.historyRows || []  // perf-lint: disable=R2  snapshot from existing 2s refresh, not a poll of its own

                            delegate: Rectangle {
                                width: historyList.width
                                height: VfTheme.dp(28)
                                color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft

                                RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                Text { Layout.preferredWidth: VfTheme.dp(34); text: String(index + 1); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(100)
                                    text: root.statusIcon(modelData.status) + " " + String(modelData.status || "")
                                    color: root.statusColor(modelData.status)
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: VfTheme.weightStrong
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(140)
                                    text: root.displayFeature(modelData.feature)
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: String(modelData.name || modelData.prompt || "")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(72)
                                    text: String(modelData.created_at_label || "")
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    Layout.preferredWidth: VfTheme.dp(88)
                                    text: String(modelData.elapsed_label || "-")
                                    color: VfTheme.text
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontTiny
                                    font.weight: VfTheme.weightStrong
                                    horizontalAlignment: Text.AlignRight
                                }
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: historyList.count <= 0
                            text: (void i18n.revision, i18n.t("job_monitor.history_empty", "Chưa có job hoàn thành"))
                            color: VfTheme.textSubtle
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.accountsExpanded ? 176 : 22
                radius: VfTheme.dp(4)
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: VfTheme.dp(22)
                    onClicked: root.accountsExpanded = !root.accountsExpanded
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: VfTheme.dp(6)
                    anchors.top: parent.top
                    anchors.topMargin: VfTheme.dp(3)
                    text: root.accountsExpanded ? "\u25BE Accounts" : "\u25B8 Accounts"
                    color: VfTheme.primary
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    font.weight: VfTheme.weightStrong
                }

                Item {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: VfTheme.dp(22)
                    anchors.bottom: parent.bottom
                    visible: root.accountsExpanded
                    clip: true

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: VfTheme.dp(24)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.border

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                Text { Layout.fillWidth: true; text: "Account"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: VfTheme.dp(80); text: "Status"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                                Text { Layout.preferredWidth: VfTheme.dp(70); text: "Slots"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: VfTheme.dp(70); text: "Credits"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: VfTheme.dp(90); text: "Rate Limit"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: VfTheme.dp(80); text: "403 CD"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: VfTheme.dp(60); text: "Queue"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            }
                        }

                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            reuseItems: true
                            model: root.accounts || []  // perf-lint: disable=R2  static/single-populate config list — one-time rebuild, no continuous cost

                            delegate: Rectangle {
                                width: parent ? parent.width : 600
                                height: VfTheme.dp(26)
                                color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: VfTheme.dp(8)

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.maskAccount(modelData.account_id || "")
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontSmall
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(80)
                                        text: root.accountStateLabel(modelData)
                                        color: root.accountStateColor(modelData)
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(70)
                                        text: String(modelData.busy_slots || 0) + " busy"
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(70)
                                        text: String(modelData.credits || 0)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(90)
                                        text: root.accountRateLimitLabel(modelData)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(80)
                                        text: root.accountCooldownLabel(modelData)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(60)
                                        text: String(modelData.locked_queue_size || 0)
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                Text {
                    Layout.fillWidth: true
                    visible: root.actionStatusText.length > 0
                    text: root.actionStatusText
                    color: root.actionStatusOk ? "#059669" : VfTheme.redText
                    font.family: VfTheme.fontFamily
                    font.pixelSize: VfTheme.fontSmall
                    wrapMode: Text.WordWrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfButton {
                    text: "Stop"
                    actionId: "job_monitor.stop"
                    tone: "danger"
                    Layout.preferredWidth: VfTheme.dp(96)
                    minWidth: VfTheme.dp(96)
                    onClicked: root.stopRequested()
                }

                VfButton {
                    text: "Start"
                    actionId: "job_monitor.start"
                    tone: "success"
                    Layout.preferredWidth: VfTheme.dp(96)
                    minWidth: VfTheme.dp(96)
                    onClicked: root.startRequested()
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    text: "Refresh"
                    actionId: "job_monitor.refresh"
                    tone: "primary"
                    Layout.preferredWidth: VfTheme.dp(108)
                    minWidth: VfTheme.dp(108)
                    onClicked: root.refreshRequested()
                }

                VfButton {
                    text: "Cancel All Active"
                    actionId: "job_monitor.cancel_all"
                    tone: "danger"
                    Layout.preferredWidth: VfTheme.dp(154)
                    minWidth: VfTheme.dp(154)
                    onClicked: cancelAllConfirmDialog.open()
                }

                VfButton {
                    text: "Close"
                    actionId: "job_monitor.close"
                    Layout.preferredWidth: VfTheme.dp(82)
                    minWidth: VfTheme.dp(82)
                    onClicked: root.close()
                }
            }
    }

    Dialog {
        id: cancelAllConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: ""
        header: null
        closePolicy: Popup.CloseOnEscape

        background: Rectangle {
            radius: VfTheme.dp(12)
            color: VfTheme.surface
            border.color: VfTheme.borderStrong
        }

        contentItem: ColumnLayout {
            spacing: VfTheme.dp(12)

            Text {
                Layout.fillWidth: true
                text: "Cancel All"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Cancel all active jobs?"
                color: VfTheme.textMuted
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: VfTheme.dp(10)

                Item { Layout.fillWidth: true }

                VfButton {
                    id: cancelCancelAllButton
                    actionId: "dialog.close"
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: cancelAllConfirmDialog.close()
                }

                VfButton {
                    id: confirmCancelAllButton
                    actionId: "job_monitor.cancel_all"
                    tone: "danger"
                    text: "Cancel All"
                    minWidth: VfTheme.dp(116)
                    onClicked: {
                        root.cancelAllRequested()
                        cancelAllConfirmDialog.close()
                    }
                }
            }
        }
    }
}
