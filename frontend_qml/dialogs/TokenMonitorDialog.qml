import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Dialog {
    id: root

    property var summary: ({})
    property var entries: []
    property var models: []
    property int monitorDays: 1
    property string monitorModel: ""
    property bool modelExpanded: false
    property string actionMessage: ""
    property bool actionError: false
    readonly property real historyIndexColumnWidth: VfTheme.dp(32)
    readonly property real historyTimeColumnWidth: VfTheme.dp(88)
    readonly property real historyModelColumnWidth: VfTheme.dp(300)
    readonly property real historyFeatureColumnWidth: VfTheme.dp(170)
    readonly property real historyMetricColumnWidth: VfTheme.dp(76)
    readonly property real historyCostColumnWidth: VfTheme.dp(112)
    readonly property real historyFormulaColumnWidth: VfTheme.dp(190)

    modal: false
    parent: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    width: VfDialogMetrics.width(parent, VfTheme.dp(1120), VfTheme.dp(48))
    height: VfDialogMetrics.height(parent, VfTheme.dp(720), VfTheme.dp(48))
    x: VfDialogMetrics.centerX(parent, width)
    y: VfDialogMetrics.centerY(parent, height)
    padding: 0

    signal refreshRequested()
    signal clearRequested()
    signal exportRequested()
    signal daysRequested(int days)
    signal modelRequested(string model)

    title: "Token Monitor"
    header: Label {
        text: root.title
        visible: text.length > 0
        color: VfTheme.text
        font.family: VfTheme.fontFamily
        font.pixelSize: VfTheme.dp(16)
        font.weight: Font.DemiBold
        leftPadding: VfTheme.dp(16)
        rightPadding: VfTheme.dp(16)
        topPadding: VfTheme.dp(14)
        bottomPadding: VfTheme.dp(4)
    }

    onOpened: {
        root.actionMessage = ""
        root.actionError = false
        root.refreshRequested()
    }

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        onTriggered: root.refreshRequested()
    }

    function fmt(value, digits) {
        var numberValue = Number(value || 0)
        if (digits !== undefined)
            return numberValue.toFixed(digits)
        if (numberValue >= 1000000)
            return (numberValue / 1000000).toFixed(1) + "M"
        if (numberValue >= 1000)
            return (numberValue / 1000).toFixed(1) + "K"
        return String(Math.round(numberValue))
    }

    function currency() {
        return String(root.summary.currency || "VND").toUpperCase()
    }

    function moneyText(value) {
        var numberValue = Number(value || 0)
        // VND has no sub-unit → integer; USD keeps 2 decimals.
        var decimals = root.currency() === "USD" ? 2 : 0
        return numberValue.toLocaleString(Qt.locale(), "f", decimals) + " " + root.currency()
    }

    function displayModel(raw) {
        var value = String(raw || "")
        if (!value)
            return "—"
        var map = {
            "deep-research-pro-preview-12-2025": "GEMINI — DEEP RESEARCH",
            "gemini-3.1-flash-tts-preview": "GEMINI — TTS 3.1",
            "gemini-2.5-flash-preview-tts": "GEMINI — TTS",
            "gemini-2.5-pro-preview-tts": "GEMINI — TTS PRO",
            "gemini-2.5-flash": "GEMINI — FLASH",
            "gemini-2.5-pro": "GEMINI — PRO",
            "gemini-2.0-flash-exp": "GEMINI — FLASH 2.0",
            "gemini-2.0-flash": "GEMINI — FLASH 2.0"
        }
        if (map[value])
            return map[value]
        var name = value.replace(/-/g, " ").replace(/_/g, " ").toUpperCase()
        return value.toLowerCase().indexOf("gemini") >= 0 ? "GEMINI — " + name : name
    }

    function modelRows() {
        var byModel = root.summary.by_model || {}
        var rows = []
        for (var key in byModel) {
            var item = byModel[key] || {}
            rows.push({
                model: key,
                display: item.display || key,
                count: item.count || 0,
                input: item.input || 0,
                output: item.output || 0,
                cost: item.cost || 0
            })
        }
        rows.sort(function(a, b) { return Number(b.cost || 0) - Number(a.cost || 0) })
        return rows
    }

    function countRows() {
        return String(root.entries ? root.entries.length : 0) + " rows"
    }

    function countModels() {
        return String(root.modelRows().length) + " models"
    }

    function periodModel() {
        return [
            { label: "Today", days: 1 },
            { label: "3 Days", days: 3 },
            { label: "7 Days", days: 7 }
        ]
    }

    function currentPeriodIndex() {
        var value = Number(root.monitorDays || 1)
        var options = root.periodModel()
        for (var index = 0; index < options.length; ++index) {
            if (Number(options[index].days || 0) === value)
                return index
        }
        return 0
    }

    function modelFilterOptions() {
        var options = [{ label: "All", value: "" }]
        var rows = root.models || []
        for (var index = 0; index < rows.length; ++index) {
            var item = rows[index] || {}
            options.push({
                label: String(item.display || item.model || ""),
                value: String(item.model || "")
            })
        }
        return options
    }

    function currentModelIndex() {
        var value = String(root.monitorModel || "")
        var options = root.modelFilterOptions()
        for (var index = 0; index < options.length; ++index) {
            if (String(options[index].value || "") === value)
                return index
        }
        return 0
    }

    function applyActionResult(result) {
        var response = result || ({})
        root.actionMessage = String(response.message || response.error || "")
        root.actionError = !Boolean(response.ok)
    }

    background: Rectangle {
        radius: VfTheme.dp(10)
        color: VfTheme.surface
        border.color: VfTheme.borderStrong
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 14
            Layout.topMargin: 14
            spacing: VfTheme.dp(10)

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(10)

                VfMetricCard {
                    label: "Cost"
                    value: root.moneyText(root.summary.total_cost)
                    accent: VfTheme.amber
                }

                VfMetricCard {
                    label: "Requests"
                    value: root.fmt(root.summary.requests)
                    accent: VfTheme.primary
                }

                VfMetricCard {
                    label: "Input Tokens"
                    value: root.fmt(root.summary.total_input_tokens)
                    accent: VfTheme.cyan
                }

                VfMetricCard {
                    label: "Output Tokens"
                    value: root.fmt(root.summary.total_output_tokens)
                    accent: VfTheme.violet
                }

                VfMetricCard {
                    label: "Top Model"
                    value: String(root.summary.top_model_display || displayModel(root.summary.top_model || ""))
                    accent: VfTheme.greenBorder
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: VfTheme.dp(28)
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: VfTheme.dp(8)
                    anchors.rightMargin: VfTheme.dp(8)
                    anchors.bottomMargin: VfTheme.dp(8)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(30)
                        spacing: VfTheme.dp(8)

                        Text {
                            text: "Period:"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                        }

                        NoScrollComboBox {
                            id: periodCombo
                            Layout.preferredWidth: VfTheme.dp(104)
                            model: root.periodModel()
                            textRole: "label"
                            currentIndex: root.currentPeriodIndex()
                            onActivated: {
                                var item = periodCombo.model[index] || {}
                                root.daysRequested(Number(item.days || 1))
                            }
                        }

                        Text {
                            text: "Model:"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                        }

                        NoScrollComboBox {
                            id: modelCombo
                            Layout.preferredWidth: VfTheme.dp(240)
                            model: root.modelFilterOptions()
                            textRole: "label"
                            currentIndex: root.currentModelIndex()
                            onActivated: {
                                var item = modelCombo.model[index] || {}
                                root.modelRequested(String(item.value || ""))
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(22)

                        Text {
                            Layout.fillWidth: true
                            text: "Request History"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: VfTheme.weightTitle
                        }

                        Text {
                            text: root.countRows()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        visible: root.actionMessage.length > 0
                        text: root.actionMessage
                        color: root.actionError ? "#DC2626" : VfTheme.tealText
                        font.family: VfTheme.fontFamily
                        font.pixelSize: VfTheme.fontSmall
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(28)
                        color: VfTheme.surfaceSoft

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: VfTheme.dp(8)
                            anchors.rightMargin: VfTheme.dp(8)
                            spacing: VfTheme.dp(8)

                            Text { Layout.preferredWidth: root.historyIndexColumnWidth; text: "#"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: root.historyTimeColumnWidth; text: "Time"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong }
                            Text { Layout.preferredWidth: root.historyModelColumnWidth; text: "Model"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; elide: Text.ElideRight }
                            Text { Layout.preferredWidth: root.historyFeatureColumnWidth; Layout.fillWidth: true; text: "Tiêu thụ vào"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; elide: Text.ElideRight }
                            Text { Layout.preferredWidth: root.historyMetricColumnWidth; text: "Input"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: root.historyMetricColumnWidth; text: "Output"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: root.historyCostColumnWidth; text: "Cost"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; horizontalAlignment: Text.AlignRight }
                            Text { Layout.preferredWidth: root.historyFormulaColumnWidth; Layout.fillWidth: true; Layout.leftMargin: VfTheme.dp(8); text: "Formula"; color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; font.weight: VfTheme.weightStrong; elide: Text.ElideRight }
                        }
                    }

                    ListView {
                        id: tokenList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        reuseItems: true
                        model: root.entries || []

                        delegate: Rectangle {
                            width: tokenList.width
                            height: VfTheme.dp(30)
                            color: index % 2 === 0 ? VfTheme.surface : VfTheme.surfaceSoft

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: VfTheme.dp(8)
                                anchors.rightMargin: VfTheme.dp(8)
                                spacing: VfTheme.dp(8)

                                Text { Layout.preferredWidth: root.historyIndexColumnWidth; text: String(index + 1); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall }
                                Text { Layout.preferredWidth: root.historyTimeColumnWidth; text: String(modelData.ts || "").slice(11, 19); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: root.historyModelColumnWidth; text: String(modelData.model_display || modelData.model || "-"); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: root.historyFeatureColumnWidth; Layout.fillWidth: true; text: String(modelData.feature_display || "—"); color: VfTheme.tealText; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; elide: Text.ElideRight }
                                Text { Layout.preferredWidth: root.historyMetricColumnWidth; text: root.fmt(modelData.input_tokens); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: root.historyMetricColumnWidth; text: root.fmt(modelData.output_tokens); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: root.historyCostColumnWidth; text: root.moneyText(modelData.cost); color: VfTheme.greenBorder; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: root.historyFormulaColumnWidth; Layout.fillWidth: true; Layout.leftMargin: VfTheme.dp(8); text: String(modelData.formula || ""); color: VfTheme.textSubtle; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontTiny; elide: Text.ElideRight }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.modelExpanded ? 146 : 28
                radius: VfTheme.radiusPanel
                color: VfTheme.surface
                border.color: VfTheme.borderBox
                clip: true

                MouseArea {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    height: VfTheme.dp(28)
                    onClicked: root.modelExpanded = !root.modelExpanded
                    cursorShape: Qt.PointingHandCursor
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    spacing: VfTheme.dp(5)

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(24)

                        Text {
                            Layout.fillWidth: true
                            text: (root.modelExpanded ? "▼ " : "▶ ") + "Per-Model Breakdown"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontControl
                            font.weight: VfTheme.weightTitle
                        }

                        Text {
                            text: root.countModels()
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: root.modelExpanded

                        ListView {
                            id: modelList
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.topMargin: VfTheme.dp(2)
                            anchors.bottom: parent.bottom
                            clip: true
                            reuseItems: true
                            model: root.modelRows()

                            delegate: Rectangle {
                                width: modelList.width
                                height: VfTheme.dp(28)
                                color: index % 2 === 0 ? VfTheme.surfaceSoft : VfTheme.surface

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(8)
                                    anchors.rightMargin: VfTheme.dp(8)
                                    spacing: VfTheme.dp(8)

                                    Text { Layout.fillWidth: true; text: String(modelData.display || modelData.model || "-"); color: VfTheme.text; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; elide: Text.ElideRight }
                                    Text { Layout.preferredWidth: VfTheme.dp(70); text: root.fmt(modelData.count); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                    Text { Layout.preferredWidth: VfTheme.dp(92); text: root.fmt(modelData.input); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                    Text { Layout.preferredWidth: VfTheme.dp(92); text: root.fmt(modelData.output); color: VfTheme.textMuted; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                    Text { Layout.preferredWidth: VfTheme.dp(112); text: root.moneyText(modelData.cost); color: VfTheme.greenBorder; font.family: VfTheme.fontFamily; font.pixelSize: VfTheme.fontSmall; horizontalAlignment: Text.AlignRight }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: VfTheme.dp(8)

                VfButton {
                    id: exportButton
                    text: "Export CSV"
                    actionId: "token_monitor.export"
                    tone: "primary"
                    Layout.preferredWidth: VfTheme.dp(120)
                    minWidth: VfTheme.dp(120)
                    onClicked: root.exportRequested()
                }

                VfButton {
                    id: clearButton
                    text: "Clear Usage"
                    actionId: "token_monitor.clear"
                    tone: "danger"
                    Layout.preferredWidth: VfTheme.dp(140)
                    minWidth: VfTheme.dp(140)
                    onClicked: clearConfirmDialog.open()
                }

                Item { Layout.fillWidth: true }

                VfButton {
                    id: refreshButton
                    text: "Refresh"
                    actionId: "token_monitor.refresh"
                    tone: "primary"
                    Layout.preferredWidth: VfTheme.dp(108)
                    minWidth: VfTheme.dp(108)
                    onClicked: root.refreshRequested()
                }

                VfButton {
                    id: closeButton
                    text: "Close"
                    actionId: "token_monitor.close"
                    tone: "neutral"
                    Layout.preferredWidth: VfTheme.dp(82)
                    minWidth: VfTheme.dp(82)
                    onClicked: root.close()
                }
            }
        }
    }

    Dialog {
        id: clearConfirmDialog

        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: VfDialogMetrics.width(parent, VfTheme.dp(380), VfTheme.dp(64))
        padding: VfTheme.dp(20)
        title: "Token Monitor"
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
                text: "Clear Usage"
                color: VfTheme.text
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.dp(20)
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }

            Text {
                Layout.fillWidth: true
                text: "Delete all usage history? This cannot be undone."
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
                    id: cancelClearButton
                    actionId: "dialog.close"
                    text: (void i18n.revision, i18n.t("common.cancel", "Cancel"))
                    minWidth: VfTheme.dp(96)
                    onClicked: clearConfirmDialog.close()
                }

                VfButton {
                    id: confirmClearButton
                    actionId: "token_monitor.clear"
                    tone: "danger"
                    text: "Clear"
                    minWidth: VfTheme.dp(96)
                    onClicked: {
                        root.clearRequested()
                        clearConfirmDialog.close()
                    }
                }
            }
        }
    }
}
