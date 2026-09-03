pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerAutomationHistoryPage"

    required property var plane
    signal navigateRequested(string route)
    signal openWorkflowRequested(string workflow)

    property int selectedIndex: 0
    property int modelRevision: 0
    property string query: ""
    property string statusFilter: ""
    property string workflowFilter: ""
    property string channelFilter: ""
    property int rangeDays: 30
    readonly property bool compactLayout: width < 1450
    readonly property var historyModel: root.plane.publishAttemptModel
    readonly property var selectedAttempt: root.attemptAt(root.selectedIndex)
    readonly property var selectedOrder: root.orderFor(root.selectedAttempt)
    readonly property string selectedWorkflow: root.workflowFor(root.selectedAttempt)
    readonly property int totalRows: Number((root.plane.publishAttemptPage || {}).total
        || (root.historyModel ? root.historyModel.count : 0))

    function attemptAt(index) {
        const revision = root.modelRevision
        if (!root.historyModel || index < 0 || index >= Number(root.historyModel.count || 0))
            return ({})
        return root.historyModel.get(index) || ({})
    }

    function requestPage(offset) {
        root.plane.callTool("tool1.publish.history.page", {
            "query": root.query,
            "status": root.statusFilter,
            "limit": 50,
            "offset": Number(offset || 0)
        })
    }

    function resultUrl(row) {
        return String(row.postUrl || row.externalPostId || "")
    }

    function orderFor(row) {
        const revision = root.modelRevision
        const expected = String(row.orderId || "")
        const model = root.plane.orderModel
        if (!model || !expected)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const order = model.get(index) || ({})
            if (String(order.orderId || "") === expected)
                return order
        }
        return ({})
    }

    function workflowFor(row) {
        const order = root.orderFor(row)
        return String(((order.assignmentDefinition || {}).production_control || {}).workflow
            || row.workflow || "publish")
    }

    function matches(row) {
        if (root.statusFilter
                && String(row.status || "").toLowerCase() !== root.statusFilter)
            return false
        if (root.workflowFilter && root.workflowFor(row) !== root.workflowFilter)
            return false
        if (root.channelFilter && String(row.channelId || "") !== root.channelFilter)
            return false
        if (root.rangeDays > 0) {
            const value = new Date(String(row.completedAt || row.updatedAt || row.createdAt || ""))
            if (!isNaN(value.getTime())
                    && Date.now() - value.getTime() > root.rangeDays * 86400000)
                return false
        }
        if (!root.query)
            return true
        const haystack = [row.orderTitle, row.orderId, row.attemptId, row.postUrl,
            row.externalPostId, row.channelId, row.platform].join(" ").toLowerCase()
        return haystack.indexOf(root.query) >= 0
    }

    function matchingCount() {
        const revision = root.modelRevision
        let count = 0
        if (!root.historyModel)
            return count
        for (let index = 0; index < Number(root.historyModel.count || 0); ++index) {
            if (root.matches(root.historyModel.get(index) || ({})))
                count++
        }
        return count
    }

    function durationLabel(row) {
        const start = new Date(String(row.dispatchedAt || row.createdAt || ""))
        const end = new Date(String(row.completedAt || row.updatedAt || ""))
        if (isNaN(start.getTime()) || isNaN(end.getTime()) || end < start)
            return "—"
        const total = Math.max(0, Math.round((end.getTime() - start.getTime()) / 1000))
        const hours = Math.floor(total / 3600)
        const minutes = Math.floor((total % 3600) / 60)
        const seconds = total % 60
        return root.two(hours) + ":" + root.two(minutes) + ":" + root.two(seconds)
    }

    function two(value) { return String(value).padStart(2, "0") }

    Connections {
        target: root.historyModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() {
            root.modelRevision++
            if (root.selectedIndex >= Number(root.historyModel.count || 0))
                root.selectedIndex = Math.max(0, Number(root.historyModel.count || 0) - 1)
        }
    }

    Connections {
        target: root.plane.orderModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    component SectionTitle: Text {
        color: CenterTokens.text
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.sectionTitle
        font.weight: Font.DemiBold
    }

    component MetaText: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        elide: Text.ElideRight
    }

    component HeaderCell: Text {
        color: CenterTokens.muted
        font.family: CenterTokens.fontFamily
        font.pixelSize: CenterTokens.metadata + 1
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    component LineageRow: RowLayout {
        id: lineage
        required property int number
        required property string iconName
        required property string title
        required property string detail
        required property bool complete
        Layout.fillWidth: true
        Layout.preferredHeight: root.compactLayout ? 28 : 34
        spacing: 8
        Rectangle {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            radius: 10
            color: lineage.complete ? CenterTokens.success : CenterTokens.panelSoft
            border.width: 1
            border.color: lineage.complete ? CenterTokens.success : CenterTokens.borderStrong
            Text {
                anchors.centerIn: parent
                text: String(lineage.number)
                color: lineage.complete ? "white" : CenterTokens.muted
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.metadata
                font.weight: Font.Bold
            }
        }
        UiIcon {
            name: lineage.iconName
            tone: lineage.complete ? CenterTokens.success : CenterTokens.faint
            iconSize: 15
            Layout.preferredWidth: 15
            Layout.preferredHeight: 15
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text {
                Layout.fillWidth: true
                text: lineage.title
                color: CenterTokens.text
                font.family: CenterTokens.fontFamily
                font.pixelSize: CenterTokens.body
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            MetaText { Layout.fillWidth: true; text: lineage.detail }
        }
        CenterStatusBadge {
            text: lineage.complete ? qsTr("Hoàn tất") : qsTr("Không có")
            status: lineage.complete ? "success" : "neutral"
            iconName: lineage.complete ? "semantic/check-circle" : ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: CenterTokens.pageGutter
        anchors.rightMargin: CenterTokens.pageGutter
        anchors.topMargin: 14
        anchors.bottomMargin: 0
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            spacing: 10
            ColumnLayout {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout ? 270 : 410
                spacing: 3
                Text {
                    text: qsTr("Lịch sử")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Tra cứu toàn bộ nguồn, Assignment, native job, artifact và kết quả đăng.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    elide: Text.ElideRight
                }
            }
            Item { Layout.fillWidth: true }
            CenterSearchField {
                Layout.preferredWidth: root.compactLayout ? 220 : 270
                placeholderText: qsTr("Tìm nội dung, order, post URL...")
                onQueryCommitted: query => {
                    root.query = query.toLowerCase()
                    root.requestPage(0)
                }
            }
            AppComboBox {
                objectName: "automationHistoryDateFilter"
                Layout.preferredWidth: root.compactLayout ? 135 : 160
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("7 ngày qua"), "value": 7},
                    {"text": qsTr("30 ngày qua"), "value": 30},
                    {"text": qsTr("90 ngày qua"), "value": 90},
                    {"text": qsTr("Toàn bộ thời gian"), "value": 0}
                ]
                textRole: "text"
                valueRole: "value"
                currentIndex: 1
                onActivated: root.rangeDays = Number(currentValue || 0)
            }
            AppComboBox {
                objectName: "automationHistoryWorkflowFilter"
                Layout.preferredWidth: root.compactLayout ? 140 : 160
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("Tất cả workflow"), "value": ""},
                    {"text": "Master Prompt", "value": "master"},
                    {"text": "Clone Video", "value": "clone"},
                    {"text": "Audio to Video", "value": "transcript"},
                    {"text": "Affiliate", "value": "affiliate"},
                    {"text": "Time Machine", "value": "timemachine"}
                ]
                textRole: "text"
                valueRole: "value"
                onActivated: root.workflowFilter = String(currentValue || "")
            }
            AppComboBox {
                objectName: "automationHistoryChannelFilter"
                Layout.preferredWidth: root.compactLayout ? 140 : 160
                Layout.preferredHeight: CenterTokens.controlHeight
                model: root.plane.profileModel
                textRole: "label"
                currentIndex: -1
                displayText: currentIndex < 0 ? qsTr("Tất cả kênh") : currentText
                onActivated: root.channelFilter = String(
                    (model.get(currentIndex) || ({})).label || "")
            }
            AppComboBox {
                objectName: "automationHistoryStatusFilter"
                Layout.preferredWidth: root.compactLayout ? 145 : 180
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [qsTr("Tất cả kết quả"), qsTr("Đã đăng"), qsTr("Thất bại"), qsTr("Cần xử lý")]
                onActivated: {
                    root.statusFilter = currentIndex === 1 ? "succeeded"
                        : currentIndex === 2 ? "failed"
                        : currentIndex === 3 ? "needs_attention" : ""
                    root.requestPage(0)
                }
            }
            AppButton {
                Layout.preferredWidth: 140
                text: qsTr("Xuất báo cáo")
                leadingIcon: "ui/download"
                primary: true
                enabled: false
                visualEnabled: true
                availabilityReason: qsTr("Export chưa có adapter first-party; dữ liệu lịch sử vẫn được lưu cục bộ.")
                visible: !root.compactLayout
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            CenterPanel {
                Layout.minimumWidth: 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        SectionTitle { text: qsTr("Hoạt động đã hoàn tất") }
                        Item { Layout.fillWidth: true }
                        MetaText { text: qsTr("%1 bản ghi").arg(root.totalRows) }
                        AppButton {
                            text: ""
                            leadingIcon: "ui/refresh-cw"
                            subtle: true
                            leftPadding: 4
                            rightPadding: 4
                            enabled: !root.plane.actionBusy
                            onClicked: root.requestPage(0)
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        spacing: 12
                        RowLayout {
                            spacing: 6
                            Rectangle {
                                Layout.preferredWidth: 25
                                Layout.preferredHeight: 14
                                radius: 7
                                color: CenterTokens.primary
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: "white"
                                }
                            }
                            MetaText { text: qsTr("Theo nội dung"); color: CenterTokens.text }
                        }
                        RowLayout {
                            spacing: 6
                            Rectangle {
                                Layout.preferredWidth: 25
                                Layout.preferredHeight: 14
                                radius: 7
                                color: CenterTokens.border
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: CenterTokens.panel
                                }
                            }
                            MetaText { text: qsTr("Theo sự kiện"); color: CenterTokens.faint }
                        }
                        Item { Layout.fillWidth: true }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: CenterTokens.panelSoft
                        border.width: 1
                        border.color: CenterTokens.border
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 9
                            HeaderCell { Layout.minimumWidth: 112; Layout.preferredWidth: 112; Layout.maximumWidth: 112; text: qsTr("Thời gian") }
                            HeaderCell { Layout.fillWidth: true; text: qsTr("Nội dung") }
                            HeaderCell { Layout.minimumWidth: 120; Layout.preferredWidth: 120; Layout.maximumWidth: 120; text: qsTr("Workflow") }
                            HeaderCell { Layout.minimumWidth: 145; Layout.preferredWidth: 145; Layout.maximumWidth: 145; text: qsTr("Kênh") }
                            HeaderCell { Layout.minimumWidth: 110; Layout.preferredWidth: 110; Layout.maximumWidth: 110; text: qsTr("Kết quả sản xuất"); visible: !root.compactLayout }
                            HeaderCell { Layout.minimumWidth: 150; Layout.preferredWidth: 150; Layout.maximumWidth: 150; text: qsTr("Kết quả đăng") }
                            HeaderCell { Layout.minimumWidth: 80; Layout.preferredWidth: 80; Layout.maximumWidth: 80; text: qsTr("Thời lượng"); visible: !root.compactLayout }
                            Item { Layout.minimumWidth: 22; Layout.preferredWidth: 22; Layout.maximumWidth: 22 }
                        }
                    }
                    ListView {
                        id: historyList
                        objectName: "automationHistoryList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.historyModel
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Rectangle {
                            id: historyRow
                            required property int index
                            required property var modelData
                            readonly property bool rowMatches: root.matches(modelData)
                            width: ListView.view.width
                            height: rowMatches ? 43 : 0
                            visible: rowMatches
                            color: root.selectedIndex === index
                                ? CenterTokens.primarySoft : CenterTokens.panel
                            border.width: 1
                            border.color: root.selectedIndex === index
                                ? CenterTokens.primary : CenterTokens.border
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 9
                                MetaText {
                                    Layout.minimumWidth: 112
                                    Layout.preferredWidth: 112
                                    Layout.maximumWidth: 112
                                    text: Fmt.timeLabel(historyRow.modelData.completedAt
                                        || historyRow.modelData.updatedAt || historyRow.modelData.createdAt)
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 0
                                    Text {
                                        Layout.fillWidth: true
                                        text: String(historyRow.modelData.orderTitle || qsTr("Nội dung đã xuất bản"))
                                        color: CenterTokens.text
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.body
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                    }
                                    MetaText { Layout.fillWidth: true; text: String(historyRow.modelData.attemptId || "—") }
                                }
                                RowLayout {
                                    Layout.minimumWidth: 120
                                    Layout.preferredWidth: 120
                                    Layout.maximumWidth: 120
                                    CenterStatusBadge {
                                        text: Fmt.workflowLabel(root.workflowFor(historyRow.modelData))
                                        status: Fmt.workflowTone(root.workflowFor(historyRow.modelData))
                                    }
                                }
                                RowLayout {
                                    Layout.minimumWidth: 145
                                    Layout.preferredWidth: 145
                                    Layout.maximumWidth: 145
                                    PlatformIcon {
                                        platform: String(historyRow.modelData.platform || "generic")
                                        iconSize: 14
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                    }
                                    MetaText {
                                        Layout.fillWidth: true
                                        text: String(historyRow.modelData.channelId
                                            || historyRow.modelData.profileId || "—")
                                    }
                                }
                                CenterStatusBadge {
                                    Layout.minimumWidth: 110
                                    Layout.preferredWidth: 110
                                    Layout.maximumWidth: 110
                                    text: Fmt.statusLabel(historyRow.modelData.orderStatus,
                                        historyRow.modelData.orderStatus)
                                    status: Fmt.statusKind(historyRow.modelData.orderStatus)
                                    iconName: Fmt.statusKind(historyRow.modelData.orderStatus) === "success"
                                        ? "semantic/check-circle" : ""
                                    visible: !root.compactLayout
                                }
                                ColumnLayout {
                                    Layout.minimumWidth: 150
                                    Layout.preferredWidth: 150
                                    Layout.maximumWidth: 150
                                    spacing: 0
                                    MetaText {
                                        Layout.fillWidth: true
                                        text: Fmt.statusLabel(historyRow.modelData.status,
                                            historyRow.modelData.statusLabel)
                                        color: Fmt.statusKind(historyRow.modelData.status) === "success"
                                            ? CenterTokens.success
                                            : Fmt.statusKind(historyRow.modelData.status) === "danger"
                                            ? CenterTokens.danger : CenterTokens.warning
                                    }
                                    MetaText {
                                        Layout.fillWidth: true
                                        text: root.resultUrl(historyRow.modelData)
                                            || qsTr("Không có URL ngoài")
                                        color: root.resultUrl(historyRow.modelData)
                                            ? CenterTokens.primary : CenterTokens.muted
                                    }
                                }
                                MetaText {
                                    Layout.minimumWidth: 80
                                    Layout.preferredWidth: 80
                                    Layout.maximumWidth: 80
                                    text: root.durationLabel(historyRow.modelData)
                                    visible: !root.compactLayout
                                }
                                AppButton {
                                    Layout.minimumWidth: 22
                                    Layout.preferredWidth: 22
                                    Layout.maximumWidth: 22
                                    text: ""
                                    leadingIcon: "ui/more-horizontal"
                                    subtle: true
                                    leftPadding: 3
                                    rightPadding: 3
                                }
                            }
                            TapHandler { onTapped: root.selectedIndex = historyRow.index }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: root.matchingCount() === 0
                            text: qsTr("Chưa có publish attempt trong trang lịch sử hiện tại.")
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        MetaText {
                            Layout.fillWidth: true
                            text: qsTr("Hiển thị %1 / %2 bản ghi").arg(
                                root.matchingCount()).arg(root.totalRows)
                        }
                        AppButton { text: qsTr("Trước"); subtle: true; enabled: false }
                        CenterStatusBadge { text: "1"; status: "info" }
                        AppButton {
                            text: qsTr("Sau")
                            subtle: true
                            enabled: Boolean((root.plane.publishAttemptPage || {}).hasMore)
                            onClicked: root.requestPage(50)
                        }
                    }
                }
            }

            CenterPanel {
                objectName: "automationHistoryLineageInspector"
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(330, root.width * 0.28)
                    : Math.max(410, root.width * 0.315)
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.compactLayout ? 10 : CenterTokens.panelPadding
                    spacing: root.compactLayout ? 5 : 8
                    RowLayout {
                        Layout.fillWidth: true
                        SectionTitle { Layout.fillWidth: true; text: qsTr("Dòng đời nội dung") }
                        AppButton { text: ""; leadingIcon: "ui/close"; subtle: true; enabled: false }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 104
                            Layout.preferredHeight: root.compactLayout ? 60 : 70
                            radius: CenterTokens.radiusSmall
                            color: CenterTokens.panelSoft
                            UiIcon {
                                anchors.centerIn: parent
                                name: "ui/play"
                                tone: CenterTokens.faint
                                iconSize: 22
                            }
                            MetaText {
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 4
                                text: root.durationLabel(root.selectedAttempt)
                                color: CenterTokens.text
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 3
                            Text {
                                Layout.fillWidth: true
                                text: String(root.selectedAttempt.orderTitle || qsTr("Chọn một publish attempt"))
                                color: CenterTokens.text
                                font.family: CenterTokens.fontFamily
                                font.pixelSize: CenterTokens.body
                                font.weight: Font.DemiBold
                                wrapMode: Text.Wrap
                            }
                            RowLayout {
                                PlatformIcon {
                                    platform: String(root.selectedAttempt.platform || "generic")
                                    iconSize: 14
                                    Layout.preferredWidth: 14
                                    Layout.preferredHeight: 14
                                }
                                MetaText { text: String(root.selectedAttempt.channelId || root.selectedAttempt.profileId || "—") }
                            }
                            CenterStatusBadge {
                                text: Fmt.statusLabel(root.selectedAttempt.status,
                                    root.selectedAttempt.statusLabel)
                                status: Fmt.statusKind(root.selectedAttempt.status)
                                iconName: Fmt.statusKind(root.selectedAttempt.status) === "success"
                                    ? "semantic/check-circle" : ""
                            }
                            MetaText {
                                Layout.fillWidth: true
                                text: root.resultUrl(root.selectedAttempt) || qsTr("Chưa có canonical URL / post ID")
                                color: root.resultUrl(root.selectedAttempt)
                                    ? CenterTokens.primary : CenterTokens.warning
                            }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    LineageRow {
                        number: 1
                        iconName: "semantic/lightbulb"
                        title: qsTr("Nguồn")
                        detail: qsTr("Nguồn operator cung cấp hoặc brief AI đã duyệt")
                        complete: Boolean(root.selectedAttempt.orderId)
                    }
                    LineageRow {
                        number: 2
                        iconName: "ui/file-text"
                        title: qsTr("Assignment V2")
                        detail: String(root.selectedAttempt.orderId || qsTr("Không có order"))
                        complete: Boolean(root.selectedAttempt.orderId)
                    }
                    LineageRow {
                        number: 3
                        iconName: "semantic/workflow"
                        title: Fmt.workflowLabel(root.selectedWorkflow)
                        detail: String(root.selectedAttempt.stepId || qsTr("Không có step"))
                        complete: Boolean(root.selectedAttempt.stepId)
                    }
                    LineageRow {
                        number: 4
                        iconName: "ui/folder"
                        title: qsTr("Artifact đã xác minh")
                        detail: String(root.selectedAttempt.evidencePath
                            || Fmt.compactId(root.selectedAttempt.evidenceSha256))
                        complete: Boolean(root.selectedAttempt.evidencePath
                            || root.selectedAttempt.evidenceSha256)
                    }
                    LineageRow {
                        number: 5
                        iconName: "ui/calendar"
                        title: qsTr("Lịch đăng")
                        detail: Fmt.timeLabel(root.selectedAttempt.dispatchedAt || root.selectedAttempt.createdAt)
                        complete: Boolean(root.selectedAttempt.dispatchedAt || root.selectedAttempt.createdAt)
                    }
                    LineageRow {
                        number: 6
                        iconName: "semantic/upload-cloud"
                        title: qsTr("Publish attempt")
                        detail: String(root.selectedAttempt.attemptId || qsTr("Không có attempt"))
                            + (root.resultUrl(root.selectedAttempt)
                                ? " · " + root.resultUrl(root.selectedAttempt) : "")
                        complete: Boolean(root.selectedAttempt.attemptId)
                    }
                    SectionTitle { text: qsTr("Artifact liên quan") }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24
                        color: CenterTokens.panelSoft
                        border.width: 1
                        border.color: CenterTokens.border
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8
                            HeaderCell { Layout.fillWidth: true; text: qsTr("Bằng chứng") }
                            HeaderCell { Layout.preferredWidth: 120; text: "SHA-256" }
                            HeaderCell { Layout.preferredWidth: 80; text: qsTr("Xác minh") }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        spacing: 8
                        MetaText {
                            Layout.fillWidth: true
                            text: String(root.selectedAttempt.evidencePath
                                || root.selectedAttempt.postUrl
                                || qsTr("Chưa có artifact evidence"))
                        }
                        MetaText {
                            Layout.preferredWidth: 120
                            text: Fmt.compactId(root.selectedAttempt.evidenceSha256)
                        }
                        CenterStatusBadge {
                            Layout.preferredWidth: 80
                            text: Boolean(root.selectedAttempt.evidenceSha256
                                || root.resultUrl(root.selectedAttempt))
                                ? qsTr("Đã xác minh") : qsTr("Chưa có")
                            status: Boolean(root.selectedAttempt.evidenceSha256
                                || root.resultUrl(root.selectedAttempt))
                                ? "success" : "neutral"
                        }
                    }
                    Item { Layout.fillHeight: true }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        AppButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: qsTr("Mở tab")
                            leadingIcon: "ui/external-link"
                            enabled: Boolean(root.selectedWorkflow)
                            onClicked: root.openWorkflowRequested(root.selectedWorkflow)
                        }
                        AppButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: qsTr("Mở log")
                            leadingIcon: "ui/file-text"
                            onClicked: root.plane.openLogFolder()
                        }
                        AppButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: qsTr("Mở bài")
                            leadingIcon: "ui/external-link"
                            enabled: Boolean(root.resultUrl(root.selectedAttempt))
                            onClicked: Qt.openUrlExternally(root.resultUrl(root.selectedAttempt))
                        }
                        AppButton {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            text: qsTr("Hồ sơ")
                            leadingIcon: "navigation/users"
                            enabled: Boolean(root.selectedAttempt.profileId)
                            onClicked: root.navigateRequested("profiles")
                        }
                    }
                    AppButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        text: qsTr("Tạo lại từ nguồn này")
                        leadingIcon: "ui/refresh-cw"
                        primary: true
                        enabled: Boolean(root.selectedAttempt.orderId)
                        onClicked: root.navigateRequested("coordination")
                    }
                    Text {
                        Layout.fillWidth: true
                        text: qsTr("Tạo một Assignment mới; không phát lại native job identity đã kết thúc.")
                        color: CenterTokens.faint
                        font.family: CenterTokens.fontFamily
                        font.pixelSize: CenterTokens.metadata
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        visible: !root.compactLayout
                    }
                }
            }
        }
    }
}
