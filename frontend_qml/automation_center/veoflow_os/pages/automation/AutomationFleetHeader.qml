pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    property var navigation: []
    property string activeTab: "fleet"
    property var runtime: ({})
    property var fleet: ({})
    property var rules: ({})
    property var activity: ({})
    property string bannerMessage: ""
    signal tabRequested(string tabKey)
    signal createRuleRequested()
    signal refreshRequested()

    color: Theme.panel
    radius: Theme.radiusLarge
    border.width: 1
    border.color: Theme.borderSoft

    readonly property var publishRunner: root.map(root.runtime.publish_runner)
    readonly property var careRunner: root.map(root.runtime.care_runner)
    readonly property var realHands: root.map(root.runtime.real_hands)
    readonly property var createAction: root.map(root.map(root.rules.actions).create)

    function map(value) {
        return value === null || value === undefined ? ({}) : value
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.space4
        spacing: Theme.space3

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Tự động hóa kênh"
                    color: Theme.text
                    font.pixelSize: Theme.fontPageTitle
                    font.weight: Font.Bold
                }
                Text {
                    text: "Đăng video, kiểm tra comment và theo dõi 50–500 kênh từ một nơi"
                    color: Theme.textMuted
                    font.pixelSize: Theme.fontMetadata
                }
            }

            Repeater {
                model: [
                    {"label": "Kênh", "value": Number(root.fleet.total || 0),
                        "icon": "semantic/video", "tone": Theme.info},
                    {"label": "Kế hoạch", "value": Number(root.rules.total || 0),
                        "icon": "semantic/workflow", "tone": Theme.accent},
                    {"label": "Sự kiện 24h", "value": Number(root.activity.total || 0),
                        "icon": "semantic/bar-chart", "tone": Theme.success}
                ]
                delegate: Rectangle {
                    id: metric
                    required property var modelData
                    Layout.preferredWidth: 126
                    Layout.preferredHeight: 54
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 9
                        UiIcon {
                            name: metric.modelData.icon
                            tone: metric.modelData.tone
                            iconSize: 20
                        }
                        ColumnLayout {
                            spacing: 0
                            Text {
                                text: String(metric.modelData.value)
                                color: Theme.text
                                font.pixelSize: 18
                                font.weight: Font.Bold
                            }
                            Text {
                                text: metric.modelData.label
                                color: Theme.textMuted
                                font.pixelSize: Theme.fontMetadata
                            }
                        }
                    }
                }
            }

            AppButton {
                objectName: "automationRefreshButton"
                text: "Làm mới"
                leadingIcon: "ui/refresh-cw"
                onClicked: root.refreshRequested()
            }
            AppButton {
                objectName: "automationCreateRuleButton"
                text: "Tạo kế hoạch"
                leadingIcon: "ui/plus"
                primary: true
                enabled: root.createAction.available === true
                availabilityReason: String(root.createAction.reason_code || "")
                onClicked: root.createRuleRequested()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space3
            Repeater {
                model: root.navigation
                delegate: Button {
                    id: tabButton
                    required property var modelData
                    objectName: "automationTab_" + String(modelData.key || "")
                    activeFocusOnTab: true
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 38
                    text: String(modelData.label || "")
                    checkable: true
                    checked: root.activeTab === String(modelData.key || "")
                    font.pixelSize: Theme.fontBody
                    font.weight: checked ? Font.DemiBold : Font.Normal
                    Accessible.name: text
                    contentItem: RowLayout {
                        spacing: 7
                        UiIcon {
                            name: tabButton.modelData.key === "fleet"
                                ? "semantic/video"
                                : tabButton.modelData.key === "rules"
                                    ? "semantic/workflow" : "semantic/bar-chart"
                            tone: tabButton.checked ? Theme.accent : Theme.textMuted
                            iconSize: 16
                        }
                        Text {
                            Layout.fillWidth: true
                            text: tabButton.text
                            color: tabButton.checked ? Theme.accent : Theme.textMuted
                            font: tabButton.font
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                    background: Rectangle {
                        color: tabButton.checked ? Theme.accentSoft : "transparent"
                        radius: Theme.radiusSmall
                        border.width: tabButton.checked ? 1 : 0
                        border.color: Theme.accent
                    }
                    onClicked: root.tabRequested(String(modelData.key || ""))
                }
            }
            Item { Layout.fillWidth: true }
            Repeater {
                model: [
                    {"key": "publish_runner", "label": "Đăng bài",
                        "value": root.publishRunner},
                    {"key": "care_runner", "label": "Comment",
                        "value": root.careRunner},
                    {"key": "real_hands", "label": "Browser",
                        "value": root.realHands}
                ]
                delegate: Rectangle {
                    id: runtimeBadge
                    required property var modelData
                    objectName: "automationRuntime_" + String(modelData.key)
                    Layout.preferredWidth: 116
                    Layout.minimumWidth: 116
                    Layout.maximumWidth: 116
                    Layout.preferredHeight: 30
                    clip: true
                    radius: 15
                    color: Boolean(modelData.value.configured)
                        ? Theme.successSoft : Theme.warningSoft
                    border.width: 1
                    border.color: Boolean(modelData.value.configured)
                        ? Theme.success : Theme.warning
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            Layout.preferredWidth: 7
                            Layout.preferredHeight: 7
                            radius: 4
                            color: Boolean(runtimeBadge.modelData.value.configured)
                                ? Theme.success : Theme.warning
                        }
                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: runtimeBadge.modelData.label + " · "
                                + (Boolean(runtimeBadge.modelData.value.configured)
                                    ? "Sẵn sàng" : "Đang tắt")
                            color: Boolean(runtimeBadge.modelData.value.configured)
                                ? Theme.success : Theme.warning
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: root.bannerMessage.length > 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 26 : 0
            radius: Theme.radiusSmall
            color: Theme.accentSoft
            Text {
                anchors.centerIn: parent
                text: root.bannerMessage
                color: Theme.accent
                font.pixelSize: Theme.fontMetadata
            }
        }
    }
}
