pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../theme"

// Outcome-first Extend workspace:
// idea intake -> unattended queue -> editable manual cards.
// Child segments prefer native Extend while the locked account can afford it;
// a confirmed insufficient balance pins that chain to last-frame I2V 0cr.
ColumnLayout {
    id: root

    property var cards: []
    property var cardModel: null
    property var ideaQueueModel: null
    property var queueStats: ({})
    property var routeConfig: ({})
    property var extendSessions: []
    property var extendSession: ({})

    readonly property int multiAssetLimit: Math.max(
        1, Number((routeConfig || {}).multi_asset_reference_limit || 3))
    readonly property var rootAssets: (routeConfig || {}).extend_root_assets || []
    readonly property int inputFilledCount: {
        var count = 0
        for (var i = 0; i < rootAssets.length; ++i) {
            var asset = rootAssets[i] || ({})
            if (String(asset.media_id || asset.id || asset.path
                       || asset.source_path || asset.thumbnail_url || "").length > 0)
                count += 1
        }
        return count
    }
    readonly property int inputSlotCount: 3
    readonly property string automaticMode: inputFilledCount <= 0
        ? "T2V"
        : inputFilledCount === 1
          ? "I2V"
          : inputFilledCount === 2 ? "I2V · Start/End" : "R2V"
    readonly property int manualCardCount: cardModel
        ? Number(cardModel.count || 0) : ((cards || []).length)

    signal actionRequested(string actionId, var payload)
    signal addBlankRequested()
    signal bulkImportRequested()
    signal submitAllRequested()
    signal clearQueueRequested()
    signal clearCompletedRequested()
    signal startQueueRequested()
    signal pauseQueueRequested()
    signal extendSessionNewRequested()
    signal extendSessionOpenRequested(string sessionKey)
    signal extendSessionDeleteRequested(string sessionKey)

    function requestAction(actionId, payload) {
        var data = { action_id: actionId, route: "extend" }
        for (var key in payload || ({}))
            data[key] = payload[key]
        root.actionRequested(actionId, data)
    }

    function requestAddBlank() {
        root.requestAction("work_panel.add_blank", { source: "extend_manual" })
        root.addBlankRequested()
    }

    function isExtendCard(item) {
        return String((item || {}).card_type || "").toUpperCase() === "EXTEND"
            || (item || {}).is_extend === true
    }

    function rootCardCount() {
        var items = root.cards || []
        var count = 0
        for (var i = 0; i < items.length; ++i)
            if (!root.isExtendCard(items[i]))
                count += 1
        return count
    }

    function selectedRootCount() {
        var items = root.cards || []
        var count = 0
        for (var i = 0; i < items.length; ++i)
            if (!root.isExtendCard(items[i]) && items[i].selected !== false)
                count += 1
        return count
    }

    function statValue(key) {
        return Math.max(0, Number((root.queueStats || {})[key] || 0))
    }

    function rootModelLabel() {
        var config = root.routeConfig || ({})
        var label = String(config.model_label || config.video_model_label || "")
        if (label.length > 0)
            return label
        var key = String(config.model_key || config.video_model_key || "")
        if (key.length > 0 && key.indexOf("speed:") !== 0)
            return key
        return "Theo cấu hình Model phía trên"
    }

    function continuationModelLabel() {
        var config = root.routeConfig || ({})
        var label = String(config.extend_model_label || "")
        if (label.length > 0)
            return label
        return "Tự động · Extend gốc / I2V 0cr"
    }

    function continuationExecutionLabel(rowData) {
        var execution = String((rowData || {}).extend_execution || "")
        if (execution === "native_extend")
            return "Extend gốc"
        if (execution === "last_frame_i2v")
            return "Frame cuối → I2V 0cr"
        if (execution === "hybrid_check")
            return "Đang kiểm tra credit"
        return "Tự động theo credit"
    }

    function continuationCreditLabel(rowData) {
        var row = rowData || ({})
        var execution = String(row.extend_execution || "")
        var raw = row.extend_credit_cost
        if (raw === undefined || raw === null || raw === "")
            raw = (root.routeConfig || {}).extend_native_credit_cost
        if (execution === "last_frame_i2v")
            return "Thiếu credit · fallback đã khóa"
        if (execution === "native_extend"
                && raw !== undefined && raw !== null && raw !== ""
                && !isNaN(Number(raw)))
            return "Đủ số dư · " + String(Number(raw)) + " credit"
        if (raw !== undefined && raw !== null && raw !== "" && !isNaN(Number(raw)))
            return "Đủ: Extend " + String(Number(raw)) + "cr · thiếu: I2V 0cr"
        return "Đủ credit: Extend gốc · thiếu: I2V 0cr"
    }

    function sessionLabel(sessionData) {
        var data = sessionData || ({})
        var title = String(data.title || "Phiên")
        var account = String(data.account_name || data.account_email || "")
        if (account.indexOf("@") >= 0)
            account = account.split("@")[0]
        if (account.length > 14)
            account = account.slice(0, 13) + "…"
        return account.length > 0 && account !== "local"
            ? title + " · " + account : title
    }

    component StatusCounter: Rectangle {
        id: counter

        property string label: ""
        property int value: 0
        property color accent: VfTheme.primary
        property color fillColor: VfTheme.blueFill

        implicitWidth: counterRow.implicitWidth + VfTheme.dp(18)
        implicitHeight: VfTheme.dp(27)
        radius: height / 2
        color: fillColor
        border.color: Qt.alpha(accent, 0.45)

        Row {
            id: counterRow
            anchors.centerIn: parent
            spacing: VfTheme.dp(5)
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: counter.label
                color: counter.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightControl
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: String(counter.value)
                color: counter.accent
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightStrong
            }
        }
    }

    spacing: 0

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: VfTheme.dp(54)
        color: VfTheme.surfaceSoft
        border.color: VfTheme.border

        RowLayout { // perf-lint: disable=R5 bounded desktop toolbar
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(10)
            anchors.rightMargin: VfTheme.dp(10)
            spacing: VfTheme.dp(7)

            NormalToolbarButton {
                minWidth: VfTheme.dp(102)
                actionId: "work_panel.extend_preview"
                text: "Xem trước"
                onClicked: root.requestAction(actionId, { source: "extend_toolbar" })
            }
            NormalToolbarButton {
                minWidth: VfTheme.dp(92)
                actionId: "work_panel.extend_render_video"
                text: "Render"
                onClicked: root.requestAction(actionId, { source: "extend_toolbar" })
            }
            NormalToolbarButton {
                minWidth: VfTheme.dp(92)
                actionId: "work_panel.extend_rules"
                text: "Quy tắc"
                onClicked: root.requestAction(actionId, { source: "extend_toolbar" })
            }

            Flickable {
                Layout.preferredWidth: VfTheme.dp(300)
                Layout.fillHeight: true
                contentWidth: toolbarSessionRow.implicitWidth
                contentHeight: height
                clip: true
                interactive: contentWidth > width
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: toolbarSessionRow
                    height: parent.height
                    spacing: VfTheme.dp(6)

                    Repeater {
                        model: root.extendSessions || [] // perf-lint: disable=R2 max 5 per account
                        delegate: Rectangle {
                            id: toolbarSessionChip
                            required property var modelData
                            readonly property string sessionKey: String(
                                (modelData || {}).session_key || (modelData || {}).id || "")
                            readonly property bool current: !!(modelData || {}).is_current
                                || sessionKey === String(
                                    (root.extendSession || {}).session_key
                                    || (root.extendSession || {}).id || "")
                            anchors.verticalCenter: parent.verticalCenter
                            width: toolbarSessionText.implicitWidth + VfTheme.dp(22)
                            height: VfTheme.controlHeight
                            radius: VfTheme.dp(7)
                            color: current ? VfTheme.blueFill : VfTheme.surface
                            border.color: current ? VfTheme.primary : VfTheme.borderSoft
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: root.sessionLabel(modelData)
                            Text {
                                id: toolbarSessionText
                                anchors.centerIn: parent
                                text: root.sessionLabel(toolbarSessionChip.modelData)
                                color: toolbarSessionChip.current ? VfTheme.text : VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: toolbarSessionChip.current
                                    ? VfTheme.weightStrong : VfTheme.weightControl
                            }
                            Keys.onReturnPressed: {
                                if (!current && sessionKey.length > 0)
                                    root.extendSessionOpenRequested(sessionKey)
                            }
                            Keys.onEnterPressed: {
                                if (!current && sessionKey.length > 0)
                                    root.extendSessionOpenRequested(sessionKey)
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!toolbarSessionChip.current
                                            && toolbarSessionChip.sessionKey.length > 0)
                                        root.extendSessionOpenRequested(toolbarSessionChip.sessionKey)
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: VfTheme.controlHeight
                        height: VfTheme.controlHeight
                        radius: VfTheme.dp(7)
                        color: VfTheme.surface
                        border.color: VfTheme.borderSoft
                        activeFocusOnTab: true
                        Accessible.role: Accessible.Button
                        Accessible.name: "Tạo phiên Extend mới"
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: VfTheme.primary
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(17)
                        }
                        Keys.onReturnPressed: root.extendSessionNewRequested()
                        Keys.onEnterPressed: root.extendSessionNewRequested()
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.extendSessionNewRequested()
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            NormalToolbarButton {
                tooltip: "Xóa phiên hiện tại"
                actionId: "work_panel.extend_delete_session"
                iconName: "cross-mark"
                text: ""
                danger: true
                onClicked: root.requestAction(actionId, { source: "extend_toolbar" })
            }
            NormalToolbarButton {
                minWidth: VfTheme.dp(142)
                actionId: "work_panel.extend_start_queue"
                text: "Chạy hàng chờ"
                selected: true
                onClicked: root.startQueueRequested()
            }
        }
    }

    // Retained only as a non-instantiated compatibility component while session
    // management lives in the compact toolbar above.
    Loader {
        active: false
        visible: false
        sourceComponent: Component {
    Rectangle {
        width: 0
        height: 0
        color: VfTheme.surface
        border.color: VfTheme.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: VfTheme.dp(12)
            anchors.rightMargin: VfTheme.dp(12)
            spacing: VfTheme.dp(8)

            Text {
                text: "Phiên"
                color: VfTheme.textSubtle
                font.family: VfTheme.fontFamily
                font.pixelSize: VfTheme.fontSmall
                font.weight: VfTheme.weightTitle
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: sessionRow.implicitWidth
                contentHeight: height
                clip: true
                interactive: contentWidth > width
                flickableDirection: Flickable.HorizontalFlick
                boundsBehavior: Flickable.StopAtBounds

                Row {
                    id: sessionRow
                    height: parent.height
                    spacing: VfTheme.dp(6)

                    Repeater {
                        model: root.extendSessions || [] // perf-lint: disable=R2 max 5 per account
                        delegate: Rectangle {
                            id: sessionChip
                            required property var modelData
                            property var sessionData: modelData || ({})
                            property string sessionKey: String(
                                sessionData.session_key || sessionData.id || "")
                            property bool current: !!sessionData.is_current
                                || sessionKey === String(
                                    (root.extendSession || {}).session_key
                                    || (root.extendSession || {}).id || "")

                            anchors.verticalCenter: parent.verticalCenter
                            width: sessionChipContent.implicitWidth + VfTheme.dp(20)
                            height: VfTheme.dp(29)
                            radius: VfTheme.dp(8)
                            color: current ? VfTheme.blueFill : VfTheme.surfaceSoft
                            border.color: current ? VfTheme.primary : VfTheme.border
                            activeFocusOnTab: true
                            Accessible.role: Accessible.Button
                            Accessible.name: sessionChipContent.sessionTitle
                            Keys.onReturnPressed: {
                                if (!current && sessionKey.length > 0)
                                    root.extendSessionOpenRequested(sessionKey)
                            }
                            Keys.onEnterPressed: {
                                if (!current && sessionKey.length > 0)
                                    root.extendSessionOpenRequested(sessionKey)
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!sessionChip.current && sessionChip.sessionKey.length > 0)
                                        root.extendSessionOpenRequested(sessionChip.sessionKey)
                                }
                            }
                            Row {
                                id: sessionChipContent
                                property string sessionTitle: {
                                    var title = String(sessionChip.sessionData.title || "Phiên")
                                    var account = String(
                                        sessionChip.sessionData.account_name
                                        || sessionChip.sessionData.account_email || "")
                                    if (account.indexOf("@") >= 0)
                                        account = account.split("@")[0]
                                    if (account.length > 11)
                                        account = account.slice(0, 10) + "…"
                                    return account.length > 0 && account !== "local"
                                        ? title + " · " + account : title
                                }
                                anchors.centerIn: parent
                                spacing: VfTheme.dp(7)
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: sessionChipContent.sessionTitle
                                    color: sessionChip.current ? VfTheme.text : VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    font.weight: sessionChip.current
                                        ? VfTheme.weightStrong : VfTheme.weightControl
                                }
                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "×"
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.dp(14)
                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -VfTheme.dp(4)
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.extendSessionDeleteRequested(
                                            sessionChip.sessionKey)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: VfTheme.dp(29)
                        height: VfTheme.dp(29)
                        radius: VfTheme.dp(8)
                        color: VfTheme.surface
                        border.color: VfTheme.primary
                        activeFocusOnTab: true
                        Accessible.role: Accessible.Button
                        Accessible.name: "Tạo phiên Extend mới"
                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: VfTheme.primary
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.dp(18)
                        }
                        Keys.onReturnPressed: root.extendSessionNewRequested()
                        Keys.onEnterPressed: root.extendSessionNewRequested()
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.extendSessionNewRequested()
                        }
                    }
                }
            }

            ExtendPill {
                text: "Tối đa 5 line / tài khoản"
                accent: VfTheme.cyan
            }
        }
    }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 0

        ColumnLayout {
            Layout.preferredWidth: Math.max(VfTheme.dp(590), root.width * 0.56)
            Layout.minimumWidth: VfTheme.dp(590)
            Layout.maximumWidth: Math.max(VfTheme.dp(680), root.width * 0.60)
            Layout.fillHeight: true
            spacing: VfTheme.dp(9)

            ExtendSectionBox {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(236)
                Layout.maximumHeight: VfTheme.dp(236)
                Layout.leftMargin: VfTheme.dp(10)
                Layout.topMargin: VfTheme.dp(10)
                Layout.rightMargin: VfTheme.dp(10)
                title: "1 · Ý tưởng & đầu vào"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(13)
                    anchors.topMargin: VfTheme.dp(40)
                    spacing: VfTheme.dp(9)

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: VfTheme.dp(132)
                        columns: 2
                        columnSpacing: VfTheme.dp(9)
                        uniformCellWidths: true
                        uniformCellHeights: true

                        Rectangle {
                            id: ideaPane
                            objectName: "extendIdeaInputPane"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: 0
                            radius: VfTheme.dp(8)
                            color: VfTheme.surface
                            border.color: ideaInput.activeFocus
                                ? VfTheme.primary : VfTheme.borderStrong
                            TextArea {
                                id: ideaInput
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(9)
                                placeholderText: "Nhập một ý tưởng video…\nVí dụ: quá trình một bản phác thảo biến thành siêu xe."
                                wrapMode: TextEdit.Wrap
                                selectByMouse: true
                                color: VfTheme.text
                                placeholderTextColor: VfTheme.textSubtle
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontControl
                                background: null
                            }
                        }

                        Rectangle {
                            id: imagePane
                            objectName: "extendImageInputPane"
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumWidth: 0
                            radius: VfTheme.dp(8)
                            color: VfTheme.surfaceSoft
                            border.color: VfTheme.borderStrong
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: VfTheme.dp(9)
                                spacing: VfTheme.dp(6)
                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: "Ảnh đầu vào"
                                        color: VfTheme.text
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontControl
                                        font.weight: VfTheme.weightTitle
                                    }
                                    Item { Layout.fillWidth: true }
                                    ExtendPill {
                                        text: root.automaticMode
                                        accent: root.inputFilledCount >= 3
                                            ? VfTheme.violet : VfTheme.primary
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.inputFilledCount === 0
                                        ? "Không có ảnh · hệ thống tự chạy T2V"
                                        : String(root.inputFilledCount)
                                          + " ảnh · tự chọn chế độ phù hợp"
                                    color: VfTheme.textMuted
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    elide: Text.ElideRight
                                }
                                Row {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: VfTheme.dp(7)
                                    Repeater {
                                        model: root.inputSlotCount
                                        ExtendAssetSlot {
                                            required property int index
                                            property var assetItem: root.rootAssets.length > index
                                                ? (root.rootAssets[index] || ({})) : ({})
                                            width: VfTheme.dp(61)
                                            height: VfTheme.dp(61)
                                            slotIndex: index
                                            title: index === 0 ? "+ Ảnh" : "+ Ảnh " + String(index + 1)
                                            assetData: assetItem
                                            imageSource: String(
                                                assetItem.thumbnail_url
                                                || assetItem.file_url
                                                || assetItem.preview_path || "")
                                            nameText: String(assetItem.name || assetItem.title || "")
                                            placeholder: String(
                                                assetItem.media_id || assetItem.id
                                                || assetItem.path || assetItem.source_path || "").length === 0
                                            onClicked: root.requestAction(
                                                "work_panel.extend_root_asset_pick",
                                                { slot_index: slotIndex, source: "extend_one_click" })
                                            onRemoveRequested: (slotIndex, assetId) =>
                                                root.requestAction(
                                                    "work_panel.extend_root_asset_remove",
                                                    {
                                                        slot_index: slotIndex,
                                                        asset_id: assetId,
                                                        source: "extend_one_click"
                                                    })
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(9)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: VfTheme.dp(1)
                            Text {
                                Layout.fillWidth: true
                                text: "ROOT · " + root.rootModelLabel()
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightStrong
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Đoạn nối · " + root.continuationModelLabel()
                                color: VfTheme.cyanText
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                font.weight: VfTheme.weightControl
                                elide: Text.ElideRight
                            }
                        }
                        NormalToolbarButton {
                            minWidth: VfTheme.dp(188)
                            actionId: "work_panel.extend_queue_idea"
                            text: "Thêm vào hàng chờ"
                            selected: true
                            blocked: ideaInput.text.trim().length === 0
                            blockedTooltip: "Cần nhập ý tưởng trước"
                            onClicked: {
                                var idea = ideaInput.text.trim()
                                if (idea.length === 0)
                                    return
                                root.requestAction(actionId, {
                                    source: "extend_one_click",
                                    idea: idea
                                })
                                ideaInput.clear()
                                ideaInput.forceActiveFocus()
                            }
                        }
                    }
                }
            }

            ExtendSectionBox {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: VfTheme.dp(10)
                Layout.rightMargin: VfTheme.dp(10)
                Layout.bottomMargin: VfTheme.dp(10)
                title: "2 · Hàng chờ tự động"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(11)
                    anchors.topMargin: VfTheme.dp(38)
                    spacing: VfTheme.dp(7)

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(6)
                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: "Mỗi ý tưởng là một chuỗi riêng · chạy lần lượt trong phiên"
                            color: VfTheme.textMuted
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            elide: Text.ElideRight
                        }
                        StatusCounter {
                            label: "Chờ"
                            value: root.statValue("pending")
                            accent: VfTheme.amberText
                            fillColor: VfTheme.amberFill
                        }
                        StatusCounter {
                            label: "Đang chạy"
                            value: root.statValue("generating")
                            accent: VfTheme.blueText
                            fillColor: VfTheme.blueFill
                        }
                        StatusCounter {
                            label: "Hoàn tất"
                            value: root.statValue("completed")
                            accent: VfTheme.greenText
                            fillColor: VfTheme.greenFill
                        }
                        StatusCounter {
                            label: "Lỗi"
                            value: root.statValue("failed")
                            accent: VfTheme.redText
                            fillColor: VfTheme.redFill
                            visible: value > 0
                        }
                        ExtendPill {
                            text: "Tự chạy"
                            accent: VfTheme.greenBorder
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: VfTheme.dp(8)
                        color: VfTheme.surfaceSoft
                        border.color: VfTheme.border
                        clip: true
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 0
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: VfTheme.dp(28)
                                color: VfTheme.surface
                                border.color: VfTheme.borderSoft
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: VfTheme.dp(9)
                                    anchors.rightMargin: VfTheme.dp(9)
                                    spacing: VfTheme.dp(9)
                                    Item { Layout.preferredWidth: VfTheme.dp(31) }
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Ý tưởng"
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(112)
                                        text: "Chuỗi"
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(154)
                                        text: "Nối đoạn"
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                    }
                                    Text {
                                        Layout.preferredWidth: VfTheme.dp(88)
                                        text: "Trạng thái"
                                        color: VfTheme.textSubtle
                                        font.family: VfTheme.fontFamily
                                        font.pixelSize: VfTheme.fontTiny
                                        font.weight: VfTheme.weightStrong
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.centerIn: parent
                                    width: parent.width - VfTheme.dp(40)
                                    visible: ideaQueue.count === 0
                                    text: "Chưa có ý tưởng trong hàng chờ.\nNhập ý tưởng ở trên rồi bấm “Thêm vào hàng chờ”."
                                    color: VfTheme.textSubtle
                                    font.family: VfTheme.fontFamily
                                    font.pixelSize: VfTheme.fontSmall
                                    horizontalAlignment: Text.AlignHCenter
                                    wrapMode: Text.WordWrap
                                }
                                ListView {
                                    id: ideaQueue
                                    objectName: "extendIdeaQueue"
                                    anchors.fill: parent
                                    anchors.margins: VfTheme.dp(6)
                                    model: root.ideaQueueModel
                                    spacing: VfTheme.dp(5)
                                    clip: true
                                    reuseItems: true
                                    boundsBehavior: Flickable.StopAtBounds

                                    delegate: Rectangle {
                                        id: ideaRow
                                        required property var qrow
                                        required property int index
                                        readonly property string statusKey: String(qrow.status_key || "pending")
                                        readonly property color statusAccent: {
                                            if (statusKey === "failed") return VfTheme.redBorder
                                            if (statusKey === "completed") return VfTheme.greenBorder
                                            if (statusKey === "running") return VfTheme.primary
                                            if (statusKey === "planning") return VfTheme.violet
                                            return VfTheme.amberBorder
                                        }
                                        width: ListView.view.width
                                        height: VfTheme.dp(44)
                                        radius: VfTheme.dp(7)
                                        color: VfTheme.surface
                                        border.color: Qt.alpha(statusAccent, 0.45)

                                        RowLayout {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.top: parent.top
                                            anchors.bottom: progress.top
                                            anchors.margins: VfTheme.dp(6)
                                            anchors.bottomMargin: VfTheme.dp(3)
                                            spacing: VfTheme.dp(9)
                                            Rectangle {
                                                Layout.preferredWidth: VfTheme.dp(31)
                                                Layout.preferredHeight: VfTheme.dp(31)
                                                radius: VfTheme.dp(8)
                                                color: ideaRow.statusKey === "completed"
                                                    ? VfTheme.greenFill : VfTheme.blueFill
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: String(ideaRow.index + 1)
                                                    color: ideaRow.statusKey === "completed"
                                                        ? VfTheme.greenText : VfTheme.blueText
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontControl
                                                    font.weight: VfTheme.weightStrong
                                                }
                                            }
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                Layout.minimumWidth: 0
                                                spacing: VfTheme.dp(2)
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: String(ideaRow.qrow.idea || "Ý tưởng")
                                                    color: VfTheme.text
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontControl
                                                    font.weight: VfTheme.weightStrong
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: {
                                                        var err = String(ideaRow.qrow.error_message || "")
                                                        if (err.length > 0)
                                                            return err
                                                        var details = String(ideaRow.qrow.aspect_ratio || "16:9")
                                                            + " · " + String(ideaRow.qrow.quality_label || "720p")
                                                        var folder = String(ideaRow.qrow.output_folder || "")
                                                        return folder.length > 0 ? details + " · " + folder : details
                                                    }
                                                    color: String(ideaRow.qrow.error_message || "").length > 0
                                                        ? VfTheme.redText : VfTheme.textSubtle
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontTiny
                                                    elide: Text.ElideMiddle
                                                }
                                            }
                                            ColumnLayout {
                                                Layout.preferredWidth: VfTheme.dp(112)
                                                Layout.minimumWidth: VfTheme.dp(112)
                                                spacing: VfTheme.dp(2)
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: Number(ideaRow.qrow.scene_count || 0) > 0
                                                        ? String(ideaRow.qrow.scene_count) + " đoạn"
                                                        : "ROOT + nối đoạn"
                                                    color: VfTheme.text
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontSmall
                                                    font.weight: VfTheme.weightStrong
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: String(ideaRow.qrow.root_model_label || "Tự động")
                                                    color: VfTheme.textSubtle
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontTiny
                                                    elide: Text.ElideRight
                                                }
                                            }
                                            ColumnLayout {
                                                Layout.preferredWidth: VfTheme.dp(154)
                                                Layout.minimumWidth: VfTheme.dp(154)
                                                spacing: VfTheme.dp(2)
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: root.continuationExecutionLabel(ideaRow.qrow)
                                                    color: VfTheme.cyanText
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontSmall
                                                    font.weight: VfTheme.weightStrong
                                                    elide: Text.ElideRight
                                                }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: root.continuationCreditLabel(ideaRow.qrow)
                                                    color: VfTheme.greenText
                                                    font.family: VfTheme.fontFamily
                                                    font.pixelSize: VfTheme.fontTiny
                                                    font.weight: VfTheme.weightControl
                                                    elide: Text.ElideRight
                                                }
                                            }
                                            ExtendPill {
                                                Layout.preferredWidth: VfTheme.dp(88)
                                                text: String(ideaRow.qrow.status_label || "Đang chờ")
                                                accent: ideaRow.statusAccent
                                            }
                                        }
                                        ProgressBar {
                                            id: progress
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.leftMargin: VfTheme.dp(48)
                                            anchors.rightMargin: VfTheme.dp(9)
                                            anchors.bottomMargin: VfTheme.dp(5)
                                            height: VfTheme.dp(3)
                                            from: 0
                                            to: 100
                                            value: Number(ideaRow.qrow.progress || 0)
                                            visible: ideaRow.statusKey === "running"
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
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: VfTheme.borderStrong
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: VfTheme.dp(440)
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(105)
                color: VfTheme.surface
                border.color: VfTheme.border
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(11)
                    spacing: VfTheme.dp(7)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(8)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: VfTheme.dp(1)
                            Text {
                                text: "Prompt thủ công"
                                color: VfTheme.text
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSection
                                font.weight: VfTheme.weightTitle
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Card đầu tiên luôn sẵn sàng; import điền vào card trống trước."
                                color: VfTheme.textMuted
                                font.family: VfTheme.fontFamily
                                font.pixelSize: VfTheme.fontSmall
                                elide: Text.ElideRight
                            }
                        }
                        ExtendPill {
                            text: String(root.selectedRootCount())
                                + "/" + String(root.rootCardCount())
                            accent: VfTheme.violet
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: VfTheme.dp(7)
                        NormalToolbarButton {
                            minWidth: VfTheme.dp(132)
                            actionId: "work_panel.add_blank"
                            text: "Thêm prompt"
                            selected: true
                            onClicked: root.requestAddBlank()
                        }
                        NormalToolbarButton {
                            minWidth: VfTheme.dp(118)
                            actionId: "work_panel.extend_bulk_import"
                            text: "Thêm hàng loạt"
                            onClicked: root.requestAction(actionId, { source: "extend_manual" })
                        }
                        NormalToolbarButton {
                            minWidth: VfTheme.dp(104)
                            actionId: "work_panel.select_all_cards"
                            text: "Chọn tất cả"
                            onClicked: root.requestAction(actionId, { source: "extend_manual" })
                        }
                        NormalToolbarButton {
                            minWidth: VfTheme.dp(86)
                            actionId: "work_panel.unselect_all_cards"
                            text: "Bỏ chọn"
                            onClicked: root.requestAction(actionId, { source: "extend_manual" })
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: VfTheme.surfaceSoft
                border.color: VfTheme.border
                clip: true
                ListView {
                    id: manualCards
                    objectName: "extendManualCards"
                    anchors.fill: parent
                    anchors.margins: VfTheme.dp(8)
                    model: root.cardModel
                    spacing: VfTheme.dp(8)
                    clip: true
                    reuseItems: true
                    boundsBehavior: Flickable.StopAtBounds
                    delegate: PromptCard {
                        required property var cardData
                        required property int index
                        width: ListView.view.width
                        card: cardData
                        promptIndex: index
                        route: "extend"
                        selected: Boolean(cardData.selected !== false)
                        multiAssetReferenceLimit: root.multiAssetLimit
                        promptEditorHeight: VfTheme.dp(124)
                        onActionRequested: (actionId, payload) =>
                            root.actionRequested(actionId, payload)
                    }
                }
            }

            Rectangle {
                objectName: "extendStickySubmitBar"
                Layout.fillWidth: true
                Layout.preferredHeight: VfTheme.dp(57)
                color: VfTheme.surface
                border.color: VfTheme.borderStrong
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: VfTheme.dp(12)
                    anchors.rightMargin: VfTheme.dp(12)
                    spacing: VfTheme.dp(9)
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        spacing: VfTheme.dp(1)
                        Text {
                            Layout.fillWidth: true
                            text: String(root.selectedRootCount()) + " prompt ROOT được chọn"
                            color: VfTheme.text
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontSmall
                            font.weight: VfTheme.weightStrong
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: "Các đoạn nối tự chọn theo số dư · "
                                + root.continuationModelLabel()
                            color: VfTheme.cyanText
                            font.family: VfTheme.fontFamily
                            font.pixelSize: VfTheme.fontTiny
                            elide: Text.ElideRight
                        }
                    }
                    NormalToolbarButton {
                        minWidth: VfTheme.dp(156)
                        actionId: "work_panel.submit_all"
                        text: "Chạy đã chọn"
                        selected: true
                        blocked: root.selectedRootCount() === 0
                        blockedTooltip: "Chọn ít nhất một prompt ROOT"
                        onClicked: root.submitAllRequested()
                    }
                }
            }
        }
    }
}
