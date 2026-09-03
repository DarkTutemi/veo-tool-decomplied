pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../.."
import "../../foundation" as Foundation

Panel {
    id: root
    objectName: "settingsAIProviderHealthPanel"
    property var runtimeStatus: ({})
    readonly property bool userFacingCopy: true
    readonly property var runtimeMap: root.mapOrEmpty(root.runtimeStatus)
    readonly property var providers: root.listOrEmpty(root.runtimeMap.providers)
    readonly property var routing: root.mapOrEmpty(root.runtimeMap.routing)
    readonly property var media: root.mapOrEmpty(root.runtimeMap.media)
    readonly property var quota: root.mapOrEmpty(root.media.quota)
    readonly property int contractColumns: root.width >= 900 ? 4
        : root.width >= 620 ? 2 : 1
    readonly property int requiredHeight: root.contractColumns === 4 ? 340
        : root.contractColumns === 2 ? 444 : 646
    implicitHeight: root.requiredHeight
    Accessible.name: "AI hỗ trợ công việc"
    Accessible.role: Accessible.Pane

    function mapOrEmpty(value) {
        return value === null || value === undefined ? ({}) : value
    }

    function listOrEmpty(value) {
        return value === null || value === undefined ? [] : value
    }

    function toneFor(provider) {
        const item = root.mapOrEmpty(provider)
        if (item.eligible === true) return Theme.success
        if (String(item.tone_key || "") === "warning") return Theme.warning
        if (String(item.tone_key || "") === "info") return Theme.info
        if (String(item.tone_key || "") === "accent") return Theme.accent
        return Theme.textFaint
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 9
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "AI hỗ trợ công việc"
                color: Theme.text
                font.pixelSize: 15
                font.weight: Font.Bold
            }
            Foundation.StatusPill {
                text: root.runtimeStatus.ai_available === true
                    ? "Sẵn sàng" : "Dùng bản nháp an toàn"
                tone: root.runtimeStatus.ai_available === true
                    ? Theme.success : Theme.warning
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Text {
                objectName: "settingsAIMediaBindingText"
                text: String(root.media.active_bindings || 0)
                    + " tệp sẵn sàng · "
                    + String(root.media.failed_uploads || 0) + " tệp cần thử lại"
                color: Number(root.media.failed_uploads || 0) > 0
                    ? Theme.warning : Theme.success
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Text {
                id: quotaText
                objectName: "settingsAIQuotaText"
                property string availabilityReason: String(root.quota.reason_code || "")
                text: root.quota.usage_available === true
                    ? "Đã ghi nhận lượt dùng · Google không cung cấp số dư còn lại"
                    : "Google không cung cấp số lượt miễn phí còn lại"
                color: root.quota.usage_available === true ? Theme.info : Theme.textFaint
                font.pixelSize: 11
                Accessible.name: quotaText.text
                Accessible.description: String(root.quota.detail || quotaText.availabilityReason)
                Accessible.role: Accessible.StaticText
            }
            Item { Layout.fillWidth: true }
            Text {
                objectName: "settingsAIMediaPolicyText"
                text: "Ảnh và video chỉ được gửi sau khi bạn cho phép"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }
        Text {
            Layout.fillWidth: true
            text: "VeoFlow ưu tiên AI miễn phí. Nếu không dùng được, hệ thống chỉ thử lựa chọn bạn đã bật. Mọi kết quả đều là bản nháp để bạn kiểm tra."
            color: Theme.textFaint
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: root.providers
                delegate: Rectangle {
                    id: providerCard
                    required property var modelData
                    objectName: "settingsAIProvider_"
                        + String(providerCard.modelData.provider || "unknown")
                    Layout.fillWidth: true
                    Layout.minimumWidth: 180
                    Layout.preferredHeight: 74
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Qt.rgba(
                        root.toneFor(providerCard.modelData).r,
                        root.toneFor(providerCard.modelData).g,
                        root.toneFor(providerCard.modelData).b,
                        providerCard.modelData.eligible === true ? 0.7 : 0.3)
                    Accessible.name: String(providerCard.modelData.label || "AI")
                        + ". " + String(providerCard.modelData.state_label || "Chưa rõ")
                        + ". " + String(providerCard.modelData.session_label || "")
                        + ". " + String(providerCard.modelData.cost_label || "")
                    Accessible.role: Accessible.StaticText
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 8
                        UiIcon {
                            name: String(providerCard.modelData.icon_key || "semantic/info")
                            tone: root.toneFor(providerCard.modelData)
                            iconSize: 20
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: String(providerCard.modelData.label || "AI")
                                color: Theme.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                objectName: "settingsAIProviderState_"
                                    + String(providerCard.modelData.provider || "unknown")
                                Layout.fillWidth: true
                                text: String(providerCard.modelData.state_label || "Chưa rõ")
                                color: root.toneFor(providerCard.modelData)
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                            Text {
                                objectName: "settingsAIProviderSession_"
                                    + String(providerCard.modelData.provider || "unknown")
                                Layout.fillWidth: true
                                text: String(providerCard.modelData.session_label || "")
                                    + " · " + String(providerCard.modelData.cost_label || "")
                                color: Theme.textFaint
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Text {
                objectName: "settingsAIPaidPolicyText"
                Layout.fillWidth: true
                text: root.routing.paid_fallback_requested === true
                    ? (root.routing.paid_fallback_authorized === true
                        ? "Dịch vụ có phí: được phép sử dụng khi cần"
                        : "Dịch vụ có phí: đang chờ bạn xác nhận")
                    : "Dịch vụ có phí: không được tự động sử dụng"
                color: root.routing.allow_paid_fallback === true
                    ? Theme.success : Theme.warning
                font.pixelSize: 11
                font.weight: Font.DemiBold
            }
            Text {
                text: "Nếu AI đều lỗi: giữ bản nháp an toàn để bạn tiếp tục"
                color: Theme.textFaint
                font.pixelSize: 11
            }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.borderSoft
        }
        GridLayout {
            objectName: "settingsAIOperatingContractRow"
            Layout.fillWidth: true
            columns: root.contractColumns
            columnSpacing: 8
            rowSpacing: 8
            Layout.minimumHeight: root.contractColumns === 4 ? 94
                : root.contractColumns === 2 ? 196 : 400
            Layout.preferredHeight: Layout.minimumHeight
            Repeater {
                model: [
                    {
                        "key": "fallback",
                        "icon": "semantic/workflow",
                        "title": "Khi AI tạm lỗi",
                        "detail": "Thử lựa chọn tiếp theo; nếu vẫn lỗi, giữ bản nháp an toàn để bạn tiếp tục."
                    },
                    {
                        "key": "context",
                        "icon": "device/agent",
                        "title": "Mỗi lần hỏi đều đủ dữ liệu",
                        "detail": "Mỗi yêu cầu gửi đủ thông tin của công việc, nguồn, kênh và quyền cần thiết."
                    },
                    {
                        "key": "media",
                        "icon": "semantic/video",
                        "title": "Ảnh và video đúng nguồn",
                        "detail": root.media.account_affinity_enforced === true
                            ? "Chỉ dùng tệp đúng tài khoản đã tải lên; tệp hết hạn phải tải lại."
                            : "Chưa xác minh được tài khoản của tệp nên VeoFlow chưa gửi tệp ra ngoài."
                    },
                    {
                        "key": "cost",
                        "icon": "semantic/shield-check",
                        "title": "Không tự phát sinh chi phí",
                        "detail": root.routing.allow_paid_fallback === true
                            ? "Dịch vụ có phí chỉ được dùng vì bạn đã bật và quyền phê duyệt hiện hợp lệ."
                            : "Không tự phát sinh chi phí; dịch vụ có phí chỉ chạy khi bạn bật và phê duyệt."
                    }
                ]
                delegate: Rectangle {
                    id: contractCard
                    required property var modelData
                    objectName: "settingsAIContract_" + String(contractCard.modelData.key)
                    Layout.fillWidth: true
                    Layout.minimumWidth: 150
                    Layout.minimumHeight: 94
                    Layout.preferredHeight: 94
                    radius: Theme.radiusMedium
                    color: Theme.elevated
                    border.width: 1
                    border.color: Theme.borderSoft
                    Accessible.name: String(contractCard.modelData.title) + ". "
                        + String(contractCard.modelData.detail)
                    Accessible.role: Accessible.StaticText
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 7
                        UiIcon {
                            name: String(contractCard.modelData.icon)
                            tone: contractCard.modelData.key === "cost"
                                ? Theme.warning : Theme.info
                            iconSize: 18
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                text: String(contractCard.modelData.title)
                                color: Theme.text
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }
                            Text {
                                id: contractDetail
                                objectName: "settingsAIContractDetail_"
                                    + String(contractCard.modelData.key)
                                readonly property bool labelTruncated: truncated
                                Layout.fillWidth: true
                                text: String(contractCard.modelData.detail)
                                color: Theme.textFaint
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }
}
