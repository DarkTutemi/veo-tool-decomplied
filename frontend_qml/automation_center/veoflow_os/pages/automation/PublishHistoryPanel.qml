pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Item {
    id: root
    objectName: "publishHistoryPanel"

    property var controlPlaneBridge: null
    property string platformFilter: ""
    property string statusFilter: ""
    property string attentionTypeFilter: ""
    property string activeView: "history"
    property bool closeVisible: true
    signal closeRequested()
    signal scheduleRequested()
    signal workOrderRequested(string orderId)

    readonly property var attemptModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.publishAttemptModel : null
    readonly property var page: root.controlPlaneBridge
        ? root.controlPlaneBridge.publishAttemptPage : ({})
    readonly property var attentionModel: root.controlPlaneBridge
        ? root.controlPlaneBridge.attentionModel : null
    readonly property var attentionPage: root.controlPlaneBridge
        ? root.controlPlaneBridge.attentionPage : ({})
    readonly property bool actionBusy: root.controlPlaneBridge
        ? Boolean(root.controlPlaneBridge.actionBusy) : false

    Accessible.name: "Lịch sử Publish Executor"
    Accessible.role: Accessible.Pane

    function stateTone(state) {
        const value = String(state || "").toLowerCase()
        if (value === "succeeded") return Theme.success
        if (value === "failed" || value === "needs_attention") return Theme.danger
        if (value === "publishing") return Theme.accent
        return Theme.textFaint
    }

    function requestPage(offset) {
        if (!root.controlPlaneBridge || root.actionBusy)
            return false
        root.controlPlaneBridge.callTool("tool1.publish.history.page", {
            "offset": Math.max(0, Number(offset || 0)),
            "limit": Math.max(1, Number(root.page.limit || 100)),
            "platform": root.platformFilter,
            "status": root.statusFilter,
            "search": historySearch.text.trim()
        })
        return true
    }

    function requestAttentionPage(offset) {
        if (!root.controlPlaneBridge || root.actionBusy)
            return false
        root.controlPlaneBridge.callTool("tool1.attention.page", {
            "offset": Math.max(0, Number(offset || 0)),
            "limit": Math.max(1, Number(root.attentionPage.limit || 100)),
            "case_type": root.attentionTypeFilter,
            "search": attentionSearch.text.trim()
        })
        return true
    }

    function selectView(view) {
        root.activeView = String(view || "history") === "attention"
            ? "attention" : "history"
        if (root.activeView === "attention")
            root.requestAttentionPage(0)
        else
            root.requestPage(0)
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space3
            spacing: Theme.space3

            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 11
                color: Theme.accentSoft
                UiIcon {
                    anchors.centerIn: parent
                    name: "semantic/upload-cloud"
                    tone: Theme.accent
                    iconSize: 21
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: root.activeView === "attention"
                        ? "Cần đối soát" : "Lịch sử đăng"
                    color: Theme.text
                    font.pixelSize: Theme.fontSection
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.fillWidth: true
                    text: root.activeView === "attention"
                        ? "Xung đột lịch và kết quả đăng chưa chắc chắn được gom về một nơi."
                        : "Post ID, URL và ảnh bằng chứng do Publish Executor lưu sau mỗi lần đăng."
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                    elide: Text.ElideRight
                }
            }
            AppButton {
                objectName: "publishHistoryEvidenceModeButton"
                text: "Bằng chứng"
                primary: root.activeView === "history"
                subtle: root.activeView !== "history"
                onClicked: root.selectView("history")
            }
            AppButton {
                objectName: "publishHistoryAttentionModeButton"
                text: "Cần xử lý (" + String(Number(
                    root.attentionPage.total
                    || (root.attentionModel ? root.attentionModel.count : 0)
                )) + ")"
                primary: root.activeView === "attention"
                subtle: root.activeView !== "attention"
                onClicked: root.selectView("attention")
            }
            AppButton {
                objectName: "publishHistoryCloseButton"
                text: "Đóng"
                visible: root.closeVisible
                leadingIcon: "ui/close"
                onClicked: root.closeRequested()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            visible: root.activeView === "history"
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            spacing: Theme.space2

            WorkflowTextField {
                id: historySearch
                objectName: "publishHistorySearch"
                Layout.fillWidth: true
                placeholderText: "Tìm Post ID, URL hoặc profile…"
                onAccepted: root.requestPage(0)
            }
            WorkflowComboBox {
                id: platformCombo
                objectName: "publishHistoryPlatformFilter"
                Layout.preferredWidth: 160
                textRole: "label"
                valueRole: "value"
                model: [
                    {"label": "Mọi nền tảng", "value": ""},
                    {"label": "YouTube", "value": "youtube"},
                    {"label": "TikTok", "value": "tiktok"},
                    {"label": "Facebook", "value": "facebook"}
                ]
                onActivated: {
                    root.platformFilter = String(currentValue || "")
                    root.requestPage(0)
                }
            }
            WorkflowComboBox {
                id: statusCombo
                objectName: "publishHistoryStatusFilter"
                Layout.preferredWidth: 165
                textRole: "label"
                valueRole: "value"
                model: [
                    {"label": "Mọi trạng thái", "value": ""},
                    {"label": "Đã đăng", "value": "succeeded"},
                    {"label": "Cần xử lý", "value": "needs_attention"},
                    {"label": "Thất bại", "value": "failed"},
                    {"label": "Đang đăng", "value": "publishing"}
                ]
                onActivated: {
                    root.statusFilter = String(currentValue || "")
                    root.requestPage(0)
                }
            }
            AppButton {
                objectName: "publishHistoryRefreshButton"
                text: "Làm mới"
                leadingIcon: "ui/refresh-cw"
                enabled: !root.actionBusy
                onClicked: root.requestPage(Number(root.page.offset || 0))
            }
        }

        RowLayout {
            visible: root.activeView === "attention"
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            spacing: Theme.space2

            WorkflowTextField {
                id: attentionSearch
                objectName: "publishAttentionSearch"
                Layout.fillWidth: true
                placeholderText: "Tìm work order, kênh hoặc mã lỗi…"
                onAccepted: root.requestAttentionPage(0)
            }
            WorkflowComboBox {
                id: attentionTypeCombo
                objectName: "publishAttentionTypeFilter"
                Layout.preferredWidth: 210
                textRole: "label"
                valueRole: "value"
                model: [
                    {"label": "Mọi việc cần xử lý", "value": ""},
                    {"label": "Đối soát work order", "value": "work_order"},
                    {"label": "Xung đột lịch", "value": "schedule_conflict"}
                ]
                onActivated: {
                    root.attentionTypeFilter = String(currentValue || "")
                    root.requestAttentionPage(0)
                }
            }
            AppButton {
                objectName: "publishAttentionRefreshButton"
                text: "Làm mới"
                leadingIcon: "ui/refresh-cw"
                enabled: !root.actionBusy
                onClicked: root.requestAttentionPage(
                    Number(root.attentionPage.offset || 0))
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        ListView {
            id: historyList
            objectName: "publishHistoryList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.activeView === "history"
            Layout.margins: Theme.space3
            spacing: 7
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            model: root.attemptModel

            delegate: Rectangle {
                id: historyRow
                required property var modelData

                width: historyList.width
                height: 92
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.borderSoft
                Accessible.name: String(historyRow.modelData.platform || "")
                    + " " + String(historyRow.modelData.statusLabel || "")
                Accessible.role: Accessible.Row

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 11

                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 12
                        color: Theme.panel
                        border.width: 1
                        border.color: Theme.borderSoft
                        PlatformIcon {
                            anchors.centerIn: parent
                            platform: String(historyRow.modelData.platform || "generic")
                            iconSize: 28
                        }
                    }
                    Image {
                        visible: String(historyRow.modelData.evidencePath || "").length > 0
                        Layout.preferredWidth: visible ? 70 : 0
                        Layout.preferredHeight: visible ? 48 : 0
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize.width: 140
                        sourceSize.height: 96
                        source: visible && root.controlPlaneBridge
                            ? root.controlPlaneBridge.authorizedThumbnailUrl(
                                "", String(historyRow.modelData.evidencePath || ""))
                            : ""
                        Accessible.name: "Ảnh bằng chứng đăng"
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: String(historyRow.modelData.orderTitle
                                    || historyRow.modelData.profileId || "Profile")
                                color: Theme.text
                                font.pixelSize: Theme.fontBody
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Foundation.StatusPill {
                                text: String(historyRow.modelData.statusLabel
                                    || historyRow.modelData.status || "")
                                tone: root.stateTone(historyRow.modelData.status)
                                pulse: String(historyRow.modelData.status || "") === "publishing"
                            }
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(historyRow.modelData.channelId || "").length
                                ? String(historyRow.modelData.channelId) + " · "
                                    + (String(historyRow.modelData.externalPostId || "").length
                                        ? "Post ID: " + String(historyRow.modelData.externalPostId)
                                        : String(historyRow.modelData.errorMessage || "Chưa có Post ID"))
                                : String(historyRow.modelData.externalPostId || "").length
                                ? "Post ID: " + String(historyRow.modelData.externalPostId)
                                : String(historyRow.modelData.errorMessage || "Chưa có Post ID")
                            color: String(historyRow.modelData.errorMessage || "").length
                                ? Theme.danger : Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideMiddle
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(historyRow.modelData.completedAt
                                || historyRow.modelData.updatedAt
                                || historyRow.modelData.createdAt || "")
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                    }
                    AppButton {
                        visible: String(historyRow.modelData.orderId || "").length > 0
                        text: "Work order"
                        leadingIcon: "ui/external-link"
                        onClicked: {
                            if (root.controlPlaneBridge) {
                                root.controlPlaneBridge.selectOrder(String(
                                    historyRow.modelData.orderId || ""))
                                root.workOrderRequested(String(
                                    historyRow.modelData.orderId || ""))
                            }
                        }
                    }
                    AppButton {
                        visible: String(historyRow.modelData.postUrl || "").length > 0
                        text: "Mở bài đăng"
                        leadingIcon: "ui/external-link"
                        onClicked: Qt.openUrlExternally(
                            String(historyRow.modelData.postUrl || ""))
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.attemptModel
                    || Number(root.attemptModel.count || 0) === 0
                width: Math.min(parent.width - 48, 480)
                text: "Chưa có lần đăng nào trong bộ lọc hiện tại."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        ListView {
            id: attentionList
            objectName: "publishAttentionList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: Theme.space3
            visible: root.activeView === "attention"
            spacing: 7
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            model: root.attentionModel

            delegate: Rectangle {
                id: attentionRow
                required property var modelData
                readonly property bool scheduleConflict:
                    String(attentionRow.modelData.caseType || "")
                        === "schedule_conflict"

                width: attentionList.width
                height: 88
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: Theme.warning
                Accessible.name: String(attentionRow.modelData.title || "Cần xử lý")
                Accessible.role: Accessible.Row

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 11
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        radius: 11
                        color: Theme.warningSoft
                        UiIcon {
                            anchors.centerIn: parent
                            name: attentionRow.scheduleConflict
                                ? "ui/calendar" : "semantic/shield-check"
                            tone: Theme.warning
                            iconSize: 21
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text {
                            Layout.fillWidth: true
                            text: String(attentionRow.modelData.title || "Cần xử lý")
                            color: Theme.text
                            font.pixelSize: Theme.fontBody
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(attentionRow.modelData.errorMessage
                                || attentionRow.modelData.errorCode || "")
                            color: Theme.textMuted
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(attentionRow.modelData.platform || "").toUpperCase()
                                + " · " + String(attentionRow.modelData.channelId || "")
                            color: Theme.textFaint
                            font.pixelSize: Theme.fontMetadata
                            elide: Text.ElideRight
                        }
                    }
                    AppButton {
                        text: attentionRow.scheduleConflict
                            ? "Xem lịch" : "Mở work order"
                        leadingIcon: attentionRow.scheduleConflict
                            ? "ui/calendar" : "ui/external-link"
                        onClicked: {
                            if (attentionRow.scheduleConflict) {
                                root.scheduleRequested()
                            } else if (root.controlPlaneBridge) {
                                root.controlPlaneBridge.selectOrder(String(
                                    attentionRow.modelData.orderId || ""))
                                root.workOrderRequested(String(
                                    attentionRow.modelData.orderId || ""))
                            }
                        }
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                visible: !root.attentionModel
                    || Number(root.attentionModel.count || 0) === 0
                width: Math.min(parent.width - 48, 480)
                text: "Không có việc nào đang chờ đối soát."
                color: Theme.textMuted
                font.pixelSize: Theme.fontBody
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }

        RowLayout {
            visible: root.activeView === "history"
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            spacing: Theme.space2
            Text {
                Layout.fillWidth: true
                text: String(Number(root.page.total || 0)) + " lần đăng · "
                    + String(Number(root.page.offset || 0) + 1) + "–"
                    + String(Math.min(
                        Number(root.page.total || 0),
                        Number(root.page.offset || 0)
                            + Number(root.attemptModel ? root.attemptModel.count : 0)))
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
            }
            AppButton {
                objectName: "publishHistoryPreviousButton"
                text: "Trước"
                leadingIcon: "ui/chevron-left"
                enabled: !root.actionBusy && Number(root.page.offset || 0) > 0
                onClicked: root.requestPage(Math.max(
                    0, Number(root.page.offset || 0) - Number(root.page.limit || 100)))
            }
            AppButton {
                objectName: "publishHistoryNextButton"
                text: "Sau"
                leadingIcon: "ui/chevron-right"
                enabled: !root.actionBusy && Boolean(root.page.has_more)
                onClicked: root.requestPage(
                    Number(root.page.offset || 0) + Number(root.page.limit || 100))
            }
        }

        RowLayout {
            visible: root.activeView === "attention"
            Layout.fillWidth: true
            Layout.preferredHeight: 54
            Layout.leftMargin: Theme.space4
            Layout.rightMargin: Theme.space4
            spacing: Theme.space2
            Text {
                Layout.fillWidth: true
                text: String(Number(root.attentionPage.total || 0))
                    + " việc cần xử lý"
                color: Theme.textMuted
                font.pixelSize: Theme.fontMetadata
            }
            AppButton {
                text: "Trước"
                leadingIcon: "ui/chevron-left"
                enabled: !root.actionBusy
                    && Number(root.attentionPage.offset || 0) > 0
                onClicked: root.requestAttentionPage(Math.max(
                    0,
                    Number(root.attentionPage.offset || 0)
                        - Number(root.attentionPage.limit || 100)))
            }
            AppButton {
                text: "Sau"
                leadingIcon: "ui/chevron-right"
                enabled: !root.actionBusy
                    && Boolean(root.attentionPage.has_more)
                onClicked: root.requestAttentionPage(
                    Number(root.attentionPage.offset || 0)
                        + Number(root.attentionPage.limit || 100))
            }
        }
    }
}
