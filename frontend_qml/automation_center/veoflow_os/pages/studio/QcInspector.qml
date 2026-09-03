pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    objectName: "studioQcInspector"
    property var qcData: ({})
    property var ruleModel: null
    property var groupModel: null
    property var advisoryModel: null
    property var estimatorsData: ({})
    property var recipeData: ({})
    property bool canRun: false
    property bool runBusy: false
    signal runRequested()
    signal reportRequested()
    signal groupRequested(string key)
    signal fixRequested(string targetTab)
    readonly property var summaryData: root.qcData.summary || ({})
    readonly property var sizeEstimator: root.estimatorsData.output_size || ({})
    readonly property var durationEstimator: root.estimatorsData.render_duration || ({})
    readonly property var deliveryData: ((root.recipeData.editor || {}).delivery) || ({})
    readonly property var publishPolicy: root.deliveryData.publish_policy || ({})
    readonly property var targetData: root.qcData.target || ({})
    color: Theme.panel
    radius: Theme.radiusMedium
    border.width: 1
    border.color: Theme.borderSoft
    Accessible.role: Accessible.Pane
    Accessible.name: "Kiểm tra chất lượng"

    function toneFor(status) {
        const value = String(status || "").toLowerCase()
        if (value === "failed" || value === "blocked") return Theme.danger
        if (value === "warning" || value === "unavailable") return Theme.warning
        if (value === "passed" || value === "completed") return Theme.success
        return Theme.textFaint
    }

    function formatDuration(value, unit) {
        if (String(unit || "").toLowerCase() !== "s")
            return String(value) + (unit ? " " + String(unit) : "")
        const seconds = Math.max(0, Math.round(Number(value || 0)))
        const minutes = Math.floor(seconds / 60)
        const rest = seconds % 60
        if (minutes > 0) return "~ " + minutes + " phút " + rest + " giây"
        return "~ " + rest + " giây"
    }

    function platformLabel(value) {
        const platform = String(value || "").toLowerCase()
        if (platform === "tiktok") return "TikTok"
        if (platform === "youtube") return "YouTube"
        if (platform === "facebook") return "Facebook"
        return platform || "—"
    }

    component EstimatorRow: Rectangle {
        id: estimate
        property string label: ""
        property string displayValue: "—"
        property string reasonCode: ""
        property string secondaryText: ""
        implicitHeight: 40
        color: Theme.elevated
        radius: 7
        border.width: 1
        border.color: Theme.borderSoft
        Accessible.role: Accessible.StaticText
        Accessible.name: label + ": " + displayValue + (reasonCode ? ". " + reasonCode : "")
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 7
            spacing: 1
            RowLayout {
                Layout.fillWidth: true
                Text { text: estimate.label; color: Theme.textFaint; font.pixelSize: 11 }
                Item { Layout.fillWidth: true }
                Text { text: estimate.displayValue; color: estimate.displayValue === "—" ? Theme.textFaint : Theme.text; font.pixelSize: 11; font.weight: Font.DemiBold }
            }
            Text {
                Layout.fillWidth: true
                visible: estimate.reasonCode.length > 0 || estimate.secondaryText.length > 0
                text: estimate.reasonCode || estimate.secondaryText
                color: estimate.reasonCode ? Theme.warning : Theme.textFaint
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 7

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Kiểm tra chất lượng"; color: Theme.text; font.pixelSize: Theme.fontSection; font.weight: Font.Bold }
            Item { Layout.fillWidth: true }
            StudioButton {
                id: runButton
                objectName: "studioQcRunButton"
                text: root.runBusy ? "Đang kiểm tra…" : "Kiểm tra lại"
                enabled: root.canRun && !root.runBusy
                activeFocusOnTab: true
                Accessible.name: "Chạy kiểm tra chất lượng cho asset và draft hiện tại"
                Accessible.description: enabled ? "" : String(root.targetData.reason_code || "STUDIO_QC_TARGET_UNAVAILABLE")
                onClicked: root.runRequested()
            }
        }

        Item {
            id: score
            objectName: "studioQcScore"
            property string scoreText: String(root.qcData.state || "") === "available"
                ? Number(root.summaryData.passed || 0) + " / " + Number(root.summaryData.total || 0)
                : "—"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 78
            Layout.preferredHeight: 78
            Accessible.role: Accessible.StaticText
            Accessible.name: "QC đạt " + scoreText
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Theme.elevated
                border.width: 4
                border.color: root.toneFor(root.qcData.status)
            }
            Column {
                anchors.centerIn: parent
                spacing: 1
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: score.scoreText; color: Theme.text; font.pixelSize: 17; font.weight: Font.Bold }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: String(root.qcData.status || "unavailable"); color: root.toneFor(root.qcData.status); font.pixelSize: 11 }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.qcData.ruleset
                ? String(root.qcData.ruleset.key || "") + " · v" + Number(root.qcData.ruleset.version || 0)
                : String(root.qcData.reason_code || "QC_UNAVAILABLE")
            color: Theme.textFaint
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        ScrollView {
            id: ruleList
            objectName: "studioQcRuleList"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            Accessible.role: Accessible.List
            Accessible.name: "Các quy tắc QC đã đánh giá"

            Column {
                id: ruleColumn
                width: ruleList.availableWidth
                spacing: 2
                Repeater {
                    model: root.groupModel
                    delegate: Item {
                        id: groupRow
                        required property string key
                        required property var label
                        required property string status
                        required property int total
                        required property int passed
                        required property int warning
                        required property int failed
                        readonly property string groupKey: String(groupRow.key || "unknown")
                        property string statusValue: String(groupRow.status || "unavailable")
                        objectName: "studioQcRule_" + groupKey
                        width: ruleColumn.width
                        height: 29
                        activeFocusOnTab: true
                        Accessible.role: Accessible.Button
                        Accessible.name: String(groupRow.label || groupKey) + ": "
                            + Number(groupRow.passed) + " trên " + Number(groupRow.total)
                            + ", " + statusValue
                        function activate(): bool {
                            root.groupRequested(groupRow.groupKey)
                            return true
                        }
                        Keys.onReturnPressed: groupRow.activate()
                        Keys.onSpacePressed: groupRow.activate()
                        Rectangle {
                            anchors.fill: parent
                            radius: 5
                            color: groupMouse.containsMouse ? Theme.hover : "transparent"
                        }
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            Rectangle { Layout.preferredWidth: 12; Layout.preferredHeight: 12; radius: 6; color: root.toneFor(groupRow.statusValue); Text { anchors.centerIn: parent; text: groupRow.statusValue === "passed" ? "✓" : "!"; color: "white"; font.pixelSize: 11; font.weight: Font.Bold } }
                            Text { Layout.fillWidth: true; text: String(groupRow.label || groupRow.groupKey); color: Theme.textMuted; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { text: Number(groupRow.passed) + "/" + Number(groupRow.total); color: root.toneFor(groupRow.statusValue); font.pixelSize: 11; font.weight: Font.DemiBold }
                        }
                        MouseArea {
                            id: groupMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: groupRow.activate()
                        }
                    }
                }
            }
        }

        Repeater {
            model: root.advisoryModel
            delegate: Rectangle {
                id: advisory
                required property int index
                readonly property var advisoryData: root.advisoryModel
                    ? (root.advisoryModel.get(advisory.index) || ({})) : ({})
                readonly property string advisoryId: String(advisory.advisoryData.id || "unknown")
                readonly property string targetTab: String(advisory.advisoryData.target_tab || "recipe")
                objectName: "studioQcAdvisory_" + advisoryId
                Layout.fillWidth: true
                Layout.preferredHeight: 58
                radius: 7
                color: Qt.rgba(Theme.warning.r, Theme.warning.g, Theme.warning.b, 0.09)
                border.width: 1
                border.color: Theme.warning
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: String(advisory.advisoryData.title || "Cảnh báo QC") + ". "
                    + String(advisory.advisoryData.message || "") + ". Mở tab " + advisory.targetTab
                function activate(): bool {
                    root.fixRequested(advisory.targetTab)
                    return true
                }
                Keys.onReturnPressed: advisory.activate()
                Keys.onSpacePressed: advisory.activate()
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 7
                    UiIcon { name: "semantic/lightbulb"; tone: Theme.warning; iconSize: 16 }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text { Layout.fillWidth: true; text: String(advisory.advisoryData.title || "Cảnh báo QC"); color: Theme.warning; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { Layout.fillWidth: true; text: String(advisory.advisoryData.message || ""); color: Theme.textFaint; font.pixelSize: 11; elide: Text.ElideRight }
                    }
                    UiIcon { name: "ui/chevron-right"; tone: Theme.textFaint; iconSize: 13 }
                }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: advisory.activate() }
            }
        }

        EstimatorRow {
            id: estimatedSize
            objectName: "studioEstimatedSize"
            Layout.fillWidth: true
            label: "Dung lượng ước tính"
            displayValue: Boolean(root.sizeEstimator.available) && root.sizeEstimator.value !== undefined
                ? String(root.sizeEstimator.value) + (root.sizeEstimator.unit ? " " + root.sizeEstimator.unit : "") : "—"
            reasonCode: Boolean(root.sizeEstimator.available) ? "" : String(root.sizeEstimator.reason_code || "STUDIO_SIZE_ESTIMATOR_UNAVAILABLE")
            secondaryText: Boolean(root.sizeEstimator.available) && root.sizeEstimator.tolerance_percent !== undefined
                ? "±" + Number(root.sizeEstimator.tolerance_percent) + "% · "
                    + String(root.sizeEstimator.method || "ước tính compiler") : ""
        }
        EstimatorRow {
            id: estimatedDuration
            objectName: "studioEstimatedDuration"
            Layout.fillWidth: true
            label: "Thời gian render"
            displayValue: Boolean(root.durationEstimator.available) && root.durationEstimator.value !== undefined
                ? root.formatDuration(root.durationEstimator.value, root.durationEstimator.unit) : "—"
            reasonCode: Boolean(root.durationEstimator.available) ? "" : String(root.durationEstimator.reason_code || "STUDIO_DURATION_ESTIMATOR_UNAVAILABLE")
            secondaryText: Boolean(root.durationEstimator.available)
                ? "Tin cậy " + String(root.durationEstimator.confidence || "chưa rõ")
                    + " · " + Number(root.durationEstimator.sample_count || 0) + " mẫu" : ""
        }
        EstimatorRow {
            objectName: "studioPublishingPolicy"
            Layout.fillWidth: true
            label: "Chính sách phát hành"
            displayValue: Boolean(root.deliveryData.available)
                ? (Boolean(root.publishPolicy.approval_required) ? "Cần duyệt · " : "")
                    + (String(root.publishPolicy.visibility || "") === "private" ? "Riêng tư"
                        : String(root.publishPolicy.visibility || "—"))
                : "—"
            reasonCode: Boolean(root.deliveryData.available)
                ? String(root.publishPolicy.reason_code || "")
                : String(root.deliveryData.reason_code || "STUDIO_PUBLISH_POLICY_UNAVAILABLE")
        }
        EstimatorRow {
            objectName: "studioTargetPlatform"
            Layout.fillWidth: true
            label: "Nền tảng đích"
            displayValue: root.platformLabel(root.targetData.platform)
            reasonCode: Boolean(root.targetData.supported)
                ? "" : String(root.targetData.reason_code || "STUDIO_QC_TARGET_PLATFORM_UNSUPPORTED")
        }

        StudioButton {
            id: reportButton
            primary: true
            objectName: "studioQcReportButton"
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            text: "Xem chi tiết kiểm tra"
            enabled: Boolean((root.qcData.deep_link || {}).route)
            activeFocusOnTab: true
            Accessible.role: Accessible.Button
            Accessible.name: "Mở chi tiết kiểm tra chất lượng"
            onClicked: root.reportRequested()
        }
    }
}
