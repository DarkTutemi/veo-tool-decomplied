pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "incidentHeader"
    property var header: ({})
    property var summary: ({})
    property var rules: ({})
    property bool canWrite: false
    property bool canManageRules: false
    property bool ruleBusy: false
    property bool muteBusy: false
    signal actionRequested(var action)
    Accessible.name: "Tổng quan Incident Center"
    Accessible.role: Accessible.Pane

    function metricValue(metric) {
        const item = metric || ({})
        return item.available && item.value !== null && item.value !== undefined
            ? String(item.value) : "—"
    }

    function metricReason(metric) {
        const item = metric || ({})
        if (String(item.detail || "")) return String(item.detail)
        return item.available ? "Nguồn incidents" : "Không khả dụng"
    }

    function toneColor(value, fallback) {
        const key = String(value || "")
        if (key === "danger") return Theme.danger
        if (key === "warning") return Theme.warning
        if (key === "success") return Theme.success
        if (key === "info") return Theme.info
        if (key === "accent") return Theme.accent
        return fallback || Theme.textFaint
    }

    readonly property var headerActions: (root.header || {}).actions || ({})
    readonly property var createRuleAction: root.headerActions.create_rule || ({})
    readonly property var muteAction: root.headerActions.mute || ({})
    readonly property var overflowAction: root.headerActions.overflow || ({})
    readonly property var operatorBrief: (root.summary || {}).operator_brief || ({})

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 12
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 7
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            spacing: 10
            ColumnLayout {
                Layout.preferredWidth: 360
                Layout.minimumWidth: 330
                spacing: 1
                Text {
                    text: "ĐIỀU HÀNH SỰ CỐ"
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 1.05
                }
                Text { text: String(root.header.title || "Trung tâm cảnh báo"); color: Theme.text; font.pixelSize: Theme.fontPageTitle; font.weight: Font.Bold }
            }
            Rectangle {
                id: briefCard
                objectName: "alertOperatorBrief"
                Layout.fillWidth: true
                Layout.minimumWidth: 360
                Layout.preferredHeight: 48
                radius: Theme.radiusMedium
                readonly property color briefTone: root.toneColor(
                    root.operatorBrief.tone_key, Theme.warning)
                color: Qt.rgba(briefTone.r, briefTone.g, briefTone.b, 0.10)
                border.width: 1
                border.color: Qt.rgba(briefTone.r, briefTone.g, briefTone.b, 0.42)
                Accessible.name: String(root.operatorBrief.headline || "Trạng thái vận hành")
                    + ". " + String(root.operatorBrief.detail || root.header.subtitle || "")
                Accessible.role: Accessible.StaticText
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 8
                    UiIcon {
                        name: String(root.operatorBrief.icon_key || "semantic/alert-circle")
                        tone: briefCard.briefTone
                        iconSize: 18
                        Layout.preferredWidth: 20
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: String(root.operatorBrief.headline || "Theo dõi trạng thái vận hành")
                            color: briefCard.briefTone
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            text: String(root.operatorBrief.detail || root.header.subtitle
                                || "Theo dõi và xử lý sự cố theo bằng chứng máy chủ")
                            color: Theme.textMuted
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }
            }
            AppButton {
                objectName: "alertCreateRuleButton"
                text: String(root.createRuleAction.label || "Tạo quy tắc")
                leadingIcon: String(root.createRuleAction.icon_key || "")
                primary: true
                activeFocusOnTab: true
                enabled: root.canManageRules && Boolean(root.createRuleAction.available)
                    && !root.ruleBusy
                Accessible.name: text
                Accessible.description: enabled
                    ? "Tạo rule declarative mới trong workspace hiện tại"
                    : (root.ruleBusy ? "Đang xử lý thay đổi quy tắc"
                        : String(root.createRuleAction.reason_code
                            || "INCIDENT_RULE_CREATE_UNAVAILABLE"))
                onClicked: root.actionRequested(root.createRuleAction)
            }
            AppButton {
                objectName: "alertMuteButton"
                text: root.muteBusy ? "Đang tạm ẩn…"
                    : String(root.muteAction.label || "Tạm ẩn cảnh báo")
                leadingIcon: String(root.muteAction.icon_key || "")
                activeFocusOnTab: true
                enabled: root.canWrite && Boolean(root.muteAction.available)
                    && !root.muteBusy
                Accessible.name: text
                Accessible.description: enabled
                    ? "Chọn scope, expiry và lý do trước khi xác nhận"
                    : (root.muteBusy ? "Đang chờ kết quả từ server"
                        : String(root.muteAction.reason_code || "INCIDENT_MUTE_UNAVAILABLE"))
                onClicked: root.actionRequested(root.muteAction)
            }
            Foundation.IconButton {
                objectName: "alertHeaderOverflow"
                iconName: String(root.overflowAction.icon_key || "ui/more-horizontal")
                text: ""
                accessibleName: String(root.overflowAction.label || "Tùy chọn cảnh báo")
                activeFocusOnTab: true
                enabled: Boolean(root.overflowAction.available)
                Accessible.description: enabled ? "Mở menu tùy chọn"
                    : String(root.overflowAction.reason_code || "INCIDENT_HEADER_MENU_UNAVAILABLE")
                onClicked: headerOverflowMenu.open()
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            spacing: 8
            HeaderMetric {
                objectName: "alertMetricCritical"
                label: String((root.summary.critical || {}).label || "Nghiêm trọng")
                value: root.metricValue(root.summary.critical)
                detail: root.metricReason(root.summary.critical)
                tone: root.toneColor((root.summary.critical || {}).tone_key, Theme.danger)
                iconName: String((root.summary.critical || {}).icon_key || "")
            }
            HeaderMetric {
                objectName: "alertMetricOpen"
                label: String((root.summary.open || {}).label || "Cần xử lý")
                value: root.metricValue(root.summary.open)
                detail: root.metricReason(root.summary.open)
                tone: root.toneColor((root.summary.open || {}).tone_key, Theme.warning)
                iconName: String((root.summary.open || {}).icon_key || "")
            }
            HeaderMetric {
                objectName: "alertMetricWatching"
                label: String((root.summary.watching || {}).label || "Đang theo dõi")
                value: root.metricValue(root.summary.watching)
                detail: root.metricReason(root.summary.watching)
                tone: root.toneColor((root.summary.watching || {}).tone_key, Theme.info)
                iconName: String((root.summary.watching || {}).icon_key || "")
            }
            HeaderMetric {
                objectName: "alertMetricResolvedToday"
                label: String((root.summary.resolved_today || {}).label || "Đã xử lý hôm nay")
                value: root.metricValue(root.summary.resolved_today)
                detail: root.metricReason(root.summary.resolved_today)
                tone: root.toneColor((root.summary.resolved_today || {}).tone_key, Theme.success)
                iconName: String((root.summary.resolved_today || {}).icon_key || "")
            }
        }
    }

    Popup {
        id: headerOverflowMenu
        objectName: "alertHeaderOverflowMenu"
        x: root.width - width - 12
        y: 50
        width: 230
        height: 10 + (root.overflowAction.items || []).length * 43
        padding: 5
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Item {
            Repeater {
                model: root.overflowAction.items || []
                delegate: AppButton {
                    id: menuItem
                    required property int index
                    required property var modelData
                    objectName: "alertHeaderOverflowItem_" + String(index)
                    width: parent.width
                    y: menuItem.index * 43
                    text: String(menuItem.modelData.label || "Tùy chọn")
                    leadingIcon: String(menuItem.modelData.icon_key || "")
                    subtle: true
                    enabled: Boolean(menuItem.modelData.available)
                    availabilityReason: enabled ? "" : String(
                        menuItem.modelData.reason_code || "INCIDENT_HEADER_ITEM_UNAVAILABLE"
                    )
                    onClicked: {
                        headerOverflowMenu.close()
                        root.actionRequested(menuItem.modelData)
                    }
                }
            }
        }
        background: Rectangle {
            radius: Theme.radiusMedium
            color: Theme.panel
            border.width: 1
            border.color: Theme.border
        }
    }

    component HeaderMetric: Rectangle {
        id: metric
        required property string label
        required property string value
        required property string detail
        required property color tone
        required property string iconName
        readonly property bool labelTruncated: metricLabel.truncated
        readonly property bool detailTruncated: metricDetail.truncated
        readonly property real labelWidth: metricLabel.width
        readonly property real labelImplicitWidth: metricLabel.implicitWidth
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.preferredWidth: 1
        Layout.preferredHeight: 72
        radius: Theme.radiusMedium
        color: Theme.elevated
        border.width: 1
        border.color: Theme.borderSoft
        Accessible.name: metric.label + ": " + metric.value + ". " + metric.detail
        Accessible.role: Accessible.StaticText
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 9
            UiIcon {
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                name: metric.iconName
                tone: metric.tone
                iconSize: 18
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text { id: metricLabel; text: metric.label; color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: metric.value; color: Theme.text; font.pixelSize: 20; font.weight: Font.Bold }
                Text {
                    id: metricDetail
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                    text: metric.detail
                    color: metric.value === "—" ? Theme.warning : Theme.textFaint
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                    maximumLineCount: 1
                    elide: Text.ElideRight
                }
            }
        }
    }
}
