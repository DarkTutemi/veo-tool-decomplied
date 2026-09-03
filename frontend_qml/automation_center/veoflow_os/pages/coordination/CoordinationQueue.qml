pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Rectangle {
    id: root
    objectName: "coordinationQueue"
    property var operationModel
    property string selectedOperationKey: ""
    property var channelOptions: []
    property var stageOptions: []
    property var sortOptions: []
    property string currentChannelId: ""
    property string currentStage: ""
    property string currentSort: "operational"
    property var selectionVersions: ({})
    property int selectionRevision: 0
    property int selectionCount: 0
    property int staleSelectionCount: 0
    property var bulkActions: ({})
    property int operationRowHeight: 46
    property bool showActivityColumn: true
    property string referenceTimestamp: ""
    readonly property real columnSpacing: 10
    readonly property real columnLeft: 12
    readonly property real checkColumnWidth: 26
    readonly property real taskColumnX: root.columnLeft
        + root.checkColumnWidth + root.columnSpacing
    readonly property real taskColumnWidth: Math.max(
        180,
        root.width - 12 - root.taskColumnX - 124 - 92 - 128 - 70
            - (root.showActivityColumn ? 178 : 0)
            - root.columnSpacing * (root.showActivityColumn ? 5 : 4)
    )
    readonly property real channelColumnX: root.taskColumnX
        + root.taskColumnWidth + root.columnSpacing
    readonly property real stageColumnX: root.channelColumnX + 124 + root.columnSpacing
    readonly property real progressColumnX: root.stageColumnX + 92 + root.columnSpacing
    readonly property real etaColumnX: root.progressColumnX + 128 + root.columnSpacing
    readonly property real activityColumnX: root.etaColumnX + 70 + root.columnSpacing

    signal operationSelected(string operationKey)
    signal operationOpened(string operationKey)
    signal channelFilterRequested(string channelId)
    signal stageFilterRequested(string stage)
    signal sortRequested(string sort)
    signal operationSelectionRequested(string operationKey, string versionToken, bool selected)
    signal selectAllRequested(bool selected)

    readonly property bool allSelected: root.operationModel
        && root.operationModel.count > 0
        && root.selectionCount === root.operationModel.count
    readonly property var firstBulkAction: {
        const items = (root.bulkActions || ({})).items || []
        return items.length > 0 ? items[0] : ({})
    }
    readonly property string bulkUnavailableReason: root.staleSelectionCount > 0
        ? "COORDINATION_SELECTION_STALE"
        : String(root.firstBulkAction.reason_code
            || (root.bulkActions || ({})).reason_code
            || "COORDINATION_BULK_CAPABILITY_UNAVAILABLE")

    radius: Theme.radiusLarge
    color: Theme.panel
    border.width: 1
    border.color: Theme.borderSoft
    clip: true
    Accessible.name: "Hàng đợi công việc"
    Accessible.role: Accessible.Pane

    function optionModel(allLabel, items) {
        return [{"id": "", "label": allLabel}].concat(items || [])
    }

    function optionId(combo, index) {
        const item = combo.model && index >= 0 ? combo.model[index] : null
        return item ? String(item.id || "") : ""
    }

    function optionIndex(items, id) {
        const value = String(id || "")
        for (let index = 0; index < items.length; index++) {
            if (String(items[index].id || "") === value)
                return index
        }
        return 0
    }

    function selectionVersion(operationKey) {
        const revision = root.selectionRevision
        return String((root.selectionVersions || ({}))[String(operationKey || "")] || "")
    }

    function stageLabel(value) {
        const labels = {
            "idea": "Ý tưởng",
            "production": "Sản xuất",
            "publish": "Đăng tải",
            "care": "Chăm sóc"
        }
        return labels[value] || "Không rõ"
    }

    function stageTone(value) {
        if (value === "idea") return Theme.success
        if (value === "production") return Theme.info
        if (value === "publish") return Theme.accent
        if (value === "care") return Theme.warning
        return Theme.textFaint
    }

    function stateTone(value) {
        const state = String(value || "").toLowerCase()
        if (["failed", "blocked", "verification_required"].indexOf(state) >= 0)
            return Theme.danger
        if (["succeeded", "completed", "published", "done"].indexOf(state) >= 0)
            return Theme.success
        if (["awaiting_approval", "scheduled"].indexOf(state) >= 0)
            return Theme.warning
        if (["running", "producing", "rendering", "publishing", "caring", "in_progress"].indexOf(state) >= 0)
            return Theme.info
        return Theme.textFaint
    }

    function stateLabel(value) {
        const labels = {
            "running": "Đang chạy", "producing": "Đang sản xuất",
            "rendering": "Đang render", "publishing": "Đang đăng",
            "caring": "Đang chăm sóc", "in_progress": "Đang xử lý",
            "awaiting_approval": "Chờ phê duyệt", "scheduled": "Đã lên lịch",
            "failed": "Thất bại", "blocked": "Bị chặn",
            "succeeded": "Hoàn tất", "completed": "Hoàn tất",
            "published": "Đã đăng", "done": "Hoàn tất", "unknown": "Không rõ"
        }
        return labels[String(value || "unknown").toLowerCase()] || String(value || "Không rõ")
    }

    function etaLabel(value) {
        if (!String(value || ""))
            return "Không rõ"
        const parsed = new Date(value)
        return isNaN(parsed.getTime()) ? "Không rõ" : Qt.formatDateTime(parsed, "HH:mm")
    }

    function formatEventSummary(summary) {
        const text = String(summary || "")
        if (!text) return "Chưa có hoạt động"
        if (text.indexOf("Tình huống mô phỏng") >= 0) return "Đã kiểm tra kịch bản tự động"
        return text
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
            Layout.leftMargin: 14
            Layout.rightMargin: 12
            spacing: 8

            Text {
                text: "Hàng đợi công việc"
                color: Theme.text
                font.pixelSize: 15
                font.weight: Font.Bold
            }
            Foundation.StatusPill {
                objectName: "coordinationQueueCountBadge"
                text: String(root.operationModel ? root.operationModel.count : 0)
                tone: Theme.textMuted
                showDot: false
            }
            Item { Layout.fillWidth: true }
            CoordinationFilterComboBox {
                id: channelFilter
                objectName: "coordinationChannelFilter"
                Layout.preferredWidth: 240
                popupMinimumWidth: 260
                model: root.optionModel("Tất cả kênh", root.channelOptions)
                Component.onCompleted: currentIndex = root.optionIndex(model, root.currentChannelId)
                onActivated: function(index) {
                    root.channelFilterRequested(root.optionId(channelFilter, index))
                }
                Accessible.name: "Lọc công việc theo kênh"
            }
            CoordinationFilterComboBox {
                id: stageFilter
                objectName: "coordinationStageFilter"
                Layout.preferredWidth: 146
                model: root.optionModel("Tất cả giai đoạn", root.stageOptions)
                Component.onCompleted: currentIndex = root.optionIndex(model, root.currentStage)
                onActivated: function(index) {
                    root.stageFilterRequested(root.optionId(stageFilter, index))
                }
                Accessible.name: "Lọc công việc theo giai đoạn"
            }
            CoordinationFilterComboBox {
                id: prioritySort
                objectName: "coordinationPrioritySort"
                Layout.preferredWidth: 146
                model: root.sortOptions || []
                Component.onCompleted: currentIndex = root.optionIndex(model, root.currentSort)
                onActivated: function(index) {
                    root.sortRequested(root.optionId(prioritySort, index))
                }
                Accessible.name: "Sắp xếp hàng đợi phía server"
            }
            Button {
                id: queueOptionsButton
                objectName: "coordinationQueueOptionsButton"
                Layout.preferredWidth: 34
                Layout.preferredHeight: 32
                implicitWidth: 34
                implicitHeight: 32
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                hoverEnabled: true
                activeFocusOnTab: true
                onClicked: {
                    queueOptionsPopup.visible = !queueOptionsPopup.visible
                    if (queueOptionsPopup.visible)
                        queueOptionsPopup.forceActiveFocus()
                }
                Accessible.name: "Tùy chọn hiển thị hàng đợi"
                Accessible.role: Accessible.Button
                contentItem: UiIcon {
                    objectName: "coordinationQueueOptionsIcon"
                    name: "ui/columns-3"
                    tone: queueOptionsButton.activeFocus || queueOptionsButton.hovered
                        ? Theme.text : Theme.textMuted
                    iconSize: 16
                }
                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: queueOptionsButton.down
                        ? Theme.accentSoft
                        : (queueOptionsButton.hovered ? Theme.hover : Theme.elevated)
                    border.width: 1
                    border.color: queueOptionsButton.activeFocus
                        ? Theme.accent : Theme.borderSoft
                }
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.selectionCount > 0 ? 42 : 34

            AppCheckBox {
                id: selectAll
                objectName: "coordinationSelectAll"
                x: root.columnLeft
                anchors.verticalCenter: parent.verticalCenter
                width: root.checkColumnWidth
                checked: root.allSelected
                enabled: Boolean(root.operationModel && root.operationModel.count > 0)
                availabilityReason: enabled ? "" : "Không có công việc trên trang"
                activeFocusOnTab: true
                Accessible.name: root.allSelected ? "Bỏ chọn tất cả" : "Chọn tất cả công việc trên trang"
                onClicked: root.selectAllRequested(!root.allSelected)
            }
            Text {
                objectName: "coordinationQueueHeaderTask"
                x: root.taskColumnX
                anchors.verticalCenter: parent.verticalCenter
                width: root.taskColumnWidth
                text: root.selectionCount > 0
                    ? root.selectionCount + " công việc đã chọn"
                    : "CÔNG VIỆC"
                color: root.selectionCount > 0 ? Theme.textMuted : Theme.textFaint
                font.pixelSize: root.selectionCount > 0 ? 10 : 9
                font.weight: Font.Bold
            }
            AppButton {
                id: bulkActionButton
                objectName: "coordinationBulkActionButton"
                availabilityReason: root.bulkUnavailableReason
                visible: root.selectionCount > 0
                x: root.channelColumnX
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(240, parent.width - x - 12)
                text: root.staleSelectionCount > 0
                    ? root.staleSelectionCount + " mục đã thay đổi"
                    : String(root.firstBulkAction.label || "Không có thao tác an toàn")
                implicitHeight: 30
                enabled: root.selectionCount > 0
                    && root.staleSelectionCount === 0
                    && Boolean(root.firstBulkAction.available)
                activeFocusOnTab: true
                Accessible.name: text + ". " + availabilityReason
            }
            Text { objectName: "coordinationQueueHeaderChannel"; x: root.channelColumnX; anchors.verticalCenter: parent.verticalCenter; width: 124; visible: root.selectionCount === 0; text: "KÊNH"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
            Text { objectName: "coordinationQueueHeaderStage"; x: root.stageColumnX; anchors.verticalCenter: parent.verticalCenter; width: 92; visible: root.selectionCount === 0; text: "GIAI ĐOẠN"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
            Text { objectName: "coordinationQueueHeaderProgress"; x: root.progressColumnX; anchors.verticalCenter: parent.verticalCenter; width: 128; visible: root.selectionCount === 0; text: "TIẾN ĐỘ"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
            Text { objectName: "coordinationQueueHeaderEta"; x: root.etaColumnX; anchors.verticalCenter: parent.verticalCenter; width: 70; visible: root.selectionCount === 0; text: "ETA"; color: Theme.textFaint; font.pixelSize: 11; font.weight: Font.Bold }
            Text {
                objectName: "coordinationActivityColumnHeader"
                x: root.activityColumnX
                anchors.verticalCenter: parent.verticalCenter
                width: visible ? 178 : 0
                visible: root.selectionCount === 0 && root.showActivityColumn
                text: "HOẠT ĐỘNG MỚI NHẤT"
                color: Theme.textFaint
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }

        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Theme.borderSoft }

        ListView {
            id: operationList
            objectName: "coordinationOperationList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.operationModel
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            keyNavigationEnabled: true
            activeFocusOnTab: true
            Accessible.name: "Danh sách hoạt động điều phối"
            Accessible.role: Accessible.List

            delegate: Rectangle {
                id: operationRow
                objectName: "operationRow_" + operationRow.operationKey
                required property string operation_key
                required property var version_fingerprint
                required property var operation_id
                required property var operation_kind
                required property string stage
                required property var title
                required property var platform
                required property var channel_id
                required property var channel_name
                required property var estimated_end_at
                required property var progress_value
                required property var state_value
                required property var last_event

                readonly property string operationKey: String(operationRow.operation_key || "")
                readonly property string versionToken: String(operationRow.version_fingerprint || "")
                readonly property bool bulkSelected: root.selectionVersion(operationRow.operationKey).length > 0
                readonly property bool progressKnown: operationRow.progress_value
                    && operationRow.progress_value.value !== null
                    && operationRow.progress_value.value !== undefined
                readonly property real progressValue: operationRow.progressKnown
                    ? Number(operationRow.progress_value.value) : 0
                readonly property string operationState: String(operationRow.state_value || "unknown")
                readonly property string progressText: operationRow.progressKnown
                    ? Math.round(Math.max(0, Math.min(1, operationRow.progressValue)) * 100) + "%"
                    : "Không rõ"
                readonly property string etaText: root.etaLabel(operationRow.estimated_end_at)
                readonly property bool selected: root.selectedOperationKey === operationRow.operationKey
                readonly property string lastEventSummary: String((operationRow.last_event || {}).summary || "")
                readonly property string lastEventAt: String((operationRow.last_event || {}).occurred_at || "")

                width: operationList.width
                height: root.operationRowHeight
                color: selected ? Theme.accentSoft : rowMouse.containsMouse ? Theme.hover : "transparent"
                activeFocusOnTab: true
                Accessible.name: operationRow.title + ". " + root.stateLabel(operationRow.operationState)
                    + ". Tiến độ " + operationRow.progressText + ". ETA " + operationRow.etaText
                Accessible.role: Accessible.Button
                Keys.onReturnPressed: root.operationOpened(operationRow.operationKey)
                Keys.onEnterPressed: root.operationOpened(operationRow.operationKey)

                Rectangle {
                    visible: operationRow.selected
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 3
                    color: Theme.accent
                }
                Rectangle { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; height: 1; color: Theme.borderSoft }

                Item {
                    anchors.fill: parent

                    AppCheckBox {
                        objectName: "operationCheck_" + operationRow.operationKey
                        x: root.columnLeft
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.checkColumnWidth
                        checked: operationRow.bulkSelected
                        activeFocusOnTab: true
                        Accessible.name: (checked ? "Bỏ chọn " : "Chọn ") + operationRow.title
                        onClicked: root.operationSelectionRequested(
                            operationRow.operationKey,
                            operationRow.versionToken,
                            !operationRow.bulkSelected)
                    }
                    RowLayout {
                        objectName: "operationTask_" + operationRow.operationKey
                        x: root.taskColumnX
                        anchors.verticalCenter: parent.verticalCenter
                        width: root.taskColumnWidth
                        height: parent.height
                        spacing: 8
                        Rectangle {
                            id: statusDot
                            Layout.preferredWidth: 8
                            Layout.preferredHeight: 8
                            Layout.alignment: Qt.AlignVCenter
                            radius: 4
                            color: root.stateTone(operationRow.operationState)

                            readonly property bool isRunning: ["running", "producing", "rendering", "publishing", "in_progress"].indexOf(operationRow.operationState) >= 0

                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: statusDot.isRunning
                                NumberAnimation { to: 0.35; duration: 950; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 950; easing.type: Easing.InOutQuad }
                            }
                        }
                        SocialIcon { platform: operationRow.platform || "generic"; Layout.preferredWidth: 19; Layout.preferredHeight: 19 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text { Layout.fillWidth: true; text: operationRow.title || "Công việc chưa có tiêu đề"; color: Theme.text; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { Layout.fillWidth: true; text: operationRow.operationKey; color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideMiddle }
                        }
                    }
                    Text { objectName: "operationChannel_" + operationRow.operationKey; x: root.channelColumnX; anchors.verticalCenter: parent.verticalCenter; width: 124; text: operationRow.channel_name || operationRow.channel_id || "Chưa gán"; color: operationRow.channel_name || operationRow.channel_id ? Theme.textMuted : Theme.warning; font.pixelSize: 12; elide: Text.ElideRight }
                    Foundation.StatusPill { objectName: "operationStage_" + operationRow.operationKey; x: root.stageColumnX; anchors.verticalCenter: parent.verticalCenter; width: 92; text: root.stageLabel(operationRow.stage); tone: root.stageTone(operationRow.stage); showDot: false }
                    RowLayout {
                        objectName: "operationProgress_" + operationRow.operationKey
                        x: root.progressColumnX
                        anchors.verticalCenter: parent.verticalCenter
                        width: 128
                        height: parent.height
                        spacing: 7
                        Foundation.ProgressMeter { visible: operationRow.progressKnown; Layout.preferredWidth: 76; value: operationRow.progressValue; tone: root.stageTone(operationRow.stage) }
                        Text { text: operationRow.progressText; color: operationRow.progressKnown ? Theme.textMuted : Theme.warning; font.pixelSize: 12; font.weight: Font.DemiBold }
                    }
                    Text { objectName: "operationEta_" + operationRow.operationKey; x: root.etaColumnX; anchors.verticalCenter: parent.verticalCenter; width: 70; text: operationRow.etaText; color: operationRow.etaText === "Không rõ" ? Theme.warning : Theme.textMuted; font.pixelSize: 12; font.weight: Font.DemiBold }
                    ColumnLayout {
                        objectName: "operationActivity_" + operationRow.operationKey
                        x: root.activityColumnX
                        anchors.verticalCenter: parent.verticalCenter
                        width: visible ? 178 : 0
                        height: parent.height
                        visible: root.showActivityColumn
                        spacing: 0
                        Text { Layout.fillWidth: true; text: root.formatEventSummary(operationRow.lastEventSummary); color: operationRow.lastEventSummary ? Theme.textMuted : Theme.textFaint; font.pixelSize: 12; elide: Text.ElideRight }
                        Foundation.RelativeTimeText {
                            objectName: "operationRelativeTime_" + operationRow.operationKey
                            visible: operationRow.lastEventAt.length > 0
                            timestamp: operationRow.lastEventAt
                            referenceTimestamp: root.referenceTimestamp
                        }
                    }
                }

                MouseArea {
                    id: rowMouse
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 48
                    anchors.right: parent.right
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        operationRow.forceActiveFocus()
                        root.operationSelected(operationRow.operationKey)
                    }
                    onDoubleClicked: root.operationOpened(operationRow.operationKey)
                }
            }

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Text { anchors.centerIn: parent; visible: operationList.count === 0; text: "Snapshot không có hoạt động"; color: Theme.textFaint; font.pixelSize: 12 }
        }
    }

    Rectangle {
        id: queueOptionsPopup
        objectName: "coordinationQueueOptionsPopup"
        x: root.width - width - 12
        y: 44
        width: 212
        height: 96
        z: 20
        visible: false
        activeFocusOnTab: visible
        radius: Theme.radiusSmall
        color: Theme.panel
        border.width: 1
        border.color: Theme.border
        Accessible.name: "Tùy chọn hiển thị hàng đợi"
        Accessible.role: Accessible.PopupMenu
        Keys.onEscapePressed: queueOptionsPopup.visible = false

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 4

            Button {
                id: activityColumnToggle
                objectName: "coordinationActivityColumnToggle"
                Layout.fillWidth: true
                Layout.preferredHeight: 39
                checkable: true
                checked: root.showActivityColumn
                text: "Hoạt động mới nhất"
                hoverEnabled: true
                activeFocusOnTab: true
                Accessible.name: "Hiện cột hoạt động mới nhất"
                Accessible.role: Accessible.CheckBox
                onClicked: root.showActivityColumn = checked
                contentItem: RowLayout {
                    spacing: 8
                    UiIcon {
                        name: activityColumnToggle.checked
                            ? "semantic/check-circle" : "ui/circle"
                        tone: activityColumnToggle.checked
                            ? Theme.success : Theme.textFaint
                        iconSize: 14
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Hoạt động mới nhất"
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                }
                background: Rectangle {
                    radius: 5
                    color: activityColumnToggle.hovered ? Theme.hover : "transparent"
                }
            }

            Button {
                id: densityToggle
                objectName: "coordinationQueueDensityToggle"
                Layout.fillWidth: true
                Layout.preferredHeight: 39
                hoverEnabled: true
                activeFocusOnTab: true
                text: root.operationRowHeight === 46
                    ? "Mật độ: Gọn" : "Mật độ: Thoáng"
                Accessible.name: "Đổi mật độ hàng. " + text
                onClicked: root.operationRowHeight = root.operationRowHeight === 46 ? 52 : 46
                contentItem: RowLayout {
                    spacing: 8
                    UiIcon {
                        name: "ui/columns-3"
                        tone: Theme.info
                        iconSize: 14
                    }
                    Text {
                        Layout.fillWidth: true
                        text: densityToggle.text
                        color: Theme.textMuted
                        font.pixelSize: 11
                    }
                }
                background: Rectangle {
                    radius: 5
                    color: densityToggle.hovered ? Theme.hover : "transparent"
                }
            }
        }
    }

}
