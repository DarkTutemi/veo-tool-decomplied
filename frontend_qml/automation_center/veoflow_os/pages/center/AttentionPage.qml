pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "CenterFormat.js" as Fmt

Item {
    id: root
    objectName: "centerAttentionPage"

    required property var plane
    signal navigateRequested(string route)

    property int selectedIndex: 0
    property int modelRevision: 0
    property string category: "all"
    property string query: ""
    property string severityFilter: ""
    property string channelFilter: ""
    property bool operatorCheckedPlatform: false
    readonly property bool compactLayout: width < 1450
    readonly property var attentionModel: root.plane.attentionModel
    readonly property var selectedCase: root.caseAt(root.selectedIndex)
    readonly property var selectedDetails: root.selectedCase.details || ({})
    readonly property var selectedActions: root.selectedCase.actions || []
    readonly property var selectedOrder: root.findModelRow(
        root.plane.orderModel, "orderId", root.selectedCase.orderId)
    readonly property var selectedAttempt: root.findAttempt(root.selectedCase)
    readonly property var selectedProfile: root.findProfile(root.selectedCase,
        root.selectedAttempt)
    readonly property var categories: [
        {"key": "all", "label": qsTr("Tất cả"), "icon": "ui/grid"},
        {"key": "publish_uncertain", "label": qsTr("Đăng bài không chắc chắn"), "icon": "semantic/alert-circle"},
        {"key": "profile_auth", "label": qsTr("Hồ sơ cần đăng nhập"), "icon": "navigation/users"},
        {"key": "missing_input", "label": qsTr("Thiếu đầu vào") , "icon": "semantic/alert-triangle"},
        {"key": "invalid_artifact", "label": qsTr("Artifact không hợp lệ"), "icon": "ui/file-text"},
        {"key": "binding_drift", "label": qsTr("Cấu hình lệch"), "icon": "ui/settings"}
    ]

    function caseAt(index) {
        const revision = root.modelRevision
        if (!root.attentionModel || index < 0
                || index >= Number(root.attentionModel.count || 0))
            return ({})
        return root.attentionModel.get(index) || ({})
    }

    function normalizedCategory(row) {
        const type = String(row.caseType || "").toLowerCase()
        const error = String(row.errorCode || "").toUpperCase()
        if (type.indexOf("publish") >= 0 || error.indexOf("PUBLISH_RESULT_UNCERTAIN") >= 0)
            return "publish_uncertain"
        if (type.indexOf("profile") >= 0 || type.indexOf("auth") >= 0
                || error.indexOf("AUTH_") >= 0)
            return "profile_auth"
        if (type.indexOf("artifact") >= 0 || error.indexOf("ARTIFACT") >= 0)
            return "invalid_artifact"
        if (type.indexOf("binding") >= 0 || error.indexOf("BINDING") >= 0)
            return "binding_drift"
        if (type.indexOf("input") >= 0 || error.indexOf("INPUT") >= 0
                || error.indexOf("SOURCE") >= 0)
            return "missing_input"
        return "missing_input"
    }

    function severityFor(row) {
        const category = root.normalizedCategory(row)
        if (category === "publish_uncertain")
            return "critical"
        if (category === "profile_auth" || category === "binding_drift")
            return "info"
        return "warning"
    }

    function findModelRow(model, field, value) {
        const revision = root.modelRevision
        const expected = String(value || "")
        if (!model || !expected)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row[field] || "") === expected)
                return row
        }
        return ({})
    }

    function findAttempt(attentionCase) {
        const revision = root.modelRevision
        const model = root.plane.publishAttemptModel
        const orderId = String(attentionCase.orderId || "")
        const stepId = String(attentionCase.stepId || "")
        if (!model || !orderId)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if (String(row.orderId || "") === orderId
                    && (!stepId || String(row.stepId || "") === stepId))
                return row
        }
        return ({})
    }

    function findProfile(attentionCase, attempt) {
        const revision = root.modelRevision
        const model = root.plane.profileModel
        const profileId = String(attempt.profileId || "")
        const channel = String(attentionCase.channelId || "")
        if (!model)
            return ({})
        for (let index = 0; index < Number(model.count || 0); ++index) {
            const row = model.get(index) || ({})
            if ((profileId && String(row.profileId || "") === profileId)
                    || (channel && [row.label, row.channelId, row.accountHandle]
                        .map(value => String(value || "")).indexOf(channel) >= 0))
                return row
        }
        return ({})
    }

    function matches(row) {
        if (root.category !== "all" && root.normalizedCategory(row) !== root.category)
            return false
        if (root.severityFilter && root.severityFor(row) !== root.severityFilter)
            return false
        if (root.channelFilter && String(row.channelId || "") !== root.channelFilter)
            return false
        if (!root.query)
            return true
        const haystack = (String(row.title || "") + " " + String(row.orderId || "")
            + " " + String(row.errorCode || "") + " " + String(row.errorMessage || "")).toLowerCase()
        return haystack.indexOf(root.query) >= 0
    }

    function categoryCount(key) {
        const revision = root.modelRevision
        let count = 0
        if (!root.attentionModel)
            return 0
        for (let index = 0; index < Number(root.attentionModel.count || 0); ++index) {
            const row = root.attentionModel.get(index) || ({})
            if (key === "all" || root.normalizedCategory(row) === key)
                ++count
        }
        return count
    }

    function severityCount(key) {
        const revision = root.modelRevision
        let count = 0
        if (!root.attentionModel)
            return count
        for (let index = 0; index < Number(root.attentionModel.count || 0); ++index) {
            if (root.severityFor(root.attentionModel.get(index) || ({})) === key)
                count++
        }
        return count
    }

    function evidenceOk(key, value) {
        const text = String(value || "").toLowerCase()
        if (key === "preflight")
            return text.indexOf("đã") >= 0 || text.indexOf("qua") >= 0
                || text.indexOf("pass") >= 0
        if (key === "upload")
            return text.indexOf("hoàn") >= 0 || text.indexOf("complete") >= 0
        if (key === "click")
            return text.indexOf("đã bấm") >= 0 || text.indexOf("clicked") >= 0
        return Boolean(root.selectedAttempt.externalPostId)
            || (text.length > 0 && text.indexOf("chưa") < 0
                && text.indexOf("thiếu") < 0 && text.indexOf("không áp dụng") < 0)
    }

    function hasAction(action) {
        return root.selectedActions.indexOf(action) >= 0
    }

    function resolve(resolution) {
        if (!root.operatorCheckedPlatform)
            return
        root.plane.callTool("tool1.order.resolve_attention", {
            "order_id": String(root.selectedCase.orderId || ""),
            "step_id": String(root.selectedCase.stepId || ""),
            "resolution": resolution,
            "evidence": {
                "operator_checked_platform": true,
                "case_id": String(root.selectedCase.caseId || ""),
                "confirmation": resolution === "published"
                    ? "operator_confirmed_published"
                    : "operator_confirmed_not_published"
            }
        })
    }

    onSelectedIndexChanged: operatorCheckedPlatform = false

    Connections {
        target: root.attentionModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() {
            root.modelRevision++
            if (root.selectedIndex >= Number(root.attentionModel.count || 0))
                root.selectedIndex = Math.max(0, Number(root.attentionModel.count || 0) - 1)
        }
    }

    Connections {
        target: root.plane.orderModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    Connections {
        target: root.plane.publishAttemptModel
        function onModelReset() { root.modelRevision++ }
        function onDataChanged() { root.modelRevision++ }
        function onCountChanged() { root.modelRevision++ }
    }

    Connections {
        target: root.plane.profileModel
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
            spacing: 14
            ColumnLayout {
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout ? 300 : 420
                spacing: 3
                Text {
                    text: qsTr("Cần xử lý")
                    color: CenterTokens.text
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.pageTitle
                    font.weight: Font.Bold
                }
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Kiểm tra bằng chứng và giải quyết những bước không thể tự động tiếp tục an toàn.")
                    color: CenterTokens.muted
                    font.family: CenterTokens.fontFamily
                    font.pixelSize: CenterTokens.body
                    elide: Text.ElideRight
                }
            }
            Item { Layout.fillWidth: true }
            CenterSearchField {
                Layout.preferredWidth: root.compactLayout ? 160 : 180
                placeholderText: qsTr("Tìm sự cố, job...")
                onQueryCommitted: query => root.query = query.toLowerCase()
            }
            AppComboBox {
                objectName: "attentionSeverityFilter"
                Layout.preferredWidth: root.compactLayout ? 125 : 140
                Layout.preferredHeight: CenterTokens.controlHeight
                model: [
                    {"text": qsTr("Tất cả mức độ"), "value": ""},
                    {"text": qsTr("Nghiêm trọng"), "value": "critical"},
                    {"text": qsTr("Cảnh báo"), "value": "warning"},
                    {"text": qsTr("Thông tin"), "value": "info"}
                ]
                textRole: "text"
                valueRole: "value"
                onActivated: root.severityFilter = String(currentValue || "")
            }
            AppComboBox {
                objectName: "attentionChannelFilter"
                Layout.preferredWidth: root.compactLayout ? 115 : 125
                Layout.preferredHeight: CenterTokens.controlHeight
                model: root.plane.profileModel
                textRole: "label"
                currentIndex: -1
                displayText: currentIndex < 0 ? qsTr("Tất cả kênh") : currentText
                onActivated: root.channelFilter = String(
                    (model.get(currentIndex) || ({})).label || "")
            }
            CenterStatusBadge {
                Layout.preferredWidth: root.compactLayout ? 105 : 112
                text: String(root.severityCount("critical")) + qsTr(" nghiêm trọng")
                status: root.severityCount("critical") > 0 ? "danger" : "success"
                iconName: "semantic/alert-circle"
            }
            CenterStatusBadge {
                Layout.preferredWidth: root.compactLayout ? 95 : 100
                text: String(root.severityCount("warning")) + qsTr(" cảnh báo")
                status: "warning"
                iconName: "semantic/alert-triangle"
            }
            CenterStatusBadge {
                Layout.preferredWidth: 120
                text: String(root.severityCount("info")) + qsTr(" thông tin")
                status: "info"
                iconName: "semantic/info"
                visible: !root.compactLayout
            }
            AppButton {
                Layout.preferredWidth: root.compactLayout ? 110 : 130
                text: qsTr("Làm mới")
                leadingIcon: "ui/refresh-cw"
                primary: true
                enabled: !root.plane.actionBusy
                onClicked: root.plane.callTool("tool1.attention.page", {"limit": 50, "offset": 0})
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: CenterTokens.gap

            ColumnLayout {
                Layout.fillWidth: false
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(210, root.width * 0.18)
                    : Math.min(320, Math.max(260, root.width * 0.185))
                Layout.maximumWidth: root.compactLayout ? 240 : 320
                Layout.fillHeight: true
                spacing: 10
                CenterPanel {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: CenterTokens.panelPadding
                        spacing: 7
                        SectionTitle { text: qsTr("Danh mục") }
                        Repeater {
                            model: root.categories
                            delegate: Button {
                                id: categoryButton
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 43
                                text: String(modelData.label)
                                checked: root.category === String(modelData.key)
                                checkable: true
                                onClicked: root.category = String(modelData.key)
                                contentItem: RowLayout {
                                    spacing: 9
                                    UiIcon {
                                        name: String(categoryButton.modelData.icon)
                                        tone: categoryButton.checked ? CenterTokens.primary : CenterTokens.muted
                                        iconSize: 16
                                        Layout.preferredWidth: 16
                                        Layout.preferredHeight: 16
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: categoryButton.text
                                        color: categoryButton.checked ? CenterTokens.primary : CenterTokens.text
                                        font.family: CenterTokens.fontFamily
                                        font.pixelSize: CenterTokens.body
                                        font.weight: categoryButton.checked ? Font.DemiBold : Font.Normal
                                        elide: Text.ElideRight
                                    }
                                    CenterStatusBadge {
                                        text: String(root.categoryCount(String(categoryButton.modelData.key)))
                                        status: categoryButton.checked ? "info" : "neutral"
                                    }
                                }
                                background: Rectangle {
                                    radius: CenterTokens.radiusSmall
                                    color: categoryButton.checked ? CenterTokens.primarySoft : CenterTokens.panel
                                    border.width: categoryButton.checked ? 1 : 0
                                    border.color: CenterTokens.primary
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }
                }
                CenterPanel {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 88
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6
                        SectionTitle { text: qsTr("SLA & thời gian chờ") }
                        RowLayout {
                            Layout.fillWidth: true
                            UiIcon {
                                name: "ui/timer"
                                tone: CenterTokens.warning
                                iconSize: 17
                                Layout.preferredWidth: 17
                                Layout.preferredHeight: 17
                            }
                            MetaText { Layout.fillWidth: true; text: qsTr("Ưu tiên case publish không chắc chắn") }
                        }
                    }
                }
            }

            CenterPanel {
                Layout.fillWidth: false
                Layout.minimumWidth: 0
                Layout.preferredWidth: root.compactLayout
                    ? Math.max(390, root.width * 0.34)
                    : Math.min(650, Math.max(520, root.width * 0.38))
                Layout.maximumWidth: root.compactLayout ? 440 : 650
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: CenterTokens.panelPadding
                    spacing: 8
                    SectionTitle { text: qsTr("Danh sách cần xử lý") }
                    ListView {
                        id: attentionList
                        objectName: "attentionInboxList"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        model: root.attentionModel
                        clip: true
                        reuseItems: true
                        boundsBehavior: Flickable.StopAtBounds
                        delegate: Item {
                            id: caseItem
                            required property int index
                            required property var modelData
                            readonly property bool rowMatches: root.matches(modelData)
                            width: ListView.view.width
                            height: rowMatches ? 76 : 0
                            visible: rowMatches
                            Rectangle {
                                anchors.fill: parent
                                color: root.selectedIndex === caseItem.index
                                    ? CenterTokens.primarySoft : CenterTokens.panel
                                border.width: 1
                                border.color: root.selectedIndex === caseItem.index
                                    ? CenterTokens.primary : CenterTokens.border
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10
                                    UiIcon {
                                        name: root.severityFor(caseItem.modelData) === "critical"
                                            ? "semantic/alert-circle"
                                            : root.severityFor(caseItem.modelData) === "info"
                                            ? "semantic/info" : "semantic/alert-triangle"
                                        tone: root.severityFor(caseItem.modelData) === "critical"
                                            ? CenterTokens.danger
                                            : root.severityFor(caseItem.modelData) === "info"
                                            ? CenterTokens.primary : CenterTokens.warning
                                        iconSize: 19
                                        Layout.preferredWidth: 19
                                        Layout.preferredHeight: 19
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3
                                        Text {
                                            Layout.fillWidth: true
                                            text: String(caseItem.modelData.title || qsTr("Case cần xử lý"))
                                            color: CenterTokens.text
                                            font.family: CenterTokens.fontFamily
                                            font.pixelSize: CenterTokens.body
                                            font.weight: Font.DemiBold
                                            elide: Text.ElideRight
                                        }
                                        RowLayout {
                                            Layout.fillWidth: true
                                            CenterStatusBadge {
                                                text: Fmt.workflowLabel(caseItem.modelData.workflow
                                                    || caseItem.modelData.stepKind)
                                                status: "info"
                                            }
                                            PlatformIcon {
                                                platform: String(caseItem.modelData.platform || "generic")
                                                iconSize: 13
                                                Layout.preferredWidth: 13
                                                Layout.preferredHeight: 13
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: String(caseItem.modelData.channelId || qsTr("Chưa có kênh"))
                                            }
                                        }
                                        MetaText {
                                            Layout.fillWidth: true
                                            text: String(caseItem.modelData.errorMessage || caseItem.modelData.errorCode || "")
                                        }
                                    }
                                    ColumnLayout {
                                        Layout.preferredWidth: 92
                                        spacing: 4
                                        CenterStatusBadge {
                                            text: root.severityFor(caseItem.modelData) === "critical"
                                                ? qsTr("Nghiêm trọng")
                                                : root.severityFor(caseItem.modelData) === "info"
                                                ? qsTr("Thông tin") : qsTr("Cảnh báo")
                                            status: root.severityFor(caseItem.modelData) === "critical"
                                                ? "danger"
                                                : root.severityFor(caseItem.modelData) === "info"
                                                ? "info" : "warning"
                                        }
                                        MetaText { text: Fmt.timeLabel(caseItem.modelData.updatedAt || caseItem.modelData.createdAt) }
                                    }
                                }
                                TapHandler {
                                    onTapped: {
                                        root.selectedIndex = caseItem.index
                                        root.operatorCheckedPlatform = false
                                    }
                                }
                            }
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: attentionList.count === 0
                            text: qsTr("Không có case cần xử lý trong projection hiện tại.")
                            color: CenterTokens.faint
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.body
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        MetaText {
                            Layout.fillWidth: true
                            text: qsTr("Hiển thị ") + String(root.attentionModel ? root.attentionModel.count : 0)
                                + qsTr(" case")
                        }
                        CenterStatusBadge { text: "1"; status: "info" }
                    }
                }
            }

            CenterPanel {
                id: inspector
                objectName: "attentionEvidenceInspector"
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                Layout.fillHeight: true
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: root.compactLayout ? 10 : CenterTokens.panelPadding
                    spacing: root.compactLayout ? 6 : 9
                    RowLayout {
                        Layout.fillWidth: true
                        SectionTitle {
                            Layout.fillWidth: true
                            text: String(root.selectedCase.title || qsTr("Chọn một case để kiểm tra"))
                        }
                        CenterStatusBadge {
                            text: root.severityFor(root.selectedCase) === "critical"
                                ? qsTr("Nghiêm trọng")
                                : root.severityFor(root.selectedCase) === "info"
                                ? qsTr("Thông tin") : qsTr("Cần kiểm tra")
                            status: root.severityFor(root.selectedCase) === "critical"
                                ? "danger"
                                : root.severityFor(root.selectedCase) === "info"
                                ? "info" : "warning"
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 12
                            rowSpacing: root.compactLayout ? 4 : 6
                            MetaText { text: qsTr("Nội dung") }
                            MetaText { text: String(root.selectedOrder.title || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Kênh") }
                            MetaText { text: String(root.selectedCase.channelId || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Nền tảng") }
                            MetaText { text: Fmt.platformLabel(root.selectedCase.platform); color: CenterTokens.text }
                            MetaText { text: qsTr("Order ID") }
                            MetaText { text: String(root.selectedCase.orderId || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Publish attempt") }
                            MetaText { text: String(root.selectedAttempt.attemptId || "—"); color: CenterTokens.text }
                        }
                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: CenterTokens.border
                        }
                        GridLayout {
                            Layout.preferredWidth: 290
                            columns: 2
                            columnSpacing: 10
                            rowSpacing: root.compactLayout ? 4 : 6
                            MetaText { text: qsTr("Trạng thái") }
                            MetaText {
                                text: String(root.selectedAttempt.confirmation
                                    || root.selectedCase.errorCode || "—")
                                color: CenterTokens.text
                            }
                            MetaText { text: qsTr("Thời gian") }
                            MetaText { text: Fmt.timeLabel(root.selectedCase.updatedAt); color: CenterTokens.text }
                            MetaText { text: qsTr("Trình duyệt") }
                            MetaText { text: String(root.selectedProfile.browserKey || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Profile") }
                            MetaText { text: String(root.selectedProfile.profileId || "—"); color: CenterTokens.text }
                            MetaText { text: qsTr("Post ID ngoài") }
                            MetaText { text: String(root.selectedAttempt.externalPostId || qsTr("Chưa có")); color: CenterTokens.text }
                        }
                    }
                    Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: CenterTokens.border }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: root.compactLayout ? 8 : 10
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: (inspector.width - 30) * 0.5
                            spacing: 6
                            SectionTitle { text: qsTr("Dòng thời gian bằng chứng") }
                            Repeater {
                                model: [
                                    {"key": "preflight", "label": qsTr("Preflight"), "value": String(root.selectedDetails.preflight || qsTr("Đã kiểm tra"))},
                                    {"key": "upload", "label": qsTr("Upload"), "value": String(root.selectedDetails.upload || qsTr("Chưa rõ"))},
                                    {"key": "click", "label": qsTr("Click đăng"), "value": String(root.selectedDetails.click || qsTr("Chưa rõ"))},
                                    {"key": "external", "label": qsTr("Bằng chứng ngoài"), "value": String(root.selectedDetails.external_evidence || qsTr("Thiếu"))}
                                ]
                                delegate: RowLayout {
                                    id: evidenceRow
                                    required property int index
                                    required property var modelData
                                    Layout.fillWidth: true
                                    UiIcon {
                                        name: root.evidenceOk(evidenceRow.modelData.key,
                                            evidenceRow.modelData.value)
                                            ? "semantic/check-circle" : "semantic/alert-circle"
                                        tone: root.evidenceOk(evidenceRow.modelData.key,
                                            evidenceRow.modelData.value)
                                            ? CenterTokens.success : CenterTokens.danger
                                        iconSize: 13
                                        Layout.preferredWidth: 13
                                        Layout.preferredHeight: 13
                                    }
                                    MetaText { Layout.fillWidth: true; text: String(evidenceRow.modelData.label) }
                                    MetaText {
                                        Layout.preferredWidth: 150
                                        text: String(evidenceRow.modelData.value)
                                        color: root.evidenceOk(evidenceRow.modelData.key,
                                            evidenceRow.modelData.value)
                                            ? CenterTokens.success : CenterTokens.danger
                                    }
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            Layout.preferredWidth: (inspector.width - 30) * 0.5
                            spacing: 6
                            SectionTitle { text: qsTr("Bằng chứng & dữ liệu liên quan") }
                            GridLayout {
                                Layout.fillWidth: true
                                columns: 2
                                columnSpacing: 6
                                rowSpacing: 6
                                Repeater {
                                    model: [
                                        {"title": qsTr("Case / occurrence"), "value": String(root.selectedCase.caseId || "—") + " · " + String(root.selectedCase.occurrenceId || "—")},
                                        {"title": qsTr("Bằng chứng attempt"), "value": String(root.selectedAttempt.evidencePath || root.selectedAttempt.evidenceSha256 || qsTr("Chưa có"))},
                                        {"title": qsTr("Browser action log"), "value": String(root.selectedDetails.click || qsTr("Chưa có"))},
                                        {"title": qsTr("PublishKit metadata"), "value": String(root.selectedCase.errorCode || root.selectedDetails.preflight || "—")}
                                    ]
                                    delegate: CenterPanel {
                                        id: evidenceCard
                                        required property var modelData
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: root.compactLayout ? 54 : 62
                                        elevated: true
                                        ColumnLayout {
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 3
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: String(evidenceCard.modelData.title)
                                                color: CenterTokens.text
                                            }
                                            MetaText {
                                                Layout.fillWidth: true
                                                text: String(evidenceCard.modelData.value)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: warningText.implicitHeight + 18
                        radius: CenterTokens.radiusSmall
                        color: CenterTokens.warningSoft
                        border.width: 1
                        border.color: CenterTokens.warning
                        Text {
                            id: warningText
                            anchors.fill: parent
                            anchors.margins: 9
                            text: root.normalizedCategory(root.selectedCase) === "publish_uncertain"
                                ? qsTr("Không tự động đăng lại khi kết quả bên ngoài chưa rõ. Phải kiểm tra nền tảng trước.")
                                : qsTr("Chỉ tiếp tục sau khi nguyên nhân đã được người vận hành xác nhận.")
                            color: CenterTokens.warning
                            font.family: CenterTokens.fontFamily
                            font.pixelSize: CenterTokens.metadata + 1
                            wrapMode: Text.Wrap
                        }
                    }
                    Item { Layout.fillHeight: true }
                    SectionTitle { text: qsTr("Giải quyết (chỉ khi bạn đã kiểm tra)") }
                    CheckBox {
                        id: inspectedCheck
                        Layout.fillWidth: true
                        text: qsTr("Tôi đã kiểm tra trạng thái thật trên nền tảng")
                        checked: root.operatorCheckedPlatform
                        onToggled: root.operatorCheckedPlatform = checked
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Mở hồ sơ để kiểm tra")
                            leadingIcon: "ui/external-link"
                            onClicked: root.navigateRequested("profiles")
                        }
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Xác nhận đã đăng")
                            leadingIcon: "semantic/check-circle"
                            primary: true
                            enabled: root.operatorCheckedPlatform && root.hasAction("published")
                            onClicked: root.resolve("published")
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Xác nhận chưa đăng & thử lại")
                            leadingIcon: "ui/refresh-cw"
                            enabled: root.operatorCheckedPlatform && root.hasAction("not_published")
                            onClicked: root.resolve("not_published")
                        }
                        AppButton {
                            Layout.fillWidth: true
                            text: qsTr("Mở job gốc")
                            leadingIcon: "ui/external-link"
                            onClicked: root.navigateRequested("progress")
                        }
                    }
                }
            }
        }
    }
}
